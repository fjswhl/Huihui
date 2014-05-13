//
//  LINMoodCommentViewController.m
//  Huihui
//
//  Created by Lin on 14-5-13.
//  Copyright (c) 2014年 Lin. All rights reserved.
//

#import "LINMoodCommentViewController.h"
#import "NSDate+Helper.h"
#import <objc/runtime.h>
#import "MKNetworkKit.h"
#import "LINMoodComment.h"
#import "UIColor+LINColor.h"

NSString *const __apiFetchComment = @"index.php/Mood/fetchcomment";
NSString *const __apiNewComment = @"index.php/Mood/newcomment";
extern NSString *const __apiThumbUp;
extern NSString *const __apiThumbDown;

@interface LINMoodCommentViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *toolBar;

@property (weak, nonatomic) MKNetworkEngine *engine;

@property (strong, nonatomic) NSMutableArray *commentArray;

@property (nonatomic) BOOL keyboardIsShown;

@property (nonatomic) CGFloat keyboardHeight;

@end

@implementation LINMoodCommentViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"%@", self.mood.moodId);
    
    // Do any additional setup after loading the view.
    [self fetchComment];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Getter
- (MKNetworkEngine *)engine{
    if (!_engine) {
        id delegate = [[UIApplication sharedApplication] delegate];
        _engine = [delegate engine];
    }
    return _engine;
}

- (NSMutableArray *)commentArray{
    if (!_commentArray) {
        _commentArray = [NSMutableArray new];
    }
    return _commentArray;
}


#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 1;
    }else{
        return [self.commentArray count];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return 202;
    }else{
        
        CGSize constraint = CGSizeMake(280, 20000);
        LINMoodComment *moodComment = [[LINMoodComment alloc] initWithDictionary: self.commentArray[indexPath.row]];
        CGSize size = [moodComment.content boundingRectWithSize:constraint options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14]} context:nil].size;
        NSLog(@"%lf", size.height);
        return size.height + 30;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"secretCell"];
        UILabel *label = (UILabel *)[cell.contentView viewWithTag:1];
        UILabel *timeLabel = (UILabel *)[cell.contentView viewWithTag:4];
        UIButton *thumbupButton = (UIButton *)[cell.contentView viewWithTag:2];
        UIButton *commentButton = (UIButton *)[cell.contentView viewWithTag:3];
        
        //  NSLog(@"%@", self.moodArray[indexPath.row]);
        
        label.text = self.mood.content;
        //  [textView addObserver:self forKeyPath:@"contentSize" options:(NSKeyValueObservingOptionNew) context:NULL];
        static char cellKey;
        NSString *setted = objc_getAssociatedObject(cell, &cellKey);
        if (!setted) {
            objc_setAssociatedObject(cell, &cellKey, @"0", OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            [cell.contentView addObserver:self forKeyPath:@"backgroundColor" options:(NSKeyValueObservingOptionNew) context:NULL];
            [thumbupButton addTarget:self action:@selector(thumbupButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            [commentButton addTarget:self action:@selector(commentButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            
        }
        cell.contentView.backgroundColor = self.mood.bgColor;
        
        timeLabel.text = [NSDate timeFlagWithDate:self.mood.date];
        [thumbupButton setTitle:[NSString stringWithFormat:@"%@", self.mood.numofthumbup] forState:UIControlStateNormal];
        [commentButton setTitle:[NSString stringWithFormat:@"%@", self.mood.numofcomment] forState:UIControlStateNormal];
        if ([self.mood.isthumbup isEqualToString:@"no"]) {
            thumbupButton.selected = NO;
        }else{
            thumbupButton.selected = YES;
        }
        return cell;
    }else if (indexPath.section == 1){
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"commentCell"];
        UILabel *commentContentLabel = (UILabel *)[cell.contentView viewWithTag:1];
        UILabel *additionInfoLabel = (UILabel *)[cell.contentView viewWithTag:2];
        
        LINMoodComment *aComment = [[LINMoodComment alloc] initWithDictionary:self.commentArray[indexPath.row]];
        commentContentLabel.text = aComment.content;
        
        additionInfoLabel.text = [NSString stringWithFormat:@"%li楼  ", (long)(indexPath.row + 1)];
        additionInfoLabel.text = [additionInfoLabel.text stringByAppendingString:[NSDate timeFlagWithDate:aComment.date]];
        if ([aComment.isMe integerValue] == 1) {
            additionInfoLabel.text = [additionInfoLabel.text stringByAppendingString:@"  我"];
            commentContentLabel.textColor = [UIColor preferredColor];
        }else{
            additionInfoLabel.text = [additionInfoLabel.text stringByAppendingString:@"  朋友"];
        }
        return cell;
    }
    return nil;
}

#pragma mark - KVO and Notification

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"backgroundColor"]){
        UIView *contentView = object;
        //        CGFloat saturation;
        //        CGFloat brightness;
        CGFloat red;
        CGFloat green;
        CGFloat blue;
        //     [textView.backgroundColor getHue:NULL saturation:&saturation brightness:&brightness alpha:NULL];
        UILabel *label = (UILabel *)[contentView viewWithTag:1];
        
        [contentView.backgroundColor getRed:&red green:&green blue:&blue alpha:NULL];
        if ((red + green + blue) * 255 > 200) {
            label.textColor = [UIColor whiteColor];
        }else{
            label.textColor = [UIColor blackColor];
        }
    }
}

