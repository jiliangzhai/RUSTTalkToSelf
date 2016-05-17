//
//  MyLoginController.m
//  TalkToSelf
//
//  Created by rust_33 on 16/3/25.
//  Copyright © 2016年 rust_33. All rights reserved.
//

#import "MyLoginController.h"
#import "baseView.h"
#import "MySecretManager.h"
#import "MyRegisterController.h"
#import "MyViewController.h"
#import "MyPasswordRetrieveController.h"

@interface MyLoginController ()<touchEnded>

@property (weak, nonatomic) IBOutlet UIButton *forgetButton;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *forgetBtnTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *registerBtnTop;

- (IBAction)forgetPassword:(id)sender;
- (IBAction)userRegister:(id)sender;
- (IBAction)login:(id)sender;


@end

@implementation MyLoginController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithRed:124/255.0 green:195/255.0 blue:85/255.0 alpha:1.0];
    self.navigationController.navigationBarHidden = YES;
    
    _registerButton.layer.cornerRadius = 10.0;
    _registerButton.layer.masksToBounds = YES;
    //_registerButton.layer.borderWidth = 2.0;
    //_registerButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    _forgetButton.layer.cornerRadius = 10.0;
    _forgetButton.layer.masksToBounds = YES;
    //_forgetButton.layer.borderWidth = 2.0;
    //_forgetButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    _loginButton.layer.cornerRadius = 10.0;
    _loginButton.layer.masksToBounds = YES;

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)userRegister:(id)sender {
    
    //用户注册
    if (![MySecretManager getPassword]) {
        MyRegisterController *rc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"MyRegisterController"];
        rc.isTarget = NO;
        [self.navigationController pushViewController:rc animated:YES];
    }else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"已存在账户" message:@"账户已存在，若忘记密码可通过相关信息找回！" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertView show];
    }

}

- (IBAction)login:(id)sender {
    
    //用户登录
    if ([MySecretManager getPassword]) {
        _loginButton.hidden = YES;
        CGFloat topY = 156;
        CGFloat bottomY = CGRectGetHeight(self.view.bounds) - 80;
        CGFloat lockWidth = MIN(CGRectGetWidth(self.view.bounds), (bottomY - topY));
        
        _forgetBtnTop.constant = lockWidth - 75;
        _registerBtnTop.constant  = 10;
        
        baseView *MyBaseView = [[baseView alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.view.bounds)-lockWidth)/2.0, topY, lockWidth, lockWidth)];
        MyBaseView.touchView.delegate = self;
        [self.view addSubview:MyBaseView];
        [self.view layoutIfNeeded];
    }else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"没有账户存在！" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertView show];
    }
    
}

- (IBAction)forgetPassword:(id)sender {
    //密码找回
    if ([MySecretManager getPassword]) {
        MyPasswordRetrieveController *rc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"MyPasswordRetrieveController"];
        [self.navigationController pushViewController:rc animated:YES];
    }
}

#pragma delegate
- (void)touchEndedWithCode:(NSString *)code
{
    NSString *rightCode = [MySecretManager getPassword];
    if (rightCode) {
        if ([code isEqualToString:rightCode]) {
            [self.navigationController popToRootViewControllerAnimated:YES];
        }else
        {
            UIAlertView* alert=[[UIAlertView alloc] initWithTitle:@"密码错误" message:@"请输入正确的密码" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
        }
    }
}

@end





