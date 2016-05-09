//
//  MyTableViewCell.h
//  TalkToSelf
//
//  Created by rust_33 on 16/1/26.
//  Copyright © 2016年 rust_33. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyMessage.h"

@class MyTableViewCell;
@class MyMessageButton;
@class MyCellFrame;

@protocol MyCellDelegate <NSObject>

- (void)thumbnailClickedWithMessageOriation:(MessageOriation)oriation;
- (void)thumbnailLongPressedAtLocation:(CGPoint)location messageOriation:(MessageOriation)oriation;
- (void)deleteCell:(MyTableViewCell*)cell;

@optional
- (void)contentButtonClicked:(MyTableViewCell *)cell;
- (void)contentButtonPressed:(MyTableViewCell *)cell;

@end

@interface MyTableViewCell : UITableViewCell

@property(nonatomic,strong)UILabel *timeLabel;
@property(nonatomic,strong)UIButton *thumbnailButton;
@property(nonatomic,strong)UILabel *userName;
@property(nonatomic,weak)id<MyCellDelegate>delegate;
@property(nonatomic,strong)MyMessageButton *contentButton;
@property(nonatomic,strong)MyCellFrame *cellFrame;
@property(nonatomic)MessageOriation oriation;

@end
