## HPC GPU

This is a sample submit script for the OSU HPC Cluster with GPU compute units. 
Simply `cd` to this directory and run `qsub submit-gpu.csh` to submit the 
script to the job scheduler. Make sure to change `/path/to/torch` to where 
torch is installed in `submit-gpu.csh`.

This only works on the OSU HPC Cluster. You also need access to the GPU compute units.
