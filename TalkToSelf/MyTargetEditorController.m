//
//  MyTargetEditorController.m
//  TalkToSelf
//
//  Created by rust_33 on 16/3/30.
//  Copyright © 2016年 rust_33. All rights reserved.
//

#import "MyTargetEditorController.h"
#import "MyUserManager.h"
#import "MyDataSourcemanager.h"
#import "MyUserNameAndThumbnailEditor.h"
#import "MyRegisterController.h"
#import "MyCollectionViewCell.h"
#import "MyCollectionViewLayout.h"

@interface MyTargetEditorController ()<UICollectionViewDataSource, UICollectionViewDelegate,UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *targetThumbnail;
@property (weak, nonatomic) IBOutlet UILabel *targetName;
@property (weak, nonatomic) IBOutlet UILabel *messageNum;
- (IBAction)targetEditored:(id)sender;
- (IBAction)changeTarget:(id)sender;
- (IBAction)creatNewTarget:(id)sender;
- (IBAction)removeAllMessage:(id)sender;

@property (nonatomic, strong) NSMutableArray *images;
@property (nonatomic, weak) UICollectionView *collectionView;
@property (nonatomic,weak)UIView *bgview;
@end

@implementation MyTargetEditorController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [UIApplication sharedApplication].statusBarHidden = YES;
    _targetThumbnail.image = [UIImage imageWithData:[MyUserManager targetThumbnailAtIndex:[MyUserManager lastTargetIndex]]];
    _targetThumbnail.layer.cornerRadius = 5.0;
    _targetThumbnail.layer.masksToBounds = YES;
    _targetName.text = [MyUserManager targetNameAtIndex:[MyUserManager lastTargetIndex]];
    _messageNum.text = [NSString stringWithFormat:@"%li",(long)[MyDataSourcemanager numOfMessageAtindex:[MyUserManager lastTargetIndex]]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (IBAction)targetEditored:(id)sender {
    //对象信息编辑
    MyUserNameAndThumbnailEditor *editor = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"UserNameAndThumbnail"];
    editor.isTarget = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userInfoDidChanged) name:@"userInfoDidChanged" object:nil];
    [self.navigationController pushViewController:editor animated:YES];
}

- (IBAction)changeTarget:(id)sender {
    //切换对话对象
    _images = [MyUserManager targetThumbnails];
    
    MyCollectionViewLayout *layout = [[MyCollectionViewLayout alloc] init];
    
    CGRect rect = CGRectMake(0, CGRectGetHeight([UIScreen mainScreen].bounds)*0.5-100, CGRectGetWidth([UIScreen mainScreen].bounds), 200);
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:rect collectionViewLayout:layout];
    collectionView.dataSource = self;
    collectionView.delegate = self;
    [collectionView registerNib:[UINib nibWithNibName:@"MyCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"rust"];
    UIView *bgView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    bgView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    self.navigationController.navigationBarHidden = YES;
    
    [bgView addSubview:collectionView];
    [self.view addSubview:bgView];
    self.collectionView = collectionView;
    self.bgview = bgView;
    [self.collectionView reloadData];
    
}

- (IBAction)creatNewTarget:(id)sender {
    //创建新的对象
    MyRegisterController *rc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"MyRegisterController"];
    rc.isTarget = YES;
    [self.navigationController pushViewController:rc animated:YES];
}

- (IBAction)removeAllMessage:(id)sender {
    //清空当前对象消息
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"请确认清楚所有消息！" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alertView show];
}

- (void)userInfoDidChanged
{
    //对象信息更改后更新视图显示
    _targetThumbnail.image = [UIImage imageWithData:[MyUserManager targetThumbnailAtIndex:[MyUserManager lastTargetIndex]]];
    _targetName.text = [MyUserManager targetNameAtIndex:[MyUserManager lastTargetIndex]];
    _messageNum.text = [NSString stringWithFormat:@"%li",(long)[MyDataSourcemanager numOfMessageAtindex:[MyUserManager lastTargetIndex]]];
}


#pragma textCollectionView
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.images.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MyCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"rust" forIndexPath:indexPath];
    UIImage *image = [UIImage imageWithData:_images[indexPath.row]];
    [cell setTheImage:image];
    return cell;
}

#pragma mark - <UICollectionViewDelegate>
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row != [MyUserManager lastTargetIndex]) {
        [MyUserManager changeLastTargetIndexto:indexPath.row];
        
        self.targetThumbnail.image = [UIImage imageWithData:[MyUserManager targetThumbnailAtIndex:[MyUserManager lastTargetIndex]]];
        self.targetName.text = [MyUserManager targetNameAtIndex:[MyUserManager lastTargetIndex]];
        _messageNum.text = [NSString stringWithFormat:@"%li",(long)[MyDataSourcemanager numOfMessageAtindex:[MyUserManager lastTargetIndex]]];
    }
    
    CGFloat ratioX = 20/CGRectGetWidth([UIScreen mainScreen].bounds);
    CGFloat ratioY = 20/CGRectGetHeight([UIScreen mainScreen].bounds);
    [UIView  animateWithDuration:0.5 animations:^{
        self.navigationController.navigationBarHidden = NO;
        self.bgview.transform = CGAffineTransformMakeScale(ratioX, ratioY);
    } completion:^(BOOL finished) {
        [self.bgview removeFromSuperview];
    }];
}

#pragma uialertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [MyDataSourcemanager removeAllMessageAtIndex:[MyUserManager lastTargetIndex]];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"userInfoDidChange" object:nil];
        [self userInfoDidChanged];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end








