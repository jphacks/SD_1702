# excute by python 2.x

from sklearn import cross_validation
from sklearn import svm
from sklearn import metrics
from sklearn.externals import joblib

import numpy as np

from generate_settings import (
    MODEL_NAME
)

FILE_NAME = 'mahjong_dataset'

# load dataset
data = np.load(FILE_NAME + '.npy')

np.random.shuffle(data)

#print(data)

DATA_SIZE = len(data)
TRAIN_SIZE_RATE = 0.9
TRAIN_SIZE = int(DATA_SIZE * TRAIN_SIZE_RATE)

print ' * %d examples loaded. train by %d / %d examples' % (DATA_SIZE, TRAIN_SIZE, DATA_SIZE)

#print(data)

# extract labels and features from dataset
labels, features = np.hsplit(data, [1])
labels = labels.astype('int')
labels = labels.flatten()


labels_train = labels[:TRAIN_SIZE]
features_train = features[:TRAIN_SIZE]
labels_test = labels[TRAIN_SIZE:]
features_test = features[TRAIN_SIZE:]

clf = svm.SVC(C=100, gamma=0.001)
clf.fit(features_train, labels_train)

model_file_name = MODEL_NAME + '.pkl'
joblib.dump(clf, model_file_name)
print 'saved model: ' + model_file_name

labels_pred_train = clf.predict(features_train)
labels_pred_test = clf.predict(features_test)

train_score = metrics.accuracy_score(labels_train, labels_pred_train)
test_score = metrics.accuracy_score(labels_test, labels_pred_test)

print 'train score: ' + str(train_score * 100) + ' %'
print 'test score: ' + str(test_score * 100) + ' %'
