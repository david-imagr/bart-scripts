#!/bin/bash
# download script for lsun

# you can replace DATADIR with anything
# MAKE SURE YOU ARE NOT OVERWRITING SOMEONE ELSE'S DIRECTORY
readonly DATADIR="/scratch/datasets"

# other global variables
readonly SCRIPT_NAME=$0
readonly LSUNDIR="lsun"
readonly PYTHON_BIN="python2.7"

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

extract_images() {
	local testset='test_lmdb.zip'
	local train_ext='_train_lmdb.zip'
	local val_ext='_val_lmdb.zip'
	local bedroom='bedroom'
	local bridge='bridge'
	local church_outdoor='church_outdoor'
	local classroom='classroom'
	local conference_room='conference_room'
	local dining_room='dining_room'
	local kitchen='kitchen'
	local living_room='living_room'
	local restaurant='restaurant'
	local tower='tower'

	cd $DATADIR/$LSUNDIR

	unzip "${bedroom}${train_ext}" && rm -f "${bedroom}${train_ext}"
	unzip "${bridge}${train_ext}" && rm -f "${bridge}${train_ext}"
	unzip "${church_outdoor}${train_ext}" && rm -f "${church_outdoor}${train_ext}"
	unzip "${classroom}${train_ext}" && rm -f "${classroom}${train_ext}"
	unzip "${conference_room}${train_ext}" && rm -f "${conference_room}${train_ext}"
	unzip "${dining_room}${train_ext}" && rm -f "${dining_room}${train_ext}"
	unzip "${kitchen}${train_ext}" && rm -f "${kitchen}${train_ext}"
	unzip "${living_room}${train_ext}" && rm -f "${living_room}${train_ext}"
	unzip "${restaurant}${train_ext}" && rm -f "${restaurant}${train_ext}"
	unzip "${tower}${train_ext}" && rm -f "${tower}${train_ext}"

	unzip "${bedroom}${val_ext}" && rm -f "${bedroom}${val_ext}"
	unzip "${bridge}${val_ext}" && rm -f "${bridge}${val_ext}"
	unzip "${church_outdoor}${val_ext}" && rm -f "${church_outdoor}${val_ext}"
	unzip "${classroom}${val_ext}" && rm -f "${classroom}${val_ext}"
	unzip "${conference_room}${val_ext}" && rm -f "${conference_room}${val_ext}"
	unzip "${dining_room}${val_ext}" && rm -f "${dining_room}${val_ext}"
	unzip "${kitchen}${val_ext}" && rm -f "${kitchen}${val_ext}"
	unzip "${living_room}${val_ext}" && rm -f "${living_room}${val_ext}"
	unzip "${restaurant}${val_ext}" && rm -f "${restaurant}${val_ext}"
	unzip "${tower}${val_ext}" && rm -f "${tower}${val_ext}"

	unzip "${testset}" && rm -f "${testset}"

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

	echo
	echo "[${SCRIPT_NAME}] Extracting images..."
	extract_images

	# grant access to everyone; comment out if desired
	grant_access "${DATADIR}/${LSUNDIR}"

	echo
	echo "[${SCRIPT_NAME}] Done."
}
main
