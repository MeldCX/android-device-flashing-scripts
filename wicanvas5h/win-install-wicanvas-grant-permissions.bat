@echo off
adb version
echo MeldCX note: ADB Version must be 1.0.33 or above

adb root
timeout /t 5 /NOBREAK
REM Permission for Watchdog
echo Stopping WatchDog
adb shell am force-stop com.meldcx.watchdog
timeout /t 3 /NOBREAK
echo Granting PACKAGE_USAGE_STATS to WatchDog
adb shell pm grant com.meldcx.watchdog android.permission.PACKAGE_USAGE_STATS
timeout /t 2 /NOBREAK
adb shell settings put secure enabled_accessibility_services %accessibility:com.meldcx.watchdog/com.meldcx.watchdog.WindowChangeDetectingService
timeout /t 2 /NOBREAK

REM Permission for App Updater
echo Stopping App Updater
adb shell am force-stop com.meldcx.appupdater
timeout /t 3 /NOBREAK
echo Granting WRITE_EXTERNAL_STORAGE permission to App Updater
adb shell pm grant com.meldcx.appupdater android.permission.WRITE_EXTERNAL_STORAGE

REM Permission for OnBoarding
timeout /t 3 /NOBREAK
adb shell pm grant com.meldcx.agentm.service.onboarding android.permission.ACCESS_COARSE_LOCATION

adb shell am start -n "com.meldcx.agentm/com.meldcx.agentm.install.InstallUtil"
timeout /t 2 /NOBREAK

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

adb shell am start-foreground-service com.meldcx.appupdater/.pollingservice.PollingService
adb shell am start-foreground-service com.meldcx.watchdog/.WatchdogService
adb reboot