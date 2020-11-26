#!/usr/bin/env bash
command -v adb >/dev/null 2>&1 || { echo >&2 "I require adb but it's not installed.  Aborting."; exit 1; }
adb root
sleep 10s
#Permission for Watchdog
adb shell am force-stop com.meldcx.watchdog
sleep 3s
adb shell pm grant com.meldcx.watchdog android.permission.PACKAGE_USAGE_STATS

#Permission for App Updater
adb shell am force-stop com.meldcx.appupdater
sleep 3s
adb shell pm grant com.meldcx.appupdater android.permission.WRITE_EXTERNAL_STORAGE

#Permission for OnBoarding
sleep 3s
adb shell pm grant com.meldcx.agentm.service.onboarding android.permission.ACCESS_COARSE_LOCATION

adb shell am start-foreground-service com.meldcx.appupdater/.pollingservice.PollingService
adb shell am start-foreground-service com.meldcx.watchdog/.WatchdogService
popd || exit