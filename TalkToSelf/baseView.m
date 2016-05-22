//
//  baseView.m
//  ScreenLock
//
//  Created by rust_33 on 15/8/4.
//  Copyright (c) 2015年 rust_33. All rights reserved.
//

#import "baseView.h"


@implementation baseView

-(instancetype) initWithFrame:(CGRect)frame
{
    self=[super initWithFrame:frame];
    if (self) {
        
        //计算底层图案大小
        self.backgroundColor=[UIColor clearColor];
        _radius=frame.size.width/9.5;
        CGFloat mariginUpDown=(frame.size.height-7.5*_radius)/2.0;
        
        _rects=[[NSMutableArray alloc] init];
        
        for (int i=0; i<9; i++) {
            
            int shang=i/3;
            int yu=i%3;
            
            CGRect rect=CGRectMake(_radius+yu*2.75*_radius, mariginUpDown+shang*2.75*_radius, 2*_radius, 2*_radius);
            
            NSValue* value=[NSValue valueWithCGRect:rect];
            
            [_rects addObject:value];
        }
    }
    
    //添加滑动视图
    touchView *view = [[touchView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    view.radius = _radius;
    view.rects=[_rects copy];
    self.touchView = view;
    [self addSubview:self.touchView];
    
    return self;
}


-(void) drawRect:(CGRect)rect
{
    //绘制底层图案
    UIBezierPath* path1=[[UIBezierPath alloc] init];
    
    for (int i=0; i<9; i++) {
        
        NSValue* value=_rects[i];
        CGRect rect=[value CGRectValue];
        
        [path1 moveToPoint:CGPointMake(rect.origin.x+2*_radius, rect.origin.y+_radius)];
        
        [path1 addArcWithCenter:CGPointMake(rect.origin.x+_radius, rect.origin.y+_radius) radius:_radius startAngle:0
                      endAngle:M_PI*2 clockwise:YES];
        
        [path1 moveToPoint:CGPointMake(rect.origin.x+_radius+3, rect.origin.y+_radius)];
        [path1 addArcWithCenter:CGPointMake(rect.origin.x+_radius, rect.origin.y+_radius) radius:3 startAngle:0
                      endAngle:M_PI*2 clockwise:YES];
    }
    
    [[UIColor whiteColor] setStroke];
    path1.lineWidth=4.0;
    
    [path1 stroke];
    
    UIBezierPath* path2=[[UIBezierPath alloc] init];
    for (int i=0; i<9; i++) {
        
        NSValue* value=_rects[i];
        CGRect rect=[value CGRectValue];
        
        [path2 moveToPoint:CGPointMake(rect.origin.x+_radius+3, rect.origin.y+_radius)];
        [path2 addArcWithCenter:CGPointMake(rect.origin.x+_radius, rect.origin.y+_radius) radius:3 startAngle:0
                      endAngle:M_PI*2 clockwise:YES];
    }
    
    path2.lineWidth=6.0;
    
    [path2 stroke];
}

@end





















