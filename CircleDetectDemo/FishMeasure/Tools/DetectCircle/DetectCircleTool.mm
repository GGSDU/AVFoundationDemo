//
//  DetectCircleTool.m
//  AVFoundationDemo
//
//  Created by Story5 on 4/7/17.
//  Copyright © 2017 Story5. All rights reserved.
//

#import <opencv2/opencv.hpp>
#import <opencv2/imgcodecs/ios.h>
#import <opencv2/imgproc/imgproc.hpp>

#import "DetectCircleTool.h"

@implementation DetectCircleTool

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.size = 9;
        self.dp = 1;
        self.minDist = 8;
        self.param1 = 200;
        self.param2 = 100;
        self.minRadius = 0;
        self.maxRadius = 0;
    }
    return self;
}

- (BOOL)detectCircleInImage:(UIImage *)image
{
    // 将 UIImage 转成 MAT
    cv::Mat src;
    UIImageToMat(image, src);
    
    // 将图像作灰度处理
    cv::Mat src_gray;
    cv::cvtColor(src, src_gray, CV_BGR2GRAY);
    image = MatToUIImage(src_gray);
    
    
    // 将图像直方图均值化,提高图像对比度
//    cv::Mat src_hist;
//    cv::equalizeHist(src_gray,src_gray);
//    image = MatToUIImage(src_gray);

    // 锐化图像,突显边界
//    cv::Mat dst,dst2;
//    cv::Sobel(src_gray, src_gray, -1, 1, 1);
//    image = MatToUIImage(src_gray);
//    cv::Laplacian(src_gray, src_gray, -1);
//    image = MatToUIImage(src_gray);
    
    // 高斯滤镜
    cv::Mat src_gaussian;
    cv::GaussianBlur(src_gray,          // src
                     src_gaussian,          // dst
                     cv::Size(self.size, self.size),    // ksize
//                     cv::Size(7, 7),
                     2,                 // sigmaX
                     2);                // sigmaY
    image = MatToUIImage(src_gaussian);
    
    // 霍夫变换检测圆形
    std::vector<cv::Vec3f> circles;
    cv::HoughCircles(src_gaussian,
                     circles,
                     CV_HOUGH_GRADIENT,
//                     CV_HOUGH_PROBABILISTIC,
                     self.dp,
//                     src_gray.rows / self.minDist,
                     10,
                     self.param1,
                     self.param2,
                     self.minRadius,
                     self.maxRadius);
    
    if (circles.size() <= 0) {
        _center = CGPointZero;
        _radius = 0;
        _covertImage = nil;
        return false;
    }
    
    for( size_t i = 0; i < circles.size(); i++ )
    {
        // 圆心
        cv::Point center(cvRound(circles[i][0]), cvRound(circles[i][1]));
        // 半径
        int radius = cvRound(circles[i][2]);
        
        // 图像上画圆
        // circle center
        circle( src, center, 3, cv::Scalar(0,0,255), -1, 8, 0 );
        // circle outline
        circle( src, center, radius, cv::Scalar(0,255,0), 5, 8, 0 );
        
        
        _center = CGPointMake(center.x, center.y);
        _radius = radius;
    }
    
    // 将 MAT 转换成 UIImage
    _covertImage = MatToUIImage(src);
    
    return true;
}

@end
