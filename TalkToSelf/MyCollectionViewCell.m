//
//  MyCollectionViewCell.m
//  TalkToSelf
//
//  Created by rust_33 on 16/4/5.
//  Copyright © 2016年 rust_33. All rights reserved.
//

#import "MyCollectionViewCell.h"

@interface MyCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation MyCollectionViewCell

- (void)awakeFromNib {
    
    _imageView.layer.cornerRadius = 5.0;
    _imageView.layer.borderColor = [UIColor whiteColor].CGColor;
    _imageView.layer.borderWidth = 2.0;
    _imageView.layer.masksToBounds = YES;
    _imageView.backgroundColor = [UIColor whiteColor];
}

- (void)setTheImage:(UIImage *)image
{
    _imageView.image = image;
}
@end
