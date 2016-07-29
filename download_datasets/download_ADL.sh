#!/bin/bash
# download script for Activities of Daily Living in First Person Camera Views (ADL)
# http://people.csail.mit.edu/hpirsiav/codes/ADLdataset/adl.html

# you can replace DATADIR with anything
# MAKE SURE YOU ARE NOT OVERWRITING SOMEONE ELSE'S DIRECTORY
readonly DATADIR="/scratch/datasets"

# other global variables
readonly SCRIPT_NAME=$0
readonly ADLDIR="ADL_video"

setup_script() {
	mkdir $DATADIR/$ADLDIR
}

download_adl() {
	local adl_base_url="http://people.csail.mit.edu/hpirsiav/codes/ADLdataset/ADL_videos"

	cd $DATADIR/$ADLDIR

	# download all videos:
	for i in $(seq -f "%02g" 1 20); do
		wget ${adl_base_url}/P_${i}.MP4
	done

	cd -
}

grant_access() {
	local dir=$0
	chmod -R 777 $dir
}

main() {
	echo
	echo "[${SCRIPT_NAME}] Setting up folders..."
	setup_script

	echo
	echo "[${SCRIPT_NAME}] Downloading ADL Dataset..."
	download_adl

	# grant access to everyone; comment out if desired
	grant_access "${DATADIR}/${ADLDIR}"

	echo
	echo "[${SCRIPT_NAME}] Done."
}
main
