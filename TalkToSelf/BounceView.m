//
//  BounceView.m
//  RUSTBounceView
//
//  Created by rust_33 on 16/1/15.
//  Copyright © 2016年 rust_33. All rights reserved.
//

#import "BounceView.h"
#import "PathLine.h"

@interface BounceView ()<UIGestureRecognizerDelegate>{
    
    CALayer *bounceLayer;
    UIImage *targetImage;
    NSMutableArray *lines;
    CGPoint initialVelocity;
    CGPoint lastTranslation;
    NSInteger viewWidth;
    NSInteger viewHeight;
    float duration;
    UIImageView *kissImageView;
    BOOL isPanedInRect;
    CGPoint startLocation;
    CGFloat imageRadius;
}

@end

@implementation BounceView

- (instancetype)initWithFrame:(CGRect)frame image:(UIImage *)image startLocation:(CGPoint)location
{
    self = [super initWithFrame:frame];
    if (self) {
        targetImage =[[UIImage alloc] init];
        targetImage = image;
        lines = [NSMutableArray array];
        viewWidth = frame.size.width;
        viewHeight = frame.size.height;
        imageRadius= 30;
        startLocation = location;
    }
    
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [self addBounceLayer];
    [self addPanGerture];
    [self adDdoubleTapGesture];
    [self addLongPressGesture];
}

- (void)addBounceLayer
{
    bounceLayer = [[CALayer alloc] init];
    bounceLayer.bounds = CGRectMake(0, 0, imageRadius*2,imageRadius*2);
    bounceLayer.position = startLocation;
    bounceLayer.cornerRadius = imageRadius;
    bounceLayer.borderWidth = 2.0;
    bounceLayer.borderColor = [UIColor yellowColor].CGColor;
    bounceLayer.masksToBounds = YES;
    bounceLayer.contents = (id)[self thumbnailMakerWithImage:targetImage size:bounceLayer.bounds.size].CGImage;
    
    [self.layer addSublayer:bounceLayer];
}

- (void)addPanGerture
{
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGeature:)];
    pan.delegate = self;
    [self addGestureRecognizer:pan];
}

- (void)panGeature:(UIPanGestureRecognizer *)pan
{
    CGPoint location = [pan locationInView:self];
    if (pan.state == UIGestureRecognizerStateBegan) {
        isPanedInRect = CGRectContainsPoint(bounceLayer.frame,location);
        return;
    }
    
    if (isPanedInRect) {
        
        if (pan.state == UIGestureRecognizerStateChanged){
            
            [CATransaction begin];
            [CATransaction setDisableActions:YES];
            float x = MIN(CGRectGetWidth(self.bounds)-imageRadius, location.x);
            float y = MIN(CGRectGetHeight(self.bounds)-imageRadius, location.y);
            x = MAX(x, imageRadius);
            y = MAX(y, imageRadius);
            CGPoint newLocation = CGPointMake(x, y);
            bounceLayer.position = newLocation;
            [CATransaction commit];
            
            lastTranslation = [pan translationInView:self];
        }else
        {
            initialVelocity = [pan velocityInView:self];
            [self startAnimation];
        }
        
        [pan setTranslation:CGPointZero inView:self];
    }
}

- (void)adDdoubleTapGesture
{
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    [self addGestureRecognizer:doubleTap];
}

- (void)doubleTap:(UITapGestureRecognizer *)doubleTap
{
    if (!kissImageView) {
        kissImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"kiss.png"]];
    }
    
    if (doubleTap.state == UIGestureRecognizerStateEnded)
    {
        kissImageView.center = bounceLayer.position;
        kissImageView.transform = CGAffineTransformMakeScale(0.5, 0.5);
        [self addSubview:kissImageView];
        
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            kissImageView.transform  = CGAffineTransformMakeScale(2.0, 2.0);
            kissImageView.alpha = 0.1;
        } completion:^(BOOL finished) {
            [kissImageView removeFromSuperview];
            kissImageView.transform = CGAffineTransformIdentity;
            kissImageView.alpha = 1.0;
        }];
      
    }
}

- (void)addLongPressGesture
{
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [self addGestureRecognizer:longPress];
}

