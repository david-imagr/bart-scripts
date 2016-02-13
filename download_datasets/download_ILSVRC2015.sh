#!/bin/bash
# download script for ILSVRC2015 (ImageNet Challenge)

# you can replace DATADIR with anything
# MAKE SURE YOU ARE NOT OVERWRITING SOMEONE ELSE'S DIRECTORY
readonly DATADIR="/scratch/datasets"

# check command line arguments
readonly SCRIPT_NAME=$0
usage() {
	echo "usage: $SCRIPT_NAME DATASET_URL DEVKIT_URL"
	echo ""
	echo "Download ILSVRC2015 dataset (CLS-LOC) and devkit."
	echo "Two arguments are required:"
	echo -e "\t- DATASET_URL: URL to CLS-LOC dataset"
	echo -e "\t- DEVKIT_URL: URL to development kit"
}
if [ "$#" -ne 2 ]; then
	echo "Invalid number of arguments."
	usage
	exit 1
fi

# (MUST SPECIFY DOWNLOAD URLS YOURSELF SINCE IMAGENET DOWNLOAD IS NOT PUBLIC)
readonly DATASET_URL=$1
readonly DEVKIT_URL=$2

# other global variables
readonly ILSVRC2015DIR="ILSVRC2015"

download_devkit() {
	local tarfile="devkit.tar.gz"

	cd $DATADIR

	# download everything:
	wget $DEVKIT_URL -O $tarfile

	# extract everything:
	tar -zxvf $tarfile

	# delete tar files
	rm -f $tarfile

	cd -
}

download_dataset() {
	local tarfile="dataset.tar.gz"

	cd $DATADIR

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
	echo "[${SCRIPT_NAME}] Downloading development kit..."
	download_devkit

	echo
	echo "[${SCRIPT_NAME}] Downloading dataset..."
	download_dataset

	# grant access to everyone; comment out if desired
	grant_access "${DATADIR}/${ILSVRC2015DIR}"

	echo
	echo "[${SCRIPT_NAME}] Done."
}
main
