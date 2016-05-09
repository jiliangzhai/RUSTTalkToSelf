//
//  MyRegisterController.m
//  TalkToSelf
//
//  Created by rust_33 on 16/3/28.
//  Copyright © 2016年 rust_33. All rights reserved.
//

#import "MyRegisterController.h"
#import "MyPassworeSettingController.h"
#import "MyUserManager.h"
#import "MyInitTargetEditorController.h"

@interface MyRegisterController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    UIImage *thumbnail;
}
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *selectThumbnail;
@property (weak, nonatomic) IBOutlet UITextField *nickName;
@property (weak, nonatomic) IBOutlet UIButton *nestStep;
@property (weak, nonatomic) IBOutlet UILabel *nickNameLabel;
- (IBAction)selectThumbnail:(id)sender;
- (IBAction)nextStep:(id)sender;

@end

@implementation MyRegisterController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = NO;
    [UIApplication sharedApplication].statusBarHidden = YES;
    
    _imageView.layer.cornerRadius = 10.0;
    _imageView.layer.masksToBounds = YES;
    
    
    if (_isTarget) {
        [_selectThumbnail setTitle:@"点击选择对象头像" forState:UIControlStateNormal];
        _nickNameLabel.text = @"对象昵称 :";
        thumbnail = [UIImage imageWithData:[MyUserManager targetThumbnailAtIndex:[MyUserManager lastTargetIndex]]];
        [_nestStep setTitle:@"保存信息" forState:UIControlStateNormal];
    }else
    {
        thumbnail = [UIImage imageWithData:[MyUserManager userThumbnail]];
        [_nestStep setTitle:@"下一步" forState:UIControlStateNormal];
    }
    _imageView.image = thumbnail;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [self.tableView addGestureRecognizer:tap];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)selectThumbnail:(id)sender {
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        picker.allowsEditing = YES;
        picker.delegate = self;
        [self presentViewController:picker animated:YES completion:nil];
    }
}

- (IBAction)nextStep:(id)sender {
    
    NSString *userName = [_nickName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (_isTarget) {
        if (![userName isEqualToString:@""]) {
            [MyUserManager addTargetName:userName thumbnail:self.imageView.image];
        }else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"创建失败" message:@"请输入对象昵称"delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alert show];
            return;
        }
    }else
    {
        if (![userName isEqualToString:@""]) {
            [MyUserManager changeUserNameTo:userName];
            [MyUserManager save];
            
            MyInitTargetEditorController *ctr = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"MyInitTargetEditor"];
            [self.navigationController pushViewController:ctr animated:YES];
        }else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"创建失败" message:@"请输入用户昵称"delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alert show];
            return;
        }
    }
    if (_isTarget) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"newTargetCreated" object:nil];
        [self.navigationController popToRootViewControllerAnimated:YES];
        return;
    }
}

- (void)tap:(UITapGestureRecognizer *)tap
{
    [self.tableView endEditing:YES];
}

#pragma imagePickerdelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    if (image) {
        self.imageView.image = image;
        if (!_isTarget) {
            [MyUserManager changeThumbnailTo:image];
        }
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end








