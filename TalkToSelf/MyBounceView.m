//
//  MyBounceView.m
//  RUSTBounceView
//
//  Created by rust_33 on 16/4/15.
//  Copyright © 2016年 rust_33. All rights reserved.
//

#import "MyBounceView.h"
#import "MyUserManager.h"

@interface Ball : UIImageView

@end

@implementation Ball

- (UIDynamicItemCollisionBoundsType)collisionBoundsType
{
    return UIDynamicItemCollisionBoundsTypeEllipse;
}

@end

@interface MyBounceView ()<UIGestureRecognizerDelegate>
{
    CGPoint transition;
    CGPoint formerLocation;
    CGFloat formerTime;
    CGPoint panStartLocation;
    CGPoint panEndLocation;
    UIImageView *kissImageView;
}
@property (nonatomic,weak)UIImageView *imageView;
@property (nonatomic,strong)UIDynamicAnimator *animator;
@property (nonatomic,strong)UISnapBehavior *snap;
@property (nonatomic,strong)UICollisionBehavior *collosition;
@property (nonatomic,strong)UIPushBehavior *push;
@property (nonatomic,strong)UIDynamicItemBehavior *behaver;
@property (nonatomic)CGPoint location;


@end

@implementation MyBounceView

- (instancetype)initWithFrame:(CGRect)frame image:(UIImage *)image startLocation:(CGPoint)location
{
    self = [super initWithFrame:frame];
    if (self) {
        Ball *imageView = [[Ball alloc] initWithFrame:CGRectMake(location.x, location.y, 2*BallRadius, 2*BallRadius)];
        imageView.contentMode = UIViewContentModeScaleToFill;;
        imageView.image = image;
        imageView.layer.cornerRadius = BallRadius;
        imageView.layer.masksToBounds = YES;
        
        UIPanGestureRecognizer *pan= [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
        pan.delegate = self;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        tap.numberOfTouchesRequired = 1;
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
        doubleTap.numberOfTouchesRequired = 2;
        UILongPressGestureRecognizer *press = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
        [imageView addGestureRecognizer:pan];
        [imageView addGestureRecognizer:press];
        [self addGestureRecognizer:tap];
        [self addGestureRecognizer:doubleTap];
        
        imageView.userInteractionEnabled = YES;
        imageView.center = CGPointMake(location.x, location.y);
        [self addSubview:imageView];
        
        self.imageView = imageView;
        self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self];
        self.multipleTouchEnabled = YES;
    }
    
    return self;
}

- (void)tap:(UITapGestureRecognizer *)tap
{
    [self.animator removeAllBehaviors];
    if (self.snap) {
        self.snap = nil;
    }else{
        self.push = nil;
        self.behaver = nil;
        self.collosition = nil;
    }
    
    CGPoint location = [tap locationInView:self];
    self.imageView.transform = CGAffineTransformMakeScale(0.5, 0.5);
    self.imageView.center = location;
    [UIView animateWithDuration:0.5 animations:^{
        self.imageView.transform = CGAffineTransformMakeScale(4, 4);
        self.imageView.transform = CGAffineTransformMakeRotation(0);
    } completion:^(BOOL finished) {
        self.imageView.transform = CGAffineTransformMakeScale(1.0, 1.0);
    }];
}

- (void)doubleTap:(UITapGestureRecognizer *)doubleTap
{
    if (!kissImageView) {
        kissImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"kiss.png"]];
    }
    
    if (doubleTap.state == UIGestureRecognizerStateEnded)
    {
        kissImageView.center = self.imageView.center;
        kissImageView.transform = CGAffineTransformMakeScale(0.5, 0.5);
        [self addSubview:kissImageView];
        
        [MyUserManager addKissAtIndex:[MyUserManager lastTargetIndex]];
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

- (void)pan:(UIPanGestureRecognizer *)pan
{
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
        {
            panStartLocation = self.imageView.center;
            [self.animator removeAllBehaviors];
            if (self.snap) {
                self.snap = nil;
            }else{
                self.behaver = nil;
                self.push = nil;
                self.collosition = nil;
            }
            break;
        }
        case UIGestureRecognizerStateEnded:
        {
            panEndLocation = [pan locationInView:self];
            CGPoint velocity = [pan velocityInView:self];
            NSInteger vt = hypot(velocity.x, velocity.y);
            if (vt<=1000) {
                if (!self.snap) {
                    self.snap = [[UISnapBehavior alloc] initWithItem:self.imageView snapToPoint:panStartLocation];
                    self.snap.damping = 0.5;
                    [self.animator addBehavior:self.snap];
                }
            }else
            {
                [MyUserManager addPunchAtIndex:[MyUserManager lastTargetIndex]];
                if (!self.behaver) {
                    self.behaver = [[UIDynamicItemBehavior alloc] initWithItems:@[self.imageView]];
                    self.behaver.density = 2;
                    self.behaver.elasticity = 1.0;
                    self.behaver.friction = 2.0;
                    [self.animator addBehavior:self.behaver];
                }
                if (!self.push) {
                    self.push = [[UIPushBehavior alloc] initWithItems:@[self.imageView] mode:UIPushBehaviorModeInstantaneous];
                    self.push.pushDirection = CGVectorMake(transition.x, transition.y);
                    self.push.active = YES;
                    NSUInteger ratio = vt/2000;
                    self.push.magnitude = 3.5*ratio;
                    [self.animator addBehavior:self.push];
                }
                if (!self.collosition) {
                    self.collosition = [[UICollisionBehavior alloc] initWithItems:@[self.imageView]];
                    self.collosition.translatesReferenceBoundsIntoBoundary = YES;
                    __weak MyBounceView *weakSelf = self;
                    self.collosition.action = ^(){
                        CGFloat x = self.imageView.center.x - formerLocation.x;
                        CGFloat y = self.imageView.center.y - formerLocation.y;
                        CGFloat timeOffset = weakSelf.animator.elapsedTime - formerTime;
                        formerTime = weakSelf.animator.elapsedTime;
                        formerLocation = self.imageView.center;
                        if (hypot(x, y)/timeOffset <20) {
                            [weakSelf.animator removeAllBehaviors];
                            weakSelf.behaver = nil;
                            weakSelf.push = nil;
                            weakSelf.collosition = nil;
                            
                            [weakSelf endAnimation];
                        }
                    };
                    [self.animator addBehavior:self.collosition];
                }
            }
            break;
        }
        default:
        {
            CGPoint location = [pan locationInView:self];
            self.imageView.center = location;
            transition = [pan translationInView:self];
        }  break;
    }
    
    [pan setTranslation:CGPointZero inView:self];
}

- (void)endAnimation
{
    [UIView animateWithDuration:0.8 animations:^{
        self.imageView.center = panStartLocation;
        self.imageView.transform = CGAffineTransformMakeRotation(0);
    } completion:^(BOOL finished) {
    }];
}

#pragma pan delegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ([gestureRecognizer class] == [UIPanGestureRecognizer class]) {
        return YES;
    }else
        return NO;
    
}
@end








