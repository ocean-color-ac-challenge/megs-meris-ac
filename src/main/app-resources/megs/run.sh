#!/bin/bash

# This document is the property of Terradue and contains information directly
# resulting from knowledge and experience of Terradue.
# Any changes to this code is forbidden without written consent from Terradue Srl
#
# Contact: info@terradue.com

# source the ciop functions (e.g. ciop-log)
source ${ciop_job_include}
export LC_ALL="en_US.UTF-8"

# define the exit codes
SUCCESS=0
ERR_NOINPUT=3
ERR_MEGS=5
# add a trap to exit gracefully
function cleanExit ()
{
	local retval=$?
	local msg=""
	case "$retval" in
		$SUCCESS) 	msg="Processing successfully concluded";;
		$ERR_NOINPUT)	msg="Input not retrieved to local node";;
		$ERR_MEGS)	msg="megs returned an error";;
		*)		msg="Unknown error";;
	esac

	[ "$retval" != "0" ] && ciop-log "ERROR" "Error $retval - $msg, processing aborted" || ciop-log "INFO" "$msg"

	exit $retval
}

trap cleanExit EXIT

ciop-log "DEBUG" "Megs dir: ${TMPDIR}/megs"
ciop-log "DEBUG" "Input dir: ${TMPDIR}/megs/input"
ciop-log "DEBUG" "Output dir: ${TMPDIR}/megs/output"

megsDir=${TMPDIR}/megs/processors/MEGS_8.1/
inputDir=${megsDir}/input
outputDir=${megsDir}/output

prdurl="`ciop-getparam prdurl`"
[ "$prdurl" == "default" ] && prdurl=""

mkdir -p $megsDir

while read input
do
	#environment setup
	mkdir -p $inputDir
	mkdir -p $outputDir

	cd $inputDir
	
	ciop-log "INFO" "Working with file $input"
	file=`ciop-copy -o . $input`

	[ $? != 0 ] && exit $ERR_NOINPUT

	ciop-log "DEBUG" "ciop-copy output is $file"
	
	file=`basename $file`

	# checks if it's a RR, FR or FRS
	filetype=`echo $file | cut -c 1-10`

	#prepares the environment
	ciop-log "INFO" "copying templates to megsdir"
	mkdir -p ${megsDir}/configurations/Reference_Configuration
	cd ${megsDir}/configurations/Reference_Configuration
	cp -Rv /usr/local/MEGS_8.1/configurations/Reference_Configuration/resources .
	cp -Rv /usr/local/MEGS_8.1/configurations/Reference_Configuration/configuration.conf .
	mkdir -p job_groups/myjob
	cd job_groups/myjob
	cp -Rv /usr/local/MEGS_8.1/templates/* .
		
	#sets the correct modifiers.db and value.txt
	cp run/value.${filetype}.txt run/value.txt
	cp run/modifiers.${filetype}.db run/modifiers.db
	
	# instantiates the templates
	sed -i "s#inputfile: #inputfile: $inputDir/$file#g" $megsDir/configurations/Reference_Configuration/job_groups/myjob/job.conf
	sed -i "s#export DATABASE_DIR=.*#export DATABASE_DIR=$megsDir/configurations/Reference_Configuration/job_groups/myjob/run/database#g" $megsDir/configurations/Reference_Configuration/job_groups/myjob/run/run_megs.sh

	ciop-log "INFO" "Starting megs processor"
	cd $megsDir/configurations/Reference_Configuration/job_groups/myjob/run
	ln -s ${outputDir} output
	sh run_megs.sh "$inputDir/$file" "$prdurl"

	[ $? != 0 ] && exit $ERR_MEGS

	cd $outputDir
	ciop-log "INFO" "Publishing output"
	ciop-publish -m $outputDir/*.*
	ciop-log "DEBUG" "ciop-publish exited with $?"

	#clears the directory for the next file
	rm -rf $megsDir/*
done
