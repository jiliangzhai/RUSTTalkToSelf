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
    
    //活跃天数
    [MyUserManager newActiveDay];
    //变量初始值
    currentIndex = [MyUserManager lastTargetIndex];
    MyOriation = isFormSelf;
    self.needRefresh = NO;
    [MyDataSourcemanager sharedManager].delegate = self;
    //inputView和spreadButton
    [self layoutUI];
    //确定要加载的消息
    [self prepareLoadDataAtIndex:currentIndex];
    [self.MyTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.MyTableView.backgroundColor = [UIColor colorWithRed:255/255.0 green:248/255.0 blue:220/255.0 alpha:1.0];
    
    //添加tap以关闭键盘
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [self.view addGestureRecognizer:tap];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    currentIndex = [MyUserManager lastTargetIndex];
    //当视图出现或重新出现时判断是否需要刷新操作
    if (self.needRefresh) {
        currentIndex = [MyUserManager lastTargetIndex];
        totalNum = [MyDataSourcemanager numOfMessageAtindex:currentIndex];
        self.needRefresh = NO;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [MyDataSourcemanager reloadMessageNum:MIN(totalNum, 5) index:currentIndex];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.MyTableView reloadData];
            });
        });
    }
   
    [UIApplication sharedApplication].statusBarHidden = NO;
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //开启系统对话状态下判断是否需要发送消息
    if ([MyUserManager willShowSystemmessage]) {
         [self addOneHelloMessageFromSystem];
    }
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardChanged:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardChanged:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tableViewScrollToBottom) name:UIKeyboardDidShowNotification object:nil];
    
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
    //输入框
    inputView = [[MyInputView alloc] initPrivate];
    [self.view addSubview:inputView];
    inputView.delegate = self;
    inputView.superController = self;
    //下拉刷新
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    [refresh addTarget:self action:@selector(tableviewNeedRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.MyTableView addSubview:refresh];
    //多选按钮
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
    //初次加载至多5条消息
    totalNum = [MyDataSourcemanager numOfMessageAtindex:currentIndex];
    if (![MyDataSourcemanager dataSources]) {
        if (totalNum != 0) {
            [MyDataSourcemanager dataSourcesWithNum:MIN(totalNum, 5) index:index];
        }
    }
}

- (void)keyboardChanged:(NSNotification *)notification
{
    //根据键盘的出现消失，调整输入框的位置，动作尽量协调
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
    
    [self.view layoutIfNeeded];
    
    CGRect frame = inputView.frame;
    frame.origin.y = keyboardFrameEnd.origin.y - CGRectGetHeight(frame);
    inputView.frame = frame;
    
    [UIView commitAnimations];
}

- (void)tableViewScrollToBottom
{
    //使最后一条消息可见
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
    [self.view endEditing:YES];//滑动视图，结束编辑状态，键盘会收回
}

#pragma MyTableViewCellDelegate
- (void)thumbnailClickedWithMessageOriation:(MessageOriation)oriation
{
    //点击用户和对象头像进入对应的编辑界面
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
    //长按对象头像，调出弹球效果
    if (oriation == isFormSystem) {
        MyBounceView *view = [[MyBounceView alloc] initWithFrame:self.view.bounds image:[UIImage imageWithData:[MyUserManager targetThumbnailAtIndex:currentIndex]] startLocation:location];
        view.backgroundColor = [UIColor clearColor];
        view.alpha = 1.0;
        [self.view addSubview:view];
    }
}

- (void)deleteCell:(MyTableViewCell *)cell
{
    //cell删除
    [MyDataSourcemanager removeMessage:cell.cellFrame index:currentIndex];
    NSIndexPath *path = [self.MyTableView indexPathForCell:cell];
    [self.MyTableView deleteRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationLeft];
}

#pragma inputView Delegate
- (void)heightOfTextViewChangedBy:(float)height
{
    //根据输入textView中的文本高度，调整inputView的位置
    _bottomConstraint.constant +=height;
    [self.view layoutIfNeeded];
    [self tableViewScrollToBottom];
}

- (void)sendTextMessage:(NSString *)textMessage
{
    //文本输入
    inputView.textInputView.text = @"";
    [inputView changeSendButton:YES];
    NSMutableDictionary* dic = [self MessageDicWithMessageType:TextMessage];
    [dic setObject:textMessage forKey:@"textMessage"];
    MyMessage *newMessage = [[MyMessage alloc] initWithDic:dic];
    [MyDataSourcemanager addMessage:newMessage index:currentIndex];
}

- (void)sendPicMessage:(UIImage *)Pic
{
    //图片输入
    NSMutableDictionary* dic = [self MessageDicWithMessageType:PicMessage];
    [dic setObject:Pic forKey:@"picMessage"];
    MyMessage *newMessage = [[MyMessage alloc] initWithDic:dic];
    [MyDataSourcemanager addMessage:newMessage index:currentIndex];
}

- (void)sentVoiceMessage:(NSData *)voiceMessage duration:(NSInteger)duration
{
    //语音输入
    NSMutableDictionary* dic = [self MessageDicWithMessageType:VoiceMessage];
    [dic setObject:voiceMessage forKey:@"voiceMessage"];
    [dic setObject:[NSNumber numberWithInteger:duration] forKey:@"voiceDuration"];
    MyMessage *newMessage = [[MyMessage alloc] initWithDic:dic];
    [MyDataSourcemanager addMessage:newMessage index:currentIndex];
}

- (NSMutableDictionary *)MessageDicWithMessageType:(MessageType)type
{
    //生成消息的初始化词典
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
    //结束编辑状态
    [self.view endEditing:YES];
}

#pragma MyDataSourceDelegate
- (void)newMessageAdded:(MyCellFrame *)cellFrame
{
    //tabelView添加新消息
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

#pragma add One Hello Message
- (void)addOneHelloMessageFromSystem
{
    //添加一条系统消息
    [MyDataSourcemanager initSystemMessageAtIndex:currentIndex];
}

#pragma refresh
- (void)tableviewNeedRefresh:(UIRefreshControl *)refresh
{
    //下拉刷新
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
            [self.MyTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        });
    });
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end







