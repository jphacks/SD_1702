//
//  OpenCVWrapper.mm
//  JongHelper
//
//  Created by Satoshi Kobayashi on 2017/10/21.
//  Copyright © 2017年 tomato. All rights reserved.
//

#import <opencv2/opencv.hpp>
#import <opencv2/imgcodecs/ios.h>

#import "OpenCVWrapper.h"

@implementation OpenCVWrapper

static std::vector<cv::Mat> templates;
static std::vector<std::vector<cv::KeyPoint>> templatesKeypoints;
static std::vector<cv::Mat> templatesDescripters;
const auto AKAZE = cv::AKAZE::create();

static const double TEHAI_ASPECT_RATIO = 2 * 14 / 2.7;
static const double TRIM_ASPECT_RATIO = 8;
static const double THRESH_WIDTH = 0.6;
static const int THRESH_CANNY_LOW = 30;
static const int THRESH_CANNY_HIGH = 150;
static const int TEMPLATE_WIDTH = 200;
static const int TEMPLATE_HEIGHT = 270;
static const int ANGLE_SEARCH_SIZE = 10;
static const int ANGLE_SEARCH_STEP = 0.1;
static const int ANGLE_SEARCH_CANNY_LOW = 10;
static const int ANGLE_SEARCH_CANNY_HIGH = 200;
static const int ANGLE_SEARCH_WIDTH = 3;


static const int TARGET_WIDTH = 30;
static const int TARGET_HEIGHT = 42;

static const int PADDING_TOP = 3;
static const int PADDING_BOTTOM = 3;
static const int PADDING_LEFT = 3;
static const int PADDING_RIGHT = 3;

cv::Point2f gCornerQuad[4];

static cv::Mat loadMatFromFile(NSString *fileName)
{
    NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
    NSString *path = [resourcePath stringByAppendingPathComponent:fileName];
    const char *pathChars = [path UTF8String];
    return cv::imread(pathChars);
}

- (id) init {
    if (self = [super init]) {
        /*
        templates.push_back(loadMatFromFile(@"templates/manzu/1m.JPG")); // 1 2m 8m
        templates.push_back(loadMatFromFile(@"templates/manzu/2m.JPG")); // 3 8m
        templates.push_back(loadMatFromFile(@"templates/manzu/3m.JPG")); // 1 2m
        templates.push_back(loadMatFromFile(@"templates/manzu/4m.JPG")); // 4
        templates.push_back(loadMatFromFile(@"templates/manzu/5m.JPG")); // 3 2m
        templates.push_back(loadMatFromFile(@"templates/manzu/6m.JPG")); // 5
        templates.push_back(loadMatFromFile(@"templates/manzu/7m.JPG")); // 3 2m
        templates.push_back(loadMatFromFile(@"templates/manzu/8m.JPG")); // 1 2m
        templates.push_back(loadMatFromFile(@"templates/manzu/9m.JPG")); // 1 2m
        
        templates.push_back(loadMatFromFile(@"templates/pinzu/1p.JPG")); // 4 2p
        templates.push_back(loadMatFromFile(@"templates/pinzu/2p.JPG")); // 3 3p
        templates.push_back(loadMatFromFile(@"templates/pinzu/3p.JPG")); // 5
        templates.push_back(loadMatFromFile(@"templates/pinzu/4p.JPG")); // 4 3p
        templates.push_back(loadMatFromFile(@"templates/pinzu/5p.JPG")); // 3 3p
        templates.push_back(loadMatFromFile(@"templates/pinzu/6p.JPG")); // 4 3p
        templates.push_back(loadMatFromFile(@"templates/pinzu/7p.JPG")); // 4 9p
        templates.push_back(loadMatFromFile(@"templates/pinzu/8p.JPG")); // 3 2p
        templates.push_back(loadMatFromFile(@"templates/pinzu/9p.JPG")); // 5 9p
        
        templates.push_back(loadMatFromFile(@"templates/souzu/1s.JPG")); // 2 2p 3p
        templates.push_back(loadMatFromFile(@"templates/souzu/2s.JPG")); // 4
        templates.push_back(loadMatFromFile(@"templates/souzu/3s.JPG")); // 5
        templates.push_back(loadMatFromFile(@"templates/souzu/4s.JPG")); // 5
        templates.push_back(loadMatFromFile(@"templates/souzu/5s.JPG")); // 5
        templates.push_back(loadMatFromFile(@"templates/souzu/6s.JPG")); // 5
        templates.push_back(loadMatFromFile(@"templates/souzu/7s.JPG")); // 2 9s
        templates.push_back(loadMatFromFile(@"templates/souzu/8s.JPG")); // 5
        templates.push_back(loadMatFromFile(@"templates/souzu/9s.JPG")); // 5
        
        templates.push_back(loadMatFromFile(@"templates/zihai/1z.JPG")); // 5
        templates.push_back(loadMatFromFile(@"templates/zihai/2z.JPG")); // 4 8s
        templates.push_back(loadMatFromFile(@"templates/zihai/3z.JPG")); // 5
        templates.push_back(loadMatFromFile(@"templates/zihai/4z.JPG")); // 5
        templates.push_back(loadMatFromFile(@"templates/zihai/5z.JPG")); // 1
        templates.push_back(loadMatFromFile(@"templates/zihai/6z.JPG")); // 5
        templates.push_back(loadMatFromFile(@"templates/zihai/7z.JPG")); // 5
        
        for (cv::Mat temp : templates) {
            cv::Mat resized_temp;
            cv::resize(temp,resized_temp , cv::Size(TEMPLATE_WIDTH, TEMPLATE_HEIGHT));
            std::vector<cv::KeyPoint> keypoints;
            cv::Mat descripter;
            AKAZE->detect(resized_temp, keypoints);
            AKAZE->compute(resized_temp, keypoints, descripter);
            templatesKeypoints.push_back(keypoints);
            templatesDescripters.push_back(descripter);
        }
         */
    }
    return self;
}

