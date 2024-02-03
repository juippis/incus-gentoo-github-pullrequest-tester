#!/bin/bash

echo ""
echo "!! Getting scripts and git portage configuration from "
echo "!!   https://github.com/juippis/incus-gentoo-github-pullrequest-tester"
echo ""

sleep 5

cd /root || exit
git clone --depth=1 https://github.com/juippis/incus-gentoo-github-pullrequest-tester.git --no-checkout incus-gentoo-gh || exit
cd incus-gentoo-gh || exit
git config core.sparsecheckout true
echo container/bin/* > .git/info/sparse-checkout
echo container/etc/* >> .git/info/sparse-checkout
git read-tree -m -u HEAD

echo ""
echo "!! Git configuration done."
echo ""

sleep 5

echo ""
echo "!! Symlinking new portage configuration and "
echo "!! creating necessary directories."
echo ""

sleep 5

rm -f /etc/portage/make.conf
rmdir /etc/portage/package.use/ || return

ln -s /root/incus-gentoo-gh/container/etc/portage/bashrc /etc/portage/bashrc
ln -s /root/incus-gentoo-gh/container/etc/portage/env/ /etc/portage/env
ln -s /root/incus-gentoo-gh/container/etc/portage/make.conf /etc/portage/make.conf
ln -s /root/incus-gentoo-gh/container/etc/portage/package.accept_keywords/ /etc/portage/package.accept_keywords
ln -s /root/incus-gentoo-gh/container/etc/portage/package.mask/ /etc/portage/package.mask
ln -s /root/incus-gentoo-gh/container/etc/portage/package.use/ /etc/portage/package.use
ln -s /root/incus-gentoo-gh/container/etc/portage/repos.conf/ /etc/portage/repos.conf

mkdir -p /etc/portage/package.env/
mkdir -p /etc/portage/package.unmask/
mkdir -p /var/tmp/portage/vbslogs/

touch /etc/portage/make.conf.custom

sleep 5

echo ""
echo "!! Modifying /root/.bashrc and /root/.profile to our needs."
echo ""

echo "PATH=\"\$PATH:~/incus-gentoo-gh/container/bin\"" >> /root/.bashrc
echo "/root/incus-gentoo-gh/container/bin/fixshm.sh" >> /root/.bashrc
/root/incus-gentoo-gh/container/bin/fixshm.sh

echo ""
echo "!! Switching portage tree to git, and syncing."
echo ""

sleep 5

rm -r /var/db/repos/gentoo/* || exit
rm -rf /var/db/repos/gentoo/.git || return
rm -f /var/db/repos/gentoo/.gitignore || return
rm -f /var/db/repos/gentoo/.editorconfig || return
emerge --sync || exit

echo ""
echo "!! At this point, check /etc/portage "
echo "!! (/root/incus-gentoo-gh/container/etc/portage/) files, and un-symlink "
echo "!! files you have to edit to fit your needs. You WILL need to fill "
echo "!! /etc/portage/make.conf.custom file with your personal configuration."
echo "!!"
echo "!! Also see /root/.bashrc / /root/.profile and add your preferred EDITOR, etc."
echo "!!"
echo "!! Then run:" 
echo "!!   emerge -uavDN @world"
echo "!!   perl-cleaner --all"
echo "!!   eselect news read"
echo "!!   etc-update (or dispatch-conf)"
echo "!!   (gcc-config -l; gcc-config 2; source /etc/profile)"
echo "!!"
echo "!! and finally install any software you're going to use:"
echo "!!   emerge -av app-admin/eclean-kernel app-editors/emacs \\"
echo "     app-emacs/ebuild-mode app-editors/vim app-portage/gentoolkit \\"
echo "     app-portage/pfl app-portage/portage-utils app-portage/repoman \\"
echo "     app-text/ansifilter dev-util/pkgcheck sys-kernel/gentoo-kernel-bin \\"
echo "     app-portage/pkg-testing-tool app-portage/iwdevtools net-misc/dhcp"
echo ""
echo "Continue reading: "
echo "  TODO"
echo ""

