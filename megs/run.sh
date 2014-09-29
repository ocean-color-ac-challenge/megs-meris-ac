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

megsDir=${TMPDIR}/megs
inputDir=${megsDir}/input
outputDir=${megsDir}/output

mkdir -p $megsDir

while read input
do
	mkdir -p $inputDir
	mkdir -p $outputDir
	
	ciop-log "INFO" "Working with file $input"
	file=`ciop-copy -o $inputDir -U $input`

	ciop-log "DEBUG" "ciop-copy output is $file"

	file=`basename $file`

	#prepares the environment
	ciop-log "DEBUG" "copying templates to megsdir"
	cp -Rv /usr/local/MEGS_8.1/templates $megsDir
	sed -i 's#inputfile: #inputfile: $inputDir/$file#g' $megsDir/job.conf


	ciop-log "INFO" "Starting megs processor"
	cd $megsDir/run
	sh -x run_megs.sh $inputDir/$file	

	cd $outputDir
	ciop-log "INFO" "Publishing output"
	ciop-publish -m *.N1

	#clears the directory for the next file
	rm -rf $megsDir/*
done
