//
//  MyDataSourcemanager.m
//  TalkToSelf
//
//  Created by rust_33 on 16/3/1.
//  Copyright © 2016年 rust_33. All rights reserved.
//

#import "MyDataSourcemanager.h"
#import "MyUserManager.h"
#import "MyMessage.h"
#import "MyCellFrame.h"
#import "NSDate+Utils.h"
#import "FMDatabase.h"

@implementation UIImage (store)

+ (UIImage *)getTheImageWithName:(NSString *)name
{
    //图片消息获取
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSInteger index = [MyUserManager lastTargetIndex];
    path = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"images%li/%@",(long)index,name]];
    
    
    return [UIImage imageWithContentsOfFile:path];
}

- (NSString*)storeTheImage
{
    //图片消息存储
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSUUID *uuid = [[NSUUID alloc] init];
    NSString *key = [uuid UUIDString];
    path = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"images%li",(long)(long)[MyUserManager lastTargetIndex]]];
    BOOL hasDir;
    [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&hasDir];
    if (!hasDir) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:NULL];
    }
    path = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",key]];
    __weak UIImage *weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *data = UIImageJPEGRepresentation(weakSelf, 1.0);
        [data writeToFile:path atomically:YES];
    });
    return [NSString stringWithFormat:@"%@.jpg",key];
    
}

@end

@implementation NSData (store)

+ (NSData *)getTheDataWithName:(NSString *)name
{
    //语音消息获取
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    path = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"voices%li/%@",(long)(long)[MyUserManager lastTargetIndex],name]];
    
    return [NSData dataWithContentsOfFile:path];
}

- (NSString *)storeTheData
{
    //语音消息存储
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSUUID *uuid = [[NSUUID alloc] init];
    NSString *key = [uuid UUIDString];
    path = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"voices%li",(long)(long)[MyUserManager lastTargetIndex]]];
    BOOL hasDir;
    [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&hasDir];
    if (!hasDir) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:NULL];
    }
    path = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp3",key]];
    __weak NSData *weakself = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [weakself writeToFile:path atomically:YES];
    });
    return [NSString stringWithFormat:@"%@.mp3",key];
}

@end

@interface MyDataSourcemanager ()
{
    FMDatabase *db;
}

@property(atomic,strong)NSMutableArray *dataSource;

@end

@implementation MyDataSourcemanager

+ (instancetype)sharedManager
{
    static MyDataSourcemanager *sharedManager = nil;
    if (!sharedManager) {
        static dispatch_once_t once;
        dispatch_once(&once, ^{
            sharedManager = [[MyDataSourcemanager alloc] initPrivate];
        });
    }
    return sharedManager;
}

- (instancetype)initPrivate
{
    self = [super init];
    if (self) {
        [self setupDB];
    }
    return self;
}

+ (NSInteger)numOfMessageAtindex:(NSInteger)index
{
    return [[MyDataSourcemanager sharedManager] numOfMessgesAtIndex:index];
}

+ (NSInteger)numOfTextMessageAtindex:(NSInteger)index
{
    return [[MyDataSourcemanager sharedManager] numOfTextMessageAtIndex:index];
}

+ (NSInteger)numOfPicMessageAtindex:(NSInteger)index
{
    return [[MyDataSourcemanager sharedManager] numOfPicMessageAtIndex:index];
}

+ (NSInteger)numOfVoiceMessageAtindex:(NSInteger)index
{
    return [[MyDataSourcemanager sharedManager] numOfVoiceMessageAtIndex:index];
}

+ (NSArray *)dataSources
{
    if ([MyDataSourcemanager sharedManager].dataSource) {
        return [MyDataSourcemanager sharedManager].dataSource;
    }else
        return nil;//加载时候用，如果没有数据就调用下面的方法，从数据库加载数据
}

