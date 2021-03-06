#!/usr/bin/env bash
command -v adb >/dev/null 2>&1 || { echo >&2 "I require adb but it's not installed.  Aborting."; exit 1; }
adb root
sleep 5s
#Permission for Watchdog
echo "Stopping Watchdog"
adb shell am force-stop com.meldcx.watchdog
sleep 3s
echo "Granting PACKAGE_USAGE_STATS to WatchDog"
adb shell pm grant com.meldcx.watchdog android.permission.PACKAGE_USAGE_STATS
sleep 2s
adb shell settings put secure enabled_accessibility_services %accessibility:com.meldcx.watchdog/com.meldcx.watchdog.WindowChangeDetectingService
sleep 2s

#Permission for App Updater
echo "Stopping App Updater"
adb shell am force-stop com.meldcx.appupdater
sleep 3s
echo "Granting WRITE_EXTERNAL_STORAGE to App Updater"
adb shell pm grant com.meldcx.appupdater android.permission.WRITE_EXTERNAL_STORAGE

#Permission for OnBoarding
sleep 3s
echo "Granting ACCESS_COARSE_LOCATION to OnBoarding"
adb shell pm grant com.meldcx.agentm.service.onboarding android.permission.ACCESS_COARSE_LOCATION

adb shell am start -n "com.meldcx.agentm/com.meldcx.agentm.install.InstallUtil"
sleep 5s
if [ "$(adb shell dumpsys window displays | grep -c 'mBounds=\[0,0\]\[1080,1920\]')" -ge 1 ]; then
    echo "Portrait Dismiss"
    adb shell input tap 196 948
    sleep 1s
    adb shell input tap 820 1040
    sleep 3s
    adb shell input tap 1000 400
    adb shell input keyevent KEYCODE_BACK
else 
    echo "Landscape Dismiss"
    adb shell input tap 500 580
    sleep 2s
    adb shell input tap 1250 670
    sleep 3s
    adb shell input tap 1745 390
    adb shell input keyevent KEYCODE_BACK
fi

adb shell am start-foreground-service com.meldcx.appupdater/.pollingservice.PollingService
adb shell am start-foreground-service com.meldcx.watchdog/.WatchdogService
sleep 2s
adb reboot