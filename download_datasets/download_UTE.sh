#!/bin/bash
# download script for UT Egocentric Dataset
# http://vision.cs.utexas.edu/projects/egocentric/download_register.html

# you can replace DATADIR with anything
# MAKE SURE YOU ARE NOT OVERWRITING SOMEONE ELSE'S DIRECTORY
readonly DATADIR="/scratch/datasets"

# other global variables
readonly SCRIPT_NAME=$0
readonly UTEDIR="UTE_video"

setup_script() {
	mkdir $DATADIR/$UTEDIR
}

download_ute() {
	local utezip="UTE_video.zip"

	cd $DATADIR/$UTEDIR

	# download everything:
	wget http://vision.cs.utexas.edu/projects/egocentric/download.php -O $utezip

	# extract everything:
	unzip $utezip

	# delete tar files
	rm -f $utezip

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
	echo "[${SCRIPT_NAME}] Downloading UT Egocentric Dataset..."
	download_ute

	# grant access to everyone; comment out if desired
	grant_access "${DATADIR}/${UTEDIR}"

	echo
	echo "[${SCRIPT_NAME}] Done."
}
main
