all:
	#./gcodis-live-build.sh 2>&1 > log_gcodis-live-build.log
	echo "-- BEGIN new gcodis full live-build compilation --" >> log_gcodis-live-build.log
	date >> log_gcodis-live-build.log
	./gcodis-live-build.sh | tee -a log_gcodis-live-build.log
	date >> log_gcodis-live-build.log
	echo "-- END   new gcodis full live-build compilation --" >> log_gcodis-live-build.log
