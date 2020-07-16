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

files_w_broken_links=$(find -L * -name ".*" -prune -o -type f -empty -print | xargs ls -Ll | grep -oE "[^ ]*$")

rm files_w_broken_links.txt
touch files_w_broken_links.txt
for file in ${files_w_broken_links[@]}
do
	# Retreive the file url
	file_url=$(grep -o "http.*${file}" ${DOWNLOAD_SCRIPT})
	# If its path cannot be found explicitely, use the first match of its name
	if [ -z "${file_url}" ]
	then
		file_url=$(grep -o "http.*$(basename ${file})" ${DOWNLOAD_SCRIPT})
	fi

	# Attempt to download again in case the broken link now resolves
	subset=$(echo "${file}" | grep -oP "amicorpus/.*?/")
	relfile=$(realpath -s --relative-to=${subset} ${file})
	if [ ! -z "${subset}" ]
	then
		cd ${subset}/
	fi

	git rm ${relfile}
	echo "${file_url} ${relfile}" | git-annex addurl -c annex.largefiles=anything --raw --batch --with-files
	# File is still empty
	if [ ! -s "${relfile}" ]
	then
		# Remove from stage all other changes. New files will be commited 
		# at the end of the script by datalad
		git reset
		git rm ${relfile}
		git commit -m "Delete broken link file"
	fi

	if [ ! -z "${subset}" ]
	then
		cd ../..
	fi

	if [ ! -f ${file} ] || [ ! -s ${file} ]
	then
		echo "${file_url} ${file}" >> files_w_broken_links.txt
	fi
done
