//
//  MyUserManager.m
//  TalkToSelf
//
//  Created by rust_33 on 16/3/4.
//  Copyright © 2016年 rust_33. All rights reserved.
//

#import "MyUserManager.h"
#import "MyDataSourcemanager.h"

@interface MyUserManager ()

@property(atomic,strong)NSMutableDictionary *dic;

@end

@implementation MyUserManager//也可以不用这个类，直接把dic直接存起来，和nscache一起用,起到同样的作用。

+ (instancetype)sharedUserManager
{
    static MyUserManager *sharedUserManager = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedUserManager = [[MyUserManager alloc] init];
    });
    return sharedUserManager;
}

+ (NSMutableDictionary *)userDic
{
    if([MyUserManager sharedUserManager].dic)
        return [MyUserManager sharedUserManager].dic;
    else
    {
        NSCache *cache = [[NSCache alloc] init];
        [MyUserManager sharedUserManager].dic = [cache objectForKey:@"userDic"];
        if([MyUserManager sharedUserManager].dic)
            return [MyUserManager sharedUserManager].dic;
        else
        {
            [[MyUserManager sharedUserManager] setupManager];
            return [MyUserManager sharedUserManager].dic;
        }
    }
}

+ (NSString *)initDate
{
    NSDate *date = [[MyUserManager userDic] objectForKey:@"initDate"];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    return [formatter stringFromDate:date];
}

+ (NSInteger)activeDays
{
    NSNumber *num = [[MyUserManager userDic] objectForKey:@"activeDays"];
    return [num integerValue];
}

+ (void)newActiveDay
{
    NSDate *lastDate = [[MyUserManager userDic] objectForKey:@"lastDate"];
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *lastDayStr = [formatter stringFromDate:lastDate];
    NSString *dateStr = [formatter stringFromDate:date];
    
    if (![dateStr isEqualToString:lastDayStr]) {
        NSNumber *number = [[MyUserManager userDic] objectForKey:@"activeDays"];
        NSInteger num = [number integerValue];
        num++;
        [[MyUserManager userDic] setObject:[NSNumber numberWithInteger:num] forKey:@"activeDays"];
        [[MyUserManager userDic] setObject:date forKey:@"lastDate"];
        [MyUserManager save];
    }
}

+ (BOOL)willShowSystemmessage
{
    NSNumber *num = [[MyUserManager userDic] objectForKey:@"systemMessage"];
    NSInteger show = [num integerValue];
    if (show == 1) {
        return YES;
    }else
        return NO;
}

+ (void)showSystem:(BOOL)show
{
    NSNumber *num = show? @1:@0;
    [[MyUserManager userDic] removeObjectForKey:@"systemMessage"];
    [[MyUserManager userDic] setObject:num forKey:@"systemMessage"];
}

+ (NSInteger)numOfMessage
{
    NSInteger numOfTarget = [MyUserManager targetNames].count;
    NSInteger sum = 0;
    for (NSInteger i = 0; i<numOfTarget; i++) {
        sum += [MyDataSourcemanager numOfMessageAtindex:i];
    }
    
    [[MyUserManager userDic] setObject:[NSNumber numberWithInteger:sum] forKey:@"numOfMessage"];
    return sum;
}

+ (void)addKissAtIndex:(NSInteger)index
{
    NSMutableArray *array = [[MyUserManager userDic] objectForKey:@"kissNum"];
    NSNumber *num = [array objectAtIndex:index];
    NSInteger inter = [num integerValue];
    inter++;
    num = [NSNumber numberWithInteger:inter];
    [array removeObjectAtIndex:index];
    [array insertObject:num atIndex:index];
    
    [MyUserManager save];
}

+ (void)addPunchAtIndex:(NSInteger)index
{
    NSMutableArray *array = [[MyUserManager userDic] objectForKey:@"punchNum"];
    NSNumber *num = [array objectAtIndex:index];
    NSInteger inter = [num integerValue];
    inter++;
    num = [NSNumber numberWithInteger:inter];
    [array removeObjectAtIndex:index];
    [array insertObject:num atIndex:index];
    
    [MyUserManager save];
}

+ (NSInteger)kissNumAtIndex:(NSInteger)index
{
    NSMutableArray *array = [[MyUserManager userDic] objectForKey:@"kissNum"];
    NSNumber *num = [array objectAtIndex:index];
    return [num integerValue];
}

+ (NSInteger)punchNumAtIndex:(NSInteger)index
{
    NSMutableArray *array = [[MyUserManager userDic] objectForKey:@"punchNum"];
    NSNumber *num = [array objectAtIndex:index];
    return [num integerValue];
}

+ (NSString *)userName
{
    return [[MyUserManager userDic] objectForKey:@"userName"];
}

+ (void)changeUserNameTo:(NSString *)newName
{
    [[MyUserManager userDic] removeObjectForKey:@"userName"];
    [[MyUserManager userDic] setObject:newName forKey:@"userName"];
}

+ (void)changeTargetNameTo:(NSString *)newName atIndex:(NSInteger)index
{
    [[[MyUserManager userDic] objectForKey:@"targetNames"] removeObjectAtIndex:index];
    [[[MyUserManager userDic] objectForKey:@"targetNames"] insertObject:newName atIndex:index];
    [MyUserManager save];
}

+ (NSData *)userThumbnail
{
    return [[MyUserManager userDic] objectForKey:@"userThumbnail"];
}

