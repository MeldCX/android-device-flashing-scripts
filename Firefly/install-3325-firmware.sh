#!/usr/bin/env bash

# command -v adb >/dev/null 2>&1 || { echo >&2 "I require adb but it's not installed.  Aborting."; exit 1; }

# Backup existing firmware
# TIMESTAMP=`date +%Y-%m-%d_%H-%M-%S`
# mkdir backup
# OUTPUT="backup/framework-res$TIMESTAMP.apk"

 
# #Disable stuff
# adb root
# sleep 5
# adb disable-verity
# adb reboot

# echo "waiting for reboot..."
# sleep 60
# echo "..."

# # Firmware
# adb root
# sleep 5
# adb remount
# sleep 3
# adb shell stop
# sleep 2
# adb pull /system/framework/framework-res.apk $OUTPUT
# adb push binaries/framework-res.apk /system/framework/framework-res.apk
# adb push binaries/bootanimation.zip /oem/media/bootanimation.zip
# adb shell start

# sleep 30

# # Install Chromium
# echo "Installing Chromium Webview"
# if adb shell pm list packages | grep -q 'com.google.android.webview'; then
#     adb uninstall com.google.android.webview
# fi
# adb root
# sleep 5
# adb remount
# sleep 3
# adb shell stop
# sleep 2
# adb shell rm -rf /system/app/webview /system/app/WebViewGoogle /system/app/WebViewStub \
#                  /system/product_services/app/webview /system/product_services/app/WebViewGoogle \
#                  /system/product_services/app/WebViewStub /system/product_services/app/TrichromeWebView
# adb shell start
# echo "waiting for shell restart"
# sleep 30
# echo "..."
# adb install -r -d binaries/webview.apk


# Agent WebUI
echo "Installing AgentM WebUI"
if adb shell pm list packages | grep -q 'com.meldcx.agent.webui'; then
    adb uninstall com.meldcx.agentm.webui
fi
adb install binaries/AgentWebUI.apk

# Agent
echo "Installing AgentM"
if adb shell pm list packages | grep -q 'com.meldcx.agentm$'; then
    adb uninstall com.meldcx.agentm
fi
adb install binaries/AgentM.apk

sleep 5
#Setup Accessibility
adb shell settings put secure enabled_accessibility_services %accessibility:com.meldcx.agentm/com.meldcx.agentm.diagnostics.AccessibilityKeyDetector
echo "Accessibility Installed"

#Disable Screen Capture Dialog:
sleep 5
adb shell am start -n "com.meldcx.agentm/com.meldcx.agentm.install.InstallUtil"
sleep 10
# if [ "$(adb shell dumpsys window displays | grep -c 'mBounds=\[0,0\]\[1080,1920\]')" -ge 1 ]; then
#     echo "Portrait Dismiss"
#     adb shell input tap 200 920
#     adb shell input tap 200 940
#     adb shell input tap 200 960
#     adb shell input tap 200 1000
#     sleep 2s
#     adb shell input tap 800 1020
#     adb shell input tap 800 1040
#     adb shell input tap 800 1060
#     adb shell input tap 800 1100
#     adb shell input tap 800 1120
#     sleep 12s
#     adb shell input tap 1000 400
# else 
#     echo "Landscape Dismiss"
#     adb shell input tap 530 500
#     adb shell input tap 530 520
#     adb shell input tap 530 540
#     adb shell input tap 530 560
#     adb shell input tap 530 580
#     adb shell input tap 530 600
#     sleep 2s
#     adb shell input tap 1300 590
#     adb shell input tap 1300 610
#     adb shell input tap 1300 630
#     adb shell input tap 1300 650
#     adb shell input tap 1300 670
#     adb shell input tap 1300 690
#     sleep 12s
#     adb shell input tap 1745 390
# fi

# Updater
echo "Installing Updater"
if adb shell pm list packages | grep -q 'com.meldcx.appupdater'; then
    adb shell am force-stop com.meldcx.appupdater
    adb uninstall com.meldcx.appupdater
fi
adb install binaries/AppUpdater.apk

# Authentication/Enrollment
echo "Installing Authentication & Enrollment"
if adb shell pm list packages | grep -q 'com.meldcx.enrollment'; then
    adb shell am force-stop com.meldcx.enrollment
    adb shell pm uninstall com.meldcx.enrollment
fi
adb install binaries/Enrollment.apk

# Watchdog (package:com.meldcx.watchdog)
echo "Installing Watchdog"
if adb shell pm list packages | grep -q 'com.meldcx.watchdog'; then
    adb uninstall com.meldcx.watchdog
fi
adb install binaries/WatchDog.apk
sleep 5
adb shell pm grant com.meldcx.watchdog android.permission.PACKAGE_USAGE_STATS
sleep 3
adb shell settings put secure enabled_accessibility_services %accessibility:com.meldcx.watchdog/com.meldcx.watchdog.WindowChangeDetectingService
sleep 2

# Launcher (package:com.meldcx.meldcxlauncher)
#echo "Installing Meld Launcher"
#if adb shell pm list packages | grep -q 'com.meldcx.meldcxlauncher'; then
#    adb uninstall com.meldcx.meldcxlauncher
#fi
#adb install binaries/launcher-signed.apk
adb shell pm hide com.android.launcher3
adb shell pm disable com.android.launcher3
adb shell cmd package set-home-activity "com.meldcx.agentm/com.meldcx.agentm.MainActivity"

# Bluetooth onboarding (package:com.meldcx.agentm.service.onboarding)
echo "Installing Onboarding"
if adb shell pm list packages | grep -q 'com.meldcx.agentm.service.onboarding'; then
    adb uninstall com.meldcx.agentm.service.onboarding
fi
adb install binaries/OnBoarding.apk
adb shell pm grant com.meldcx.agentm.service.onboarding android.permission.ACCESS_COARSE_LOCATION

# Stop notifications:
echo "Removing Notifications"
adb shell settings put global heads_up_notifications_enabled 0

# start watchdog, launcher, updater
echo "Starting Services"
adb shell am start-foreground-service com.meldcx.watchdog/.WatchdogService
adb shell am start -n "com.meldcx.agentm/com.meldcx.agentm.MainActivity"
adb shell am start-foreground-service com.meldcx.appupdater/.pollingservice.PollingService

echo "*** INSTALL COMPLETE ***"
echo "*** Rebooting ***"
adb reboot
echo "*** All Done ***"
echo "*** Please run Step 2 after reboot to complete the installation process ***"