+ (void)dataSourcesWithNum:(NSInteger)num index:(NSInteger)index
{
    if ([MyDataSourcemanager sharedManager].dataSource) {
        if ([MyDataSourcemanager sharedManager].dataSource.count >= num) {
            return;
        }else
        {
            [[MyDataSourcemanager sharedManager].dataSource removeAllObjects];
        }
    }else
       [MyDataSourcemanager sharedManager].dataSource = [NSMutableArray array];
    [[MyDataSourcemanager sharedManager] loadMoreMessageAtIndex:index totalCount:num];
    return;//初次加载
}

+ (void)reloadMessageNum:(NSInteger)num index:(NSInteger)index
{
    //加载更多消息
    if (![MyDataSourcemanager sharedManager].dataSource) {
        [MyDataSourcemanager sharedManager].dataSource = [NSMutableArray array];
    }
    [[MyDataSourcemanager sharedManager] loadMoreMessageAtIndex:index totalCount:num];
}

+ (void)addMessage:(MyMessage *)message index:(NSInteger)index
{
    //添加消息到数据库
    MyCellFrame *lastCellFrame = [MyDataSourcemanager sharedManager].dataSource.lastObject;
    if (lastCellFrame) {
         message.showTimeLabel = [[MyDataSourcemanager sharedManager] timeOffsetBetweenStartDate:lastCellFrame.message.createdTime toEndStr:message.createdTime];
    }else
    {
         message.showTimeLabel = YES;
    }
    MyCellFrame *frame = [[MyCellFrame alloc] initWithMessage:message];
    
    if (![MyDataSourcemanager sharedManager].dataSource) {
        [MyDataSourcemanager sharedManager].dataSource = [NSMutableArray array];
    }
    [[MyDataSourcemanager sharedManager].dataSource addObject:frame];
    [[MyDataSourcemanager sharedManager] insertMessage:message index:index];
    [[MyDataSourcemanager sharedManager].delegate newMessageAdded:frame];
}

+ (void)removeAllMessageAtIndex:(NSInteger)index
{
    [[MyDataSourcemanager sharedManager]removeAllMessageAtIndex:index];
    [[MyDataSourcemanager sharedManager].dataSource removeAllObjects];
}

+ (void)removeMessage:(MyCellFrame *)frame index:(NSInteger)index
{
    //删除消息并调整相邻消息的日期标签显示与否
    NSMutableArray *array = [MyDataSourcemanager sharedManager].dataSource;
    if (array) {
        NSInteger num = [array indexOfObject:frame];
        if (num != array.count-1 && num != 0) {
            MyCellFrame *frame1 = [array objectAtIndex:num+1];
            if (frame.message.showTimeLabel == YES) {
                if (frame1.message.showTimeLabel != YES) {
                    frame1.message.showTimeLabel = YES;
                    [[MyDataSourcemanager sharedManager] modifyTheTimeLabelTo:YES message:frame1.message index:index];
                }
            }else
            {
                MyCellFrame *frame2 = [array objectAtIndex:num-1];
                BOOL show = [[MyDataSourcemanager sharedManager] timeOffsetBetweenStartDate:frame2.message.createdTime toEndStr:frame1.message.createdTime];
                if (frame1.message.showTimeLabel !=show) {
                    [[MyDataSourcemanager sharedManager] modifyTheTimeLabelTo:show message:frame1.message index:index];
                }
            }
        }else if (num != array.count-1)
        {
            MyCellFrame *frame1 = [array objectAtIndex:num+1];
            frame1.message.showTimeLabel = YES;
            [[MyDataSourcemanager sharedManager] modifyTheTimeLabelTo:YES message:frame1.message index:index];
        }
        [array removeObject:frame];
    }
    [[MyDataSourcemanager sharedManager] deleteMessage:frame.message index:index];
}

+ (NSString *)helloMessageAccordingToTime
{
    //根据当前时间，发送系统消息
    NSDate *currentTime = [NSDate date];
    NSString *helloWord;
    if ([currentTime hour]>=5 && [currentTime hour]<12) {
        helloWord = @"早上好！";
    }else if ([currentTime hour]>=12 && [currentTime hour]<=18){
        helloWord = @"下午好！";
    }else if ([currentTime hour]>18 && [currentTime hour]<=23){
        helloWord = @"晚上好！";
    }else{
        helloWord= @"要保证充足的睡眠哟！";
    }
    return helloWord;
}

