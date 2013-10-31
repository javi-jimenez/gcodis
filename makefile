all:
	#./gcodis-live-build.sh 2>&1 > log_gcodis-live-build.log
	./gcodis-live-build.sh | tee log_gcodis-live-build.log

