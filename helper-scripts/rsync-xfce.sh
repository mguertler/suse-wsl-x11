#!/bin/sh
EXEC_PATH="`dirname \"$0\"`"
rsync -av ~/.config/xfce4/* $EXEC_PATH/../config-files/xfce4
