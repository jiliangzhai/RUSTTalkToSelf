//
//  MyUserInformationEditor.m
//  TalkToSelf
//
//  Created by rust_33 on 16/3/11.
//  Copyright © 2016年 rust_33. All rights reserved.
//

#import "MyUserInformationEditor.h"
#import "MyUserManager.h"
#import "MyUserNameAndThumbnailEditor.h"
#import "MyPassworeSettingController.h"

@interface MyUserInformationEditor ()

@property (weak, nonatomic) IBOutlet UIImageView *userThumbnail;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *messageCount;
@property (weak, nonatomic) IBOutlet UIButton *closeSystemMsgBtn;

- (IBAction)turnDownSystemMessage:(id)sender;
- (IBAction)privacySetting:(id)sender;
- (IBAction)UserNameAndThumbnail:(id)sender;

@end

@implementation MyUserInformationEditor//静态表就不用实现协议那些了，否则会影响视图显示。

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [UIApplication sharedApplication].statusBarHidden = YES;
    _userName.text = [MyUserManager userName];
    _messageCount.text = [NSString stringWithFormat:@"%li",[MyUserManager activeDays]];
    _userThumbnail.image = [UIImage imageWithData:[MyUserManager userThumbnail]];
    _userThumbnail.layer.cornerRadius = 5.0;
    _userThumbnail.layer.masksToBounds = YES;
    _userThumbnail.contentMode = UIViewContentModeScaleToFill;
    
    NSString *str = [MyUserManager willShowSystemmessage]? @"关闭系统对话":@"开启系统对话";
    [_closeSystemMsgBtn setTitle:str forState:UIControlStateNormal];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (IBAction)turnDownSystemMessage:(id)sender {
    BOOL show = [MyUserManager willShowSystemmessage];
    [MyUserManager showSystem:!show];
    
    NSString *str = (!show)? @"关闭系统对话":@"开启系统对话";
    [_closeSystemMsgBtn setTitle:str forState:UIControlStateNormal];
}

- (IBAction)privacySetting:(id)sender {
    MyPassworeSettingController *setting = [[MyPassworeSettingController alloc] init];
    setting.isSet = NO;
    [self.navigationController pushViewController:setting animated:YES];
}

- (IBAction)UserNameAndThumbnail:(id)sender {
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    MyUserNameAndThumbnailEditor *editor = [story instantiateViewControllerWithIdentifier:@"UserNameAndThumbnail"];
    editor.isTarget = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userInfoDidChanged) name:@"userInfoDidChanged" object:nil];
    [self.navigationController pushViewController:editor animated:YES];
}

#pragma userInfoNotification
- (void)userInfoDidChanged
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *str = [MyUserManager userName];
        UIImage *image = [UIImage imageWithData:[MyUserManager userThumbnail]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            _userName.text = str;
            _userThumbnail.image = image;
        });
    });

}
@end







