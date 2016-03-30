#!/usr/bin/env python
"""Convert ImageNet dataset to binary batches.

This script converts the dataset into the same format as the
CIFAR-10 dataset in binary version.
"""

import os
import csv
from PIL import Image
import numpy as np
import struct

# paths

# path to extracted folder downloaded from dataset website
DATA_ROOT = '/scratch/datasets/ILSVRC2015'

TRAIN_IMAGES_DIR = os.path.join(DATA_ROOT, 'Data/CLS-LOC/train')
TRAIN_IMAGES_LIST_FILE = os.path.join(DATA_ROOT,
'ImageSets/CLS-LOC/train_cls.txt')

VAL_IMAGES_DIR = os.path.join(DATA_ROOT, 'Data/CLS-LOC/val')
VAL_IMAGES_LIST_FILE = os.path.join(DATA_ROOT, 'ImageSets/CLS-LOC/val.txt')
VAL_GROUNDTRUTH_FILE = os.path.join(DATA_ROOT,
'devkit/data/ILSVRC2015_clsloc_validation_ground_truth.txt')

GROUNDTRUTH_MAP_FILE = os.path.join(DATA_ROOT, 'devkit/data/map_clsloc.txt')

# path to output files
WRITE_PATH = '/scratch/datasets/ILSVRC2015/ilsvrc2015-batches-bin'

# constants

DATA_BATCH_TEMPLATE = 'data_batch_{}.bin'
TEST_BATCH_TEMPLATE = 'test_batch_{}.bin'
# how many examples in each batch file
BATCH_MAX_SIZE = 50000

# helper classes

class BatchFactory:
    """Manage creation of batch files.
    """
    def __init__(self):
        self.train_current_batch = 1
        self.train_counter = 0
        self.test_current_batch = 1
        self.test_counter = 0

        self.train_fh = open(os.path.join(WRITE_PATH,
        DATA_BATCH_TEMPLATE.format(self.train_current_batch)), 'wb')
        self.test_fh = open(os.path.join(WRITE_PATH,
        TEST_BATCH_TEMPLATE.format(self.test_current_batch)), 'wb')

    def add_training(self, image, label):
        """Add an image to a binary batch file.

        Args:
            image: PIL image
            label: integer label
        """
        # convert to byte array
        # label is 2 bytes
        label_byte_array = self._preprocess_image(image)
        # image is 256x256x3 bytes
        image_byte_array = self._preprocess_label(label)

        # write to file
        self.train_fh.write(label_byte_array)
        self.train_fh.write(image_byte_array)

        # check if need to break into another file
        self.train_counter += 1
        if self.train_counter >= BATCH_MAX_SIZE:
            print("Training batch {} done".format(self.train_current_batch))
            self.train_fh.close()
            self.train_current_batch += 1
            self.train_fh = open(os.path.join(WRITE_PATH,
            DATA_BATCH_TEMPLATE.format(self.train_current_batch)), 'wb')
            self.train_counter = 0

    def add_val(self, image, label):
        """Add an image to a binary batch file.

        Args:
            image: PIL image
            label: integer label
        """
        # convert to byte array
        # label is 2 bytes
        label_byte_array = self._preprocess_image(image)
        # image is 256x256x3 bytes
        image_byte_array = self._preprocess_label(label)

        # write to file
        self.test_fh.write(label_byte_array)
        self.test_fh.write(image_byte_array)

        # check if need to break into another file
        self.test_counter += 1
        if self.test_counter >= BATCH_MAX_SIZE:
            print("Test batch {} done".format(self.test_current_batch))
            self.test_fh.close()
            self.test_current_batch += 1
            self.test_fh = open(os.path.join(WRITE_PATH,
            TEST_BATCH_TEMPLATE.format(self.test_current_batch)), 'wb')
            self.test_counter = 0

    def finish(self):
        """Clean up when done.
        """
        # close file handlers
        self.train_fh.close()
        self.test_fh.close()

    def _preprocess_image(self, image):
        # resize, crop and flatten
        image_resized = self._resize_crop_image(image)
        image_array = np.array(image_resized)
        image_flattened = self._flatten_image(image_array)

        # convert to byte array
        image_byte_array = bytearray(image_flattened.tolist())
        return image_byte_array

    def _preprocess_label(self, label):
        # convert to byte array
        label_byte_array = bytearray(struct.pack('>H', label))
        return label_byte_array

    def _flatten_image(self, image_array):
        """Flatten image to 1-dimensional array.

        Args:
            image_array: HxWx3 (or HxW grayscale) numpy array

        Returns:
            1-dimensional numpy array
        """
        height = image_array.shape[0]
        width = image_array.shape[1]
        # check if grayscale or RGB
        if image_array.size < width*height*3:
            image_flattened = np.concatenate([image_array.flatten(),
            image_array.flatten(), image_array.flatten()])
        else:
            image_flattened = np.concatenate([image_array[:,:,0].flatten(),
            image_array[:,:,1].flatten(), image_array[:,:,2].flatten()])
        assert(image_flattened.size == width*height*3)

        return image_flattened

    def _resize_crop_image(self, image, width=256, height=256):
        """Resize and center crop image to width and height.

        Args:
            image: PIL image
            width: width to crop
            height: height to crop

        Returns:
            PIL image resized and cropped
        """
        # current ratio
        image_ratio = 1.*image.size[0] / image.size[1]
        # desired ratio
        desired_ratio = 1.*width / height
        # image is scaled/cropped vertically or horizontally depending on the ratio
        if desired_ratio > image_ratio:
            image = image.resize((width, width * image.size[1] / image.size[0]),
                Image.ANTIALIAS)
            box = (0, (image.size[1] - height) / 2, image.size[0], (image.size[1] + height) / 2)
            image = image.crop(box)
        elif desired_ratio < image_ratio:
            image = image.resize((height * image.size[0] / image.size[1], height),
                Image.ANTIALIAS)
            box = ((image.size[0] - width) / 2, 0, (image.size[0] + width) / 2, image.size[1])
            image = image.crop(box)
        else:
            image = image.resize((width, height),
                Image.ANTIALIAS)

        return image

