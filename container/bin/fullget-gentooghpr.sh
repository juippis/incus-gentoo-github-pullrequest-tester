#!/bin/bash

# compat with hosts pre Codeberg support, which call
# container/bin/fullget-gentooghpr.sh with a single argument <pr-number> from GitHub
echo "The host scripts for Incus Pull Request Testing are oudated!"
echo "Ensuring compatibility.."
sleep 2
if [[ ${#} = 1 ]]; then
	~/incus-gentoo-gh/container/bin/fullget-gentoopr.sh github "${@}"
else
	~/incus-gentoo-gh/container/bin/fullget-gentoopr.sh "${@}"
fi
