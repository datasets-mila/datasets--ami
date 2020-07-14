#!/bin/bash

# this script is meant to be used with 'datalad run'

DATASET_PATH=${PWD}

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

while IFS= read -r wget_cmd
do
	subset=$(echo "${wget_cmd}" | grep -oP "amicorpus/.*?/" | uniq)
	if [ ! -z "${subset}" ]
	then
		cd ${subset}/
	fi
	echo $(python "${DATASET_PATH}/scripts/extract_url_and_relpath.py" --dataset_path=${subset}/ -- "${wget_cmd}") | git-annex addurl -c annex.largefiles=anything --raw --batch --with-files 1>> ${DATASET_PATH}/init_and_download_subsets.out 2>> ${DATASET_PATH}/init_and_download_subsets.err
	if [ ! -z "${subset}" ]
	then
		cd ../..
	fi
done <<< $(grep "wget" "${DOWNLOAD_SCRIPT}")

for file_url in "http://groups.inf.ed.ac.uk/ami/AMICorpusAnnotations/ami_public_manual_1.6.2.zip amicorpus/ami_public_manual_1.6.2.zip" \
                "http://groups.inf.ed.ac.uk/ami/AMICorpusAnnotations/ami_public_auto_1.5.1.zip amicorpus/ami_public_auto_1.5.1.zip" \
                "http://groups.inf.ed.ac.uk/ami/AMICorpusAnnotations/dome_annotations_M1.csv amicorpus/dome_annotations_M1.csv" \
                "http://groups.inf.ed.ac.uk/ami/AMICorpusAnnotations/dome_dataset_M1.csv amicorpus/dome_dataset_M1.csv" \
                "http://groups.inf.ed.ac.uk/ami/AMICorpusAnnotations/SocialRoleAnnotation.tar.gz amicorpus/SocialRoleAnnotation.tar.gz"
do
        echo ${file_url} | git-annex addurl -c annex.largefiles=anything --raw --batch --with-files
done
