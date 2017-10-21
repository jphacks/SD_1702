//
//  Recognizer.swift
//  JongHelper
//
//  Created by Ryu Wakimoto on 2017/10/22.
//  Copyright © 2017年 tomato. All rights reserved.
//

import Foundation
import CoreML

class Recognizer {
    let model = CoreMLHaiClassifier()
    
    func recognize (feature : NSArray) -> Int{
        guard let array = try? MLMultiArray.init(shape: [1260], dataType: MLMultiArrayDataType.double) else {
            print("failed: create MLMultiArray")
            return -1
        }
        
        for (index, element) in feature.enumerated() {
            array[index] = element as! NSNumber
        }
        
        guard let result = try? model.prediction(input: array) else {
            print("failed: prediction")
            return -1
        }
        
        if let label = result.featureValue(for: "classLabel")?.int64Value {
            return Int(label)
        } else {
            return -1
        }
    }
}