+ (void)changeThumbnailTo:(UIImage *)image
{
    [[MyUserManager userDic] removeObjectForKey:@"userThumbnail"];
    NSData *data = UIImagePNGRepresentation(image);
    [[MyUserManager userDic] setObject:data forKey:@"userThumbnail"];
}

+ (NSString *)targetNameAtIndex:(NSInteger)index
{
    return [[[MyUserManager userDic] objectForKey:@"targetNames"] objectAtIndex:index];
}

+ (NSData *)targetThumbnailAtIndex:(NSInteger)index
{
    return [[[MyUserManager userDic] objectForKey:@"targetThumbnails"] objectAtIndex:index];
}

+ (NSMutableArray *)targetNames
{
    return [[MyUserManager userDic] objectForKey:@"targetNames"];
}

+(NSMutableArray *)targetThumbnails
{
    return [[MyUserManager userDic] objectForKey:@"targetThumbnails"];
}

+ (void)changeTargetThumbnail:(UIImage *)image atIndex:(NSInteger)index
{
    [[[MyUserManager userDic] objectForKey:@"targetThumbnails"] removeObjectAtIndex:index];
    [[[MyUserManager userDic] objectForKey:@"targetThumbnails"] insertObject:UIImagePNGRepresentation(image) atIndex:index];
}

+ (NSInteger)lastTargetIndex
{
    NSNumber *num = [[MyUserManager userDic] objectForKey:@"lastTargetIndex"];
    return [num integerValue];
}

+ (void)changeLastTargetIndexto:(NSInteger)index
{
    NSNumber *num = [NSNumber numberWithInteger:index];
    [[MyUserManager userDic] removeObjectForKey:@"lastTargetIndex"];
    [[MyUserManager userDic] setObject:num forKey:@"lastTargetIndex"];
    
    [MyUserManager save];
}

+ (void)addTargetName:(NSString *)name thumbnail:(UIImage *)thumbnail
{
    UIImage *image = thumbnail;
    if (!image) {
        image = [UIImage imageNamed:@"0.jpg"];
    }
    NSData *data = UIImagePNGRepresentation(image);
    [[[MyUserManager userDic] objectForKey:@"targetNames"] addObject:name];
    [[[MyUserManager userDic] objectForKey:@"targetThumbnails"] addObject:data];
    NSMutableArray *targetNames = [[MyUserManager userDic] objectForKey:@"targetNames"];
    NSNumber *num = [NSNumber numberWithInteger:targetNames.count-1];
    [[MyUserManager userDic] setObject:num forKey:@"lastTargetIndex"];
    NSMutableArray *kissNum = [[MyUserManager userDic] objectForKey:@"kissNum"];
    [kissNum addObject:@0];
    NSMutableArray *punchNum = [[MyUserManager userDic] objectForKey:@"punchNum"];
    [punchNum addObject:@0];
    [MyUserManager save];
}

+ (void)removeTargetNamed:(NSString *)name
{
    NSInteger index = [[[MyUserManager userDic] objectForKey:@"targetNames"] indexOfObject:name];
    [[[MyUserManager userDic] objectForKey:@"targetNames"] removeObject:name];
    [[[MyUserManager userDic] objectForKey:@"targetThumbnails"] removeObjectAtIndex:index];
    [MyUserManager save];
}

+ (void)save
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *path = [MyUserManager path];
        NSFileManager *manager = [NSFileManager defaultManager];
        if ([manager fileExistsAtPath:path]) {
            [manager removeItemAtPath:path error:nil];
        }
        [NSKeyedArchiver archiveRootObject:[MyUserManager userDic] toFile:path];
    });
}

+ (NSString *)path
{
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"userDic.archiver"];
    return path;
}
- (void)setupManager
{
    _dic = [NSKeyedUnarchiver unarchiveObjectWithFile:[MyUserManager path]];
    if (!_dic)
    {
    [self setWithdefault];
    }
    
}

- (void)setWithdefault
{
    NSMutableArray *targetNames = [[NSMutableArray alloc] init];
    [targetNames addObject:@"XMan"];
    NSMutableArray *targetThumbnails = [[NSMutableArray alloc] init];
    NSData *data1 = UIImageJPEGRepresentation([UIImage imageNamed:@"targetDefault.png"], 1.0);
    [targetThumbnails addObject:data1];
    NSDate *date = [NSDate date];
    _dic = [[NSMutableDictionary alloc] init];
    [_dic setObject:@"user" forKey:@"userName"];
    NSData *data2 = UIImageJPEGRepresentation([UIImage imageNamed:@"userDefault.png"], 1.0);
    [_dic setObject:data2 forKey:@"userThumbnail"];
    [_dic setObject:targetNames forKey:@"targetNames"];
    [_dic setObject:targetThumbnails forKey:@"targetThumbnails"];
    [_dic setObject:@0 forKey:@"lastTargetIndex"];
    [_dic setObject:date forKey:@"initDate"];
    [_dic setObject:date forKey:@"lastDate"];
    [_dic setObject:@1 forKey:@"activeDays"];
    
    NSMutableArray *kissNum = [NSMutableArray array];
    [kissNum addObject:@0];
    [_dic setObject:kissNum forKey:@"kissNum"];
    NSMutableArray *punchNum = [NSMutableArray array];
    [punchNum addObject:@0];
    [_dic setObject:punchNum forKey:@"punchNum"];
    [_dic setObject:@0 forKey:@"systemMessage"];
    
    NSCache *cache = [[NSCache alloc] init];
    [cache setObject:_dic forKey:@"userDic"];
}
@end







