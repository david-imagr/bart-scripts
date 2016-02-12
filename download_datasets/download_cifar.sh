#!/bin/bash
# download script for cifar

# you can replace DATADIR with anything
# MAKE SURE YOU ARE NOT OVERWRITING SOMEONE ELSE'S DIRECTORY
readonly DATADIR="/scratch/datasets"

# other global variables
readonly SCRIPT_NAME=$0
readonly CIFAR10DIR="cifar-10"
readonly CIFAR100DIR="cifar-100"

setup_script() {
	mkdir $DATADIR/$CIFAR10DIR
	mkdir $DATADIR/$CIFAR100DIR
}

download_cifar10() {
	local pythontar="cifar-10-python.tar.gz"
	local matlabtar="cifar-10-matlab.tar.gz"
	local binarytar="cifar-10-binary.tar.gz"

	cd $DATADIR/$CIFAR10DIR

	# download everything:
	wget https://www.cs.toronto.edu/~kriz/cifar-10-python.tar.gz -O $pythontar
	wget https://www.cs.toronto.edu/~kriz/cifar-10-matlab.tar.gz -O $matlabtar
	wget https://www.cs.toronto.edu/~kriz/cifar-10-binary.tar.gz -O $binarytar

	# extract everything:
	tar -zxvf $pythontar
	tar -zxvf $matlabtar
	tar -zxvf $binarytar

	# delete tar files
	rm -f $pythontar
	rm -f $matlabtar
	rm -f $binarytar

	cd -
}

download_cifar100() {
	local pythontar="cifar-100-python.tar.gz"
	local matlabtar="cifar-100-matlab.tar.gz"
	local binarytar="cifar-100-binary.tar.gz"

	cd $DATADIR/$CIFAR100DIR

	# download everything:
	wget https://www.cs.toronto.edu/~kriz/cifar-100-python.tar.gz -O $pythontar
	wget https://www.cs.toronto.edu/~kriz/cifar-100-matlab.tar.gz -O $matlabtar
	wget https://www.cs.toronto.edu/~kriz/cifar-100-binary.tar.gz -O $binarytar

	# extract everything:
	tar -zxvf $pythontar
	tar -zxvf $matlabtar
	tar -zxvf $binarytar

	# delete tar files
	rm -f $pythontar
	rm -f $matlabtar
	rm -f $binarytar

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
	echo "[${SCRIPT_NAME}] Downloading cifar-10..."
	download_cifar10

	echo
	echo "[${SCRIPT_NAME}] Downloading cifar-100..."
	download_cifar100

	# grant access to everyone; comment out if desired
	grant_access "${DATADIR}/${CIFAR10DIR}"
	grant_access "${DATADIR}/${CIFAR100DIR}"

	echo
	echo "[${SCRIPT_NAME}] Done."
}
main
