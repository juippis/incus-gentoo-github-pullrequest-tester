#!/bin/bash

# Start the container and launch root bash in it
incus start my-gentoo-gh-test-container
incus exec my-gentoo-gh-test-container bash
incus stop my-gentoo-gh-test-container
#incus exec my-gentoo-gh-test-container -- poweroff
