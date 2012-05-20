#!/bin/sh
########################################################
##
## Description: Finds duplicate files via shell commands
## Author: strud
## TODO: licence, autodetect md5, add tempdir for performance increase
########################################################

SAVEIFS=$IFS
IFS=$(echo -en "\n\b")
if [ -e /sbin/md5 ]
then
    MD5BIN="/sbin/md5"
    MD5OPTS="-r"
else
    MD5BIN="/usr/bin/md5sum"
    MD5OPTS=""
fi

function printusage() {
	echo "$0 source_dir compare_dir [mode]"	
}

function matchByNameCheckByMD5() {
	for source in `find ${SOURCEDIR} -type f`
	do
		FILES=`expr ${FILES} + 1`
		fnamesource=`basename ${source}`
		for candidate in `find ${COMPAREDIR} -type f -name "${fnamesource}"`
		do
			md5match=0
			if [ "${source}" != "${candidate}" ]
			then
			    sourcemd5=`${MD5BIN} ${MD5OPTS} ${source}`
                sourcemd5="${sourcemd5%% *}"
                candidatemd5=`${MD5BIN} ${MD5OPTS} ${candidate}`
                candidatemd5="${candidatemd5%% *}"
				if [ "${sourcemd5}" == "${candidatemd5}" ]
				then
					md5match=1				
				fi
				if [ ${md5match} -eq 1 ]
				then
					echo "Found duplicate files: '${source}' - '${candidate}'"
					MD5MATCHES=`expr ${MD5MATCHES} + 1`
				else
					echo "Found matching names: '${source}' - '${candidate}'"
					NAMEMATCHES=`expr ${NAMEMATCHES} + 1`
				fi
			fi
		done
	done
	echo "Analyzed ${FILES} files, found ${NAMEMATCHES} matching filenames and ${MD5MATCHES} matching md5 sums"
}

function matchByMD5() {
	for source in `find ${SOURCEDIR} -type f`
	do
		FILES=`expr ${FILES} + 1`
		for candidate in `find ${COMPAREDIR} -type f`
		do
			if [ "${source}" != "${candidate}" ]
			then
				md5match=0
			    sourcemd5=`${MD5BIN} ${MD5OPTS} ${source}`
                sourcemd5="${sourcemd5%% *}"
                candidatemd5=`${MD5BIN} ${MD5OPTS} ${candidate}`
                candidatemd5="${candidatemd5%% *}"
				if [ "${sourcemd5}" == "${candidatemd5}" ]
				then
					echo "Found duplicate files: '${source}' - '${candidate}'"
					MD5MATCHES=`expr ${MD5MATCHES} + 1`
				fi
			fi
		done
	done
	echo "Analyzed ${FILES} files, found ${MD5MATCHES} matching md5 sums"
}

if [ $# -lt 2 ]
then
	printusage
	exit -1
fi

SOURCEDIR=$1
COMPAREDIR=$2
MODE=$3
: ${MODE:=1}

if [ ! -d ${SOURCEDIR} ]
then 
	echo "No source directory set"
	exit -1
fi

if [ ! -d ${COMPAREDIR} ]
then 
	echo "No compare directory set"
	exit -1
fi

NAMEMATCHES=0
MD5MATCHES=0
FILES=0

case ${MODE} in
	1)
		matchByNameCheckByMD5;;
	2)
		matchByMD5;;
	*)
		echo "Not a valid mode"
esac

IFS=$SAVEIFS
exit 0

