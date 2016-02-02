#!/bin/bash
# download script for lsun

# you can replace DATADIR with anything
# MAKE SURE YOU ARE NOT OVERWRITING SOMEONE ELSE'S DIRECTORY
readonly DATADIR="/scratch/datasets"

# other global variables
readonly SCRIPT_NAME=$0
readonly LSUNDIR="lsun"
readonly PYTHON_BIN="/usr/bin/python2.7"

setup_script() {
	cd $DATADIR
	git clone https://github.com/fyu/lsun.git $LSUNDIR
	cd -
}

download_images() {
	cd $DATADIR/$LSUNDIR
	# download everything:
	${PYTHON_BIN} download.py -o $DATADIR/$LSUNDIR
	cd -
}

grant_access() {
	local dir=$0
	chmod -R 777 $dir
}

main() {
	echo
	echo "[${SCRIPT_NAME}] Setting up downloader script..."
	setup_script

	echo
	echo "[${SCRIPT_NAME}] Downloading images..."
	download_images

	# grant access to everyone; comment out if desired
	grant_access "${DATADIR}/${LSUNDIR}"

	echo
	echo "[${SCRIPT_NAME}] Done."
}
main
