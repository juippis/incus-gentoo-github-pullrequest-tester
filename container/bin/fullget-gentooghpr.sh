#!/bin/bash

# Just a simple PR patch merger. It's much more wise to set up your git config with (any)
# user.email and user.name, but this in general should work without setup everywhere.
#
# Github is limiting frequent requests when you're not logged in. Add a loop and delay to
# keep using this without API keys, for now.

cd /var/db/repos/gentoo || exit

# Wait for a bit over 2 minutes - this seems to work.
# 1 minute is too short.
sleepdelay=125
ghpr="https://github.com/gentoo/gentoo/pull/${1}.patch"
outputpatchfilename="gentoo-github-pr-${1}"

while true; do
	wget -O /tmp/"${outputpatchfilename}".patch "${ghpr}"

	if [ $? -eq 8 ]; then
		echo "Received HTTP 429: Too Many Requests. Retrying in ${sleepdelay} seconds."
		sleep ${sleepdelay}
	else
		git -c user.email=my@email -c user.name=MyName am --keep-cr -3 /tmp/"${outputpatchfilename}".patch
		break
	fi
done