- (void)keyboardWillShow:(NSNotification *)notification{
    NSDictionary *userInfo = [notification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    CGRect keyboardRect = [aValue CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    [UIView animateWithDuration:animationDuration animations:^{
        CGRect frame = self.toolBar.frame;
        frame.origin.y -= keyboardRect.size.height;
        self.toolBar.frame = frame;
    }];
    self.keyboardIsShown = true;
    self.keyboardHeight = keyboardRect.size.height;
}

- (void)keyboardWillHide:(NSNotification *)notification{
    NSDictionary *userInfo = [notification userInfo];
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    
    
    [UIView animateWithDuration:animationDuration animations:^{
        CGRect frame = self.toolBar.frame;
        frame.origin.y += self.keyboardHeight;
        self.toolBar.frame = frame;
        
    }];
    self.keyboardHeight = 0;
    self.keyboardIsShown = false;
}

- (void)keyboardDidHide:(NSNotification *)notification{
    
}
#pragma mark - Server

- (void)fetchComment{
    MKNetworkOperation *op = [self.engine operationWithPath:__apiFetchComment params:@{@"length":@(99), @"page":@(1), @"moodid":self.mood.moodId} httpMethod:@"POST"];
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSDictionary *dic = [completedOperation responseJSON];
        NSLog(@"%@", dic);
        /**
         *  error == 2 的话表示没有评论
         */
        [self.commentArray addObjectsFromArray:dic[@"success"][@"list"]];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
#warning wait
    }];
    [self.engine enqueueOperation:op];
}

- (void)thumbupWithMood:(LINMood *)mood{
    MKNetworkOperation *op = [self.engine operationWithPath:__apiThumbUp
                                                     params:@{@"moodid":mood.moodId}
                                                 httpMethod:@"POST"];
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSDictionary *dic = [completedOperation responseJSON];
        NSLog(@"%@", dic);
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
#warning wait
    }];
    [self.engine enqueueOperation:op];
}

- (void)thumbDownWithMood:(LINMood *)mood{
    MKNetworkOperation *op = [self.engine operationWithPath:__apiThumbDown
                                                     params:@{@"moodid":mood.moodId}
                                                 httpMethod:@"POST"];
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSDictionary *dic = [completedOperation responseJSON];
        NSLog(@"%@", dic);
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
#warning wait
    }];
    [self.engine enqueueOperation:op];
}


- (void)thumbupButtonTapped:(id)sender{
    UIButton *button = sender;
    
    // [self thumbupWithMood:mood];
    // NSLog(@"%@", mood.moodId);
    if (button.selected) {
        button.selected = false;
        NSString *buttonTitle = [button titleForState:UIControlStateSelected];
        [button setTitle:[NSString stringWithFormat:@"%li",(long)([buttonTitle integerValue] - 1) ] forState:UIControlStateNormal];
        
        [self thumbDownWithMood:self.mood];
    }else{
        button.selected = true;
        NSString *buttonTitle = [button titleForState:UIControlStateNormal];
        [button setTitle:[NSString stringWithFormat:@"%li",(long)([buttonTitle integerValue] + 1) ]  forState:UIControlStateSelected];
        [self thumbupWithMood:self.mood];
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
