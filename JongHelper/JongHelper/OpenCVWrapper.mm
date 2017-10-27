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
static const double TRIM_CENTER_RATIO = 0.7;
static const double THRESH_WIDTH = 0.6;
static const int TEMPLATE_WIDTH = 200;
static const int TEMPLATE_HEIGHT = 270;

static const int TARGET_WIDTH = 30;
static const int TARGET_HEIGHT = 42;

static const int PADDING_TOP = 5;
static const int PADDING_BOTTOM = 0;
static const int PADDING_LEFT = 2;
static const int PADDING_RIGHT = 2;

const double PHOTO_SIZE_WIDTH = 3264.0;
const double PHOTO_SIZE_HEIGHT = 2448.0;

cv::Point2f gCornerQuad[4];

- (id) init {
    if (self = [super init]) {
    }
    return self;
}

- (NSArray *)getFeatures:(UIImage *)image
{
    cv::Mat mat;
    UIImageToMat(image, mat);
    
//    std::cout << "初期サイズ：" << mat.size().width << std::endl;
//
    // iPhone6のカメラの解像度に合わせる
    if(mat.size().width != (int)PHOTO_SIZE_WIDTH) {
        std::cout << "リサイズした" << std::endl;
        cv::resize(mat, mat, cv::Size(), PHOTO_SIZE_WIDTH/mat.cols, PHOTO_SIZE_HEIGHT/mat.rows, cv::INTER_AREA);
    }
    
    int width = mat.size().width;
    int height = mat.size().height;
    //std::cout << "width: " << width << "  height: " << height << std::endl;
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
        
        for (int y = 0; y < TARGET_HEIGHT; ++y) {
            for (int x = 0; x < TARGET_WIDTH; ++x) {
                NSInteger val = roi.data[y * roi.step + x * roi.elemSize()];
                
                // デバッグ用
                //std::cout << (val == 1 ? '*' : '.');
                
                [feature addObject:[NSNumber numberWithInteger:val]];
            }
            std::cout << std::endl;
        }
        
        std::cout << std::endl;
        
        [features addObject:feature];
    }
    
    return features;
}

- (UIImage *)filter:(UIImage *)image
{
    cv::Mat mat;
    cv::Mat filtered;
    
    UIImageToMat(image, mat);
    
    int width = mat.size().width;
    int height = mat.size().height;
    std::cout << "width: " << width << "  height: " << height << std::endl;
    int center = mat.size().height * TRIM_CENTER_RATIO;
    int trimHeight = width / TRIM_ASPECT_RATIO;
    cv::Rect trimRect = cv::Rect(0, center - trimHeight / 2, width, trimHeight);
    
    //cv::rectangle(mat, trimRect, cv::Scalar(0, 255, 0, 255), 5);
    
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
        //cv::Point2f delta = (pRight - pLeft) / 14;
        
        cv::Scalar linecolor(231, 76, 60, 255);
        int linewidth = 2;
        for (int i = 0; i < 15; ++i) {
            cv::Point bottom = pLeft + delta * i / 14;
            cv::Point top = bottom + normal;
            cv::line(mat, bottom, top, linecolor, linewidth, CV_AA);
        }
        cv::line(mat, pRight, pLeft, linecolor, linewidth, CV_AA);
        cv::line(mat, pRight + normal, pLeft + normal, linecolor, linewidth, CV_AA);
        
    }
    
    //cv::rectangle(mat, trimRect, cv::Scalar(0, 0, 255, 255));
    
    //cv::putText(mat, label, cv::Point(40,80), cv::FONT_HERSHEY_PLAIN, 4.0, cv::Scalar(255,0,0,255), 5);
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
