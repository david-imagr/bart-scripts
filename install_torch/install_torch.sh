#!/bin/bash
# install script for Torch 7 for OSU computing server

# you can replace TORCHDIR with anything
# MAKE SURE YOU ARE NOT OVERWRITING SOMEONE ELSE'S DIRECTORY
readonly TORCHDIR=/scratch/software/torch7

# path to where cuda is installed
readonly CUDAPATH=/scratch/cuda

# other global variables
readonly CUSTOMDIR=$TORCHDIR/custom
readonly THISDIR=`pwd`

initialize_environment() {
	export LD_LIBRARY_PATH=$CUDAPATH/lib64:$LD_LIBRARY_PATH
	export PATH=$CUDAPATH/bin:$PATH
}

install_torch() {
	# install torch
	rm -rf $TORCHDIR
	mkdir -p $TORCHDIR
	git clone https://github.com/torch/distro.git $TORCHDIR --recursive
	cd $TORCHDIR
	# use a specific commit; comment out to use latest
	git reset --hard 019d85288f1a4d53efb2a097000bbe6550be595d
	./install.sh
	cd -
}

activate_torch() {
	# activate torch - only for this script's session
	if ! . $TORCHDIR/install/bin/torch-activate
	then
		echo "Unable to activate torch."
		exit 1
	fi
}

install_display() {
	local displayfolder='display'

	# install display package manually (luarocks install version is older)
	rm -rf $CUSTOMDIR/$displayfolder
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
	rm -rf $CUSTOMDIR/$libjpegfolder
	wget http://www.ijg.org/files/jpegsrc.v9a.tar.gz -O $CUSTOMDIR/$tarfile
	tar -zxvf $CUSTOMDIR/$tarfile -C $CUSTOMDIR
	cd $CUSTOMDIR/$libjpegfolder
	if ! ( ./configure --prefix=$CUSTOMDIR/$libjpegfolder/build && make && make install )
	then
		echo "Error encountered trying to install libjpeg"
		exit 1
	fi
	cd -
}

apply_CMakeList_patch() {
	local imagefolder=$1
	local libjpegfolder=$2
	local patchfile='CMakeLists.txt.patch'
	local build_dir=$CUSTOMDIR/$libjpegfolder/build

	# overwrite CMakeLists.txt to use custom libjpeg installation
	rm -f $CUSTOMDIR/$imagefolder/CMakeLists.txt
	echo "Applying CMakeLists patch for image package..."
	cp $THISDIR/$patchfile $CUSTOMDIR/$imagefolder/CMakeLists.txt
	cd $CUSTOMDIR/$imagefolder
	sed -i "s|INSERT_PREFIX_HERE|${build_dir}|" CMakeLists.txt
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
	rm -rf $CUSTOMDIR/$imagefolder
	git clone https://github.com/torch/image.git $CUSTOMDIR/$imagefolder
	cd $CUSTOMDIR/$imagefolder
	# use a specific commit; comment out to use latest
	git reset --hard 24b1e7ec2f4520302bd94e4139ab656b1ba633ab

	# patch CMakeList
	apply_CMakeList_patch $imagefolder $libjpegfolder

	# build and install
	if ! luarocks make image-1.1.alpha-0.rockspec
	then
		echo "Error encountered trying to install image"
		exit 1
	fi

	# run test
	th -e "require 'image'.test()"
	cd -
}

create_install_csh_file() {
	installdir=$TORCHDIR/install/bin
	activatefile=$installdir/torch-activate
	cshactivatefile=$installdir/torch-activate-csh

	if [ ! -f $activatefile ]
	then
		echo "torch-activate file not found!"
		echo "Torch probably did not install completely."
		exit 1
	fi

	rm -f $cshactivatefile
	cp $activatefile $installdir/tmp
	cd $installdir
	sed -i 's/export //g' tmp

	while read -r line
	do
		IFS='=' read -a lineAsArray <<< "$line"
		local variable=${lineAsArray[0]}
		local value=${lineAsArray[1]}

		IFS=':' read -a lineAsArray <<< "$value"
		local path=${lineAsArray[0]}
		local other=${lineAsArray[1]}

		if [ -z "$other" ]
		then
			echo "setenv ${variable} ${value}" >> $cshactivatefile
		else
			echo 'if (${?'"${variable}"'}) then' >> $cshactivatefile
			echo "	setenv ${variable} ${value}" >> $cshactivatefile
			echo 'else' >> $cshactivatefile
			echo "	setenv ${variable} ${path}" >> $cshactivatefile
			echo 'endif' >> $cshactivatefile
		fi
	done < tmp

	rm -f tmp
	cd -
}

grant_all_access() {
	chmod -R 777 $TORCHDIR
}

main() {
	# install torch
	initialize_environment
	install_torch
	create_install_csh_file
	activate_torch

	# install packages and dependencies
	mkdir -p $CUSTOMDIR
	install_image
	install_display
	luarocks install rnn
	luarocks install mobdebug

	# grant permission for everyone
	grant_all_access

	echo
	echo
	echo "Installation complete."
	echo "You will need to add the following to the end of your .bashrc script:"
	echo
	echo "	. ${TORCHDIR}/install/bin/torch-activate"
	echo
	echo "Or for .cshrc script:"
	echo
	echo "	source ${TORCHDIR}/install/bin/torch-activate-csh"
}
main
