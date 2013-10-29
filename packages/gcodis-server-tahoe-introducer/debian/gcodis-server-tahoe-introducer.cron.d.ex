#
# Regular cron jobs for the gcodis-server-tahoe-introducer package
#
0 4	* * *	root	[ -x /usr/bin/gcodis-server-tahoe-introducer_maintenance ] && /usr/bin/gcodis-server-tahoe-introducer_maintenance
