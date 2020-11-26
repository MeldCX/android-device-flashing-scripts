@echo off
adb version
echo MeldCX note: ADB Version must be 1.0.33 or above

adb root
timeout /t 20 /NOBREAK
REM Permission for Watchdog
adb shell am force-stop com.meldcx.watchdog
timeout /t 3 /NOBREAK
adb shell pm grant com.meldcx.watchdog android.permission.PACKAGE_USAGE_STATS

REM Permission for App Updater
adb shell am force-stop com.meldcx.appupdater
timeout /t 3 /NOBREAK
adb shell pm grant com.meldcx.appupdater android.permission.WRITE_EXTERNAL_STORAGE

REM Permission for OnBoarding
timeout /t 3 /NOBREAK
adb shell pm grant com.meldcx.agentm.service.onboarding android.permission.ACCESS_COARSE_LOCATION

adb shell am start-foreground-service com.meldcx.appupdater/.pollingservice.PollingService
adb shell am start-foreground-service com.meldcx.watchdog/.WatchdogService