//
//  MyViewController.m
//  TalkToSelf
//
//  Created by rust_33 on 16/2/26.
//  Copyright © 2016年 rust_33. All rights reserved.
//

#import "MyViewController.h"
#import "MyRecordProgressView.h"
#import "MyImageBrowser.h"
#import "MyTableViewCell.h"
#import "MyCellFrame.h"
#import "MyMessage.h"
#import "MyInputView.h"
#import "MyDataSourcemanager.h"
#import "MyUserManager.h"
#import "BounceView.h"
#import "MyUserInformationEditor.h"
#import "MyTargetEditorController.h"
#import "ZYSpreadButton.h"
#import "ZYSpreadSubButton.h"
#import "MyStatisticsController.h"
#import "MyBounceView.h"

@interface MyViewController ()<MyInputViewDelegate,MyCellDelegate,MyDateSourceDelegate,UITableViewDataSource,UITableViewDelegate>
{
    MyInputView *inputView;
    NSString *lastCreatedTime;
    NSInteger totalNum;
    NSInteger currentIndex;
    CGPoint currentLocation;
    MessageOriation MyOriation;
}
@property (weak, nonatomic) IBOutlet UITableView *MyTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;

@end

@implementation MyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    self.navigationController.navigationBarHidden = YES;
    self.MyTableView.showsVerticalScrollIndicator = NO;
    
    [MyUserManager newActiveDay];
    currentIndex = [MyUserManager lastTargetIndex];
    MyOriation = isFormSelf;
    [MyDataSourcemanager sharedManager].delegate = self;
    [self layoutUI];
    [self.MyTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [self.view addGestureRecognizer:tap];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (currentIndex != [MyUserManager lastTargetIndex]) {
        currentIndex = [MyUserManager lastTargetIndex];
        totalNum = [MyDataSourcemanager numOfMessageAtindex:currentIndex];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [MyDataSourcemanager reloadMessageNum:MIN(totalNum, 5) index:currentIndex];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.MyTableView reloadData];
            });
        });
    }else
    {
        [self prepareLoadDataAtIndex:currentIndex];
        [self.MyTableView reloadData];
    }
   
    [UIApplication sharedApplication].statusBarHidden = NO;
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ([MyUserManager willShowSystemmessage]) {
         [self addOneHelloMessageFromSystem];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardChanged:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardChanged:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tableViewScrollToBottom) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userInfoDidChanged) name:@"userInfoDidChanged" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newTargetCreated) name:@"newTargetCreated" object:nil];
    [self tableViewScrollToBottom];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (void)layoutUI
{
    inputView = [[MyInputView alloc] initPrivate];
    [self.view addSubview:inputView];
    inputView.delegate = self;
    inputView.superController = self;
    
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    [refresh addTarget:self action:@selector(tableviewNeedRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.MyTableView addSubview:refresh];
    
    ZYSpreadSubButton *sub1 = [[ZYSpreadSubButton alloc] initWithBackgroundImage:[UIImage imageNamed:@"btn1.png"] highlightImage:nil clickedBlock:^(int index, UIButton *sender) {
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        MyUserInformationEditor *userInfo = [story instantiateViewControllerWithIdentifier:@"MyUserInfo"];
        self.navigationController.navigationBarHidden = NO;
        [self.navigationController pushViewController:userInfo animated:YES];
    }];
    ZYSpreadSubButton *sub2 = [[ZYSpreadSubButton alloc] initWithBackgroundImage:[UIImage imageNamed:@"btn2.png"] highlightImage:nil clickedBlock:^(int index, UIButton *sender) {
        MyTargetEditorController *editor = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"MyTargetsEditorController"];
        self.navigationController.navigationBarHidden = NO;
        [self.navigationController pushViewController:editor animated:YES];
    }];
    ZYSpreadSubButton *sub3 = [[ZYSpreadSubButton alloc] initWithBackgroundImage:[UIImage imageNamed:@"btn3.png"] highlightImage:nil clickedBlock:^(int index, UIButton *sender) {
        if (MyOriation == isFormSelf) {
            MyOriation = isFormSystem;
        }else
            MyOriation = isFormSelf;
    }];
    ZYSpreadSubButton *sub4 = [[ZYSpreadSubButton alloc] initWithBackgroundImage:[UIImage imageNamed:@"btn4.png"] highlightImage:nil clickedBlock:^(int index, UIButton *sender) {
        MyStatisticsController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@" MyStatisticsController"];
        [self.navigationController pushViewController:vc animated:YES];
    }];
    ZYSpreadButton *button = [[ZYSpreadButton alloc] initWithBackgroundImage:[UIImage imageNamed:@"powerButton"] highlightImage:nil position:CGPointMake([UIScreen mainScreen].bounds.size.width - 28, [UIScreen mainScreen].bounds.size.height-150)];
    [button setSubButtons:@[sub1,sub2,sub3,sub4]];
    [self.view addSubview:button];
    button.mode = SpreadModeSickleSpread;
    button.direction = SpreadDirectionLeft;
    button.radius = 70;
    button.positionMode = SpreadPositionModeTouchBorder;
}

