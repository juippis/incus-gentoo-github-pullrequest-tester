#!/bin/bash

# Test a https://github.com/gentoo/gentoo pull request, for example:
# Input: test-gentoo-gh-pr.sh 12345
# Would test https://github.com/gentoo/gentoo/pull/12345
#
# Input options: 
#   -1: runs a single build test. Useful for testing minor fixes.
#    test-gentoo-gh-pr.sh -1 12345
#
#   -i: interactive. Spawn a shell before launching tests, if need to modify
#       the ebuild somehow for example. Will merge the patch and you need to  
#       manually call "gentoo-gh-prtester.sh" manually afterwards.
#    test-gentoo-gh-pr.sh -i 12345
# 
#   (null): runs the default test suite.
#   test-gentoo-gh-pr.sh 12345
#

if [[ -z ${1} ]]; then
	echo "Please insert a GitHub PR number!"
	echo "https://github.com/gentoo/gentoo/pull/<this_one>"
	exit
fi

main() {
	local run=""
	local prId=""

	while [[ ${#} -gt 0 ]]; do
		case ${1} in
			-1)
				run="1"
				prId="${2}"
				;;
			-i)
				run="i"
				prId="${2}"
				;;
			*)
				prId="${1}"
				;;
		esac
		shift
	done

	echo "Initializing new test environment... this will take a while."
	incus copy my-gentoo-gh-test-container my-gentoo-gh-test-container-snap-"${prId}"
	incus start my-gentoo-gh-test-container-snap-"${prId}"
	incus exec my-gentoo-gh-test-container-snap-"${prId}" -- su -lc "(sleep 10 && cd /var/db/repos/gentoo && curl -s -L https://patch-diff.githubusercontent.com/raw/gentoo/gentoo/pull/${prId}.patch | git -c user.email=my@email -c user.name=MyName am --keep-cr -3)"

	if [[ -z "${run}" ]]; then
		echo "INFO: Doing the default test runs."
		incus exec my-gentoo-gh-test-container-snap-"${prId}" -- su -lc "(sleep 10 && ~/incus-gentoo-gh/container/bin/gentoo-gh-prtester.sh)"
		incus exec my-gentoo-gh-test-container-snap-"${prId}" -- su -lc "(~/incus-gentoo-gh/container/bin/gentoo_pkg_errors_and_qa_notices.sh)"
		incus exec my-gentoo-gh-test-container-snap-"${prId}" bash

	elif [[ "${run}" == 1 ]]; then
		echo "INFO: -1 invoked - doing a single test-run."
		incus exec my-gentoo-gh-test-container-snap-"${prId}" -- su -lc "(sleep 10 && sed -i -e 's/--max-use-combinations 6/--max-use-combinations 0/g' /root/incus-gentoo-gh/container/bin/gentoo-gh-prtester.sh)"
		incus exec my-gentoo-gh-test-container-snap-"${prId}" -- su -lc "(sleep 10 && ~/incus-gentoo-gh/container/bin/gentoo-gh-prtester.sh)"
		incus exec my-gentoo-gh-test-container-snap-"${prId}" -- su -lc "(~/incus-gentoo-gh/container/bin/gentoo_pkg_errors_and_qa_notices.sh)"
		incus exec my-gentoo-gh-test-container-snap-"${prId}" bash

	elif [[ "${run}" == "i" ]]; then
		echo "INFO: -i invoked - entering interactive mode."
		incus exec my-gentoo-gh-test-container-snap-"${prId}" bash

	else
		echo "ERROR: Not sure what to do here. Insert proper inputs. Check help."
		exit

	fi

	incus exec my-gentoo-gh-test-container-snap-"${prId}" -- su -lc "(sleep 10 && pfl &>/dev/null)"
	incus stop my-gentoo-gh-test-container-snap-"${prId}" 
}

main "${@}"
