#!/bin/bash
if [ ! -f "$2" ]; then
	curl -s "$1" --output /tmp/conkyimg && \
	convert /tmp/conkyimg "$2" && \
	rm /tmp/conkyimg
fi