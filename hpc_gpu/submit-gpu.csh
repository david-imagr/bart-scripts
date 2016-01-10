#!/bin/csh

# use current working directory for input and output
# default is to use the users home directory
#$ -cwd

# name this job
#$ -N Torch-Example

# send stdout and stderror to this file
#$ -o torch-example.out
#$ -j y

# select queue - if needed 
#$ -q gpu

# activate Torch
setenv torchpath /scratch/cluster-share/lamm-gpu/software/torch
source $torchpath/install/bin/torch-activate-csh

# see where the job is being run
hostname

# print date and time
date

# print out luarocks list
luarocks list

echo "Torch-Test"

# run torch script
echo "===================="
th th_script.lua
echo "===================="

# print date and time again
date