+ (void)initSystemMessageAtIndex:(NSInteger)index
{
    //完整系统消息并发布
    if (![[MyDataSourcemanager sharedManager] showHolleMessageAtIndex:index]) {
        return;
    }
    NSMutableDictionary* dic = [[NSMutableDictionary alloc] init];
    
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];//格式大小写很敏感药注意啊
    NSString *dateStr = [formatter stringFromDate:date];
    [dic setObject:dateStr forKey:@"createdTime"];
    MessageType type = TextMessage;
    [dic setObject:[NSNumber numberWithInteger:type] forKey:@"messageType"];
    [dic setObject:[MyDataSourcemanager helloMessageAccordingToTime] forKey:@"textMessage"];
    MessageOriation oriation = isFormSystem;
    [dic setObject:[NSNumber numberWithInteger:oriation] forKey:@"messageOriation"];
    UIImage *image = [UIImage imageWithData:[MyUserManager targetThumbnailAtIndex:index]];
    [dic setObject:image forKey:@"thumbnail"];
    [dic setObject:[MyUserManager targetNameAtIndex:index] forKey:@"userName"];
    MyMessage *newMessage = [[MyMessage alloc] initWithDic:dic];
    newMessage.showTimeLabel = YES;
    MyCellFrame *frame = [[MyCellFrame alloc] initWithMessage:newMessage];
    
    if (![MyDataSourcemanager sharedManager].dataSource) {
        [MyDataSourcemanager sharedManager].dataSource = [NSMutableArray array];
    }
    [[MyDataSourcemanager sharedManager].dataSource addObject:frame];
    [[MyDataSourcemanager sharedManager] insertMessage:newMessage index:index];
    [[MyDataSourcemanager sharedManager].delegate newMessageAdded:frame];
    
}

+ (void)creatNewTableAtIndex:(NSInteger)index
{
    [[MyDataSourcemanager sharedManager] creatNewTableWithIndex:index];
}

- (void)setupDB
{
    //数据库初始化，存在 db文件则打开该文件若不存在则创建并创建第一个表
    NSString *directory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *path = [directory stringByAppendingPathComponent:@"messages.db"];
    
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:path] == NO) {
        NSLog(@"create new table");
        db = [FMDatabase databaseWithPath:path];
        if ([db open]) {
            NSString *sql = @"create table 'target0' ('id' INTEGER PRIMARY KEY AUTOINCREMENT  NOT NULL, 'createdTime' TEXT, 'messageType' INTEGER, 'messageOriation' INTEGER, 'messageBody' TEXT, 'showTimeLabel' INTEGER, 'voiceDuration' INTEGER)";
            BOOL res = [db executeUpdate:sql];
            if (!res) {
                NSLog(@"%@",[db lastError]);
            }else
                NSLog(@"create table");
            [db close];
        }else
            NSLog(@"error when open db");
    }else
    { db = [FMDatabase databaseWithPath:path];
        NSLog(@"already has a db");
    }
    
}

- (NSInteger)numOfMessgesAtIndex:(NSInteger)index
{
    //消息数量
    if ([db open]) {
        NSInteger count = 0;
        NSString *sql = [NSString stringWithFormat:@"select (id) from target%li",(long)index];
        FMResultSet *res = [db executeQuery:sql];
        while ([res next]) {
            count++;
        }
        return count;
    }else
    {
         NSLog(@"error when open db");
        return -1;
    }
}

- (NSInteger)numOfTextMessageAtIndex:(NSInteger)index
{
    //文本消息数量
    if ([db open]) {
        NSInteger count = 0;
        NSString *sql = [NSString stringWithFormat:@"select (id) from target%li where messageType = 0",(long)index];
        FMResultSet *res = [db executeQuery:sql];
        while ([res next]) {
            count++;
        }
        return count;
    }else
    {
        NSLog(@"error when open db");
        return -1;
    }
}

