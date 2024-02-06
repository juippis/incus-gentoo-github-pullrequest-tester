#!/bin/bash

### Original script: 
###   https://discuss.linuxcontainers.org/t/script-to-get-cpu-usage-in-percentage/18428

getCpuTime() {
	if [[ -f /sys/fs/cgroup/lxc.payload.${1}/cpu.stat ]] ; then
		head -n1 /sys/fs/cgroup/lxc.payload."${1}"/cpu.stat | awk '{print $2}'
	elif [[ -f /sys/fs/cgroup/lxc.payload.user-${UID}_"${1}"/cpu.stat ]] ; then
		head -n1 /sys/fs/cgroup/lxc.payload.user-${UID}_"${1}"/cpu.stat | awk '{print $2}'
	elif [[ -f /sys/fs/cgroup/cpuacct/lxc.payload."${1}"/cpuacct.usage ]] ; then
		cat /sys/fs/cgroup/cpuacct/lxc.payload."${1}"/cpuacct.usage
	else
		cat /sys/fs/cgroup/cpuacct/lxc.payload.user-${UID}_"${1}"/cpuacct.usage
	fi
}

getTimeConvert() {
	if [[ -f /sys/fs/cgroup/lxc.payload.${1}/cpu.stat ]] ; then
		echo "1000000"
	elif [[ -f /sys/fs/cgroup/lxc.payload.user-${UID}_${1}/cpu.stat ]] ; then
		echo "1000000"
	else
		echo "1000000000"
	fi
}

getCpuCores() {
	nproc
}

getPercentage() {
	container="${1}"
	cpuCoresLxd=$(getCpuCores "${container}")
	cpu_usage=$(getCpuTime "${container}")
	sleep 1

	cpu_usage_after=$(getCpuTime "${container}")
	total_cpu_time=$((cpu_usage_after - cpu_usage))
	timeConvert=$(getTimeConvert "${container}")
	cpu_percentage=$(echo "scale=2; (${total_cpu_time} / ${timeConvert}) / ${cpuCoresLxd} * 100" | bc )

	echo "${container} - ${cpu_percentage} %"
}

mapfile -t containers < <(incus list --format=json | jq -r '.[] | select(.state.status == "Running") | .name')

for c in "${containers[@]}" ; do
	getPercentage "${c}"
done

wait