- (void)longPress:(UILongPressGestureRecognizer *)press
{
    if (press.state == UIGestureRecognizerStateBegan) {
        [UIView animateWithDuration:0.5 animations:^{
            self.alpha = 0.0;
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
    }
    
}

- (void)startAnimation
{
    [lines removeAllObjects];
    [self caculationThePathWithVelocaty:initialVelocity];
    [self durationAccordingToVelocity:initialVelocity];
    
    if (duration > 0.0) {
        [self animationWithPaths:lines];
    }
}

- (UIImage *)thumbnailMakerWithImage:(UIImage *)image size:(CGSize)targetsize
{
    if (!image) {
        return nil;
    }
    
    CGSize imageSize = image.size;
    float ratioX = targetsize.width/imageSize.width;
    float ratioY = targetsize.height/imageSize.height;
    float ratio = MAX(ratioX, ratioY);
    
    float targetWidth = ratio*imageSize.width;
    float targetHeight = ratio*imageSize.height;
    
    float originX = (targetsize.width-targetWidth)/2.0;
    float originY = (targetsize.height-targetHeight)/2.0;
    
    UIGraphicsBeginImageContext(targetsize);
    [image drawInRect:CGRectMake(originX, originY, targetWidth, targetHeight)];
    UIImage *thumbnail = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return thumbnail;
}

- (void)caculationThePathWithVelocaty:(CGPoint)velocity
{
    NSInteger total = (NSInteger)hypot(velocity.x, velocity.y)/2;
    NSInteger currentLength = 0;
    CGPoint startPoint = bounceLayer.position;
    
    for (int count = 0; currentLength < total; count++) {
        PathLine *line = [self getNextLineWithStartPoint:startPoint direction:lastTranslation];
        if (line) {
            [lines addObject:line];
            startPoint = line.endPoint;
            currentLength += [line getLength];
        }else
            return;
    }
}

- (PathLine *)getNextLineWithStartPoint:(CGPoint)startpoint direction:(CGPoint)transition
{
    PathLine *line = [[PathLine alloc] init];
    line.startPoint = startpoint;
    CGPoint nextTransition;
    NSInteger x = 0;
    NSInteger y = 0;
    float k = 0;
    
    if (transition.x == 0 && transition.y == 0) {
        return nil;
    }
    
    if (transition.x > 0) {
        k = transition.y/transition.x;
        x = viewWidth - imageRadius;
        y = k * (x - startpoint.x) + startpoint.y;
        nextTransition = CGPointMake(-transition.x, transition.y);
        if (y > viewHeight - imageRadius)
        {
            y = viewHeight - imageRadius;
            x = (y - startpoint.y)/k +startpoint.x;
            nextTransition  = CGPointMake(transition.x, -transition.y);
            
        }else if (y < imageRadius)
        {
            y = imageRadius;
            x = (y - startpoint.y)/k +startpoint.x;
            nextTransition  = CGPointMake(transition.x, -transition.y);
        }
        
    }else if (transition.x < 0)
    {
        k = transition.y/transition.x;
        x = imageRadius;
        y = k * (x - startpoint.x) + startpoint.y;
        nextTransition = CGPointMake(-transition.x, transition.y);
        if (y > viewHeight-imageRadius) {
            y = viewHeight - imageRadius;
            x = (y - startpoint.y)/k +startpoint.x;
            nextTransition  = CGPointMake(transition.x, -transition.y);
            
        }else if (y < imageRadius)
        {
            y = imageRadius;
            x = (y - startpoint.y)/k +startpoint.x;
            nextTransition  = CGPointMake(transition.x, -transition.y);
        }

    }else
    {
        if (transition.y > 0)
            y = viewHeight - imageRadius;
        else
            y = imageRadius;
            x = startpoint.x;
    }
    
    line.endPoint = CGPointMake(x, y);
    lastTranslation = nextTransition;
    return line;
}

/*- (void)drawLines:(NSMutableArray *)drawLines
{
    if (!drawLines) {
        return;
    }
    
    UIBezierPath *path = [[UIBezierPath alloc] init];
    
    for (int i = 0; i < drawLines.count; i++) {
        PathLine *line = drawLines[i];
        if (i == 0) {
            [path moveToPoint:line.startPoint];
            [path addLineToPoint:line.endPoint];
        }else
        {
            [path addLineToPoint:line.endPoint];
        }
    }
    
    [[UIColor redColor] setStroke];
    path.lineWidth = duration;
    [path stroke];
}*/

- (void)animationWithPaths:(NSArray *)paths
{
    if (!paths.count > 0) {
        return;
    }
    
    CGMutablePathRef path = CGPathCreateMutable();
    
    for (int i = 0; i < paths.count; i++) {
        
        PathLine *line = paths[i];
        
        if (i == 0)
            CGPathMoveToPoint(path, NULL, line.startPoint.x, line.startPoint.y);
        CGPathAddLineToPoint(path, NULL, line.endPoint.x, line.endPoint.y);
    }
    CGPathAddLineToPoint(path, NULL, bounceLayer.position.x, bounceLayer.position.y);
    
    CAKeyframeAnimation *keyFrameAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    keyFrameAnimation.duration = duration;
    keyFrameAnimation.path = path;
    keyFrameAnimation.delegate = self;
    
    CGPathRelease(path);
    [bounceLayer addAnimation:keyFrameAnimation forKey:@"keyFrameAnimation"];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    PathLine *line = [PathLine new];
    line = [lines lastObject];
    
    [self addEndAnimationWithLastPath:line];

}

- (void)durationAccordingToVelocity:(CGPoint)velocity
{
    float initVelocity = hypot(velocity.x, velocity.y);
    NSInteger rank = initVelocity/1000;
    
    if (initVelocity < 400) {
        duration = 0.0;
    }else
        duration = rank*0.5 + 1.0;
}

- (void)addEndAnimationWithLastPath:(PathLine *)line
{
    CABasicAnimation *endRotate = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    endRotate.duration = 0.2;
    endRotate.toValue = @(M_PI*2);
    
    [bounceLayer addAnimation:endRotate forKey:@"endRotate"];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ([gestureRecognizer class] == [UILongPressGestureRecognizer class]) {
        return YES;
    }else
        return NO;
    
}
@end
