- (void)prepareLoadDataAtIndex:(NSInteger)index
{
    totalNum = [MyDataSourcemanager numOfMessageAtindex:currentIndex];
    if (![MyDataSourcemanager dataSources]) {
        if (totalNum != 0) {
            [MyDataSourcemanager dataSourcesWithNum:MIN(totalNum, 5) index:index];
        }
    }
}

- (void)keyboardChanged:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    NSTimeInterval animationDuration;
    UIViewAnimationCurve curve;
    CGRect keyboardFrameEnd;
    
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&curve];
    [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardFrameEnd];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:curve];
    
    if (notification.name == UIKeyboardWillShowNotification) {
        _bottomConstraint.constant = CGRectGetHeight(keyboardFrameEnd)+50;
    }else
        _bottomConstraint.constant = 50;
    
    [self.view layoutIfNeeded];//find out what it works for
    
    CGRect frame = inputView.frame;
    frame.origin.y = keyboardFrameEnd.origin.y - CGRectGetHeight(frame);
    inputView.frame = frame;
    
    [UIView commitAnimations];
}

- (void)tableViewScrollToBottom
{
    if ([MyDataSourcemanager dataSources].count == 0) {
        return;
    }
    
    NSIndexPath *path = [NSIndexPath indexPathForRow:[MyDataSourcemanager dataSources].count-1 inSection:0];
    [self.MyTableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

#pragma TableView Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([MyDataSourcemanager dataSources]) {
        return [MyDataSourcemanager dataSources].count;
    }else
    {
        return MIN(totalNum, 5);
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MyTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"rust"];
    if (!cell) {
        cell = [[MyTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"rust"];
    };
    if ([MyDataSourcemanager dataSources]) {
        [cell setCellFrame:[[MyDataSourcemanager dataSources] objectAtIndex:indexPath.row]];//cellframe中包含message所以source应该是包含cellframe的数组
    }
    cell.delegate = self;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    lastCreatedTime = cell.cellFrame.message.createdTime;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    MyCellFrame *frame = [[MyDataSourcemanager dataSources] objectAtIndex:indexPath.row];
    return frame.cellHeight;
  
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.view endEditing:YES];//关闭键盘用的
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self.view endEditing:YES];
}

#pragma MyTableViewCellDelegate
- (void)thumbnailClickedWithMessageOriation:(MessageOriation)oriation
{
    if (oriation == isFormSelf) {
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        MyUserInformationEditor *userInfo = [story instantiateViewControllerWithIdentifier:@"MyUserInfo"];
        self.navigationController.navigationBarHidden = NO;
        [self.navigationController pushViewController:userInfo animated:YES];
    }else
    {
        MyTargetEditorController *editor = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"MyTargetsEditorController"];
        self.navigationController.navigationBarHidden = NO;
        [self.navigationController pushViewController:editor animated:YES];
    }
}

- (void)thumbnailLongPressedAtLocation:(CGPoint)location messageOriation:(MessageOriation)oriation
{
    if (oriation == isFormSystem) {
        MyBounceView *view = [[MyBounceView alloc] initWithFrame:self.view.bounds image:[UIImage imageWithData:[MyUserManager targetThumbnailAtIndex:currentIndex]] startLocation:location];
        view.backgroundColor = [UIColor clearColor];
        view.alpha = 1.0;
        [self.view addSubview:view];
    }
}

- (void)deleteCell:(MyTableViewCell *)cell
{
    [MyDataSourcemanager removeMessage:cell.cellFrame index:currentIndex];
    
    NSIndexPath *path = [self.MyTableView indexPathForCell:cell];
    [self.MyTableView deleteRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationLeft];
}

#pragma inputView Delegate
- (void)heightOfTextViewChangedBy:(float)height
{
    _bottomConstraint.constant +=height;
    [self.view layoutIfNeeded];
    [self tableViewScrollToBottom];
}

