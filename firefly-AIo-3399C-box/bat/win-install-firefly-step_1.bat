@echo off
adb version
echo MeldCX note: ADB Version must be 1.0.33 or above

adb root
timeout /t 5 /NOBREAK
adb remount
timeout /t 3 /NOBREAK

echo Uninstalling All Meld Apps
adb uninstall com.meldcx.agentm.webui
timeout /t 1 /NOBREAK
adb uninstall com.meldcx.agentm
timeout /t 1 /NOBREAK
adb shell am force-stop com.meldcx.enrollment
timeout /t 1 /NOBREAK
adb shell pm uninstall com.meldcx.enrollment
timeout /t 1 /NOBREAK
adb uninstall com.meldcx.watchdog
timeout /t 1 /NOBREAK
adb uninstall com.meldcx.meldcxlauncher
timeout /t 1 /NOBREAK
adb uninstall com.meldcx.agentm.service.onboarding
timeout /t 1 /NOBREAK

adb shell am force-stop com.meldcx.appupdater
adb shell stop
timeout /t 5 /NOBREAK
adb shell rm -rf /system/app/AppUpdater
adb shell rm -rf /system/priv-app/AppUpdater
adb shell rm -rf /data/data/com.meldcx.appupdater
timeout /t 1 /NOBREAK
adb shell start
timeout /t 3 /NOBREAK

echo "Installing All Meld Apps"

adb root
timeout /t 5 /NOBREAK
adb remount
timeout /t 3 /NOBREAK

REM Agent WebUI
echo Installing AgentM WebUI
timeout /t 1 /NOBREAK
adb install binaries/agent-webui-release-signed.apk
timeout /t 2 /NOBREAK

REM Agent
echo Installing AgentM
adb install binaries/agent-release-signed.apk
timeout /t 5 /NOBREAK

adb shell am start -n "com.meldcx.agentm/com.meldcx.agentm.install.InstallUtil"
timeout /t 2 /NOBREAK

adb shell dumpsys window displays | find "mBounds=[0,0][1920,1080]" > nul
if errorlevel 1 (
    echo Portrait Dismiss
    adb shell input tap 178 944 #Check Box for screen recording permission
    timeout /t 1 /NOBREAK
    adb shell input tap 847 1014 #Screen recording permission Start now button press
    timeout /t 4 /NOBREAK
    adb shell input tap 914 317 #Screen Orientation related permission by switching the toggle ON
    timeout /t 4 /NOBREAK
    adb shell input keyevent KEYCODE_BACK
) else (
    echo Landscape Dismiss
    adb shell input tap 503 529 #Check Box for screen recording permission
    timeout /t 2 /NOBREAK
    adb shell input tap 1360 594 #Screen recording permission Start now button press
    timeout /t 4 /NOBREAK
    adb shell input tap 1682 319 #Screen Orientation related permission by switching the toggle ON
    timeout /t 4 /NOBREAK
    adb shell input keyevent KEYCODE_BACK
)

REM Authentication/Enrollment
echo Installing Authentication & Enrollment
timeout /t 1 /NOBREAK
adb install binaries/enrollment-canary-release-signed.apk
timeout /t 2 /NOBREAK

REM Watchdog (package:com.meldcx.watchdog)
echo Installing Watchdog
adb install binaries/watchdog-release-signed.apk
timeout /t 2 /NOBREAK
adb shell pm grant com.meldcx.watchdog android.permission.PACKAGE_USAGE_STATS
timeout /t 1 /NOBREAK

REM Launcher (package:com.meldcx.meldcxlauncher)
echo Installing Meld Launcher
adb install binaries/launcher-signed.apk
timeout /t 1 /NOBREAK
adb shell pm hide com.android.launcher3
adb shell pm disable com.android.launcher3
adb shell cmd package set-home-activity "com.meldcx.meldcxlauncher/com.meldcx.meldcxlauncher.MainActivity"
timeout /t 2 /NOBREAK

REM Bluetooth onboarding (package:com.meldcx.agentm.service.onboarding)
echo Installing Onboarding
adb install binaries/bluetooth-onboarding-canary-release-signed.apk
timeout /t 2 /NOBREAK
adb shell pm grant com.meldcx.agentm.service.onboarding android.permission.ACCESS_COARSE_LOCATION
timeout /t 2 /NOBREAK

adb root
timeout /t 5 /NOBREAK
adb remount
timeout /t 3 /NOBREAK
adb shell stop
timeout /t 3 /NOBREAK
adb shell mkdir /system/priv-app/AppUpdater
adb push binaries/updater-canary-release-signed.apk /system/priv-app/AppUpdater/
timeout /t 1 /NOBREAK
adb shell start
timeout /t 15 /NOBREAK
adb shell pm grant com.meldcx.appupdater android.permission.WRITE_EXTERNAL_STORAGE
timeout /t 2 /NOBREAK

echo Removing Notifications
adb shell settings put global heads_up_notifications_enabled 0

REM start watchdog, launcher, updater
echo Starting Services
adb shell am start-foreground-service com.meldcx.appupdater/.pollingservice.PollingService
timeout /t 1 /NOBREAK
adb shell am start -n "com.meldcx.agentm.webui/com.meldcx.agentm.webui.MainActivity"

adb shell dumpsys window displays | find "mBounds=[0,0][1920,1080]" > nul
if errorlevel 1 (
    echo Portrait Dismiss
    adb shell input tap 700 300 #Dismiss view full screen
    sleep 2s
) else (
    echo Landscape Dismiss
    adb shell input tap 1120 300 #Dismiss view full screen
    sleep 2s
)

echo *** INSTALL COMPLETE ***
timeout /t 2 /NOBREAK

echo *** Rebooting ***
adb reboot
echo *** Please run Step 2 after reboot to complete the installation process ***