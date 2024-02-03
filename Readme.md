# Incus Gentoo Github Pullrequest tester

This repo collects the scripts and configs required to run ["Incus/Gentoo Github pullrequest testing"](https://wiki.gentoo.org/wiki/Incus/Gentoo_Github_pullrequest_testing).


## Repository structure:

* container/bin

   Scripts to be executed inside the container.

* container/etc/portage

   All relevant /etc/portage files.

* host/bin

   Necessary scripts required to run from the host machine, in other words, outside the container.

* pkg-testing-tool-patches

   Easy to access patches for different needs, e.g. general PR testing, stabilization work...


## Links
* https://wiki.gentoo.org/wiki/Incus/Gentoo_Github_pullrequest_testing
* https://wiki.gentoo.org/wiki/Incus
* https://linuxcontainers.org/incus/docs/main/
* https://packages.gentoo.org/packages/app-containers/incus
* https://spdx.org/licenses/CC0-1.0.html


## License

All of these scripts are licensed under ["CC0-1.0"](https://spdx.org/licenses/CC0-1.0.html). In other words, do **whatever** you want with them. No warranty given. ["See also"](https://wiki.creativecommons.org/wiki/CC0).


## TODO

Nothing too ambitious. As long as it works...

 * General container:
 
        * I run often into multiple different build issues with packages in ::gentoo. A general bug reporting tool to automate bug reports would be nice.

 * host/bin/test-gentoo-gh-pr.sh
 
        * Parameters for different kinds of testing, e.g.,
 
                * **-n** for `-native-symlinks` run, since some PRs are made just for that.

