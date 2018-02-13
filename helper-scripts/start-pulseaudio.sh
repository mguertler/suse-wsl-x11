#!/bin/sh
echo ""
echo "--- Starting PulseAudio Server ---"
echo ""
POWERSHELL=/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe
PROFILE_DIR_WIN=$($POWERSHELL -C "Write-Host \$env:USERPROFILE")
PROFILE_DIR_LIN=$(echo "$PROFILE_DIR_WIN" | sed -e "s/^\(.\):/\/mnt\/\L\1/" -e "s/\\\/\//g")
WINDOWS_USERNAME="$(basename $PROFILE_DIR_LIN)"
CMD="/mnt/c/Windows/System32/cmd.exe"


PULSEAUDIO_WIN="$PROFILE_DIR_WIN\pulseaudio-windows-11.1-32bit"
PULSEAUDIO_LIN="$PROFILE_DIR_LIN/pulseaudio-windows-11.1-32bit"

if [ -d "$PULSEAUDIO_LIN" ]; then
	echo "$PULSEAUDIO_WIN\bin\pulseaudio.exe"
	$POWERSHELL -C  "$PULSEAUDIO_WIN\bin\pulseaudio.exe"
fi
