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

### Activation
To activate Torch, add the following to your `~/.bashrc` (or `~/.cshrc`) file:

`. /scratch/software/torch7/install/bin/torch-activate`

If you installed it somewhere else, change the line appropriately.

After doing this and after restarting your shell, 
you should be able to run `th` to start the interpreter.
