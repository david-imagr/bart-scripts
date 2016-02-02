#!/bin/bash
# download script for coco

# you can replace DATADIR with anything
# MAKE SURE YOU ARE NOT OVERWRITING SOMEONE ELSE'S DIRECTORY
readonly DATADIR="/scratch/datasets"

# other global variables
readonly SCRIPT_NAME=$0
readonly COCODIR="coco"
readonly IMAGESDIR="images"
readonly ANNOTATIONSDIR="annotations"
readonly VIRTUALENV_DIR="venv"
readonly PYTHON_BIN="/usr/bin/python2.7"

create_virtualenv() {
	cd $DATADIR/$COCODIR
	virtualenv --no-site-packages -p $PYTHON_BIN $VIRTUALENV_DIR
	cd -
}

install_python_dependencies() {
	pip install Cython
	pip install numpy
}

download_script() {
	cd $DATADIR
	git clone https://github.com/pdollar/coco.git $COCODIR
	cd -
}

setup_script() {
	cd $DATADIR/$COCODIR/PythonAPI
	python setup.py build_ext --inplace
	cd -
}

download_images() {
	local train2014=train2014
	local val2014=val2014
	local test2014=test2014
	local test2015=test2015

	mkdir -p $DATADIR/$COCODIR/$IMAGESDIR
	cd $DATADIR/$COCODIR/$IMAGESDIR

	# download files
	wget http://msvocds.blob.core.windows.net/coco2014/train2014.zip -O ${train2014}.zip
	wget http://msvocds.blob.core.windows.net/coco2014/val2014.zip -O ${val2014}.zip
	wget http://msvocds.blob.core.windows.net/coco2014/test2014.zip -O ${test2014}.zip
	wget http://msvocds.blob.core.windows.net/coco2015/test2015.zip -O ${test2015}.zip

	# extract files
	unzip ${train2014}.zip
	unzip ${val2014}.zip
	unzip ${test2014}.zip
	unzip ${test2015}.zip

	# remove files
	rm -f ${train2014}.zip
	rm -f ${val2014}.zip
	rm -f ${test2014}.zip
	rm -f ${test2015}.zip

	cd -
}

download_annotations() {
	local instances_train_val2014=instances_train-val2014
	local captions_train_val2014=captions_train-val2014
	local image_info_test2014=image_info_test2014
	local image_info_test2015=image_info_test2015

	mkdir -p $DATADIR/$COCODIR/$ANNOTATIONSDIR
	cd $DATADIR/$COCODIR

	# download files
	wget http://msvocds.blob.core.windows.net/annotations-1-0-3/instances_train-val2014.zip -O ${instances_train_val2014}.zip
	wget http://msvocds.blob.core.windows.net/annotations-1-0-3/captions_train-val2014.zip -O ${captions_train_val2014}.zip
	wget http://msvocds.blob.core.windows.net/annotations-1-0-4/image_info_test2014.zip -O ${image_info_test2014}.zip
	wget http://msvocds.blob.core.windows.net/annotations-1-0-4/image_info_test2015.zip -O ${image_info_test2015}.zip

	# extract files
	unzip ${instances_train_val2014}.zip
	unzip ${captions_train_val2014}.zip
	unzip ${image_info_test2014}.zip
	unzip ${image_info_test2015}.zip

	# remove files
	rm -f ${instances_train_val2014}.zip
	rm -f ${captions_train_val2014}.zip
	rm -f ${image_info_test2014}.zip
	rm -f ${image_info_test2015}.zip

	cd -
}

grant_access() {
	local dir=$0
	chmod -R 777 $dir
}

main() {
	# download coco script
	echo
	echo "[${SCRIPT_NAME}] Downloading coco tools..."
	download_script

	# create and activate virtual environment
	echo
	echo "[${SCRIPT_NAME}] Creating virtual environment to install coco tools..."
	create_virtualenv
	source $DATADIR/$COCODIR/$VIRTUALENV_DIR/bin/activate

	# install dependencies
	install_python_dependencies

	# set up Python
	echo
	echo "[${SCRIPT_NAME}] Setting up coco tools..."
	setup_script
	deactivate

	# download images and annotations
	echo
	echo "[${SCRIPT_NAME}] Downloading images..."
	download_images

	echo
	echo "[${SCRIPT_NAME}] Downloading annotations..."
	download_annotations

	# grant access to everyone; comment out if desired 
	grant_access "${DATADIR}/${COCODIR}"

	echo
	echo "[${SCRIPT_NAME}] Done."
}
main
