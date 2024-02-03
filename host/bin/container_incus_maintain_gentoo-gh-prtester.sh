#!/bin/bash

# Update the container. Sleeps are added just in case bringing network up is slow. 
# Adjust to your needs. 
incus start my-gentoo-gh-test-container
incus exec my-gentoo-gh-test-container -- su -lc "(sleep 10 && cd ~/incus-gentoo-gh && git pull)"
incus exec my-gentoo-gh-test-container -- su -lc "emerge --sync"
incus exec my-gentoo-gh-test-container -- su -lc "(emerge -uvDN --binpkg-changed-deps=y --keep-going @world && emerge --depclean --with-bdeps=n)"
incus exec my-gentoo-gh-test-container -- su -lc "eclean-kernel -n 1"
incus exec my-gentoo-gh-test-container -- su -lc "(eselect news read && etc-update)"
incus exec my-gentoo-gh-test-container -- su -lc "pfl"
incus exec my-gentoo-gh-test-container -- su -lc "eclean packages --changed-deps"
incus stop my-gentoo-gh-test-container

# Delete all old snapshots. Note that this will NOT delete active containers!
incus list | awk '{print $2}' | grep my-gentoo-gh-test-container-snap | xargs -I SNAP incus delete SNAP

# For problems with inittab, use
#incus exec my-gentoo-gh-test-container -- poweroff

echo "All done."
echo
