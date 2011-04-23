#!/bin/bash

if [[ $OVERVIEWER_CFG = "" ]]; then
	echo "$0: OVERVIEWER_CFG is not set." >&2
	exit 1
fi
source "$OVERVIEWER_CFG"

cd "$WORK_DIR"

WORLD_MTIME_FILENAME="$WORLD_DIR/world-mtime.js"

echo "==> Updating world"
if ( cd world ; git pull ); then

	echo "==> Extracting biomes"
	java -jar MinecraftBiomeExtractor.jar -nogui world

	echo "==> Rendering"
	pushd "$OVERVIEWER_ROOT"
	echo "--> Rendering day"
	t1/bin/run.sh
	echo "--> Rendering night"
	t1/bin/run-night.sh
	popd

	echo "==> Filtering markers"
	pushd "$WORLD_DIR"
	"$OVERVIEWER_ROOT/t1/bin/markers.rb"
	popd

	SNAPSHOT_TIME="$(stat world.7z | grep '^Modify:' | cut -d ' ' -f 2-)"
	echo "var worldSnapshotTs='$(date -d "$SNAPSHOT_TIME")'" > \
		"$WORLD_MTIME_FILENAME"
else
    echo ''
	echo "Failed to retrieve: $WORLD_URL"
fi

echo "==> Syncing to web directory"
rsync -av --delete "$WORLD_DIR" "$WWW_DIR"
rsync -av --delete "$WORLD_NIGHT_DIR" "$WWW_DIR"