- (void)sendTextMessage:(NSString *)textMessage
{
    inputView.textInputView.text = @"";
    [inputView changeSendButton:YES];
    NSMutableDictionary* dic = [self MessageDicWithMessageType:TextMessage];
    [dic setObject:textMessage forKey:@"textMessage"];
    MyMessage *newMessage = [[MyMessage alloc] initWithDic:dic];
    [MyDataSourcemanager addMessage:newMessage index:currentIndex];
}

- (void)sendPicMessage:(UIImage *)Pic
{
    NSMutableDictionary* dic = [self MessageDicWithMessageType:PicMessage];
    [dic setObject:Pic forKey:@"picMessage"];
    MyMessage *newMessage = [[MyMessage alloc] initWithDic:dic];
    [MyDataSourcemanager addMessage:newMessage index:currentIndex];
}

- (void)sentVoiceMessage:(NSData *)voiceMessage duration:(NSInteger)duration
{
    NSMutableDictionary* dic = [self MessageDicWithMessageType:VoiceMessage];
    [dic setObject:voiceMessage forKey:@"voiceMessage"];
    [dic setObject:[NSNumber numberWithInteger:duration] forKey:@"voiceDuration"];
    MyMessage *newMessage = [[MyMessage alloc] initWithDic:dic];
    [MyDataSourcemanager addMessage:newMessage index:currentIndex];
}

- (NSMutableDictionary *)MessageDicWithMessageType:(MessageType)type
{
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];//格式大小写很敏感药注意啊
    NSString *dateStr = [formatter stringFromDate:date];
    NSString *userName = nil;
    UIImage *thumbnail = nil;

    MessageOriation oriation = MyOriation;
    if (oriation == isFormSelf) {
        userName = [MyUserManager userName];
        thumbnail = [UIImage imageWithData:[MyUserManager userThumbnail]];
    }else
    {
        userName = [MyUserManager targetNameAtIndex:currentIndex];
        thumbnail = [UIImage imageWithData:[MyUserManager targetThumbnailAtIndex:currentIndex]];
    }
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:userName forKey:@"userName"];
    [dic setObject:thumbnail forKey:@"thumbnail"];
    [dic setObject:dateStr forKey:@"createdTime"];
    [dic setObject:[NSNumber numberWithInteger:oriation] forKey:@"messageOriation"];
    [dic setObject:[NSNumber numberWithInteger:type] forKey:@"messageType"];
    
    return dic;
}

- (void)tap:(UITapGestureRecognizer*)tap
{
    [self.view endEditing:YES];
}

#pragma MyDataSourceDelegate
- (void)newMessageAdded:(MyCellFrame *)cellFrame
{
    MyTableViewCell *cell = [self.MyTableView dequeueReusableCellWithIdentifier:@"rust"];
    if (!cell) {
        cell = [[MyTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"rust"];
    };
    [cell setCellFrame:cellFrame];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSIndexPath *path = [NSIndexPath indexPathForRow:[MyDataSourcemanager dataSources].count-1 inSection:0];
    [self.MyTableView insertRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationRight];
    [self tableViewScrollToBottom];
}

#pragma userInfoNotification
- (void)userInfoDidChanged
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [MyDataSourcemanager reloadMessageNum:MIN(totalNum, 5) index:currentIndex];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.MyTableView reloadData];
        });
    });
}

#pragma newTargetCreated Notification
- (void)newTargetCreated
{
    currentIndex = [MyUserManager lastTargetIndex];
    [MyDataSourcemanager creatNewTableAtIndex:currentIndex];
    totalNum = [MyDataSourcemanager numOfMessageAtindex:currentIndex];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [MyDataSourcemanager reloadMessageNum:MIN(totalNum, 5) index:currentIndex];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.MyTableView reloadData];
        });
    });
}

#pragma add One Hello Message
- (void)addOneHelloMessageFromSystem
{
    [MyDataSourcemanager initSystemMessageAtIndex:currentIndex];
}

#pragma refresh
- (void)tableviewNeedRefresh:(UIRefreshControl *)refresh
{
    NSInteger num = [self.MyTableView numberOfRowsInSection:currentIndex];
    totalNum = [MyDataSourcemanager numOfMessageAtindex:currentIndex];
    if (num >= totalNum) {
        [refresh endRefreshing];
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSInteger targetNum = MIN(totalNum, num+5);
        [MyDataSourcemanager dataSourcesWithNum:targetNum index:currentIndex];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.MyTableView reloadData];
            [refresh endRefreshing];
            [self.MyTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:targetNum-num inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        });
    });
}
@end







