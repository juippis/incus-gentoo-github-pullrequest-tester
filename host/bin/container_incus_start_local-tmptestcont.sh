#!/bin/bash

# Just a skeleton file to launch a "basic test environment". This will be 
# deleted normally by container_incus_maintain_gentoo-gh-prtester.sh, unless this 
# container is powered on with incus start.

echo "Initializing new test environment... this will take a while."
incus copy my-gentoo-gh-test-container my-gentoo-gh-test-container-snap-tmp

incus start my-gentoo-gh-test-container-snap-tmp
incus exec my-gentoo-gh-test-container-snap-tmp bash

echo "Uploading pfl data..." 

incus exec my-gentoo-gh-test-container-snap-tmp -- su -lc "(sleep 10 && pfl &>/dev/null)"
incus stop my-gentoo-gh-test-container-snap-tmp
