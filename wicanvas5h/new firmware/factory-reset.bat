@echo off
adb version
echo MeldCX note: ADB Version must be 1.0.33 or above

adb shell pm list packages | find "com.meldcx.appupdater" > nul
if errorlevel 1 (
  echo No existing App Updater instalation
) else (  
  echo Uninstalling existing App Updater
  adb shell am force-stop com.meldcx.appupdater
  adb root
  timeout /t 5 /NOBREAK
  adb remount
  adb shell stop
  timeout /t 5 /NOBREAK
  adb shell rm -rf /system/app/AppUpdater
  adb shell rm -rf /system/priv-app/AppUpdater
  adb shell rm -rf /data/data/com.meldcx.appupdater
  adb shell start
  timeout /t 5 /NOBREAK
)

adb shell am force-stop com.meldcx.watchdog
adb shell am start -a android.settings.SETTINGS
timeout /t 2 /NOBREAK
adb shell input swipe 500 1000 300 300
timeout /t 2 /NOBREAK
adb shell dumpsys window displays | find "mBounds=[0,0][1920,1080]" > nul
if errorlevel 1 (
    echo Portrait reset
    adb shell input tap 250 1750
    timeout /t 1 /NOBREAK
    adb shell input tap 250 680
    timeout /t 1 /NOBREAK
    adb shell input tap 300 430
    timeout /t 1 /NOBREAK
    adb shell input tap 550 1760
    timeout /t 1 /NOBREAK
    adb shell input tap 530 410
) else (
    echo "Landscape reset"
    adb shell input tap 220 1010
    timeout /t 1 /NOBREAK
    adb shell input tap 250 750
    timeout /t 1 /NOBREAK
    adb shell input tap 300 400
    timeout /t 1 /NOBREAK
    adb shell input tap 900 1010
    timeout /t 1 /NOBREAK
    adb shell input tap 900 350
)