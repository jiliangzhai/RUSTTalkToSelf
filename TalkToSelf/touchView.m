//
//  touchView.m
//  ScreenLock
//
//  Created by rust_33 on 15/8/4.
//  Copyright (c) 2015年 rust_33. All rights reserved.
//

#import "touchView.h"
#import "touchLine.h"

@implementation touchView

-(instancetype) initWithFrame:(CGRect)frame
{
    self=[super initWithFrame:frame];
    if (self) {
        
        _lines=[[NSMutableArray alloc] init];
        _circles=[[NSMutableArray alloc] init];
        _currentLine=[[touchLine alloc] init];
        code=[[NSString alloc] init];
        
        self.backgroundColor=[UIColor clearColor];
    }
    return self;
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch* touch=[touches anyObject];
    
    currentPoint=[touch locationInView:self];
    for (int i=0; i<9; i++) {
        
        NSValue* value=_rects[i];
        CGRect rect=[value CGRectValue];
        if (CGRectContainsPoint(rect, currentPoint)) {
            
            currentRect=rect;
            selected=YES;
            _currentLine.begin=CGPointMake(rect.origin.x+_radius, rect.origin.y+_radius);
            _currentLine.end=CGPointMake(rect.origin.x+_radius, rect.origin.y+_radius);
            
            [_circles addObject:value];
            break;
        }
    }
    [self setNeedsDisplay];
}

-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch* touch=[touches anyObject];
    currentPoint=[touch locationInView:self];
    
    if (_circles.count >= 9) {
        return;
    }
    
    if (selected) {
        for (int i=0; i<9; i++) {
            
            NSValue* value=_rects[i];
            CGRect rect=[value CGRectValue];
            CGPoint center=CGPointMake(rect.origin.x+_radius, rect.origin.y+_radius);
            
            if ((pow(center.x-currentPoint.x, 2)+pow(center.y-currentPoint.y, 2))<400) {
            
                if (![_circles containsObject:value]) {
                    
                    CGPoint center=CGPointMake(rect.origin.x+_radius, rect.origin.y+_radius);
                    touchLine* line=[[touchLine alloc] init];
                    line.begin=_currentLine.begin;
                    line.end=center;
                    _currentLine.begin=center;
                    _currentLine.end=center;
                    
                    [_lines addObject:line];
                    [_circles addObject:value];
                }else
                    _currentLine.end = currentPoint;
                
                if (_circles.count>1) {
                        
                        NSUInteger p1=[_rects indexOfObject:[_circles lastObject]];
                        NSInteger p2=[_rects indexOfObject:_circles[[_circles count]-2]];
                        
                        if ((ABS(p1-p2)%2==0&&(ABS(p1-p2)/2)%2==1&&(ABS(p1+p2)/2)%2==1&&(p1!=4)&&(p2!=4))|(ABS(p1-p2)==8)|((p1+p2==8))){
                            
                            if (![_circles containsObject:_rects[(p1+p2)/2]]) {
                                
                                [_circles insertObject:_rects[(p1+p2)/2] atIndex:[_circles count]-1];
                            }
                        }
                    }
                [self setNeedsDisplay];
                return;
            }
            _currentLine.end=currentPoint;
    }
}
    [self setNeedsDisplay];
}

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (selected) {
        
        code=@"";
        
        for (NSValue* value in _circles) {
            
            NSInteger i=[_rects indexOfObject:value];
            
            code=[code stringByAppendingString:[NSString stringWithFormat:@"%li",(long)i]];
        }
    }
    
    _currentLine.end=_currentLine.begin;
    [_lines removeAllObjects];
    [_circles removeAllObjects];
    selected=NO;

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC*0.5), dispatch_get_main_queue(), ^{
        [self setNeedsDisplay];
    });
    
    if (![code isEqualToString:@""]) {
        [self.delegate touchEndedWithCode:code];
    }
}


-(void) drawLine:(touchLine*)line
{
    UIBezierPath* path=[[UIBezierPath alloc]init];
    [path moveToPoint:line.begin];
    [path addLineToPoint:line.end];
    
    [[UIColor colorWithRed:255 green:251 blue:240 alpha:0.75] setStroke];
    path.lineJoinStyle=kCGLineCapRound;
    path.lineWidth=5.0;
    
    [path stroke];
}

-(void) drawCircleWithRect:(CGRect) rect
{
    UIBezierPath* path=[[UIBezierPath alloc]init];
    [path moveToPoint:CGPointMake(rect.origin.x+2*_radius, rect.origin.y+_radius)];
    [path addArcWithCenter:CGPointMake(rect.origin.x+_radius, rect.origin.y+_radius) radius:_radius startAngle:0 endAngle:M_PI*2 clockwise:YES];
    [path moveToPoint:CGPointMake(rect.origin.x+_radius+3, rect.origin.y+_radius)];
    [path addArcWithCenter:CGPointMake(rect.origin.x+_radius, rect.origin.y+_radius) radius:3 startAngle:0
                  endAngle:M_PI*2 clockwise:YES];
    
    [[UIColor greenColor] setStroke];
    path.lineWidth=6.0;
    
    [path stroke];
}

-(void)drawRect:(CGRect)rect
{
    if (selected) {
        
        [self drawLine:_currentLine];
        
        for (touchLine* line in _lines) {
            [self drawLine:line];
        }
        
        for (NSValue* value in _circles) {
            
            CGRect rect=[value CGRectValue];
            
            [self drawCircleWithRect:rect];
        }
    }
}
@end

