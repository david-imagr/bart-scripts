## Installing Torch
The script `install_torch.sh` automatically installs Torch. 
It also installs some useful packages. 
Most importantly, it fixes the "corrupted" preinstalled image 
package by reinstalling with the correct libjpeg library.

Torch should be already installed on the OSU computing server. 
In case it gets deleted, this script can reinstall it.

### Usage
`cd` into this directory and run `./install_torch.sh` and that's it. 
Change the `TORCHDIR` variable to another location if you want to 
install for yourself for example.
