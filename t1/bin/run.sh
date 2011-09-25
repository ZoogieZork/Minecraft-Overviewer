#!/bin/bash

if [[ $OVERVIEWER_CFG = "" ]]; then
	echo "$0: OVERVIEWER_CFG is not set." >&2
	exit 1
fi
source "$OVERVIEWER_CFG"

cd "$OVERVIEWER_ROOT"

for world in "${WORLDS[@]}"; do
    WORLD="$WORLD_REPO_ROOT/$world"
    WORLD_DIR="$WORLDS_DIR/$world"

    time nice -n 19 python overviewer.py \
        -p 2 \
        --settings=settings.py \
        "$WORLD" \
        "$WORLD_DIR"
done
