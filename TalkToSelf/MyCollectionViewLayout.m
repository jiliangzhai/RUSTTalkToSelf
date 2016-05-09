//
//  MyCollectionViewLayout.m
//  TalkToSelf
//
//  Created by rust_33 on 16/4/5.
//  Copyright © 2016年 rust_33. All rights reserved.
//

#import "MyCollectionViewLayout.h"

@implementation MyCollectionViewLayout

- (instancetype)init
{
    if (self = [super init]) {
    }
    return self;
}

- (void)prepareLayout
{
    [super prepareLayout];
    
    // 设置滚动方向(只有流水布局才有这个属性)
    self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    // 设置cell的大小
    CGFloat itemWH = self.collectionView.frame.size.height * 0.8;
    self.itemSize = CGSizeMake(itemWH, itemWH);
    
    // 设置内边距
    CGFloat inset = (self.collectionView.frame.size.width - itemWH) * 0.5;
    self.sectionInset = UIEdgeInsetsMake(0,inset, 0, inset);
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return YES;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSArray *array = [super layoutAttributesForElementsInRect:rect];
    
    CGFloat centerX = self.collectionView.contentOffset.x + self.collectionView.frame.size.width * 0.5;
    
    for (UICollectionViewLayoutAttributes *attrs in array) {
        CGFloat delta = ABS(centerX - attrs.center.x);
        
        CGFloat scale = 1 - delta / (self.collectionView.frame.size.width + self.itemSize.width);
        attrs.transform = CGAffineTransformMakeScale(scale, scale);
    }
    
    return array;
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset
{
    CGRect rect;
    rect.origin = proposedContentOffset;
    rect.size = self.collectionView.frame.size;
    
    NSArray *array = [super layoutAttributesForElementsInRect:rect];
    
    CGFloat centerX = proposedContentOffset.x + self.collectionView.frame.size.width * 0.5;
    
    CGFloat minDist = MAXFLOAT;
    for (UICollectionViewLayoutAttributes *attrs in array) {
        if (ABS(minDist) > ABS(attrs.center.x - centerX)) {
            minDist = attrs.center.x - centerX;
        }
    }
    
    return CGPointMake(proposedContentOffset.x + minDist, proposedContentOffset.y);
}
@end
