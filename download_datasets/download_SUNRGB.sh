#!/bin/bash
# download script for SUN RGB-D

# you can replace DATADIR with anything
# MAKE SURE YOU ARE NOT OVERWRITING SOMEONE ELSE'S DIRECTORY
readonly DATADIR="/scratch/datasets"

# other global variables
readonly SCRIPT_NAME=$0

# url to dataset
readonly DATASET_URL="http://rgbd.cs.princeton.edu/data/SUNRGBD.zip"
# url to toolbox
readonly TOOLBOX_URL="http://rgbd.cs.princeton.edu/data/SUNRGBDtoolbox.zip"

# other global variables
readonly SUNRGB_DIR="SUNRGB"

download_toolbox() {
	local zipfile="SUNRGBDtoolbox.zip"

	cd "$DATADIR/${SUNRGB_DIR}"

	# download everything:
	wget $TOOLBOX_URL -O $zipfile

	# extract everything:
	unzip $zipfile

	# delete tar files
	rm -f $zipfile

	cd -
}

download_dataset() {
	local zipfile="SUNRGB.zip"

	cd "$DATADIR/${SUNRGB_DIR}"

	# download everything:
	wget $DATASET_URL -O $zipfile

	# extract everything:
	unzip $zipfile

	# delete tar files
	rm -f $zipfile

	cd -
}

grant_access() {
	local dir=$0
	chmod -R 777 $dir
}

main() {
	echo
	echo "[${SCRIPT_NAME}] Downloading dataset..."
	mkdir -p "${DATADIR}/${SUNRGB_DIR}"
	download_dataset

	echo
	echo "[${SCRIPT_NAME}] Downloading toolbox..."
	download_toolbox

	# grant access to everyone; comment out if desired
	grant_access "${DATADIR}/${SUNRGB_DIR}"

	echo
	echo "[${SCRIPT_NAME}] Done."
}
main
