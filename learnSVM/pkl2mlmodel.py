# excute with Python 2.x
from generate_settings import (
    MODEL_NAME,
    COREML_MODEL_NAME,
)

from sklearn.externals import joblib

skmodel = joblib.load(MODEL_NAME + '.pkl')

import coremltools

coremlmodel = coremltools.converters.sklearn.convert(skmodel)

coremlmodel.save(COREML_MODEL_NAME + '.mlmodel')
