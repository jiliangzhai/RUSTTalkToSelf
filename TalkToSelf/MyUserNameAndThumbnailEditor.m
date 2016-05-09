//
//  MyUserNameAndThumbnailEditor.m
//  TalkToSelf
//
//  Created by rust_33 on 16/3/15.
//  Copyright © 2016年 rust_33. All rights reserved.
//

#import "MyUserNameAndThumbnailEditor.h"
#import "MyUserManager.h"

@interface MyUserNameAndThumbnailEditor ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextFieldDelegate>
{
    BOOL changed;
}
@property (weak, nonatomic) IBOutlet UITextField *userNameInput;
@property (weak, nonatomic) IBOutlet UIImageView *userThumbnail;
@property (weak, nonatomic) IBOutlet UIButton *storeChange;
@property (weak, nonatomic) IBOutlet UIButton *selectThumbnail;
- (IBAction)selectNewThumbnail:(id)sender;
- (IBAction)storeTheChange:(id)sender;

@end

@implementation MyUserNameAndThumbnailEditor

- (void)viewDidLoad {
    [super viewDidLoad];
    
    changed = NO;
    self.navigationController.navigationBarHidden = NO;
    _userNameInput.delegate = self;
    if (_isTarget) {
        _userNameInput.placeholder = [MyUserManager targetNameAtIndex:[MyUserManager lastTargetIndex]];
        _userThumbnail.image = [UIImage imageWithData:[MyUserManager targetThumbnailAtIndex:[MyUserManager lastTargetIndex]]];
    }else
    {
        _userThumbnail.image = [UIImage imageWithData:[MyUserManager userThumbnail]];
        _userNameInput.placeholder = [MyUserManager userName];
    }
    _storeChange.layer.cornerRadius = 5.0;
    _storeChange.backgroundColor = [UIColor greenColor];
    
    _selectThumbnail.layer.cornerRadius = 5.0;
    _userThumbnail.layer.cornerRadius = 5.0;
    _userThumbnail.layer.masksToBounds = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [self.tableView addGestureRecognizer:tap];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)selectNewThumbnail:(id)sender {
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        picker.allowsEditing = YES;
        picker.delegate = self;
        [self presentViewController:picker animated:YES completion:nil];
    }
}

- (IBAction)storeTheChange:(id)sender {
    
    NSString *str = _userNameInput.text;
    [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (![str isEqualToString:@""]) {
        if (!_isTarget) {
            [MyUserManager changeUserNameTo:str];
        }else
            [MyUserManager changeTargetNameTo:str atIndex:[MyUserManager lastTargetIndex]];
        changed = YES;
    }
    if (changed) {
        [MyUserManager save];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"userInfoDidChanged" object:nil];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)tap:(UITapGestureRecognizer *)tap
{
    [self.tableView endEditing:YES];
}

#pragma imagePicker delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    if (image) {
        if (!_isTarget) {
            [MyUserManager changeThumbnailTo:image];
        }else
            [MyUserManager changeTargetThumbnail:image atIndex:[MyUserManager lastTargetIndex]];
       
        self.userThumbnail.image = image;
        changed = YES;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end








