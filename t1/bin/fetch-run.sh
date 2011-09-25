#!/bin/bash

if [[ $OVERVIEWER_CFG = "" ]]; then
	echo "$0: OVERVIEWER_CFG is not set." >&2
	exit 1
fi
source "$OVERVIEWER_CFG"

WORLD_MTIME_FILENAME="$WORLDS_DIR/world-mtime.js"

# Disable paging by git.
export GIT_PAGER=cat

echo "==> Updating world"

# Previous runs of the biome extractor may leave session.lock
# modified, preventing pull from working.
for world in "${WORLDS[@]}"; do
    cd "$WORLD_REPO_ROOT/$world"
    git checkout session.lock || exit 1
done

cd "$WORLD_REPO_ROOT"
if git pull; then

    SNAPSHOT_TIME="$(git log -1 --format='%ad')"

    #echo "==> Compacting repository"
    #echo -n "--> Before: "
    #du -h --max-depth=0 .git
    #echo "--> Compacting"
    #git gc
    #echo -n "--> After:  "
    #du -h --max-depth=0 .git

    # Disabled for now.
    #echo "==> Extracting biomes"
    #java -jar MinecraftBiomeExtractor.jar -nogui world

	echo "==> Rendering"
	pushd "$OVERVIEWER_ROOT"
	t1/bin/run.sh
	popd

    # Disabled for now.
    #echo "==> Filtering markers"
    #pushd "$WORLD_DIR"
    #"$OVERVIEWER_ROOT/t1/bin/markers.rb"
    #popd

	echo "var worldSnapshotTs='$SNAPSHOT_TIME'" > \
		"$WORLD_MTIME_FILENAME"
else
    echo ''
	echo "Failed to retrieve: $WORLD_URL"
fi

echo "==> Syncing to web directory"
rsync -av --delete "$WORLDS_DIR/" "$WWW_DIR/"
