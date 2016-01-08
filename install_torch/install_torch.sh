#!/bin/bash
# install script for Torch 7 for OSU computing server

# you can replace TORCHDIR with anything
# MAKE SURE YOU ARE NOT OVERWRITING SOMEONE ELSE'S DIRECTORY
readonly TORCHDIR=/scratch/software/torch7

# other global variables
readonly CUSTOMDIR=$TORCHDIR/custom
readonly THISDIR=`pwd`

install_torch() {
	# install torch
	git clone https://github.com/torch/distro.git $TORCHDIR --recursive
	cd $TORCHDIR
	# use a specific commit; comment out to use latest
	git reset --hard 019d85288f1a4d53efb2a097000bbe6550be595d
	./install.sh
	cd -
}

activate_torch() {
	# activate torch - only for this script's session
	. $TORCHDIR/install/bin/torch-activate
}

install_display() {
	local displayfolder='display'

	# install display package manually (luarocks install version is older)
	git clone https://github.com/szym/display.git $CUSTOMDIR/$displayfolder
	cd $CUSTOMDIR/$displayfolder
	# use a specific commit; comment out to use latest
	git reset --hard 87e680b2269d032dfcfe72a721e93ebb81fc9355
	luarocks make display-scm-0.rockspec
	cd -
}

install_libjpeg() {
	local libjpegfolder=$1
	local tarfile='jpegsrc.v9a.tar.gz'

	# install libjpeg manually
	wget http://www.ijg.org/files/jpegsrc.v9a.tar.gz -O $CUSTOMDIR/$tarfile
	tar -zxvf $CUSTOMDIR/$tarfile -C $CUSTOMDIR
	cd $CUSTOMDIR/$libjpegfolder
	./configure --prefix=$CUSTOMDIR/$libjpegfolder/build && make && make install
	cd -
}

apply_CMakeList_patch() {
	local imagefolder=$1
	local libjpegfolder=$2

	local jpeg_library=$CUSTOMDIR/$libjpegfolder/build/lib/libjpeg.so
	local jpeg_include_dir=$CUSTOMDIR/$libjpegfolder/build/include

	# overwrite CMakeLists.txt to use custom libjpeg installation
	rm -f $CUSTOMDIR/$imagefolder/CMakeLists.txt
	cp $THISDIR/CMakeLists.txt.patch $CUSTOMDIR/$imagefolder/CMakeLists.txt
	cd $CUSTOMDIR/$imagefolder
	sed "57s|.*|SET(JPEG_LIBRARY ${jpeg_library})|" CMakeLists.txt > tmp
	sed "58s|.*|SET(JPEG_INCLUDE_DIR ${jpeg_include_dir})|" tmp > CMakeLists.txt
	rm -f tmp
	cd -
}

install_image() {
	local imagefolder='image'
	local libjpegfolder='jpeg-9a'

	# install libjpeg as dependency for image package
	install_libjpeg $libjpegfolder

	# uninstall "corrupted" package
	luarocks remove --force image

	# reinstall image package manually
	git clone https://github.com/torch/image.git $CUSTOMDIR/$imagefolder
	cd $CUSTOMDIR/$imagefolder
	# use a specific commit; comment out to use latest
	git reset --hard 24b1e7ec2f4520302bd94e4139ab656b1ba633ab

	# patch CMakeList
	apply_CMakeList_patch $imagefolder $libjpegfolder

	# build and install
	luarocks make image-1.1.alpha-0.rockspec
	cd -
}

grant_all_access() {
	chmod -R 777 $TORCHDIR
}

main() {
	# install torch
	rm -rf $TORCHDIR
	mkdir -p $TORCHDIR
	install_torch
	activate_torch

	# install packages and dependencies
	mkdir -p $CUSTOMDIR
	install_display
	install_image
	luarocks install mobdebug

	# grant permission for everyone
	grant_all_access

	echo
	echo
	echo "Installation complete."
	echo "You will need to add the following to the end of your .bashrc or .cshrc script:"
	echo
	echo "	. ${TORCHDIR}/install/bin/torch-activate"
}
main