- (NSArray *)getFeatures:(UIImage *)image
{
    cv::Mat mat;
    UIImageToMat(image, mat);
    
    int width = mat.size().width;
    int height = mat.size().height;
    
    // 射影変換
    
    cv::Point2f cornerQuadPixel[4];
    
    cornerQuadPixel[0] = cv::Point2f(gCornerQuad[0].x * width, gCornerQuad[0].y * height);
    cornerQuadPixel[1] = cv::Point2f(gCornerQuad[1].x * width, gCornerQuad[1].y * height);
    cornerQuadPixel[2] = cv::Point2f(gCornerQuad[2].x * width, gCornerQuad[2].y * height);
    cornerQuadPixel[3] = cv::Point2f(gCornerQuad[3].x * width, gCornerQuad[3].y * height);
    
    int persWidth = (TARGET_WIDTH + PADDING_LEFT + PADDING_RIGHT) * 14;
    int persHeight = TARGET_HEIGHT + PADDING_TOP + PADDING_BOTTOM;
    
    cv::Point2f outputQuadPixel[4];
    
    outputQuadPixel[0] = cv::Point2f(0, persHeight);
    outputQuadPixel[1] = cv::Point2f(persWidth, persHeight);
    outputQuadPixel[2] = cv::Point2f(persWidth, 0);
    outputQuadPixel[3] = cv::Point2f(0, 0);
    
    cv::Mat output(cv::Size(persWidth, persHeight), mat.type());
    cv::Mat transform = cv::getPerspectiveTransform(cornerQuadPixel, outputQuadPixel);
    cv::warpPerspective(mat, output, transform, output.size());

    // グレースケール
    
    cv::cvtColor(output, output, cv::COLOR_BGRA2GRAY);
    
    // 二値化
    cv::threshold(output, output, 0, 1, cv::THRESH_BINARY_INV | cv::THRESH_OTSU);
    
    // 14分割してNSArrayに変換
    
    NSMutableArray *features = [NSMutableArray array];
    
    for (int i = 0; i < 14; ++i) {
        int lt = (TARGET_WIDTH + PADDING_LEFT + PADDING_RIGHT) * i;
        cv::Rect rect(lt + PADDING_LEFT, PADDING_TOP, TARGET_WIDTH, TARGET_HEIGHT);
        cv::Mat roi(output, rect);
        
        NSMutableArray *feature = [NSMutableArray array];
        
        for (int y = 0; y < TARGET_WIDTH; ++y) {
            for (int x = 0; x < TARGET_HEIGHT; ++x) {
                NSInteger val = roi.data[y * roi.step + x * roi.elemSize()];
                [feature addObject:[NSNumber numberWithInteger:val]];
            }
        }
        
        [features addObject:feature];
    }
    
    return features;
}
/*
- (NSArray*)getTehaiArray:(UIImage *)image
{
    cv::Mat mat;
    cv::Mat filtered;
    //Matへ変換
    UIImageToMat(image, mat);
    
    int width = mat.size().width;
    int height = mat.size().height;
    int center = mat.size().height / 2;
    int trimHeight = width / TRIM_ASPECT_RATIO;
    cv::Rect trimRect = cv::Rect(0, center - trimHeight / 2, width, trimHeight);
    cv::Mat trimed(mat, trimRect);
    cv::cvtColor(trimed, filtered, CV_BGR2GRAY);
    
    // ソーベルフィルタ
    cv::Sobel(filtered, filtered, CV_8U, 0, 1, 3, -1);
    // 膨張
    cv::Mat kernel = cv::getStructuringElement(cv::MORPH_ELLIPSE, cv::Size(5, 5));
    cv::dilate(filtered, filtered, kernel);
    // ２値化
    cv::threshold(filtered, filtered, 0, 255, CV_THRESH_BINARY | CV_THRESH_OTSU);
    
    cv::Mat filteredCnv;
    cv::Mat copyDest(mat, cv::Rect(0,0,width, trimHeight));
    cv::cvtColor(filtered, filteredCnv, cv::ColorConversionCodes::COLOR_GRAY2BGRA);
    //filteredCnv.copyTo(copyDest);
    
    // ラベリング
    cv::Mat labels;
    cv::Mat stats;
    cv::Mat centroids;
    cv::connectedComponentsWithStats(filtered, labels, stats, centroids, 8, CV_16U, cv::ConnectedComponentsAlgorithmsTypes::CCL_DEFAULT);
    
    cv::Rect detectedAreaRect(0,0,0,0);
    bool detected = false;
    int detectedLabel = -1;
    for(int i=1; i<stats.rows; i++)
    {
        int x = stats.at<int>(cv::Point(0, i));
        int y = stats.at<int>(cv::Point(1, i));
        int w = stats.at<int>(cv::Point(2, i));
        int h = stats.at<int>(cv::Point(3, i));
        
        cv::Rect rect(x,y + center - trimHeight / 2,w,h);
        if (rect.width > width * THRESH_WIDTH) {
            if (!detected) {
                detectedAreaRect = rect;
                detectedLabel = i;
            }
            detected = true;
            if (detectedAreaRect.y + detectedAreaRect.height < rect.y + rect.height) {
                detectedAreaRect = rect;
                detectedLabel = i;
            }
        }
    }
    NSMutableArray *array = [NSMutableArray array];
    if (detected) {
        cv::Rect localRect(detectedAreaRect.x, detectedAreaRect.y - center + trimHeight / 2, detectedAreaRect.width, detectedAreaRect.height);
        cv::Mat detectedArea(labels, localRect);
        cv::Mat detectedComponent;
        cv::inRange(detectedArea, detectedLabel, detectedLabel, detectedComponent);
        
        cv::Rect left(0, 0, 1, localRect.height);
        cv::Rect right(localRect.width - 1, 0, 1, localRect.height);
        cv::Moments mLeft = cv::moments(cv::Mat(detectedComponent, left), true);
        cv::Moments mRight = cv::moments(cv::Mat(detectedComponent, right), true);
        
        int yLeft = mLeft.m01 / mLeft.m00;
        int yRight = mRight.m01 / mRight.m00;
        
        
        cv::Point pLeft(detectedAreaRect.x, yLeft + detectedAreaRect.y);
        cv::Point pRight(detectedAreaRect.x + detectedAreaRect.width, yRight + detectedAreaRect.y);
        cv::Point delta = pRight - pLeft;
        cv::Point normal(delta.y / TEHAI_ASPECT_RATIO, - delta.x / TEHAI_ASPECT_RATIO);
        
        // 射影変換
        cv::Point2f cornerQuad[4];
        cv::Point2f outputQuad[4];
        
        cornerQuad[0] = pLeft;
        cornerQuad[1] = pRight;
        cornerQuad[2] = pRight + normal;
        cornerQuad[3] = pLeft + normal;
        
        int outputWidth = TEMPLATE_WIDTH * 14;
        int outputHeight = TEMPLATE_HEIGHT;
        cv::Mat output(outputHeight, outputWidth, mat.type());
        output += cv::Scalar(100, 100, 100, 255);
        
        outputQuad[0] = cv::Point2f(0, outputHeight - 1);
        outputQuad[1] = cv::Point2f(outputWidth - 1, outputHeight - 1);
        outputQuad[2] = cv::Point2f(outputWidth - 1, 0);
        outputQuad[3] = cv::Point2f(0, 0);
        
        cv::Mat transform = cv::getPerspectiveTransform(cornerQuad, outputQuad);
        
        cv::warpPerspective(mat, output, transform, output.size());
        
        //14等分
        cv::Mat haiArr[14];
        int w = output.size().width / 14;
        int h = output.size().height;
        const int padding_w = 8;
        const int padding_h = 8;
        for(int i = 0; i < 14; i++){
            cv::Rect rect(i * w + padding_w, padding_h, w - padding_w, h - padding_h);
            cv::Mat roi(output, rect);
            haiArr[i] = roi;
        }
        for(int i = 0; i < 14; i++){
            [array addObject:[NSNumber numberWithInt:[[self class] detectFromMat:haiArr[i]]]];
        }
        
    } else {
        std::cout << "認識失敗" << std::endl;
        [array addObject:[NSNumber numberWithInt:0]];
    }
    return array;
}*/

