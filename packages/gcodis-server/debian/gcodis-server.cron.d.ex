#
# Regular cron jobs for the gcodis-server package
#
0 4	* * *	root	[ -x /usr/bin/gcodis-server_maintenance ] && /usr/bin/gcodis-server_maintenance
