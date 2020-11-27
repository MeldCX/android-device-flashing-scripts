@echo off
adb version
echo MeldCX note: ADB Version must be 1.0.33 or above

adb root
adb shell pm hide swpc.wistron.com.wiwall.tv
adb shell pm hide com.wistron.longrun

REM Disable stuff
adb root
adb disable-verity
adb reboot

echo waiting for reboot...
timeout /t 40 /NOBREAK
echo ...

adb root
adb remount
adb shell stop
adb push binaries\framework-res-signed.apk /system/framework/framework-res.apk
adb push binaries\bootanimation.zip /oem/media/bootanimation.zip
adb shell start

echo waiting for shell restart
timeout /t 20 /NOBREAK

REM Install Chromium
echo Installing Chromium
adb shell pm list packages | find "com.google.android.webview" > nul
if errorlevel 1 (
  echo No existing Chrome instalation
) else (
  echo Uninstalling existing chrome
  adb uninstall com.google.android.webview
)
adb root
adb remount
adb shell stop
adb shell rm -rf /system/app/webview /system/app/WebViewGoogle /system/app/WebViewStub \
                 /system/product_services/app/webview /system/product_services/app/WebViewGoogle \
                 /system/product_services/app/WebViewStub /system/product_services/app/TrichromeWebView
adb shell start
echo waiting for shell restart...
timeout /t 30 /NOBREAK
echo ...
adb install -r -d binaries/SystemWebView_ARM.apk


echo Installing AgentM WebUI
adb shell pm list packages | find "com.meldcx.agentm.webui" > nul
if errorlevel 1 (
  echo No existing AgentM WebUI instalation
) else (
  echo Uninstalling existing AgentM
  adb uninstall com.meldcx.agentm.webui
)
adb install binaries/agent-webui-release-signed.apk

echo Installing AgentM
adb shell pm list packages | find "com.meldcx.agentm" > nul
if errorlevel 1 (
  echo No existing AgentM instalation
) else (
  echo Uninstalling existing AgentM
  adb uninstall com.meldcx.agentm
)
adb install binaries/agent-release-signed.apk

timeout /t 5 /NOBREAK
adb shell settings put secure enabled_accessibility_services %accessibility:com.meldcx.agentm/com.meldcx.agentm.diagnostics.AccessibilityKeyDetector
echo Accessibility Installed

REM Disable Screen Capture Dialog
adb shell am start -n "com.meldcx.agentm/com.meldcx.agentm.install.InstallUtil"
timeout /t 5 /NOBREAK
adb shell dumpsys window displays | find "mBounds=[0,0][1920,1080]" > nul
if errorlevel 1 (
    echo Portrait Dismiss
    adb shell input tap 200 980
    timeout /t 2 /NOBREAK
    adb shell input tap 800 1080
    timeout /t 2 /NOBREAK
    adb shell input tap 1000 400
) else (
    echo Landscape Dismiss
    adb shell input tap 530 560
    timeout /t 2 /NOBREAK
    adb shell input tap 1300 650
    timeout /t 2 /NOBREAK
    adb shell input tap 1745 390
)


echo Installing App Updater
adb shell pm list packages | find "com.meldcx.appupdater" > nul
if errorlevel 1 (
  echo No existing App Updater instalation
) else (  
  echo Uninstalling existing App Updater
  adb shell am force-stop com.meldcx.appupdater
  adb uninstall com.meldcx.appupdater
)
adb install binaries/updater-canary-release-signed.apk


echo Installing Authentication and Enrollment
adb shell pm list packages | find "com.meldcx.enrollment" > nul
if errorlevel 1 (
  echo No existing Authentication and Enrollment instalation
) else (  
  echo Uninstalling existing Authentication and Enrollment
  adb shell am force-stop com.meldcx.enrollment
  adb uninstall com.meldcx.enrollment
)
adb install binaries/enrollment-canary-release-signed.apk


echo Installing Watchdog
adb shell pm list packages | find "com.meldcx.watchdog" > nul
if errorlevel 1 (
  echo No existing Watchdog instalation
) else (  
  echo Uninstalling existing Watchdog
  adb uninstall com.meldcx.watchdog
)
adb install binaries/watchdog-release-signed.apk
adb shell pm grant com.meldcx.watchdog android.permission.PACKAGE_USAGE_STATS

echo Installing Meld Launcher
adb shell pm list packages | find "com.meldcx.meldcxlauncher" > nul
if errorlevel 1 (
  echo No existing Meld Launcher instalation
) else (  
  echo Uninstalling existing Meld Launcher
  adb uninstall com.meldcx.meldcxlauncher
)
adb install binaries/launcher-signed.apk
adb shell pm hide com.android.launcher3
adb shell pm disable com.android.launcher3
adb shell cmd package set-home-activity "com.meldcx.meldcxlauncher/com.meldcx.meldcxlauncher.MainActivity"


echo Installing Onboarding
adb shell pm list packages | find "com.meldcx.agentm.service.onboarding" > nul
if errorlevel 1 (
  echo No existing Onboarding instalation
) else (  
  echo Uninstalling existing Onboarding
  adb uninstall com.meldcx.agentm.service.onboarding
)
adb install binaries/bluetooth-onboarding-canary-release-signed.apk
adb shell pm grant com.meldcx.agentm.service.onboarding android.permission.ACCESS_COARSE_LOCATION

echo Removing Notifications
adb shell settings put global heads_up_notifications_enabled 0


echo Starting Services
adb shell am start-foreground-service com.meldcx.watchdog/.WatchdogService
adb shell am start -n "com.meldcx.agentm/com.meldcx.agentm.MainActivity"
adb shell am start-foreground-service com.meldcx.appupdater/.pollingservice.PollingService


echo *** INSTALL COMPLETE ***
echo *** Rebooting ***
adb reboot
echo *** All Done *** 
echo *** Please run Step 2 after reboot to complete the installation process ***