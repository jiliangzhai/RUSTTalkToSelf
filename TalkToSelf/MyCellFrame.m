//
//  MyCellFrame.m
//  TalkToSelf
//
//  Created by rust_33 on 16/5/6.
//  Copyright © 2016年 rust_33. All rights reserved.
//

#import "MyCellFrame.h"
#import "MyMessage.h"

@implementation MyCellFrame

- (instancetype)initWithMessage:(MyMessage *)message
{
    _message = message;
    CGFloat screenW = CGRectGetWidth([UIScreen mainScreen].bounds);
    
    if (message.showTimeLabel) {
        //CGSize charactersSize = [message.createdTime sizeWithFont:[UIFont systemFontOfSize:11] constrainedToSize:CGSizeMake(300, 100) lineBreakMode:NSLineBreakByWordWrapping];
        CGSize charactersSize = [self textHeight:message.createdTime size:CGSizeMake(300, 100) fontSize:11];
        CGFloat timeWidth = charactersSize.width+10;
        CGFloat timeHeight = charactersSize.height+10;
        CGFloat timeX = (screenW - timeWidth)/2;
        _timeLabelFrame = CGRectMake(timeX, 0, timeWidth, timeHeight);
    }
    
    CGFloat thumbX = 10;
    if (message.messageOriation == isFormSelf) {
        thumbX = screenW - 60; //头像大小44x44
    }
    CGFloat thumbY = CGRectGetMaxY(_timeLabelFrame)+10;
    _thumbnailFrame = CGRectMake(thumbX, thumbY, 50, 50);
    
    //CGSize userNameStrSize = [message.userName sizeWithFont:[UIFont systemFontOfSize:11] constrainedToSize:CGSizeMake(300, 100)];
    CGSize userNameStrSize = [self textHeight:message.userName size:CGSizeMake(300, 100) fontSize:11];
    CGFloat userNameW = userNameStrSize.width+10;
    CGFloat userNameH = userNameStrSize.height+10;
    CGFloat userNameX = thumbX+22-userNameW/2;
    CGFloat userNameY = CGRectGetMaxY(_thumbnailFrame);
    _userNameFrame = CGRectMake(userNameX, userNameY, userNameW, userNameH);
    
    CGFloat contentX = CGRectGetMaxX(_thumbnailFrame)+10;
    CGFloat contentY = thumbY;
    CGSize contentSize;
    
    switch (message.messageType) {
        case 0:
            //contentSize = [message.textMessage sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(200, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
            contentSize = [self textHeight:message.textMessage size:CGSizeMake(200, CGFLOAT_MAX) fontSize:14];
            contentSize = CGSizeMake(contentSize.width+40, contentSize.height+20);
            break;
        case 1:
            contentSize = [self resizedImage:message.picMessage];
            break;
        case 2:
            contentSize = CGSizeMake(160, 40);
        default:
            break;
    }
    
    if (message.messageOriation == isFormSelf) {
        contentX = thumbX-10-contentSize.width;
    }
    _contentFrame = CGRectMake(contentX, contentY, contentSize.width, contentSize.height);
    _cellHeight = MAX(CGRectGetMaxY(_contentFrame), CGRectGetMaxY(_userNameFrame))+10;
    
    return self;
}

- (CGSize)resizedImage:(UIImage *)image
{
    CGFloat width = image.size.width;
    CGFloat height = image.size.height;
    if (image.size.width > 220) {
        CGFloat ratio = 220/image.size.width;
        height = ratio*image.size.height;
        width = 220;
    }
    
    return CGSizeMake(width, height);
}

- (CGSize)textHeight:(NSString *)text size:(CGSize)size fontSize:(NSInteger)fontSize
{
    NSDictionary *dic = @{NSFontAttributeName:[UIFont systemFontOfSize:fontSize]};
    CGSize targetSize = [text boundingRectWithSize:size options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:dic context:nil].size;
    return targetSize;
}
@end






