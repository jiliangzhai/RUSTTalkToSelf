//
//  MyNumSlider.m
//  TalkToSelf
//
//  Created by rust_33 on 16/4/20.
//  Copyright © 2016年 rust_33. All rights reserved.
//

#import "MyNumSlider.h"

@interface MyNumSlider ()

@property (nonatomic,weak)UIScrollView *scrollView;

@end
@implementation MyNumSlider

- (instancetype)initWithFrame:(CGRect)frame size:(int)size color:(UIColor *)color
{
    self = [super initWithFrame:frame];
    if (self) {
        UIScrollView *scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        scroll.showsVerticalScrollIndicator = NO;
        scroll.contentSize = CGSizeMake(CGRectGetWidth(frame), 10*CGRectGetHeight(frame));
        scroll.userInteractionEnabled = NO;
        
        for (int i = 0; i<10; i++) {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(frame)*i, frame.size.width, frame.size.height)];
            label.textAlignment = NSTextAlignmentCenter;
            label.font = [UIFont fontWithName:@"Avenir-Light" size:size];
            label.textColor = color;
            label.text = [NSString stringWithFormat:@"%i",i];
            
            [scroll addSubview:label];
        }
        
        [self addSubview:scroll];
        self.scrollView = scroll;
    }

    return self;
}

- (void)slideToNum:(NSUInteger)num
{
    [self.scrollView scrollRectToVisible:CGRectMake(0, num*CGRectGetHeight(self.bounds), CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds)) animated:YES];
}

@end
