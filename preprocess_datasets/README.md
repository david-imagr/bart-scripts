## Preprocess datasets
These are convenience scripts that preprocess datasets to 
another format.

### Usage
`cd` into this directory and run the appropriate script to
preprocess that dataset. Assumes the download scripts were run.

- `./convert_ILSVRC2015_to_batches_bin.py` converts  
[ILSVRC2015 (ImageNet)](http://www.image-net.org) dataset
to batches binary format like in CIFAR
- `./convert_CUB-200-2011_to_batches_bin.py` converts
[Caltech-UCSD Birds-200-2011 dataset](http://www.vision.caltech.edu/visipedia/CUB-200-2011.html) 
dataset to batches binary format like in CIFAR

### Contributions
Please feel free to add your own preprocess scripts for other datasets 
that you may find useful for others.
Please follow the conventions of the other scripts.
