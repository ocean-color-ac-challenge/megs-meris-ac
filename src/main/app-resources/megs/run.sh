#!/bin/bash

# Project:		 ${project.name}
# Author:		  $Author: fbrito $ (Terradue Srl)
# Last update:	${doc.timestamp}:
# Element:		 ${project.name}
# Context:		 ${project.artifactId}
# Version:		 ${project.version} (${implementation.build})
# Description:	${project.description}
#
# This document is the property of Terradue and contains information directly
# resulting from knowledge and experience of Terradue.
# Any changes to this code is forbidden without written consent from Terradue Srl
#
# Contact: info@terradue.com
# 2012-02-10 - NEST in jobConfig upgraded to version 4B-1.1

# source the ciop functions (e.g. ciop-log)

source ${ciop_job_include}
export LC_ALL="en_US.UTF-8"

# define the exit codes
SUCCESS=0
ERR_NOINPUT=1

# add a trap to exit gracefully
function cleanExit ()
{
	local retval=$?
	local msg=""
	case "$retval" in
		$SUCCESS) 	msg="Processing successfully concluded";;
		$ERR_NOINPUT)	msg="Input not retrieved to local node";;
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
prdurls="`ciop-getparam prdurls`"

mkdir -p $megsDir

while read input
do
	#environment setup
	mkdir -p $inputDir
	mkdir -p $outputDir

	cd $inputDir
	
	ciop-log "INFO" "Working with file $input"
	file=`ciop-copy -o . $input`

	ciop-log "DEBUG" "ciop-copy output is $file"
	
	if [ ! -z "$file" ]
	then
		file=`basename $file`

		filetype=`echo $file | cut -c 1-10`

		#prepares the environment
		ciop-log "DEBUG" "copying templates to megsdir"
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
	
		sed -i "s#inputfile: #inputfile: $inputDir/$file#g" $megsDir/configurations/Reference_Configuration/job_groups/myjob/job.conf
		sed -i "s#export DATABASE_DIR=.*#export DATABASE_DIR=$megsDir/configurations/Reference_Configuration/job_groups/myjob/run/database#g" $megsDir/configurations/Reference_Configuration/job_groups/myjob/run/run_megs.sh

		ciop-log "INFO" "Starting megs processor"
		cd $megsDir/configurations/Reference_Configuration/job_groups/myjob/run
		ln -s ${outputDir} output
		sh run_megs.sh "$inputDir/$file" "$prdurls"

		cd $outputDir
		ciop-log "INFO" "Publishing output"
		ciop-publish -m $outputDir/*.*
		ciop-log "DEBUG" "ciop-publish exited with $?"
	else
		ciop-log "ERROR" "Error ciop-copy output is empty"
	fi

	#clears the directory for the next file
	rm -rf $megsDir/*
done
