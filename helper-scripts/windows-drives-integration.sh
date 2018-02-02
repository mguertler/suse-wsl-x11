#!/bin/sh
BOOKMARKS_DIR=~/.config/gtk-3.0
BOOKMARKS_FILE=bookmarks
DRIVES=$(ls /mnt/)

POWERSHELL=/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe
SPECIAL_DIRS=$($POWERSHELL -C "
\$documents = [environment]::getfolderpath(\"mydocuments\")
\$pictures = [environment]::getfolderpath(\"mypictures\")
\$music = [environment]::getfolderpath(\"mymusic\")
Write-Host \$documents \$pictures \$music"
)
PROFILE_DIR_WIN=$($POWERSHELL -C "Write-Host \$env:USERPROFILE")
PROFILE_DIR_LIN=$(echo "$PROFILE_DIR_WIN" | sed -e "s/^\(.\):/\/mnt\/\L\1/" -e "s/\\\/\//g")
WINDOWS_USERNAME="$(basename $PROFILE_DIR_LIN)"

mkdir -p $BOOKMARKS_DIR
mkdir -p ~/windows

sed -i "\|$PROFILE_DIR_LIN Windows-$WINDOWS_USERNAME\$|d" $BOOKMARKS_DIR/$BOOKMARKS_FILE
echo "file:///$PROFILE_DIR_LIN Windows-$WINDOWS_USERNAME" >>$BOOKMARKS_DIR/$BOOKMARKS_FILE
[ ! -e ~/windows/$WINDOWS_USERNAME ] && ln -s $PROFILE_DIR_LIN ~/windows


for DRIVE in $DRIVES; do
	sed -i "/\/mnt\/$DRIVE\$/d" $BOOKMARKS_DIR/$BOOKMARKS_FILE
	echo "file:///mnt/$DRIVE" >>$BOOKMARKS_DIR/$BOOKMARKS_FILE
	[ ! -e ~/windows/$DRIVE ] && ln -s /mnt/$DRIVE ~/windows
done
