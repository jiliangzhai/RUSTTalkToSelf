//
//  RUSTPathLine.m
//  RUSTBounceView
//
//  Created by rust_33 on 16/1/15.
//  Copyright © 2016年 rust_33. All rights reserved.
//

#import "PathLine.h"

@interface PathLine (){}

@end

@implementation PathLine


- (double)getLength
{
    float x = _endPoint.x - _startPoint.x;
    float y = _endPoint.y - _startPoint.y;
    self.PathLength = hypot(x, y);
    return _PathLength;
}
@end






