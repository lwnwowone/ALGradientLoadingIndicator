//
//  ALGradientLoadingIndicator.m
//  ALGradientLoadingIndicator
//
//  Created by Alanc on 6/2/17.
//  Copyright © 2017 Alanc. All rights reserved.
//

#import "ALGradientLoadingIndicator.h"

#define kRoate @"rotate_hole"
#define kRoateAnimation @"rotate_animate"
#define kLayerAnimation @"layer_animate"

@interface ALGradientLoadingIndicator()

@property float outsideWidth;
@property float lineWidth;

@property CAShapeLayer *outsideLayer;
@property CAShapeLayer *insideLayer;
@property CAShapeLayer *loadingLayer;
@property CAMediaTimingFunction *timeFunc;
@property bool isAnimating;

@end

@implementation ALGradientLoadingIndicator

static ALGradientLoadingIndicator *instance;

+(instancetype)instance{
    if(!instance)
        [self setup];
    return instance;
}

-(void)showInView:(UIView *)aView{
    [aView addSubview:self];
    self.center = aView.center;
    [self startAnimation];
}

+(void)setup{
    instance = [ALGradientLoadingIndicator new];
    
    instance.outsideWidth = 8;
    instance.lineWidth = 5;
    
    float theLength = [UIScreen mainScreen].bounds.size.width / 5;
    instance.frame = CGRectMake(0, 0, theLength,theLength);
    instance.layer.cornerRadius = theLength/2;
    instance.layer.masksToBounds = YES;
    instance.timeFunc = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [instance getLayer];
    [instance renderPath];
}

-(void)getLayer{
    _loadingLayer = [CAShapeLayer new];
    _loadingLayer.frame = self.bounds;
    _loadingLayer.lineWidth = self.lineWidth;
    _loadingLayer.fillColor = [UIColor clearColor].CGColor;
    _loadingLayer.strokeColor = [UIColor whiteColor].CGColor;
    [self.layer addSublayer:_loadingLayer];
    
    _outsideLayer = [CAShapeLayer new];
    _outsideLayer.frame = self.bounds;
    _outsideLayer.lineWidth = self.outsideWidth;
    _outsideLayer.fillColor = [UIColor clearColor].CGColor;
    _outsideLayer.strokeColor = [UIColor whiteColor].CGColor;
    [self.layer addSublayer:_outsideLayer];
    
    _insideLayer = [CAShapeLayer new];
    _insideLayer.frame = self.bounds;
    _insideLayer.fillColor = [UIColor whiteColor].CGColor;
    [self.layer addSublayer:_insideLayer];
}

-(void)renderPath{
    CGPoint center = CGPointMake(self.bounds.size.width/2, self.bounds.size.width/2);
    float raduis = self.bounds.size.width/2 - self.outsideWidth - self.lineWidth / 2 + 0.5f;
    
    float startAngle = 0;
    float endAngle = M_PI * 2;
    
    UIBezierPath *bPath = [UIBezierPath bezierPathWithArcCenter:center radius:raduis startAngle:startAngle endAngle:endAngle clockwise:YES];
    
    _loadingLayer.path = bPath.CGPath;
    _loadingLayer.strokeStart = 0;
    _loadingLayer.strokeEnd = 0;
    
    float oRaduis = self.bounds.size.width / 2 - self.outsideWidth / 2;
    UIBezierPath *outsidePath = [UIBezierPath bezierPathWithArcCenter:center radius:oRaduis startAngle:startAngle endAngle:endAngle clockwise:YES];
    _outsideLayer.path = outsidePath.CGPath;
    
    float iRaduis = self.bounds.size.width / 2 - self.outsideWidth - self.lineWidth + 1;
    UIBezierPath *insidePath = [UIBezierPath bezierPathWithArcCenter:center radius:iRaduis startAngle:startAngle endAngle:endAngle clockwise:YES];
    _insideLayer.path = insidePath.CGPath;
}

-(void)RenderAnimation{
    if(_isAnimating)
        return;
    
    float pathAnimationTime = 1.5f;
    float firstPartTime = pathAnimationTime * 0.55f;
    float secondPartTime = pathAnimationTime - firstPartTime;
    
    // 全局旋转
    CABasicAnimation *rotate = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    rotate.duration = 4;
    rotate.repeatCount = CGFLOAT_MAX;
    rotate.removedOnCompletion = false;
    rotate.fromValue = [NSNumber numberWithDouble:0];
    rotate.toValue = [NSNumber numberWithDouble:M_PI * 2];
    [self.layer addAnimation:rotate forKey:kRoate];
    
    CABasicAnimation *rotate1 = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    rotate1.duration = firstPartTime;
    rotate1.timingFunction = self.timeFunc;
    rotate1.fromValue = [NSNumber numberWithDouble:0];
    rotate1.toValue = [NSNumber numberWithDouble:M_PI * 1.5];
    
    CABasicAnimation *rotate2 = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    rotate2.duration = secondPartTime;
    rotate2.timingFunction = self.timeFunc;
    rotate2.beginTime = firstPartTime;
    rotate2.fromValue = [NSNumber numberWithDouble:M_PI * 1.5];
    rotate2.toValue = [NSNumber numberWithDouble:M_PI * 2];
    
    CAAnimationGroup *rGroup = [CAAnimationGroup new];
    rGroup.animations = @[rotate1,rotate2];
    rGroup.duration = pathAnimationTime;
    rGroup.removedOnCompletion = NO;
    rGroup.repeatCount = CGFLOAT_MAX;
    [_loadingLayer addAnimation:rGroup forKey:kRoateAnimation];
    
    CABasicAnimation *endFirst = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    endFirst.timingFunction = self.timeFunc;
    endFirst.duration = firstPartTime;
    endFirst.fromValue = [NSNumber numberWithDouble:1];
    endFirst.toValue = [NSNumber numberWithDouble:0.25];
    
    CABasicAnimation *endSecond = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    endSecond.timingFunction = self.timeFunc;
    endSecond.duration = secondPartTime;
    endSecond.beginTime = firstPartTime;
    endSecond.fromValue = [NSNumber numberWithDouble:0.25];
    endSecond.toValue = [NSNumber numberWithDouble:1];
    
    CAAnimationGroup *group = [CAAnimationGroup new];
    group.animations = @[endFirst,endSecond];
    group.duration = pathAnimationTime;
    group.removedOnCompletion = NO;
    group.repeatCount = CGFLOAT_MAX;
    [_loadingLayer addAnimation:group forKey:kLayerAnimation];
}

-(void)startAnimation{
    [self RenderAnimation];
    _isAnimating = YES;
}

-(void)stopANimation{
    _isAnimating = NO;
    [_loadingLayer removeAllAnimations];
}

-(void)drawRect:(CGRect)rect{
    CGContextRef con = UIGraphicsGetCurrentContext();
    
    NSArray *colors = @[(__bridge id)[UIColor blueColor].CGColor,(__bridge id)[UIColor purpleColor].CGColor];
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat locations[] = { 0.0, 1.0 };
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef) colors, locations);
    CGPoint startPoint = CGPointMake(0, rect.size.height/2);
    CGPoint endPoint = CGPointMake(rect.size.width, rect.size.height/2);
    CGContextDrawLinearGradient(con, gradient, startPoint, endPoint, kCGGradientDrawsBeforeStartLocation);
}

@end
