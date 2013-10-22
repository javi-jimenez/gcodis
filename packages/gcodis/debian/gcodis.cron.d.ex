#
# Regular cron jobs for the gcodis package
#
0 4	* * *	root	[ -x /usr/bin/gcodis_maintenance ] && /usr/bin/gcodis_maintenance