- (NSInteger)numOfPicMessageAtIndex:(NSInteger)index
{
    //图片消息数量
    if ([db open]) {
        NSInteger count = 0;
        NSString *sql = [NSString stringWithFormat:@"select (id) from target%li where messageType = 1",(long)index];
        FMResultSet *res = [db executeQuery:sql];
        while ([res next]) {
            count++;
        }
        return count;
    }else
    {
        NSLog(@"error when open db");
        return -1;
    }
}

- (NSInteger)numOfVoiceMessageAtIndex:(NSInteger)index
{
    //语音消息数量
    if ([db open]) {
        NSInteger count = 0;
        NSString *sql = [NSString stringWithFormat:@"select (id) from target%li where messageType = 2",(long)index];
        FMResultSet *res = [db executeQuery:sql];
        while ([res next]) {
            count++;
        }
        return count;
    }else
    {
        NSLog(@"error when open db");
        return -1;
    }
}

- (void)creatNewTableWithIndex:(NSInteger)index
{
    //创建新的表以存储新建对象消息
    if ([db open]) {
        NSString *sql = [NSString stringWithFormat:@"create table 'target%li' ('id' INTEGER PRIMARY KEY AUTOINCREMENT  NOT NULL, 'createdTime' TEXT, 'messageType' INTEGER, 'messageOriation' INTEGER, 'messageBody' TEXT, 'showTimeLabel' INTEGER, 'voiceDuration' INTEGER)",(long)index];
        BOOL res = [db executeUpdate:sql];
        if (!res) {
            NSLog(@"%@",[db lastError]);
        }else
            NSLog(@"creat table");
        [db close];
    }else
        NSLog(@"error when open db");
}

- (void)insertMessage:(MyMessage *)message index:(NSInteger)index
{
    //新消息存储
    switch (message.messageType) {
        case 0:
            message.messageBody = message.textMessage;
            break;
        case 1:
            message.messageBody = [message.picMessage storeTheImage];
            break;
        case 2:
            message.messageBody = [message.voiceMessage storeTheData];
            break;
        default:
            break;
    }
    if ([db open]) {
        NSString *sql = [NSString stringWithFormat:@"insert into target%li (createdTime,messageType,messageOriation,messageBody,showTimeLabel,voiceDuration) values(?,?,?,?,?,?)",(long)index];
        NSInteger show = message.showTimeLabel? 1:0;
        BOOL res = [db executeUpdate:sql, message.createdTime, [NSNumber numberWithInteger:message.messageType], [NSNumber numberWithInteger:message.messageOriation], message.messageBody,[NSNumber numberWithInteger:show], [NSNumber numberWithInteger:message.voiceDuration]];
        if (!res) {
            NSLog (@"error to insert data");
        } else {
            NSLog(@"succ to insert data");
        }
        [db close];
    }
}

- (void)removeAllMessageAtIndex:(NSInteger)index
{
    //清除某一对象的所有消息
    if ([db open]) {
        NSString* sql = [NSString stringWithFormat:@"delete from target%li",(long)index];
        BOOL res = [db executeUpdate:sql];
        if (!res) {
            NSLog (@"error to delete data");
        } else {
            NSLog(@"succ to delete data");
        }
        [db close];
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        path = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"images%li",(long)index]];
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            NSError *error;
            [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
            if (error) {
                NSLog(@"%@",error);
            }
        }
        
        NSString *path2 = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        path2 = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"voices%li",(long)index]];
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            NSError *error;
            [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
            if (error) {
                NSLog(@"%@",error);
            }
        }
    });
}

- (void)deleteMessage:(MyMessage *)message index:(NSInteger)index
{
    //删除一条消息
    if ([db open]) {
        NSString* sql = [NSString stringWithFormat:@"delete from target%li where createdTime = ?",(long)index];
        BOOL res = [db executeUpdate:sql,message.createdTime];
        if (!res) {
            NSLog (@"error to delete data");
        } else {
            NSLog(@"succ to delete data");
        }
        [db close];
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (message.messageType == 0) {
            return;
        }else
        {
            NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
            NSError *error;
            if (message.messageType == 1) {
                path = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"images%li/%@",(long)index,message.picMessage]];
            }else
            {
                path = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"voices%li/%@",(long)index,message.voiceMessage]];
            }
            if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
                [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
                if (error) {
                    NSLog(@"%@",error);
                }
            }
        }
    });
}