- (UIImage *)filter:(UIImage *)image
{
    cv::Mat mat;
    cv::Mat filtered;
    
    UIImageToMat(image, mat);
    
    int width = mat.size().width;
    int height = mat.size().height;
    int center = mat.size().height / 2;
    int trimHeight = width / TRIM_ASPECT_RATIO;
    cv::Rect trimRect = cv::Rect(0, center - trimHeight / 2, width, trimHeight);
    cv::Mat trimed(mat, trimRect);
    cv::cvtColor(trimed, filtered, CV_BGR2GRAY);
    // ソーベルフィルタ
    cv::Sobel(filtered, filtered, CV_8U, 0, 1, 3, -1);
    // 膨張
    cv::Mat kernel = cv::getStructuringElement(cv::MORPH_ELLIPSE, cv::Size(5, 5));
    cv::dilate(filtered, filtered, kernel);
    // ２値化
    cv::threshold(filtered, filtered, 0, 255, CV_THRESH_BINARY | CV_THRESH_OTSU);
    cv::Mat filteredCnv;
    cv::Mat copyDest(mat, cv::Rect(0,0,width, trimHeight));
    cv::cvtColor(filtered, filteredCnv, cv::ColorConversionCodes::COLOR_GRAY2BGRA);
    //filteredCnv.copyTo(copyDest);
    // ラベリング
    cv::Mat labels;
    cv::Mat stats;
    cv::Mat centroids;
    cv::connectedComponentsWithStats(filtered, labels, stats, centroids, 8, CV_16U, cv::ConnectedComponentsAlgorithmsTypes::CCL_DEFAULT);
    
    cv::Rect detectedAreaRect(0,0,0,0);
    bool detected = false;
    int detectedLabel = -1;
    for(int i=1; i<stats.rows; i++)
    {
        int x = stats.at<int>(cv::Point(0, i));
        int y = stats.at<int>(cv::Point(1, i));
        int w = stats.at<int>(cv::Point(2, i));
        int h = stats.at<int>(cv::Point(3, i));
        cv::Rect rect(x,y + center - trimHeight / 2,w,h);
        if (rect.width > width * THRESH_WIDTH) {
            if (!detected) {
                detectedAreaRect = rect;
                detectedLabel = i;
            }
            detected = true;
            if (detectedAreaRect.y + detectedAreaRect.height < rect.y + rect.height) {
                detectedAreaRect = rect;
                detectedLabel = i;
            }
        }
    }
    
    if (detected) {
        //cv::rectangle(mat, underRect, cv::Scalar(0, 255, 0, 255), 5);
        
        cv::Rect localRect(detectedAreaRect.x, detectedAreaRect.y - center + trimHeight / 2, detectedAreaRect.width, detectedAreaRect.height);
        cv::Mat detectedArea(labels, localRect);
        cv::Mat detectedComponent;
        cv::inRange(detectedArea, detectedLabel, detectedLabel, detectedComponent);
        
        cv::Rect left(0, 0, 1, localRect.height);
        cv::Rect right(localRect.width - 1, 0, 1, localRect.height);
        cv::Moments mLeft = cv::moments(cv::Mat(detectedComponent, left), true);
        cv::Moments mRight = cv::moments(cv::Mat(detectedComponent, right), true);
        
        int yLeft = mLeft.m01 / mLeft.m00;
        int yRight = mRight.m01 / mRight.m00;
        
        cv::Point pLeft(detectedAreaRect.x, yLeft + detectedAreaRect.y);
        cv::Point pRight(detectedAreaRect.x + detectedAreaRect.width, yRight + detectedAreaRect.y);
        cv::Point delta = pRight - pLeft;
        cv::Point normal(delta.y / TEHAI_ASPECT_RATIO, - delta.x / TEHAI_ASPECT_RATIO);
        // 射影変換
        cv::Point2f cornerQuad[4];
        cv::Point2f outputQuad[4];
        
        cornerQuad[0] = pLeft;
        cornerQuad[1] = pRight;
        cornerQuad[2] = pRight + normal;
        cornerQuad[3] = pLeft + normal;
        
        gCornerQuad[0] = cv::Point2f(cornerQuad[0].x / width, cornerQuad[0].y / height);
        gCornerQuad[1] = cv::Point2f(cornerQuad[1].x / width, cornerQuad[1].y / height);
        gCornerQuad[2] = cv::Point2f(cornerQuad[2].x / width, cornerQuad[2].y / height);
        gCornerQuad[3] = cv::Point2f(cornerQuad[3].x / width, cornerQuad[3].y / height);
        
        int outputWidth = TEMPLATE_WIDTH * 14;
        int outputHeight = TEMPLATE_HEIGHT;
        cv::Mat output(outputHeight, outputWidth, mat.type());
        output += cv::Scalar(100, 100, 100, 255);
        
        outputQuad[0] = cv::Point2f(0, outputHeight - 1);
        outputQuad[1] = cv::Point2f(outputWidth - 1, outputHeight - 1);
        outputQuad[2] = cv::Point2f(outputWidth - 1, 0);
        outputQuad[3] = cv::Point2f(0, 0);
        
        cv::Mat transform = cv::getPerspectiveTransform(cornerQuad, outputQuad);
        cv::warpPerspective(mat, output, transform, output.size());
        
        
        // 輪郭点 をプレビュー
        cv::circle(mat, pLeft, 10, cv::Scalar(0, 255, 0, 255), -1);
        cv::circle(mat, pRight, 10, cv::Scalar(0, 255, 0, 255), -1);
        cv::circle(mat, pLeft + normal, 10, cv::Scalar(0, 255, 0, 255), -1);
        cv::circle(mat, pRight + normal, 10, cv::Scalar(0, 255, 0, 255), -1);
        cv::line(mat, pRight, pLeft, cv::Scalar(0, 255, 0, 255), 5);
        
    }
    
    cv::rectangle(mat, trimRect, cv::Scalar(0, 0, 255, 255));
    
    //    cv::putText(mat, label, cv::Point(40,80), cv::FONT_HERSHEY_PLAIN, 4.0, cv::Scalar(255,0,0,255), 5);
    //std::cout << std::endl << std::endl;
    
    return MatToUIImage(mat);
}

