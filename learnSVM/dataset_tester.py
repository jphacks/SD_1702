import numpy as np

from generate_settings import (
    GENERATE_PAR_IMAGE,
    GENERATED_IMAGE_WIDTH,
    GENERATED_IMAGE_HEIGHT,
    RANDOMIZE_RADIUS,
    OUTPUT_DIR,
)

dic = [
    "1m",
    "2m",
    "3m",
    "4m",
    "5m",
    "6m",
    "7m",
    "8m",
    "9m",
    "1p",
    "2p",
    "3p",
    "4p",
    "5p",
    "6p",
    "7p",
    "8p",
    "9p",
    "1s",
    "2s",
    "3s",
    "4s",
    "5s",
    "6s",
    "7s",
    "8s",
    "9s",
    "1z",
    "2z",
    "3z",
    "4z",
    "5z",
    "6z",
    "7z",
]

data = np.load('mahjong_dataset.npy')

labels, features = np.hsplit(data, [1])
labels = labels.flatten()

datasize = len(labels)

for i in range(datasize):
    label = int(labels[i])
    print(' * {} - th data: {} ({})'.format(i, label, dic[label]))
    feature = features[i]
    feature = feature.reshape(GENERATED_IMAGE_HEIGHT, GENERATED_IMAGE_WIDTH)
    for row in feature:
        for pixel in row:
            print('*' if pixel > 0.5 else '.', end='')
            if pixel > 1:
                raise Exception('not normalized')
        print()
    
    # input(' * press any key to next data')