@echo off
adb version
echo MeldCX note: ADB Version must be 1.0.33 or above

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

echo Removing Notifications
adb shell settings put global heads_up_notifications_enabled 0

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
    adb shell input tap 196 948
    timeout /t 2 /NOBREAK
    adb shell input tap 820 1040
    timeout /t 2 /NOBREAK
    adb shell input tap 1000 400
    adb shell input keyevent KEYCODE_BACK
) else (
    echo Landscape Dismiss
    adb shell input tap 500 580
    timeout /t 2 /NOBREAK
    adb shell input tap 1250 670
    timeout /t 2 /NOBREAK
    adb shell input tap 1745 390
    adb shell input keyevent KEYCODE_BACK
)

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
timeout /t 2 /NOBREAK
adb shell dumpsys window displays | find "mBounds=[0,0][1920,1080]" > nul
if errorlevel 1 (
    echo Portrait Dismiss
    adb shell input tap 900 400
    timeout /t 2 /NOBREAK
) else (
    echo Landscape Dismiss
    adb shell input tap 1175 405
    timeout /t 2 /NOBREAK
)

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


echo Installing App Updater
adb shell pm list packages | find "com.meldcx.appupdater" > nul
if errorlevel 1 (
  echo No existing App Updater instalation
) else (  
  echo Uninstalling existing App Updater
  adb shell am force-stop com.meldcx.appupdater
)
adb remount
adb shell stop
timeout /t 5 /NOBREAK
adb shell rm -rf /system/app/AppUpdater
adb shell rm -rf /system/priv-app/AppUpdater
adb shell rm -rf /data/data/com.meldcx.appupdater
adb shell mkdir /system/priv-app/AppUpdater
adb push binaries/updater-canary-release-signed.apk /system/priv-app/AppUpdater/
adb shell start
timeout /t 20 /NOBREAK
adb shell pm grant com.meldcx.appupdater android.permission.WRITE_EXTERNAL_STORAGE


echo Starting Services
adb shell am start-foreground-service com.meldcx.watchdog/.WatchdogService
adb shell am start -n "com.meldcx.agentm/com.meldcx.agentm.MainActivity"
adb shell am start-foreground-service com.meldcx.appupdater/.pollingservice.PollingService
timeout /t 3 /NOBREAK
adb shell dumpsys window displays | find "mBounds=[0,0][1920,1080]" > nul
if errorlevel 1 (
    echo Portrait Dismiss
    adb shell input tap 900 400
) else (
    echo Landscape Dismiss
    adb shell input tap 1175 405
)
echo *** INSTALL COMPLETE ***
echo *** Rebooting ***
adb reboot
echo *** All Done *** 