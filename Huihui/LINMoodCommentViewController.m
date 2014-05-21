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
#import "MBProgressHUD.h"

NSString *const __apiFetchComment = @"index.php/Mood/fetchcomment";
NSString *const __apiNewComment = @"index.php/Mood/newcomment";
extern NSString *const __apiThumbUp;
extern NSString *const __apiThumbDown;

@interface LINMoodCommentViewController ()<UITableViewDataSource, UITableViewDelegate, UITextViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *toolBar;
@property (strong, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) IBOutlet UIButton *postCommentButton;
@property (strong, nonatomic) IBOutlet UILabel *textViewPlaceHolder;


@property (weak, nonatomic) MKNetworkEngine *engine;

@property (strong, nonatomic) NSMutableArray *commentArray;

@property (nonatomic) BOOL keyboardIsShown;
@property (nonatomic) BOOL needShowNoCommentView;

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
   // NSLog(@"%@", self.mood.moodId);
    
    // Do any additional setup after loading the view.
    [self fetchComment];
    
   // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardFrameWillChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if ([self.needInstantComment integerValue] == 1) {
        double delayInSeconds = 0.3f;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.textView becomeFirstResponder];
        });

    }
}

- (void)setupUI{

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

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (section == 1) {
        if (self.needShowNoCommentView) {
            UIView *noCommentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 258)];
            noCommentView.backgroundColor = [UIColor whiteColor];
            UILabel *label = [UILabel new];
            label.textColor = [UIColor lightGrayColor];
            label.text = @"暂时没有评论";
            [label sizeToFit];
            label.layer.position = noCommentView.layer.position;
            [noCommentView addSubview:label];
            return noCommentView;
        }
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 1) {
        if (self.needShowNoCommentView) {
            return 258.0;
        }
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return 202;
    }else{
        
        CGSize constraint = CGSizeMake(280, 20000);
        LINMoodComment *moodComment = [[LINMoodComment alloc] initWithDictionary: self.commentArray[indexPath.row]];
        CGSize size = [moodComment.content boundingRectWithSize:constraint options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14]} context:nil].size;
       // NSLog(@"%lf", size.height);
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
        LINMood *mood = [[LINMood alloc] initWithDictionary:self.mood];
        label.text = mood.content;
        //  [textView addObserver:self forKeyPath:@"contentSize" options:(NSKeyValueObservingOptionNew) context:NULL];
        static char cellKey;
        NSString *setted = objc_getAssociatedObject(cell, &cellKey);
        if (!setted) {
            objc_setAssociatedObject(cell, &cellKey, @"0", OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//            [cell.contentView addObserver:self forKeyPath:@"backgroundColor" options:(NSKeyValueObservingOptionNew) context:NULL];
            [thumbupButton addTarget:self action:@selector(thumbupButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            [commentButton addTarget:self action:@selector(commentButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            
        }
        cell.contentView.backgroundColor = mood.bgColor;
        
        timeLabel.text = [NSDate timeFlagWithDate:mood.date];
        [thumbupButton setTitle:[NSString stringWithFormat:@"%@", mood.numofthumbup] forState:UIControlStateNormal];
        [commentButton setTitle:[NSString stringWithFormat:@"%@", mood.numofcomment] forState:UIControlStateNormal];
        if ([mood.isthumbup isEqualToString:@"no"] || mood.isthumbup == nil) {
            thumbupButton.selected = NO;
        }else{
            thumbupButton.selected = YES;
        }
        
        CGFloat saturation;
        [cell.contentView.backgroundColor getHue:NULL saturation:&saturation brightness:NULL alpha:NULL];
        if (saturation >= 0.5) {
            label.textColor = [UIColor whiteColor];
        }else{
            label.textColor = [UIColor blackColor];
        }
        return cell;
    }else if (indexPath.section == 1){
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"commentCell"];
        UILabel *commentContentLabel = (UILabel *)[cell.contentView viewWithTag:1];
        UILabel *additionInfoLabel = (UILabel *)[cell.contentView viewWithTag:2];
        
        LINMoodComment *aComment = [[LINMoodComment alloc] initWithDictionary:self.commentArray[indexPath.row]];
        commentContentLabel.text = aComment.content;
        
        additionInfoLabel.text = [NSString stringWithFormat:@"%li楼  ", (long)([self.commentArray count] - indexPath.row)];
        additionInfoLabel.text = [additionInfoLabel.text stringByAppendingString:[NSDate timeFlagWithDate:aComment.date]];
        if ([aComment.isMe integerValue] == 1) {
            additionInfoLabel.text = [additionInfoLabel.text stringByAppendingString:@"  我"];
            commentContentLabel.textColor = [UIColor preferredColor];
        }else{
            additionInfoLabel.text = [additionInfoLabel.text stringByAppendingString:@"  朋友"];
            commentContentLabel.textColor = [UIColor blackColor];
        }
        return cell;
    }
    return nil;
}

#pragma mark - TextViewDelegate

- (void)textViewDidChange:(UITextView *)textView{
    
    if ([[[textView.text stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@"　" withString:@""] isEqualToString:@""]) {
        [self.postCommentButton setEnabled:NO];
        [self.textViewPlaceHolder setHidden:NO];
    }else{
        [self.postCommentButton setEnabled:YES];
        [self.textViewPlaceHolder setHidden:YES];
    }
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

//- (void)keyboardWillShow:(NSNotification *)notification{
//    NSDictionary *userInfo = [notification userInfo];
//    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
//    
//    CGRect keyboardRect = [aValue CGRectValue];
//    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
//    
//    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
//    NSTimeInterval animationDuration;
//    [animationDurationValue getValue:&animationDuration];
//    
////    if (self.keyboardIsShown) {
////        return;
////    }
//    [UIView animateWithDuration:animationDuration animations:^{
//        CGRect frame = self.toolBar.frame;
//        frame.origin.y -= keyboardRect.size.height;
//        self.toolBar.frame = frame;
//    }];
//    self.keyboardIsShown = true;
//    self.keyboardHeight = keyboardRect.size.height;
//}

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

- (void)keyboardFrameWillChange:(NSNotification *)notification{
    NSDictionary *userInfo = [notification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    CGRect keyboardRect = [aValue CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    if (keyboardRect.size.height > self.keyboardHeight) {
        [UIView animateWithDuration:animationDuration animations:^{
            CGRect frame = self.toolBar.frame;
            frame.origin.y = frame.origin.y - (keyboardRect.size.height - self.keyboardHeight);
            self.toolBar.frame = frame;
        }];
    }else{
        [UIView animateWithDuration:animationDuration animations:^{
            CGRect frame = self.toolBar.frame;
            frame.origin.y = frame.origin.y + (self.keyboardHeight - keyboardRect.size.height);
            self.toolBar.frame = frame;
        }];
    }

    self.keyboardIsShown = true;
    self.keyboardHeight = keyboardRect.size.height;
}

- (void)keyboardDidHide:(NSNotification *)notification{
    
}
#pragma mark - Server

- (void)fetchComment{
    LINMood *mood = [[LINMood alloc] initWithDictionary:self.mood];
    MKNetworkOperation *op = [self.engine operationWithPath:__apiFetchComment params:@{@"length":@(99), @"page":@(1), @"moodid":mood.moodId} httpMethod:@"POST"];
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSDictionary *dic = [completedOperation responseJSON];
       // NSLog(@"%@", dic);
        /**
         *  error == 2 的话表示没有评论
         */
        NSNumber *errorCode = dic[@"error"];
        if ([errorCode integerValue] == 2) {
            self.needShowNoCommentView = true;
        }else{
            self.needShowNoCommentView = false;
        }
        self.commentArray = [NSMutableArray new];
        [self.commentArray addObjectsFromArray:dic[@"success"][@"list"]];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
#warning wait
    }];
    [self.engine enqueueOperation:op];
}

- (void)thumbupWithMood:(NSMutableDictionary *)mood{
    mood[@"isthumbup"] = @"yes";
    NSNumber *numOfThumbU = mood[@"numofthumbup"];
    mood[@"numofthumbup"] = @([numOfThumbU integerValue] + 1);
    MKNetworkOperation *op = [self.engine operationWithPath:__apiThumbUp
                                                     params:@{@"moodid":mood[@"id"]}
                                                 httpMethod:@"POST"];
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSDictionary *dic = [completedOperation responseJSON];
        NSLog(@"%@", dic);
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
#warning wait
    }];
    [self.engine enqueueOperation:op];
}

- (void)thumbDownWithMood:(NSMutableDictionary *)mood{
    mood[@"isthumbup"] = @"no";
    NSNumber *numOfThumbU = mood[@"numofthumbup"];
    mood[@"numofthumbup"] = @([numOfThumbU integerValue] - 1);
    MKNetworkOperation *op = [self.engine operationWithPath:__apiThumbDown
                                                     params:@{@"moodid":mood[@"id"]}
                                                 httpMethod:@"POST"];
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSDictionary *dic = [completedOperation responseJSON];
        NSLog(@"%@", dic);
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
#warning wait
    }];
    [self.engine enqueueOperation:op];
}


#pragma mark - UI Related
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

- (void)commentButtonTapped:(id)sender{
    [self.textView becomeFirstResponder];
}

- (IBAction)postComment:(id)sender {
        LINMood *mood = [[LINMood alloc] initWithDictionary:self.mood];
    if ([[[self.textView.text stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@"　" withString:@""] isEqualToString:@""]) {
        NSLog(@"内容不能为空");
        return;
    }else{
        [self.textView resignFirstResponder];
        MKNetworkOperation *op = [self.engine operationWithPath:__apiNewComment params:@{@"content":[self.textView.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], @"moodid":mood.moodId} httpMethod:@"POST"];
        self.textView.text = @"";
        self.textViewPlaceHolder.hidden = NO;
        [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
            NSDictionary *dic = [completedOperation responseJSON];
            NSLog(@"%@", dic);
            [self fetchComment];


        } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
            [MBProgressHUD showNetworkErrorToView:self.view];
        }];
        [self.engine enqueueOperation:op];
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
