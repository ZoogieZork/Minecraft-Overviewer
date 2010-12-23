#!/bin/bash

if [[ $OVERVIEWER_CFG = "" ]]; then
	echo "$0: OVERVIEWER_CFG is not set." >&2
	exit 1
fi
source "$OVERVIEWER_CFG"

cd "$OVERVIEWER_ROOT"

time nice -n 19 python gmap.py \
    -p 2 \
    --lighting \
    --cachedir="$WORLD-cache" \
    "$WORLD" \
    "$WORLD_DIR"