# main script

def main():
    # open map file
    label_map = {}
    with open(GROUNDTRUTH_MAP_FILE, 'r') as f:
        reader = csv.reader(f, delimiter=' ')
        for file_name, idnum, description in reader:
            label_map[file_name] = int(idnum)

    # open train images file
    train_images_list = []
    with open(TRAIN_IMAGES_LIST_FILE, 'r') as f:
        reader = csv.reader(f, delimiter=' ')
        for file_name, idx in reader:
            train_images_list.append(file_name)

    # open val images file
    val_images_list = []
    with open(VAL_IMAGES_LIST_FILE, 'r') as f:
        reader = csv.reader(f, delimiter=' ')
        for file_name, idx in reader:
            val_images_list.append(file_name)

    # open val groundtruth file
    val_groundtruth_list = []
    with open(VAL_GROUNDTRUTH_FILE, 'r') as f:
        reader = csv.reader(f, delimiter=' ')
        for [idnum] in reader:
            val_groundtruth_list.append(int(idnum))

    batch_factory = BatchFactory()

    # process training images
    for file_name in train_images_list:
        (label_name, _) = file_name.split('/')
        label = label_map[label_name]
        image = Image.open(os.path.join(TRAIN_IMAGES_DIR, file_name + '.JPEG'))
        batch_factory.add_training(image, label)

    # process val images
    for file_name, label in zip(val_images_list, val_groundtruth_list):
        image = Image.open(os.path.join(VAL_IMAGES_DIR, file_name + '.JPEG'))
        batch_factory.add_val(image, label)

    batch_factory.finish()

if __name__ == '__main__':
    main()
