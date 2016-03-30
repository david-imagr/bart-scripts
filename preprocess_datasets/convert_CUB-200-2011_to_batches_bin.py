#!/usr/bin/env python
"""Convert CUB-200-2011 dataset to binary batches.

This script converts the dataset into the same format as the
CIFAR-10 dataset in binary version.
"""

import os
import csv
from PIL import Image
import numpy as np

# paths

# path to extracted folder downloaded from dataset website
DATA_ROOT = '/scratch/datasets/CUB-200-2011/CUB_200_2011'
IMAGES_DIR = os.path.join(DATA_ROOT, 'images/')
IMAGES_LIST_FILE = os.path.join(DATA_ROOT, 'images.txt')
TRAIN_TEST_SPLITS_FILE = os.path.join(DATA_ROOT, 'train_test_split.txt')

# path to output files
WRITE_PATH = '/scratch/datasets/CUB-200-2011/cub-200-2011-batches-bin'

# constants

DATA_BATCH_TEMPLATE = 'data_batch_{}.bin'
TEST_BATCH_TEMPLATE = 'test_batch_{}.bin'
# how many examples in each batch file
BATCH_MAX_SIZE = 1000

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

    def add(self, image, label, is_training):
        """Add an image to a binary batch file.

        Args:
            image: PIL image
            label: integer label
            is_training: bool indicating whether training example
        """
        # resize, crop and flatten
        image_resized = self._resize_crop_image(image)
        image_array = np.array(image_resized)
        image_flattened = self._flatten_image(image_array)

        # convert to byte array
        label_image = np.concatenate([np.array([label]), image_flattened])
        # label is 1 byte, image is 256x256x3 bytes
        byte_array = bytearray(label_image.tolist())

        if is_training:
            # write to file
            self.train_fh.write(byte_array)

            # check if need to break into another file
            self.train_counter += 1
            if self.train_counter >= BATCH_MAX_SIZE:
                print("Training batch {} done".format(self.train_current_batch))
                self.train_fh.close()
                self.train_current_batch += 1
                self.train_fh = open(os.path.join(WRITE_PATH,
                DATA_BATCH_TEMPLATE.format(self.train_current_batch)), 'wb')
                self.train_counter = 0
        else:
            # write to file
            self.test_fh.write(byte_array)

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
    # open images file
    images_list = []
    with open(IMAGES_LIST_FILE, 'r') as f:
        reader = csv.reader(f, delimiter=' ')
        for idx, file_name in reader:
            images_list.append(file_name)

    # open training file
    is_training_list = []
    with open(TRAIN_TEST_SPLITS_FILE, 'r') as f:
        reader = csv.reader(f, delimiter=' ')
        for idx, is_training in reader:
            is_training_list.append(bool(int(is_training)))

    # process
    batch_factory = BatchFactory()
    for file_name, is_training in zip(images_list, is_training_list):
        label = int(file_name[0:3])
        image = Image.open(os.path.join(IMAGES_DIR, file_name))
        batch_factory.add(image, label, is_training)
    batch_factory.finish()

if __name__ == '__main__':
    main()
