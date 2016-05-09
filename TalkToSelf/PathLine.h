//
//  RUSTPathLine.h
//  RUSTBounceView
//
//  Created by rust_33 on 16/1/15.
//  Copyright © 2016年 rust_33. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface PathLine : NSObject

@property(nonatomic)float PathLength;
@property(nonatomic)CGPoint startPoint;
@property(nonatomic)CGPoint endPoint;
@property(nonatomic)float initVelicity;
@property(nonatomic)float endVelocity;
- (double)getLength;

@end
