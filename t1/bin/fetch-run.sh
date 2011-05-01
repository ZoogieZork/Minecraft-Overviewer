#!/bin/bash

if [[ $OVERVIEWER_CFG = "" ]]; then
	echo "$0: OVERVIEWER_CFG is not set." >&2
	exit 1
fi
source "$OVERVIEWER_CFG"

cd "$WORK_DIR"

WORLD_MTIME_FILENAME="$WORLD_DIR/world-mtime.js"

# Disable paging by git.
export GIT_PAGER=cat

echo "==> Updating world"
if ( cd world ; git checkout session.lock ; git pull ); then

	echo "==> Extracting biomes"
	java -jar MinecraftBiomeExtractor.jar -nogui world

	echo "==> Rendering"
	pushd "$OVERVIEWER_ROOT"
	t1/bin/run.sh
	popd

	echo "==> Filtering markers"
	pushd "$WORLD_DIR"
	"$OVERVIEWER_ROOT/t1/bin/markers.rb"
	popd

	SNAPSHOT_TIME="$(cd world ; git log -1 --format='%ad')"
	echo "var worldSnapshotTs='$SNAPSHOT_TIME'" > \
		"$WORLD_MTIME_FILENAME"
else
    echo ''
	echo "Failed to retrieve: $WORLD_URL"
fi

echo "==> Syncing to web directory"
rsync -av --delete "$WORLD_DIR/" "$WWW_DIR/"
