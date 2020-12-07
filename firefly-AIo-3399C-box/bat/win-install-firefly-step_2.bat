@echo off
adb version
echo MeldCX note: ADB Version must be 1.0.33 or above

adb root
timeout /t 5 /NOBREAK
adb remount
timeout /t 3 /NOBREAK

echo Granting required permissions for Apps

REM Watchdog (package:com.meldcx.watchdog)
echo echo "Package usage permission for Watchdog"
adb shell am force-stop com.meldcx.watchdog
timeout /t 2 /NOBREAK
adb shell pm grant com.meldcx.watchdog android.permission.PACKAGE_USAGE_STATS
timeout /t 2 /NOBREAK
adb shell settings put secure enabled_accessibility_services %accessibility:com.meldcx.watchdog/com.meldcx.watchdog.WindowChangeDetectingService
timeout /t 3 /NOBREAK

REM Bluetooth onboarding (package:com.meldcx.agentm.service.onboarding)
echo Location permission required for Blueooth function part of Onboarding
adb shell pm grant com.meldcx.agentm.service.onboarding android.permission.ACCESS_COARSE_LOCATION
timeout /t 2 /NOBREAK

REM App Updater
echo WRITE_EXTERNAL_STORAGE permission for app updater
adb shell am force-stop com.meldcx.appupdater
timeout /t 2 /NOBREAK
adb shell pm grant com.meldcx.appupdater android.permission.WRITE_EXTERNAL_STORAGE
timeout /t 2 /NOBREAK

REM Agent
echo AgentM Screen capture and rotation permission
timeout /t 1 /NOBREAK
adb shell am start -n "com.meldcx.agentm/com.meldcx.agentm.install.InstallUtil"
timeout /t 2 /NOBREAK

adb shell dumpsys window displays | find "mBounds=[0,0][1920, 1080]" > nul
if errorlevel 1 (
    echo Portrait Dismiss
    adb shell input tap 178 944 #Check Box for screen recording permission
    timeout /t 1 /NOBREAK
    adb shell input tap 847 1014 #Screen recording permission Start now button press
    timeout /t 6 /NOBREAK
    adb shell input tap 914 317 #Screen Orientation related permission by switching the toggle ON
    timeout /t 4 /NOBREAK
    adb shell input keyevent KEYCODE_BACK
) else (
    echo Landscape Dismiss
    adb shell input tap 503 529 #Check Box for screen recording permission
    timeout /t 2 /NOBREAK
    adb shell input tap 1360 594 #Screen recording permission Start now button press
    timeout /t 6 /NOBREAK
    adb shell input tap 1682 319 #Screen Orientation related permission by switching the toggle ON
    timeout /t 4 /NOBREAK
    adb shell input keyevent KEYCODE_BACK
)

timeout /t 1 /NOBREAK
adb shell am start-foreground-service com.meldcx.appupdater/.pollingservice.PollingService
timeout /t 1 /NOBREAK
adb shell am start-foreground-service com.meldcx.watchdog/.WatchdogService

echo *** INSTALL COMPLETE ***
timeout /t 1 /NOBREAK

echo *** Rebooting ***
adb reboot
echo *** All Done ***