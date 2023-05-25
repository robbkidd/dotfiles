#!/bin/sh
#
if ["$1" == ""]; then
	echo "I need a name to change the name, man." ; exit 1
fi

sudo scutil --set ComputerName $1
sudo scutil --set HostName "$1.local"
sudo scutil --set LocalHostName $1

echo "ComputerName: $(scutil --get ComputerName)"
echo "HostName: $(scutil --get HostName)"
echo "LocalHostName: $(scutil --get LocalHostName)"

