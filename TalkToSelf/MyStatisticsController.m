//
//  MyStatisticsController.m
//  TalkToSelf
//
//  Created by rust_33 on 16/4/20.
//  Copyright © 2016年 rust_33. All rights reserved.
//

#import "MyStatisticsController.h"
#import "MyUserManager.h"
#import "MyDataSourcemanager.h"
#import "MyNumSlider.h"
#import "MyCollectionViewController.h"
#import "MyCollectionViewCell.h"
#import "MyCollectionViewLayout.h"

@interface MyStatisticsController ()<UICollectionViewDataSource, UICollectionViewDelegate>
{
    NSInteger currentIndex;
}

@property (weak, nonatomic) IBOutlet UIImageView *userThumbnail;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UIView *separateView1;
@property (weak, nonatomic) IBOutlet UIImageView *targetThumbnail;
@property (weak, nonatomic) IBOutlet UIView *totalNum;
@property (weak, nonatomic) IBOutlet UIView *targetTotalNum;
@property (weak, nonatomic) IBOutlet UILabel *targetName;
@property (weak, nonatomic) IBOutlet UIView *textMessageNum;
@property (weak, nonatomic) IBOutlet UIView *picMessageNum;
@property (weak, nonatomic) IBOutlet UIView *voiceMessageNum;
@property (weak, nonatomic) IBOutlet UIView *kissNum;
@property (weak, nonatomic) IBOutlet UIView *bounceNum;
@property (weak, nonatomic) IBOutlet UIView *separateView2;

@property (strong, nonatomic) NSMutableDictionary *totalNumDic;
@property (strong, nonatomic) NSMutableDictionary *targetTotalNumDic;
@property (strong, nonatomic) NSMutableDictionary *textMessageDic;
@property (strong, nonatomic) NSMutableDictionary *picMessageDic;
@property (strong, nonatomic) NSMutableDictionary *voiceMessageDic;
@property (strong, nonatomic) NSMutableDictionary *kissDic;
@property (strong, nonatomic) NSMutableDictionary *bounceDic;

@property (copy, nonatomic)NSArray *images;
@property (strong, nonatomic)UIColor *color;
@property (weak, nonatomic)UIView *bgView;
@property (weak, nonatomic)UICollectionView *collectionView;
- (IBAction)changeTarget:(id)sender;


@end

@implementation MyStatisticsController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [UIApplication sharedApplication].statusBarHidden = YES;
    currentIndex = [MyUserManager lastTargetIndex];
    
    _color = [UIColor colorWithRed:111/255.0 green:132/255.0 blue:125/255.0 alpha:1.0];
    
    _userThumbnail.layer.cornerRadius = 10.0;
    _userThumbnail.image = [UIImage imageWithData:[MyUserManager userThumbnail]];
    _userThumbnail.layer.masksToBounds = YES;
    
    _userName.text = [MyUserManager userName];
    _targetName.text = [MyUserManager targetNameAtIndex:currentIndex];
    
    _separateView1.layer.cornerRadius = 4.0;
    _separateView2.layer.cornerRadius = 4.0;
    
    _targetThumbnail.layer.cornerRadius = 10.0;
    _targetThumbnail.image = [UIImage imageWithData:[MyUserManager targetThumbnailAtIndex:currentIndex]];
    _targetThumbnail.layer.masksToBounds = YES;
    
    NSInteger totalNum = [MyUserManager numOfMessage];
   self.totalNumDic = [self addSliderWithNum:totalNum superView:_totalNum size:41 color:_color];
    
    NSInteger targetTotalNum = [MyDataSourcemanager numOfMessageAtindex:currentIndex];
    
   self.targetTotalNumDic = [self addSliderWithNum:targetTotalNum superView:_targetTotalNum size:41 color:_color];
    
    NSInteger targetTextMsg = [MyDataSourcemanager numOfTextMessageAtindex:currentIndex];
    self.textMessageDic = [self addSliderWithNum:targetTextMsg superView:_textMessageNum size:33 color:_color];
    
    NSInteger targetPicMsg = [MyDataSourcemanager numOfPicMessageAtindex:currentIndex];
    self.picMessageDic = [self addSliderWithNum:targetPicMsg superView:_picMessageNum size:33 color:_color];
    
    NSInteger targetVoiceMsg = [MyDataSourcemanager numOfVoiceMessageAtindex:currentIndex];
    self.voiceMessageDic = [self addSliderWithNum:targetVoiceMsg superView:_voiceMessageNum size:33 color:_color];
    
    NSInteger kissNum = [MyUserManager kissNumAtIndex:currentIndex];
    self.kissDic = [self addSliderWithNum:kissNum superView:_kissNum size:33 color:_color];
    
    NSInteger punchNum = [MyUserManager punchNumAtIndex:currentIndex];
    self.bounceDic = [self addSliderWithNum:punchNum superView:_bounceNum size:33 color:_color];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self slideToTargetNumWithDic:self.totalNumDic];
    [self slideToTargetNumWithDic:self.targetTotalNumDic];
    [self slideToTargetNumWithDic:self.textMessageDic];
    [self slideToTargetNumWithDic:self.picMessageDic];
    [self slideToTargetNumWithDic:self.voiceMessageDic];
    [self slideToTargetNumWithDic:self.kissDic];
    [self slideToTargetNumWithDic:self.bounceDic];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [UIApplication sharedApplication].statusBarHidden = NO;
}

