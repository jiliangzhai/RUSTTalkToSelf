//
//  MyPasswordRetrieveController.m
//  TalkToSelf
//
//  Created by rust_33 on 16/3/29.
//  Copyright © 2016年 rust_33. All rights reserved.
//

#import "MyPasswordRetrieveController.h"
#import "MyPassworeSettingController.h"
#import "MyUserManager.h"

@interface MyPasswordRetrieveController ()

@property (weak, nonatomic) IBOutlet UITextField *userName;
@property (weak, nonatomic) IBOutlet UITextField *numOfTargets;
@property (weak, nonatomic) IBOutlet UIButton *retrieveButton;
- (IBAction)retrieve:(id)sender;

@end

@implementation MyPasswordRetrieveController
//根据两个简单的问题确定能否进行密码找回
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = NO;
    [UIApplication sharedApplication].statusBarHidden = YES;
    
    _retrieveButton.layer.cornerRadius = 5.0;
    _retrieveButton.layer.masksToBounds = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [self.tableView addGestureRecognizer:tap];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)retrieve:(id)sender {
    NSString *userName = _userName.text;
    NSString *num = _numOfTargets.text;
    userName = [userName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    num = [num stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSInteger numOfTargets = [num integerValue];
    
    NSString *nameStr = [MyUserManager userName];
    NSInteger targetsNum = [MyUserManager targetNames].count;
    
    if ([nameStr isEqualToString:userName] && (targetsNum == numOfTargets)) {
        MyPassworeSettingController *setting = [[MyPassworeSettingController alloc] init];
        setting.isSet = YES;
        [self.navigationController pushViewController:setting animated:YES];
    }else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"请提交正确的信息以找回密码" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
    }
}

- (void)tap:(UITapGestureRecognizer *)tap
{
    [self.tableView endEditing:YES];
}
@end





