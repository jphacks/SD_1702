import keras
import pickle
from keras.applications.imagenet_utils import preprocess_input
from keras.preprocessing import image
from scipy.misc import imread, imresize
import numpy as np
import sys
sys.path.append("..")
from ssd import SSD300 as SSD
from ssd_utils import BBoxUtility


input_shape = (300,300,3)

prior_boxes_path = 'prior_boxes_ssd300.pkl'
weights_path = 'models/weights.08-0.58.hdf5'
recieved_image_path = 'image.png'

class_names = ['background','1m','2m','3m','4m','5m','6m','7m','8m','9m','1s','2s','3s','4s','5s','6s','7s','8s','9s','1p','2p','3p','4p','5p','6p','7p','8p','9p','ton','nan','sha','pe','haku','hatsu','chun']

id_dic = {'1m':0,'2m':1,'3m':2,'4m':3,'5m':4,'6m':5,'7m':6,'8m':7,'9m':8,'1p':9,'2p':10,'3p':11,'4p':12,'5p':13,'6p':14,'7p':15,'8p':16,'9p':17,'1s':18,'2s':19,'3s':20,'4s':21,'5s':22,'6s':23,'7s':24,'8s':25,'9s':26,'ton':27,'nan':28,'sha':29,'pe':30,'haku':31,'hatsu':32,'chun':33,}

NUM_CLASSES = len(class_names)

priors = pickle.load(open(prior_boxes_path, 'rb'))
bbox_util = BBoxUtility(NUM_CLASSES, priors)

# Change this if you run with other classes than VOC
model = SSD(input_shape, num_classes=NUM_CLASSES)

# Change this path if you want to use your own trained weights
model.load_weights(weights_path)

def predict(img_path):
    inputs = []
    images = []
    img = image.load_img(img_path, target_size=(300, 300))
    img = image.img_to_array(img)
    images.append(imread(img_path))
    inputs.append(img.copy())
    inputs = preprocess_input(np.array(inputs))

    preds = model.predict(inputs, batch_size=1, verbose=1)
    results = bbox_util.detection_out(preds)

    for i, img in enumerate(images):
        # Parse the outputs.
        det_label = results[i][:, 0]
        det_conf = results[i][:, 1]
        det_xmin = results[i][:, 2]
        det_ymin = results[i][:, 3]
        det_xmax = results[i][:, 4]
        det_ymax = results[i][:, 5]

        # Get detections with confidence higher than 0.6.
        top_indices = [i for i, conf in enumerate(det_conf) if conf >= 0.8]

        top_conf = det_conf[top_indices]
        top_label_indices = det_label[top_indices].tolist()
        top_xmin = det_xmin[top_indices]
        top_ymin = det_ymin[top_indices]
        top_xmax = det_xmax[top_indices]
        top_ymax = det_ymax[top_indices]

        hais = []
        for i in range(top_conf.shape[0]):
            xmin = int(round(top_xmin[i] * img.shape[1]))
            ymin = int(round(top_ymin[i] * img.shape[0]))
            xmax = int(round(top_xmax[i] * img.shape[1]))
            ymax = int(round(top_ymax[i] * img.shape[0]))
            score = top_conf[i]
            label = int(top_label_indices[i])
            class_name = class_names[label]
            #print(class_name)
            hais.append((class_name, xmin, label))
        hais.sort(key=lambda x: x[1])
        return hais


# Flask web server

from flask import Flask, request, jsonify

import base64

app = Flask(__name__)

@app.route('/', methods=['POST'])
def index():
    pngb64 = request.data
    
    # print(pngb64)
    print(' * recieved image')
    with open(recieved_image_path, 'wb') as f:
        print(' * saving image')
        f.write(base64.decodebytes(pngb64))

    print(' * start prediction')
    hais = predict(recieved_image_path)
    print(' * prediction result')
    #if len(hais) < 14 and len(hais) > 0:
        #print(' * could not find all 14 hais, but {} found.'.format(len(hais)))
        #dx = [hais[i + 1][1] - hais[i][1] for i in range(len(hais) - 1)]
        #insert_indicies = sorted([i for i in range(len(hais))], key=lambda x:dx[x], )

    prevx = -100
    hai_ids = []
    for i, hai in zip(range(len(hais)), hais):
        dx = hai[1] - prevx
        prevx = hai[1]
        ignore = False
        if dx < 10:
            ignore = True
        print('    [{}] {} {}'.format(i, hai, 'ignore' if ignore else ''))
        if not ignore:
            hai_ids.append(id_dic[hai[0]])
    
    if len(hai_ids) < 14 and len(hais) > 0:
        print(' * could not find all 14 hais, but {} found.'.format(len(hai_ids)))
        while len(hai_ids) < 14:
            hai_ids.append(31)
    
    #print(hais)
    return jsonify({
        'hais':hai_ids
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=80)

