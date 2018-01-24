#!/bin/bash
#
#    Installation script for installing X11 environment on WSL
#    ---------------------------------------------------------
#
#    by Markus Guertler (mguertler@suse.com)
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#

if [[ $EUID -ne 0 ]]; then
	echo "You have to be user root to execute this script!"
	sudo $0
	exit 0
fi

SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
POWERSHELL="/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe"
CMD="/mnt/c/Windows/System32/cmd.exe"
WINPATH_TEMPDIR=$($POWERSHELL -C "Write-Host \$env:TEMP")
LINPATH_TEMPDIR=echo $WINPATH_TEMPDIR | sed -e "s/^\(.\):/\/mnt\/\L\1/" -e "s/\\\/\//g"

echo ""
echo "--- Updating system ---"
echo ""
zypper ref; zypper -y up

echo ""
echo "--- Installing patterns & packages ---"
echo ""
zypper install -y --recommends -t pattern yast2_basis x11 xfce gnome_basis
zypper install -y gnome-terminal

echo ""
echo "--- Configuring display forwarding ---"
echo ""

USERS=$(ls -d /home/*)
USERS="$USERS /root"

for USER in $USERS; do
	if grep -Fxq "export DISPLAY=\":0\"" $USER/.bashrc
	then
		echo "Info: Display forwarding already setup for $USER"
	else
		echo "export DISPLAY=\":0\"" >>$USER/.bashrc
	fi
done

echo ""
echo "--- Fixing d-bus issue ---"
echo ""

mkdir /var/run/dbus

cp /etc/dbus-1/session.conf /etc/dbus-1/session.conf.wsl.bak
sed -i 's$<listen>.*</listen>$<listen>tcp:host=localhost,port=0</listen>$' /etc/dbus-1/session.conf
sed -i 's$<auth>.*</auth>$<auth>ANONYMOUS</auth>\n  <allow_anonymous/>$' /etc/dbus-1/session.conf

echo ""
echo "--- Downloading vcXsrv ---"
echo ""
LATEST="vcxsrv-latest.exe"
wget -O /tmp/$LATEST https://sourceforge.net/projects/vcxsrv/files/latest/download
mv /tmp/$LATEST $WINPATH_TEMPDIR

echo ""
echo "!!!                                                  !!!"
echo "!!! The installation script would now install vcXsrv !!!"
echo "!!!     This requires Adminstrator privileges        !!!"
echo "!!!                                                  !!!"
echo "!!!            Press any key to continue             !!!"
echo "!!!                                                  !!!"
echo ""

read -n 1 -s -r

echo ""
echo "--- Installing vcXsrv ---"
echo ""
$CMD /c "$LINPATH_TEMPDIR/$LATEST /S"

echo ""
echo "--- Preparing xfce4 environment ---"
echo ""
[ ! -d /etc/xdg.orig ] && cp -rpv /etc/xdg /etc/xdg.orig
cp -rpv $SCRIPTPATH/config-files/xfce4-session.xml /etc/xdg/xfce4/xfconf/xfce-perchannel-xml

[ ! -d ./config/xfce4.orig ] && mv ./config/xfce4 ./config/xfce4.orig
cp -rpv SCRIPTPATH/config-files/xfce4 ./config

echo ""
echo "All done. Start X11 graphical userinterface with the command"
echo "winx"
echo ""
