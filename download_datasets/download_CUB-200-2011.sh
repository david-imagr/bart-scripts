#!/bin/bash
# download script for CUB-200-2011 (Caltech-UCSD Birds-200-2011)

# you can replace DATADIR with anything
# MAKE SURE YOU ARE NOT OVERWRITING SOMEONE ELSE'S DIRECTORY
readonly DATADIR="/scratch/datasets"

# other global variables
readonly SCRIPT_NAME=$0

# url to all images and annotations (1.1 GB)
readonly DATASET_URL="http://www.vision.caltech.edu/visipedia-data/CUB-200-2011/CUB_200_2011.tgz"
# url to segmentations (37 MB)
readonly SEGMENTATIONS_URL="http://www.vision.caltech.edu/visipedia-data/CUB-200-2011/segmentations.tgz"

# other global variables
readonly CUB_200_2011_DIR="CUB-200-2011"

download_segmentations() {
	local tarfile="segmentations.tgz"

	cd "$DATADIR/${CUB_200_2011_DIR}"

	# download everything:
	wget $SEGMENTATIONS_URL -O $tarfile

	# extract everything:
	tar -zxvf $tarfile

	# delete tar files
	rm -f $tarfile

	cd -
}

download_dataset() {
	local tarfile="CUB_200_2011.tgz"

	cd "$DATADIR/${CUB_200_2011_DIR}"

	# download everything:
	wget $DATASET_URL -O $tarfile

	# extract everything:
	tar -zxvf $tarfile

	# delete tar files
	rm -f $tarfile

	cd -
}

grant_access() {
	local dir=$0
	chmod -R 777 $dir
}

main() {
	echo
	echo "[${SCRIPT_NAME}] Downloading dataset..."
	mkdir -p "${DATADIR}/${CUB_200_2011_DIR}"
	download_dataset

	echo
	echo "[${SCRIPT_NAME}] Downloading segmentations..."
	download_segmentations

	# grant access to everyone; comment out if desired
	grant_access "${DATADIR}/${CUB_200_2011_DIR}"

	echo
	echo "[${SCRIPT_NAME}] Done."
}
main
