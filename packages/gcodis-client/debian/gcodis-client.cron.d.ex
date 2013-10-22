#
# Regular cron jobs for the gcodis-client package
#
0 4	* * *	root	[ -x /usr/bin/gcodis-client_maintenance ] && /usr/bin/gcodis-client_maintenance