- (NSMutableDictionary *)addSliderWithNum:(NSInteger)num superView:(UIView *)view size:(int)fontSize color:(UIColor*)fontColor
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    NSMutableArray *sliderArray = [NSMutableArray array];
    NSMutableArray *numArray = [NSMutableArray array];
    CGSize size = view.bounds.size;
    NSInteger totalNum = num;
    NSInteger numOfDigital = 0;
    
    do {
        numOfDigital++;
        NSInteger num = totalNum%10;
        totalNum = totalNum/10;
        [numArray addObject:[NSNumber numberWithInteger:num]];
    } while (totalNum!=0);
    
    CGFloat weith = size.width/5;
    CGFloat height = size.height;
    CGFloat x = (size.width - weith*numOfDigital)/2;
    CGFloat y = 0;
    
    for (int i = 0; i<numOfDigital; i++) {
        MyNumSlider *slider = [[MyNumSlider alloc] initWithFrame:CGRectMake(x+i*weith, y, weith, height) size:fontSize color:fontColor];
        [sliderArray addObject:slider];
        [view addSubview:slider];
    }
    [dic setObject:sliderArray forKey:@"sliders"];
    [dic setObject:numArray forKey:@"nums"];
    return dic;
}

- (void)slideToTargetNumWithDic:(NSDictionary *)dic
{
    NSArray *sliders = [dic objectForKey:@"sliders"];
    NSArray *nums = [dic objectForKey:@"nums"];
    NSInteger count = sliders.count;
    for (int i = 0; i<count; i++) {
        MyNumSlider *slider = sliders[i];
        NSNumber *numnum = nums[count-i-1];
        NSInteger num = [numnum integerValue];
        [slider slideToNum:num];
    }
}

- (void)refreshDic:(NSMutableDictionary *)dic
{
    NSArray *sliders = [dic objectForKey:@"sliders"];
    for (MyNumSlider *slider in sliders) {
        [slider removeFromSuperview];
    }
    [dic removeAllObjects];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
   
}

- (IBAction)changeTarget:(id)sender {
    
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
    self.bgView = bgView;
    [self.collectionView reloadData];
    
}

#pragma collectionView delegate and datasource
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

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row != currentIndex) {
        currentIndex = indexPath.row;
        self.targetThumbnail.image = [UIImage imageWithData:[MyUserManager targetThumbnailAtIndex:currentIndex]];
        self.targetName.text = [MyUserManager targetNameAtIndex:currentIndex];
        
        NSInteger targetTotalNum = [MyDataSourcemanager numOfMessageAtindex:currentIndex];
        [self refreshDic:self.targetTotalNumDic];
        self.targetTotalNumDic = [self addSliderWithNum:targetTotalNum superView:_targetTotalNum size:41 color:_color];
        
        NSInteger textMsgNum = [MyDataSourcemanager numOfTextMessageAtindex:currentIndex];
        [self refreshDic:self.textMessageDic];
        self.textMessageDic = [self addSliderWithNum:textMsgNum superView:_textMessageNum size:33 color:_color];
        
        NSInteger picMsgNum = [MyDataSourcemanager numOfPicMessageAtindex:currentIndex];
        [self refreshDic:self.picMessageDic];
        self.picMessageDic = [self addSliderWithNum:picMsgNum superView:_picMessageNum size:33 color:_color];
        
        NSInteger voiceMsgNum = [MyDataSourcemanager numOfVoiceMessageAtindex:currentIndex];
        [self refreshDic:self.voiceMessageDic];
        self.voiceMessageDic = [self addSliderWithNum:voiceMsgNum superView:_voiceMessageNum size:33 color:_color];
        
        NSInteger kissNum = [MyUserManager kissNumAtIndex:currentIndex];
        [self refreshDic:self.kissDic];
        self.kissDic = [self addSliderWithNum:kissNum superView:_kissNum size:33 color:_color];
        
        NSInteger punchNum = [MyUserManager punchNumAtIndex:currentIndex];
        [self refreshDic:self.bounceDic];
        self.bounceDic = [self addSliderWithNum:punchNum superView:_bounceNum size:33 color:_color];
    }
    
    CGFloat ratioX = 20/CGRectGetWidth([UIScreen mainScreen].bounds);
    CGFloat ratioY = 20/CGRectGetHeight([UIScreen mainScreen].bounds);
    [UIView  animateWithDuration:0.5 animations:^{
        self.navigationController.navigationBarHidden = NO;
        self.bgView.transform = CGAffineTransformMakeScale(ratioX, ratioY);
    } completion:^(BOOL finished) {
        [self.bgView removeFromSuperview];
        [self slideToTargetNumWithDic:self.targetTotalNumDic];
        [self slideToTargetNumWithDic:self.textMessageDic];
        [self slideToTargetNumWithDic:self.picMessageDic];
        [self slideToTargetNumWithDic:self.voiceMessageDic];
        [self slideToTargetNumWithDic:self.kissDic];
        [self slideToTargetNumWithDic:self.bounceDic];
    }];
}
@end







