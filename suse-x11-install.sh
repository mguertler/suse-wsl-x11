#!/bin/bash
#
#    Installation script for installing X11 environment on WSL
#    ---------------------------------------------------------
#
#    by Markus Guertler
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

echo ""
echo "--- Updating system ---"
echo ""
zypper ref; zypper -y up

echo ""
echo "--- Installing patterns & packages ---"
echo ""
zypper install -y --recommends -t pattern yast2_basis x11 xfce gnome_basis

echo ""
echo "--- Configuring display forwarding ---"
echo ""

USERS=$(ls -d /home/*)
USERS="$USERS /root"

for USER in $USERS; do
	if grep -Fxq "export DISPLAY=\":0" $USER/.bashrc
	then
		echo "Info: Display forwarding already setup for $USER"
	else
		echo "export DISPLAY=\":0" >>$USER/.bashrc
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
CMD="/mnt/c/Windows/System32/cmd.exe"
LATEST="vcxsrv-latest.exe"
wget -O /tmp/$LATEST https://sourceforge.net/projects/vcxsrv/files/latest/download
mv /tmp/$LATEST /mnt/c/Windows/Temp

echo ""
echo "!!!                                                  !!!"
echo "!!! The installation script would now install vcXsrv !!!"
echo "!!!              Press any key to continue           !!!"
echo "!!!                                                  !!!"
echo ""

read -n 1 -s -r

echo ""
echo "--- Installing vcXsrv ---"
echo ""
$CMD /c "c:/Windows/Temp/$LATEST /S"
