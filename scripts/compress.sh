#!/bin/bash

# This script is meant to be used with datalad run

pip install -r scripts/requirements_compress.txt
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
		"whiteboard"
do
	jug status -- scripts/compress.py "amicorpus/*/${stream}/"
	jug execute -- scripts/compress.py "amicorpus/*/${stream}/" 1>> compress.out 2>> compress.err
done
