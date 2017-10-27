import cv2
import sys
import glob
import os
import os.path
import random
import numpy as np

from generate_settings import (
    GENERATE_PAR_IMAGE,
    GENERATED_IMAGE_WIDTH,
    GENERATED_IMAGE_HEIGHT,
    RANDOMIZE_RADIUS,
    OUTPUT_DIR,
)

dic = {
    "1m":0,
    "2m":1,
    "3m":2,
    "4m":3,
    "5m":4,
    "6m":5,
    "7m":6,
    "8m":7,
    "9m":8,
    "1p":9,
    "2p":10,
    "3p":11,
    "4p":12,
    "5p":13,
    "6p":14,
    "7p":15,
    "8p":16,
    "9p":17,
    "1s":18,
    "2s":19,
    "3s":20,
    "4s":21,
    "5s":22,
    "6s":23,
    "7s":24,
    "8s":25,
    "9s":26,
    "1z":27,
    "2z":28,
    "3z":29,
    "4z":30,
    "5z":31,
    "6z":32,
    "7z":33,
}

def main(dirpath):
    absdirpath = os.path.abspath(dirpath)
    files = os.listdir(absdirpath + '/')
    jpgfiles = []
    for fp in files:
        if fp[-4:] == '.JPG':
            jpgfiles.append(fp)
    
    count = len(jpgfiles)
    print(' * [{}] .jpg files detected. generate [{}] images.'.format(count, count * 2 * GENERATE_PAR_IMAGE))

    outarray = np.empty((0,GENERATED_IMAGE_HEIGHT * GENERATED_IMAGE_WIDTH + 1), int)
    # print(outarray.shape)

    for jpgfile in jpgfiles:
        jpgpath = dirpath + '/' + jpgfile
        print(' * {}'.format(jpgpath))

        tag = jpgfile[:2]
        if tag not in dic:
            print(' * unknown label: {}'.format(tag))
        label = dic[tag]

        image = cv2.imread(jpgpath)

        index = 0
        inv = ''
        for _ in range(2):

            for index in range(GENERATE_PAR_IMAGE):
                generated_image = generate(image)
                outjpgname = '{}_{}{}.JPG'.format(jpgfile[:-4], index, inv)
                outjpgpath = os.path.join(OUTPUT_DIR, outjpgname)
                cv2.imwrite(outjpgpath, generated_image)

                array = np.append([label], generated_image.flatten().copy() // 255) 
                # print(array.shape)
                outarray = np.append(outarray, [array], axis=0)
        
            # inverse image
            image = cv2.flip(image, -1)
            index = 0
            inv = 'inv'

        #print(outarray)
        #print(outarray.shape)
        #input()

    
    np.save('mahjong_dataset', outarray)

def generate(image):

    size = tuple(np.array([image.shape[1], image.shape[0]]))

    width = size[0]
    height = size[1]

    rands = [random.randint(- RANDOMIZE_RADIUS, RANDOMIZE_RADIUS) for _ in range(8)]

    src_prs = np.float32(
        [
            [0 + rands[0], 0 + rands[1]],
            [width + rands[2], 0 + rands[3]],
            [width + rands[4], height + rands[5]],
            [0 + rands[6], height + rands[7]]
        ]
    )
    
    dst_prs = np.float32(
        [
            [0, 0],
            [GENERATED_IMAGE_WIDTH, 0],
            [GENERATED_IMAGE_WIDTH, GENERATED_IMAGE_HEIGHT],
            [0, GENERATED_IMAGE_HEIGHT]
        ]
    )

    transform = cv2.getPerspectiveTransform(src_prs, dst_prs)

    outsize = tuple([GENERATED_IMAGE_WIDTH, GENERATED_IMAGE_HEIGHT])

    randomized = cv2.warpPerspective(image, transform, size, borderMode=cv2.BORDER_CONSTANT, borderValue=(255, 255, 255))
    randomized = randomized[0:GENERATED_IMAGE_HEIGHT, 0:GENERATED_IMAGE_WIDTH]

    randomized = cv2.cvtColor(randomized, cv2.COLOR_RGBA2GRAY)
    ret, thres = cv2.threshold(randomized,0,255,cv2.THRESH_BINARY_INV+cv2.THRESH_OTSU)

    return thres

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print(' * please specify target image')
    else:
        dirpath = sys.argv[1]
        if (os.path.isfile(dirpath)):
            print(' * {} is not directory'.format(dirpath))
        if not os.path.exists(OUTPUT_DIR):
            os.mkdir(OUTPUT_DIR)
        
        main(dirpath)