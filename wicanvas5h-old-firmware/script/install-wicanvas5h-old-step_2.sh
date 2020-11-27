#!/usr/bin/env bash

command -v adb >/dev/null 2>&1 || { echo >&2 "I require adb but it's not installed.  Aborting."; exit 1; }

echo "Granting required permissions for Apps"

adb root
sleep 3s
adb remount
sleep 1s

# Watchdog (package:com.meldcx.watchdog)
echo "Package usage permission for Watchdog"
adb shell am force-stop com.meldcx.watchdog
sleep 2s
adb shell pm grant com.meldcx.watchdog android.permission.PACKAGE_USAGE_STATS

# Onboarding
echo "Location permission required for Blueooth function part of Onboarding"
sleep 2s
adb shell pm grant com.meldcx.agentm.service.onboarding android.permission.ACCESS_COARSE_LOCATION

# App Updater
echo "WRITE_EXTERNAL_STORAGE permission for app updater"
adb shell am force-stop com.meldcx.appupdater
sleep 2s
adb shell pm grant com.meldcx.appupdater android.permission.WRITE_EXTERNAL_STORAGE
sleep 2s

#AgentM
echo "AgentM Screen capture and rotation permission"
adb shell am start -n "com.meldcx.agentm/com.meldcx.agentm.install.InstallUtil"
sleep 2s

if [ "$(adb shell dumpsys window displays | grep -c 'mBounds=\[0,0\]\[1080,1920\]')" -ge 1 ]; then
    echo "Portrait Dismiss"
    adb shell input tap 200 920
    adb shell input tap 200 940
    adb shell input tap 200 960
    adb shell input tap 200 1000
    sleep 2s
    adb shell input tap 800 1020
    adb shell input tap 800 1040
    adb shell input tap 800 1060
    adb shell input tap 800 1100
    adb shell input tap 800 1120
    sleep 12s
    adb shell input tap 1000 400
else 
    echo "Landscape Dismiss"
    adb shell input tap 530 500
    adb shell input tap 530 520
    adb shell input tap 530 540
    adb shell input tap 530 560
    adb shell input tap 530 580
    adb shell input tap 530 600
    sleep 2s
    adb shell input tap 1300 590
    adb shell input tap 1300 610
    adb shell input tap 1300 630
    adb shell input tap 1300 650
    adb shell input tap 1300 670
    adb shell input tap 1300 690
    sleep 12s
    adb shell input tap 1745 390
fi

sleep 1s
adb shell am start-foreground-service com.meldcx.appupdater/.pollingservice.PollingService
sleep 1s
adb shell am start-foreground-service com.meldcx.watchdog/.WatchdogService

echo "*** INSTALL COMPLETE ***"
sleep 1s
echo "*** Rebooting ***"
adb reboot
echo "*** All Done ***"