#!/usr/bin/env bash
command -v adb >/dev/null 2>&1 || { echo >&2 "I require adb but it's not installed.  Aborting."; exit 1; }

if adb shell pm list packages | grep -q 'com.meldcx.appupdater'; then
    adb root
    sleep 5s
    adb remount
    sleep 10s
    adb shell stop
    sleep 10s
    adb shell am force-stop com.meldcx.appupdater
    adb shell rm -rf /system/app/AppUpdater
    adb shell rm -rf /system/priv-app/AppUpdater
    adb shell rm -rf /data/data/com.meldcx.appupdater
    adb shell start
    sleep 30s
fi

adb shell am force-stop com.meldcx.watchdog
adb shell am start -a android.settings.SETTINGS
sleep 2s
adb shell input swipe 500 1000 300 300
sleep 3s
if [ "$(adb shell dumpsys window displays | grep -c 'mBounds=\[0,0\]\[1080,1920\]')" -ge 1 ]; then
    echo "Portrait reset"
    adb shell input tap 250 1750
    sleep 1s
    adb shell input tap 250 680
    sleep 1s
    adb shell input tap 300 430
    sleep 1s
    adb shell input tap 550 1760
    sleep 1s
    adb shell input tap 530 410
    
else 
    echo "Landscape reset"
    adb shell input tap 220 1010
    sleep 1s
    adb shell input tap 250 650
    sleep 1s
    adb shell input tap 300 400
    sleep 1s
    adb shell input tap 900 1010
    sleep 1s
    adb shell input tap 900 350
fi
echo "Waiting for device restart"
sleep 120s
adb shell am start -a android.settings.SETTINGS
sleep 2s
if [ "$(adb shell dumpsys window displays | grep -c 'mBounds=\[0,0\]\[1080,1920\]')" -ge 1 ]; then
    echo "Portrait enable wifi and bluetooth"
    adb shell input tap 250 250
    sleep 2s
    adb shell input tap 1000 230
    sleep 2s
    adb shell input keyevent KEYCODE_BACK
    sleep 2s
    adb shell input tap 260 400
    sleep 2s
    adb shell input tap 1000 230
    sleep 3s
    adb shell input keyevent KEYCODE_BACK
    sleep 1s
else 
    echo "Landscape enable wifi and bluetooth"
    adb shell input tap 300 250
    sleep 2s
    adb shell input tap 1730 215
    sleep 2s
    adb shell input keyevent KEYCODE_BACK
    sleep 2s
    adb shell input tap 260 400
    sleep 2s
    adb shell input tap 730 215
    sleep 3s
    adb shell input keyevent KEYCODE_BACK
    sleep 1s
fi
echo "Factory reset finished, please run install-wicanvas5h-new-firmware.sh to install meldcx apps"
