//
//  MyCollectionViewController.m
//  TalkToSelf
//
//  Created by rust_33 on 16/4/5.
//  Copyright © 2016年 rust_33. All rights reserved.
//

#import "MyCollectionViewController.h"
#import "MyCollectionViewCell.h"
#import "MyCollectionViewLayout.h"
#import "MyUserManager.h"

@interface MyCollectionViewController () <UICollectionViewDataSource, UICollectionViewDelegate>
/** 所有的图片名 */
@property (nonatomic, strong) NSMutableArray *images;
@property (nonatomic, weak) UICollectionView *collectionView;
@end

@implementation MyCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    _images = [MyUserManager targetThumbnails];
    
    MyCollectionViewLayout *layout = [[MyCollectionViewLayout alloc] init];
    
    CGRect rect = CGRectMake(0, CGRectGetHeight([UIScreen mainScreen].bounds)*0.5-100, CGRectGetWidth([UIScreen mainScreen].bounds), 200);
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:rect collectionViewLayout:layout];
    collectionView.dataSource = self;
    collectionView.delegate = self;
    [collectionView registerNib:[UINib nibWithNibName:@"MyCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"rust"];

    [self.view addSubview:collectionView];
    self.collectionView = collectionView;
    
}

#pragma mark - <UICollectionViewDataSource>
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
        [[NSNotificationCenter defaultCenter] postNotificationName:@"didChangeTarget" object:nil];
        
    }
}

@end