- (void)loadMoreMessageAtIndex:(NSInteger)index totalCount:(NSInteger)count
{
    //加载某对象的特定数量的消息
    [self.dataSource removeAllObjects];
    if ([db open]) {
        NSString* sql = [NSString stringWithFormat:@"select * from (select * from target%li order by id desc limit %li) order by id asc",(long)index,(long)count];
        FMResultSet *result = [db executeQuery:sql];
        while ([result next]) {
            MyMessage *message = [[MyMessage alloc] init];
            message.createdTime = [result stringForColumn:@"createdTime"];
            message.messageType = [result intForColumn:@"messageType"];
            message.messageOriation = [result intForColumn:@"messageOriation"];
            NSInteger show = [result intForColumn:@"showTimeLabel"];
            message.showTimeLabel = ((show == 1)? YES:NO);
            message.messageBody = [result stringForColumn:@"messageBody"];
            message.voiceDuration = [result intForColumn:@"voiceDuration"];
            [message completeTheMessage];
            
            MyCellFrame *frame = [[MyCellFrame alloc] initWithMessage:message];
            [self.dataSource addObject:frame];
        }
        [db close];
    }else
        NSLog(@"error when open db");
}

- (void)modifyTheTimeLabelTo:(BOOL)showTimeLabel message:(MyMessage *)message index:(NSInteger)index
{
    //更改时间标签显示属性
    if ([db open]) {
        NSString *sql = [NSString stringWithFormat:@"update target%li set showTimeLabel = ? where createdTime = ?",(long)index];
        [db executeUpdate:sql,(showTimeLabel? @1:@0),message.createdTime];
        [db close];
    }else
        NSLog(@"error when open db");
}

- (NSInteger)numOfTables
{
    //db文件中表的数量
    NSInteger count = 0;
    if ([db open]) {
        NSString* sql = @"select name from sqlite_master where type = 'table'";
       FMResultSet *res = [db executeQuery:sql];
        while ([res next]) {
            count++;
        }
        [db close];
    }else
        NSLog(@"error when open db");
    return count;
}

#pragma define will show Hello Message or not
- (BOOL)showHolleMessageAtIndex:(NSInteger)index
{
    //是否添加系统信息
    if ([db open]) {
        NSString *lastMessageTime;
        NSString* sql = [NSString stringWithFormat:@"select * from target%li order by id desc limit 1",(long)index];
        FMResultSet *result = [db executeQuery:sql];
        while ([result next]) {
            lastMessageTime = [result stringForColumn:@"createdTime"];
        }
        [db close];
        if (lastMessageTime) {
            NSString *sunEnd = [lastMessageTime substringWithRange:NSMakeRange(0, 19)];
            NSDate *endDate = [NSDate dateFromString:sunEnd withFormat:@"yyyy-MM-dd HH:mm:ss"];
            
            NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:endDate];
            if (fabs (timeInterval) > 21600) {
                return YES;
            }
        }else
            return YES;
        return NO;
    }else
    {
        NSLog(@"error when open db");
        return NO;
    }
}
#pragma process cell timeLabel

- (BOOL)timeOffsetBetweenStartDate:(NSString *)startDateStr toEndStr:(NSString *)endDateStr
{
    if (!startDateStr) {
        return YES;
    }
    
    NSString *subStart = [startDateStr substringWithRange:NSMakeRange(0, 19)];
    NSDate *startDate = [NSDate dateFromString:subStart withFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSString *sunEnd = [endDateStr substringWithRange:NSMakeRange(0, 19)];
    NSDate *endDate = [NSDate dateFromString:sunEnd withFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSTimeInterval timeInterval = [startDate timeIntervalSinceDate:endDate];
    
    if (fabs (timeInterval) > 3000) {
        return YES;
    }else{
        return NO;
    }
}
@end
