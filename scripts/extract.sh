#!/bin/bash

# This script is meant to be used with datalad run

pip install -r scripts/requirements_extract.txt
ERR=$?
if [ $ERR -ne 0 ]; then
   echo "Failed to install requirements: pip install: $ERR"
   exit $ERR
fi

for stream in "audio" \
		"browsable" \
		"pens" \
		"shared-doc" \
		"slides" \
		"video" \
		"whiteboard":
do
	jug status -- scripts/extract.py "amicorpus/*/${stream}.zip"
	jug execute -- scripts/extract.py "amicorpus/*/${stream}.zip" 1>> extract.out 2>> extract.err
done

rm files_count.stats
for dir in amicorpus/*/
do
	echo $(find $dir -type f | wc -l; echo $dir) >> files_count.stats
done

du -s amicorpus/*/ > disk_usage.stats
