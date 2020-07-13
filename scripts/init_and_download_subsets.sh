#!/bin/bash

# this script is meant to be used with 'datalad run'

for i in "$@"
do
	case ${i} in
		--download_script=*)
		DOWNLOAD_SCRIPT="${i#*=}"
		echo "DOWNLOAD_SCRIPT = [${DOWNLOAD_SCRIPT}]"
		if [ ! -f "${DOWNLOAD_SCRIPT}" ]
		then
			>&2 echo --download_script option must be an existing file
			unset DOWNLOAD_SCRIPT
		fi
		;;
		*)
		>&2 echo Unknown option [${i}]
		exit 1
		;;
	esac
done

if [ -z "${DOWNLOAD_SCRIPT}" ]
then
	>&2 echo --download_script option must be an existing file
	>&2 echo missing --download_script option
	exit 1
fi

SUBSETS=$(grep -oP "amicorpus/.*?/" "${DOWNLOAD_SCRIPT}" | sort | uniq)

for subset in ${SUBSETS}
do
	mkdir -p ${subset}/
	datalad create -d . ${subset}/
done

./"${DOWNLOAD_SCRIPT}"
