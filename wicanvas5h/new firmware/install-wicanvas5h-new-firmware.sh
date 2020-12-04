#!/usr/bin/env bash

command -v adb >/dev/null 2>&1 || { echo >&2 "I require adb but it's not installed.  Aborting."; exit 1; }

# Install Chromium
echo "Installing Chromium Webview"
if adb shell pm list packages | grep -q 'com.google.android.webview'; then
    adb uninstall com.google.android.webview
fi
adb root
sleep 5s
adb remount
sleep 3s
adb shell stop
sleep 2s
adb shell rm -rf /system/app/webview /system/app/WebViewGoogle /system/app/WebViewStub \
                 /system/product_services/app/webview /system/product_services/app/WebViewGoogle \
                 /system/product_services/app/WebViewStub /system/product_services/app/TrichromeWebView
adb shell start
echo "waiting for shell restart"
sleep 30s
echo "..."
adb install -r -d binaries/SystemWebView_ARM.apk
# Stop notifications:
echo "Removing Notifications"
adb shell settings put global heads_up_notifications_enabled 0

# Agent WebUI
echo "Installing AgentM WebUI"
if adb shell pm list packages | grep -q 'com.meldcx.agent.webui'; then
    adb uninstall com.meldcx.agentm.webui
fi
adb install binaries/agent-webui-release-signed.apk

# Agent
echo "Installing AgentM"
if adb shell pm list packages | grep -q 'com.meldcx.agentm$'; then
    adb uninstall com.meldcx.agentm
fi
adb install binaries/agent-release-signed.apk

sleep 5s
#Setup Accessibility
adb shell settings put secure enabled_accessibility_services %accessibility:com.meldcx.agentm/com.meldcx.agentm.diagnostics.AccessibilityKeyDetector
echo "Accessibility Installed"

#Disable Screen Capture Dialog:
sleep 5s
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

# Updater
# echo "Installing Updater"
# if adb shell pm list packages | grep -q 'com.meldcx.appupdater'; then
#     adb shell am force-stop com.meldcx.appupdater
#     adb uninstall com.meldcx.appupdater
# fi
# adb install binaries/updater-external-debug-signed.apk

# Authentication/Enrollment
echo "Installing Authentication & Enrollment"
if adb shell pm list packages | grep -q 'com.meldcx.enrollment'; then
    adb shell am force-stop com.meldcx.enrollment
    adb shell pm uninstall com.meldcx.enrollment
fi
adb install binaries/enrollment-canary-release-signed.apk

# Watchdog (package:com.meldcx.watchdog)
echo "Installing Watchdog"
if adb shell pm list packages | grep -q 'com.meldcx.watchdog'; then
    adb uninstall com.meldcx.watchdog
fi
adb install binaries/watchdog-release-signed.apk
sleep 5s
adb shell pm grant com.meldcx.watchdog android.permission.PACKAGE_USAGE_STATS
sleep 3s
adb shell settings put secure enabled_accessibility_services %accessibility:com.meldcx.watchdog/com.meldcx.watchdog.WindowChangeDetectingService
sleep 2s

# Launcher (package:com.meldcx.meldcxlauncher)
echo "Installing Meld Launcher"
if adb shell pm list packages | grep -q 'com.meldcx.meldcxlauncher'; then
    adb uninstall com.meldcx.meldcxlauncher
fi
adb install binaries/launcher-signed.apk
adb shell pm hide com.android.launcher3
adb shell pm disable com.android.launcher3
adb shell cmd package set-home-activity "com.meldcx.meldcxlauncher/com.meldcx.meldcxlauncher.MainActivity"
sleep 2s
if [ "$(adb shell dumpsys window displays | grep -c 'mBounds=\[0,0\]\[1080,1920\]')" -ge 1 ]; then
    echo "Portrait Dismiss"
    adb shell input tap 900 400
    sleep 2s
else 
    adb shell input tap 1175 405
    sleep 2s
fi
# Bluetooth onboarding (package:com.meldcx.agentm.service.onboarding)
echo "Installing Onboarding"
if adb shell pm list packages | grep -q 'com.meldcx.agentm.service.onboarding'; then
    adb uninstall com.meldcx.agentm.service.onboarding
fi
adb install binaries/bluetooth-onboarding-canary-release-signed.apk
adb shell pm grant com.meldcx.agentm.service.onboarding android.permission.ACCESS_COARSE_LOCATION

echo "Installing Updater"
if adb shell pm list packages | grep -q 'com.meldcx.appupdater'; then
    adb shell am force-stop com.meldcx.appupdater
fi
adb remount
sleep 3s
adb shell stop
sleep 5s
adb shell rm -rf /system/app/AppUpdater
adb shell rm -rf /system/priv-app/AppUpdater
adb shell rm -rf /data/data/com.meldcx.appupdater
adb shell mkdir /system/priv-app/AppUpdater
adb push binaries/updater-canary-release-signed.apk /system/priv-app/AppUpdater/
adb shell start
sleep 20s
adb shell pm grant com.meldcx.appupdater android.permission.WRITE_EXTERNAL_STORAGE
# start watchdog, launcher, updater
echo "Starting Services"
adb shell am start-foreground-service com.meldcx.appupdater/.pollingservice.PollingService
adb shell am start -n "com.meldcx.agentm.webui/com.meldcx.agentm.webui.MainActivity"

echo "*** INSTALL COMPLETE ***"
sleep 2s
if [ "$(adb shell dumpsys window displays | grep -c 'mBounds=\[0,0\]\[1080,1920\]')" -ge 1 ]; then
    echo "Portrait Dismiss"
    adb shell input tap 900 400
    sleep 2s
else 
    adb shell input tap 1175 405
    sleep 2s
fi
echo "*** Rebooting ***"
adb reboot
echo "*** All Done ***"
echo "*** Please run Step 2 after reboot to complete the installation process ***"
