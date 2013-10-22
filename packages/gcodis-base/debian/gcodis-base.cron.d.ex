#
# Regular cron jobs for the gcodis-base package
#
0 4	* * *	root	[ -x /usr/bin/gcodis-base_maintenance ] && /usr/bin/gcodis-base_maintenance
