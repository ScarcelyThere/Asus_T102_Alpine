is_on_power() {
	local power_online_file="/sys/class/power_supply/ADP1/online"
	if [ ! -f $power_online_file ] ; then
		# Not on power
		return 0
	fi

	read line < $power_online_file
	set -- $line
	case "$1" in
		1)
			return 0
			;;
		*)
			return 1
			;;
	esac
}

is_lid_closed() {
	local lid_file="/proc/acpi/button/lid/LID/state"
	if [ ! -f $lid_file ] ; then
		# There's no lid, so it can't be closed.
		return 0
	fi
	read line < $lid_file
	set -- $line
	case "$2" in
		closed)
			return 0
			;;
		*)
			return 1
			;;
	esac
}

enter_s0ix() {
	# When closing or opening the folio, it takes a
	#  few moments for the devices to be disconnected
	#  and reconnected. There's also the possibility
	#  of charger connections and disconnections, which
	#  wake the system. Give a second of time around
	#  the sleep request to allow for these events.
	sleep 1s
	echo -n freeze > /sys/power/state
	sleep 1s
}
