//
//  OpenCVWrapper.h
//  JongHelper
//
//  Created by Satoshi Kobayashi on 2017/10/21.
//  Copyright © 2017年 tomato. All rights reserved.
//

#ifndef Open_h
#define Open_h

#import <UIKit/UIKit.h>

@interface OpenCVWrapper: NSObject
- (NSArray *) getFeatures:(UIImage *)image;
- (NSArray *) getTehaiArray:(UIImage *)image;
- (UIImage *) filter:(UIImage *)image;
@end

#endif /* Open_h */
