## Download datasets
These are convenience scripts that does all the downloading and
unpacking of various datasets. It is primarily useful when
the server needs to be wiped clean and datasets have to be
installed again.

### Usage
`cd` into this directory and run the appropriate script to
download that dataset.

- `./download_cifar.sh` downloads
[CIFAR-10 and CIFAR-100](https://www.cs.toronto.edu/~kriz/cifar.html).
- `./download_coco.sh` downloads
[MS COCO dataset](http://mscoco.org/).
- `./download_ILSVRC2015.sh DATASET_URL DEVKIT_URL` downloads
[ILSVRC2015 (ImageNet)](http://www.image-net.org) dataset
and development kit for image classification.
- `./download_lsun.sh` downloads
[LSUN scene classification dataset](http://lsun.cs.princeton.edu/#classification).
- `./download_CUB-200-2011.sh` downloads
[Caltech-UCSD Birds-200-2011 dataset](http://www.vision.caltech.edu/visipedia/CUB-200-2011.html)
- `./download_SUNRGB.sh` downloads
[SUN RGB-D dataset](http://rgbd.cs.princeton.edu/)
- `./download_UTE.sh` downloads
[UT Egocentric dataset](http://vision.cs.utexas.edu/projects/egocentric/download_register.html)

### Contributions
Please feel free to add your own download scripts for other datasets.
Please follow the conventions of the other scripts.