+ (int)detectFromMat:(cv::Mat)resizedRoi
{
    std::vector<cv::KeyPoint> roiKeypoints;
    cv::Mat roiDescripter;
    
    AKAZE->detect(resizedRoi, roiKeypoints);
    AKAZE->compute(resizedRoi, roiKeypoints, roiDescripter);
    
    float mindist = 100000000;
    float minindex = -1;
    
    for (int i = 0; i < templates.size(); ++i) {
        std::vector<cv::KeyPoint> tempKeypoints = templatesKeypoints[i];
        cv::Mat tempDescripter = templatesDescripters[i];
        cv::Ptr<cv::DescriptorMatcher> matcher =  cv::DescriptorMatcher::create("BruteForce");
        std::vector<cv::DMatch> match, match12, match21;
        matcher->match(tempDescripter, roiDescripter,match12);
        matcher->match(roiDescripter,tempDescripter,match21);
        if (match12.size() == 0) {
            continue;
        }
        float dist = 0;
        for (cv::DMatch m : match12) {
            dist += m.distance;
        }
        dist /= match12.size();
        
        if (dist < mindist) {
            mindist = dist;
            minindex = i;
        }
    }
    int result;
    if (minindex != -1) {
        result = minindex;
    } else {
        result = 31; //haku
    }
    return result;
}


@end
