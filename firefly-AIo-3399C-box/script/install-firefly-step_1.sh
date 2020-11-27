#!/usr/bin/env bash

command -v adb >/dev/null 2>&1 || { echo >&2 "I require adb but it's not installed.  Aborting."; exit 1; }

echo "Installing All Meld Apps"

adb root
sleep 1s
adb remount
sleep 1s

# Agent WebUI
echo "Installing AgentM WebUI"
if adb shell pm list packages | grep -q 'com.meldcx.agent.webui'; then
    adb uninstall com.meldcx.agentm.webui
fi
sleep 1s
adb install binaries/agent-webui-release-signed.apk
sleep 2s

# Agent
echo "Installing AgentM"
if adb shell pm list packages | grep -q 'com.meldcx.agentm$'; then
    adb uninstall com.meldcx.agentm
fi
sleep 1s
adb install binaries/agent-release-signed.apk
sleep 10s

adb shell am start -n "com.meldcx.agentm/com.meldcx.agentm.install.InstallUtil"
sleep 4s
# 1080,1920
if [ "$(adb shell dumpsys window displays | grep -c 'mBounds=\[0,0\]\[1080,1920\]')" -ge 1 ]; then
    echo "Portrait Dismiss"
    adb shell input tap 178 944 #Check Box for screen recording permission
    sleep 2s
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

# Authentication/Enrollment
echo "Installing Authentication & Enrollment"
if adb shell pm list packages | grep -q 'com.meldcx.enrollment'; then
    adb shell am force-stop com.meldcx.enrollment
    adb shell pm uninstall com.meldcx.enrollment
fi
sleep 1s
adb install binaries/enrollment-canary-release-signed.apk
sleep 2s

# Watchdog (package:com.meldcx.watchdog)
echo "Installing Watchdog"
if adb shell pm list packages | grep -q 'com.meldcx.watchdog'; then
    adb uninstall com.meldcx.watchdog
fi
sleep 1s
adb install binaries/watchdog-release-signed.apk
sleep 2s
adb shell pm grant com.meldcx.watchdog android.permission.PACKAGE_USAGE_STATS
sleep 1s

# Launcher (package:com.meldcx.meldcxlauncher)
echo "Installing Meld Launcher"
if adb shell pm list packages | grep -q 'com.meldcx.meldcxlauncher'; then
    adb uninstall com.meldcx.meldcxlauncher
fi
sleep 1s
adb install binaries/launcher-signed.apk
sleep 1s
adb shell pm hide com.android.launcher3
adb shell pm disable com.android.launcher3
adb shell cmd package set-home-activity "com.meldcx.meldcxlauncher/com.meldcx.meldcxlauncher.MainActivity"
sleep 2s

# Bluetooth onboarding (package:com.meldcx.agentm.service.onboarding)
echo "Installing Onboarding"
if adb shell pm list packages | grep -q 'com.meldcx.agentm.service.onboarding'; then
    adb uninstall com.meldcx.agentm.service.onboarding
fi
sleep 1s
adb install binaries/bluetooth-onboarding-canary-release-signed.apk
sleep 2s
adb shell pm grant com.meldcx.agentm.service.onboarding android.permission.ACCESS_COARSE_LOCATION
sleep 2s

echo "Installing Updater"
if adb shell pm list packages | grep -q 'com.meldcx.appupdater'; then
    adb shell am force-stop com.meldcx.appupdater
fi

adb root
sleep 1s
adb remount
sleep 1s
adb shell stop
sleep 5s
adb shell rm -rf /system/app/AppUpdater
adb shell rm -rf /system/priv-app/AppUpdater
adb shell rm -rf /data/data/com.meldcx.appupdater
adb shell mkdir /system/priv-app/AppUpdater
adb push binaries/updater-canary-release-signed.apk /system/priv-app/AppUpdater/
sleep 1s
adb shell start
sleep 15s
adb shell pm grant com.meldcx.appupdater android.permission.WRITE_EXTERNAL_STORAGE
sleep 2s
# start watchdog, launcher, updater
echo "Starting Services"
adb shell am start-foreground-service com.meldcx.appupdater/.pollingservice.PollingService
sleep 1s
adb shell am start -n "com.meldcx.agentm.webui/com.meldcx.agentm.webui.MainActivity"

echo "*** INSTALL COMPLETE ***"
sleep 2s

echo "*** Rebooting ***"
adb reboot
echo "*** Please run Step 2 after reboot to complete the installation process ***"
