//
//  MyInitTargetEditorController.m
//  TalkToSelf
//
//  Created by rust_33 on 16/4/27.
//  Copyright © 2016年 rust_33. All rights reserved.
//

#import "MyInitTargetEditorController.h"
#import "MyUserManager.h"
#import "MyPassworeSettingController.h"

@interface MyInitTargetEditorController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *targetName;
@property (weak, nonatomic) IBOutlet UIImageView *defaultThumbnail;
@property (weak, nonatomic) IBOutlet UIButton *nextStepBtn;
@property (weak, nonatomic) IBOutlet UIButton *selectThumbnailBtn;
- (IBAction)selectThumbnail:(id)sender;
- (IBAction)nextStep:(id)sender;

@end

@implementation MyInitTargetEditorController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = NO;
    [UIApplication sharedApplication].statusBarHidden = YES;
    
    _defaultThumbnail.layer.cornerRadius = 10.0;
    _defaultThumbnail.layer.masksToBounds = YES;
    
    UIImage *defaultThumbnail = [UIImage imageWithData:[MyUserManager targetThumbnailAtIndex:[MyUserManager lastTargetIndex]]];
    _defaultThumbnail.image = defaultThumbnail;
    
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
    NSString *targetName = [_targetName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (![targetName isEqualToString:@""]) {
        [MyUserManager changeTargetNameTo:targetName atIndex:[MyUserManager lastTargetIndex]];
        MyPassworeSettingController* setting = [[MyPassworeSettingController alloc] init];
        setting.isSet = YES;
        [self.navigationController pushViewController:setting animated:YES];
    }else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"请输入对象昵称" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
    }

}

- (void)tap:(UITapGestureRecognizer *)tap
{
    [self.tableView endEditing:YES];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    if (image) {
        self.defaultThumbnail.image = image;
        [MyUserManager changeTargetThumbnail:image atIndex:[MyUserManager lastTargetIndex]];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}@end








