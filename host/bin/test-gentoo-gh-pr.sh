#!/bin/bash

print_usage() {
	echo "Usage: ${0} [<options>] <pr-number|pr-url>"
}

print_help() {
	print_usage
	echo
	cat <<-EOF
	Test a Gentoo ebuild repository pull request.

	Without any options, run the default test suite.

	Options:
	  -1
	                   Run a single build test
	  -i
	                   Interactive; Spawn a shell before launching tests, if you
	                   need to modify the ebuild somehow for example. Will merge
	                   the patch and you need to manually call
	                   "gentoo-gh-prtester.sh" manually afterwards.

	Parameters:
	  <pr-number>      GitHub PR number
	  <pr-url>         Full URL to the pull request (Codeberg or GitHub)
	EOF
}

main() {
	local forge=""
	local run=""
	local prId=""

	while [[ ${#} -gt 0 ]]; do
		case ${1} in
			-h|--help)
				print_help
				exit 0
				;;
			-1)
				run="1"
				;;
			-i)
				run="i"
				;;
			-*)
				print_usage >&2
				exit 1
				;;
			*)
				if [[ -n "${prId}" ]]; then
					echo "${0}: only a single PR can be specified" >&2
					print_usage >&2
					exit 1
				fi
				prId="${1}"
				;;
		esac
		shift
	done

	if [[ -z "${prId}" ]]; then
		print_usage >&2
		exit 1
	fi

	case "${prId}" in
		*://codeberg.org/*/gentoo/pulls/*)
			forge="codeberg"
			prId="${prId##*/}"
			;;
		*://github.com/*/gentoo/pull/*)
			forge="github"
			prId="${prId##*/}"
			;;
		[0-9]*)
			forge="github"
			;;
		*)
			echo "Cannot parse ${prId}!" >&2
			print_usage >&2
			exit 1
			;;
	esac

	echo "Initializing new test environment... this will take a while."
	incus copy my-gentoo-gh-test-container my-gentoo-gh-test-container-snap-"${prId}"
	incus start my-gentoo-gh-test-container-snap-"${prId}"

	# compat with containers pre Codeberg support, where container/bin/fullget-gentooghpr.sh
	# only takes a single argument <pr-number> from GitHub
	local fullget_cmd="fullget-gentoopr.sh ${forge} ${prId}"
	incus exec my-gentoo-gh-test-container-snap-"${prId}" -- su -lc \
	      "([[ -x ~/incus-gentoo-gh/container/bin/fullget-gentoopr.sh ]] || exit 1)"
	if [[ ${?} != 0 ]]; then
		echo "~/incus-gentoo-gh/ on my-gentoo-gh-test-container-snap-${prId} is outdated!"
		sleep 2
		if [[ "${forge}" = codeberg ]]; then
			echo "Update the repository on the container before trying again." >&2
			exit 1
		else
			fullget_cmd="fullget-gentooghpr.sh ${prId}"
		fi
	fi

	incus exec my-gentoo-gh-test-container-snap-"${prId}" -- su -lc "(sleep 10 && cd /var/db/repos/gentoo && ~/incus-gentoo-gh/container/bin/${fullget_cmd})"
	wait

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
	fi

	incus exec my-gentoo-gh-test-container-snap-"${prId}" -- su -lc "(sleep 10 && pfl &>/dev/null)"
	incus stop my-gentoo-gh-test-container-snap-"${prId}"
}

main "${@}"
