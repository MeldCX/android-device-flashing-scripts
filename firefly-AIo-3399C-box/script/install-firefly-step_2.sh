#!/usr/bin/env bash

command -v adb >/dev/null 2>&1 || { echo >&2 "I require adb but it's not installed.  Aborting."; exit 1; }

echo "Granting required permissions for Apps"

adb root
sleep 1s
adb remount
sleep 1s

#AgentM
echo "AgentM Screen capture and rotation permission"

adb shell am start -n "com.meldcx.agentm/com.meldcx.agentm.install.InstallUtil"
sleep 2s

if [ "$(adb shell dumpsys window displays | grep -c 'mBounds=\[0,0\]\[1080,1920\]')" -ge 1 ]; then
    echo "Portrait Dismiss"
    adb shell input tap 178 944 #Check Box for screen recording permission
    sleep 1s
    adb shell input tap 847 1014 #Screen recording permission Start now button press
    sleep 6s
    adb shell input tap 914 317 #Screen Orientation related permission by switching the toggle ON
    sleep 4s
    adb shell input keyevent KEYCODE_BACK
else
    echo "Landscape Dismiss"
    adb shell input tap 503 529 #Check Box for screen recording permission
    sleep 2s
    adb shell input tap 1360 594 #Screen recording permission Start now button press
    sleep 6s
    adb shell input tap 1682 319 #Screen Orientation related permission by switching the toggle ON
    sleep 4s
    adb shell input keyevent KEYCODE_BACK
fi

# Watchdog (package:com.meldcx.watchdog)
echo "Package usage permission for Watchdog"
sleep 2s
adb shell pm grant com.meldcx.watchdog android.permission.PACKAGE_USAGE_STATS

# Onboarding
echo "Location permission required for Blueooth function part of Onboarding"
sleep 2s
adb shell pm grant com.meldcx.agentm.service.onboarding android.permission.ACCESS_COARSE_LOCATION

# App Updater
echo "WRITE_EXTERNAL_STORAGE permission for app updater"
sleep 2s
adb shell pm grant com.meldcx.appupdater android.permission.WRITE_EXTERNAL_STORAGE
sleep 2s
echo ""*** INSTALL COMPLETE ***""
sleep 1s
echo "*** Rebooting ***"
adb reboot
echo "*** All Done ***"
