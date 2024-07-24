#!/bin/bash

# Quick and dirty way for disabling native-symlinks. Intended to be used with 
# discardable containers, ie, does not "toggle" the state of native-symlinks.

mkdir -p /etc/portage/profile/

if [[ -d /etc/portage/profile/package.use.force ]] ; then
	puftarget="/etc/portage/profile/package.use.force/native-symlinks"
else
	puftarget="/etc/portage/profile/package.use.force"
fi

{
	echo "dev-lang/python-exec -native-symlinks"
	echo "sys-devel/binutils-config -native-symlinks"
	echo "sys-devel/gcc-config -cc-wrappers -native-symlinks"
} >> "${puftarget}"

if [[ -d /etc/portage/package.use ]] ; then
	putarget="/etc/portage/package.use/native-symlinks"
else
	putarget="/etc/portage/package.use"
fi

{
	echo "dev-lang/python-exec -native-symlinks"
	echo "sys-devel/binutils-config -native-symlinks"
	echo "sys-devel/gcc-config -cc-wrappers -native-symlinks"
} >> "${putarget}"

emerge -1av --usepkg-exclude dev-lang/python-exec --usepkg-exclude sys-devel/binutils-config --usepkg-exclude sys-devel/gcc-config dev-lang/python-exec sys-devel/binutils-config sys-devel/gcc-config
