//
//  LINMoodWallViewController.m
//  Huihui
//
//  Created by Lin on 4/23/14.
//  Copyright (c) 2014 Lin. All rights reserved.
//

//success =     {
//    count = 52;
//    list =         (
//                    {
//                        bg = "-3549200";
//                        content = "%E5%90%83%E9%A5%AD%E3%80%82%E3%80%82%E3%80%82";
//                        id = 61;
//                        isthumbup = no;
//                        numofcomment = 0;
//                        numofthumbup = 1;
//                        time = 1399888637;
//                    },
//                    {
//                        bg = "-10000";
//                        content = "%E4%BB%8A%E5%A4%A9%E5%90%83%E5%95%A5%E5%AD%90%E5%91%A2%EF%BC%9F";
//                        id = 60;
//                        isthumbup = no;
//                        numofcomment = 0;
//                        numofthumbup = 0;
//                        time = 1399886070;
//                    },
//                    {
//                        bg = "-10000";
//                        content = "%E9%9D%9E%E6%B3%95%E8%AF%8D%E6%B1%87%E9%9D%9E%E6%B3%95%E8%AF%8D%E6%B1%87%E9%9D%9E%E6%B3%95%E8%AF%8D%E6%B1%87%E9%9D%9E%E6%B3%95%E8%AF%8D%E6%B1%87%E9%9D%9E%E6%B3%95%E8%AF%8D%E6%B1%87%E9%9D%9E%E6%B3%95%E8%AF%8D%E6%B1%87%E3%80%82%E3%80%82%E3%80%82%E6%B2%A1%E6%9C%89%E8%A2%AB%E5%B1%8F%E8%94%BD%E8%80%B6%E5%A5%BD%E5%BC%80%E5%BF%83%E3%80%82%E3%80%82%E3%80%82%E7%A8%8D%E7%AD%89%E6%88%91%E5%8E%BB%E5%BC%80%E4%B8%AA%E9%97%A8%EF%BC%8C%E5%9B%9E%E8%81%8A%E3%80%82";
//                        id = 59;
//                        isthumbup = no;
//                        numofcomment = 0;
//                        numofthumbup = 1;
//                        time = 1399877062;
//                    },
//                    {
//                        bg = "-10000";
//                        content = "%E5%90%90%E6%A7%BD%E4%B8%80%E5%8F%A5%E3%80%82%E3%80%82%E3%80%82%E3%80%82%E7%9D%A1%E8%A7%89%E5%8E%BB%E3%80%82%E3%80%82%E3%80%82";
//                        id = 58;
//                        isthumbup = no;
//                        numofcomment = 0;
//                        numofthumbup = 0;
//                        time = 1399822755;
//                    },
//                    {
//                        bg = "-10000";
//                        content = "%E6%89%93%E9%85%B1%E6%B2%B9%E3%80%82%E3%80%82%EF%BC%9F";
//                        id = 57;
//                        isthumbup = no;
//                        numofcomment = 3;
//                        numofthumbup = 1;
//                        time = 1399818334;
//                    }
//                    );
//    totalPages = 11;
//};
//}

#import "LINMoodWallViewController.h"
#import "MKNetworkKit.h"
#import "LINMood.h"
#import <objc/runtime.h>
#import "LINRootVC.h"
#import "LINPostMoodViewController.h"
#import "NSDate+Helper.h"

NSString *const __apiFetchMood = @"index.php/Mood/fetchmood";
NSString *const __apiThumbUp = @"index.php/Mood/thumbup";
NSString *const __apiThumbDown = @"index.php/Mood/thumbdown";

@interface LINMoodWallViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) MKNetworkEngine *engine;

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *loadMoreIndicator;





@property (nonatomic) BOOL loadMoreViewIsShown;

@property (strong, nonatomic) UITableViewController *tbvc;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (nonatomic) BOOL refreshFlag;
@end

@implementation LINMoodWallViewController

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
    // Do any additional setup after loading the view.
    self.title = @"校园圈";
    self.pageCount = 1;
   // [self fetchMoodWithPage:self.pageCount];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    LINRootVC *rootVC = (LINRootVC *)self.tabBarController;
    [rootVC showTabbarAnimated:YES];
    
    
}

- (void)viewDidAppear:(BOOL)animated{
    UIEdgeInsets edgeInsets = self.tableView.contentInset;
    NSLog(@"%@", NSStringFromUIEdgeInsets(edgeInsets));
        edgeInsets.top = 64.0f;
    edgeInsets.bottom = 49.0f;
        self.tableView.contentInset = edgeInsets;
    self.tableView.separatorInset = edgeInsets;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addRefreshControl{
    self.tbvc = [UITableViewController new];
    [self.tbvc setAutomaticallyAdjustsScrollViewInsets:NO];
    [self.tbvc setEdgesForExtendedLayout:UIRectEdgeNone];
    self.tbvc.tableView = self.tableView;
    self.refreshControl = [UIRefreshControl new];
    [self.refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    self.tbvc.refreshControl = self.refreshControl;
}

- (void)refresh:(id)sender{
    self.refreshFlag = true;
    [self fetchMoodWithPage:1];
}
#pragma mark - Getter
- (MKNetworkEngine *)engine{
    if (!_engine) {
        id delegate = [[UIApplication sharedApplication] delegate];
        _engine = [delegate engine];
    }
    return _engine;
}

- (NSMutableArray *)moodArray{
    if (!_moodArray) {
        _moodArray = [NSMutableArray new];
    }
    return _moodArray;
}
//#pragma mark - KVO and Notification
//
//-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
//    if ([keyPath isEqualToString:@"backgroundColor"]){
//        UIView *contentView = object;
////        CGFloat saturation;
////        CGFloat brightness;
////        CGFloat red;
////        CGFloat green;
////        CGFloat blue;
////   //     [textView.backgroundColor getHue:NULL saturation:&saturation brightness:&brightness alpha:NULL];
//        UILabel *label = (UILabel *)[contentView viewWithTag:1];
////        
////        [contentView.backgroundColor getRed:&red green:&green blue:&blue alpha:NULL];
////        if ((red + green + blue) * 255 > 200) {
////            label.textColor = [UIColor whiteColor];
////        }else{
////            label.textColor = [UIColor blackColor];
////        }
//        
//        CGFloat saturation;
//        [contentView.backgroundColor getHue:NULL saturation:&saturation brightness:NULL alpha:NULL];
//        if (saturation >= 0.5) {
//            label.textColor = [UIColor whiteColor];
//        }else{
//            label.textColor = [UIColor blackColor];
//        }
//    }
//}

#pragma mark - TableView



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.moodArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"secretCell"];
    
    LINMood *mood = nil;
    if ([self.moodArray[indexPath.row] isKindOfClass:[LINMood class]]) {
        mood = self.moodArray[indexPath.row];
    }else{
        mood = [[LINMood alloc] initWithDictionary:self.moodArray[indexPath.row]];
    }
    
    
    UILabel *label = (UILabel *)[cell.contentView viewWithTag:1];
    UILabel *timeLabel = (UILabel *)[cell.contentView viewWithTag:4];
    UIButton *thumbupButton = (UIButton *)[cell.contentView viewWithTag:2];
    UIButton *commentButton = (UIButton *)[cell.contentView viewWithTag:3];
    
  //  NSLog(@"%@", self.moodArray[indexPath.row]);
    
    label.text = mood.content;
  //  [textView addObserver:self forKeyPath:@"contentSize" options:(NSKeyValueObservingOptionNew) context:NULL];
    static char cellKey;
    NSString *setted = objc_getAssociatedObject(cell, &cellKey);
    if (!setted) {
        objc_setAssociatedObject(cell, &cellKey, @"0", OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        //[cell.contentView addObserver:self forKeyPath:@"backgroundColor" options:(NSKeyValueObservingOptionNew) context:NULL];
        [thumbupButton addTarget:self action:@selector(thumbupButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [commentButton addTarget:self action:@selector(commentButtonTapped:) forControlEvents:UIControlEventTouchUpInside];

    }
    
    cell.contentView.backgroundColor = mood.bgColor;
    
    timeLabel.text = [NSDate timeFlagWithDate:mood.date];
    [thumbupButton setTitle:[NSString stringWithFormat:@"%@", mood.numofthumbup] forState:UIControlStateNormal];
    [commentButton setTitle:[NSString stringWithFormat:@"%@", mood.numofcomment] forState:UIControlStateNormal];
    if ([mood.isthumbup isEqualToString:@"no"]) {
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
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self performSegueWithIdentifier:@"moodWallToShowComment" sender:indexPath];
}

//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
//    cell.alpha = 0.3;
//    [UIView animateWithDuration:0.7 animations:^{
//        cell.alpha = 1;
//    }];
//}

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView {
//    if (self.scrollViewDidScrollFlag) {
//        self.scrollViewDidScrollFlag = false;
//        return;
//    }
    if (aScrollView == self.tableView) {
        
        CGPoint offset = aScrollView.contentOffset;
        CGRect bounds = aScrollView.bounds;
        CGSize size = aScrollView.contentSize;
        UIEdgeInsets inset = aScrollView.contentInset;
        float y = offset.y + bounds.size.height - inset.bottom;
        float h = size.height;
        // NSLog(@"offset: %f", offset.y);
        // NSLog(@"content.height: %f", size.height);
        // NSLog(@"bounds.height: %f", bounds.size.height);
        // NSLog(@"inset.top: %f", inset.top);
        // NSLog(@"inset.bottom: %f", inset.bottom);
        // NSLog(@"pos: %f of %f", y, h);
        float reload_distance = 10;
        if(y > h + reload_distance) {
            //NSLog(@"load more rows");
            if (self.loadMoreViewIsShown == false && ![self.refreshControl isRefreshing]) {
                self.loadMoreViewIsShown = true;
                [self fetchMoodWithPage:self.pageCount];
            }
            
        }
    }
    
}

- (NSArray *)indexPathsForRange:(NSRange)range{
    NSMutableArray *result = [NSMutableArray new];
    for (int i = range.location; i < (range.location + range.length); i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        [result addObject:indexPath];
    }
    return [result copy];
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

#pragma mark - Server

- (void)fetchMoodWithPage:(NSInteger)page{
//    if (!self.refreshFlag && self.refreshControl && self.loadMoreViewIsShown == false) {
//        return;
//    }else{
//        self.refreshFlag = false;
//    }
    
    MKNetworkOperation *op = [self.engine operationWithPath:__apiFetchMood params:@{@"length":@(5), @"page":@(page)} httpMethod:@"POST"];
    
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        if (page == 1 && !self.refreshControl) {
            [self addRefreshControl];
        }
        if (page == 1) {
            self.pageCount = page;
            self.moodArray = [NSMutableArray new];
            [self.tableView reloadData];
        }
        
        self.loadMoreViewIsShown = false;
        
        NSDictionary *dic = [completedOperation responseJSON];
        
        NSArray *st = dic[@"success"][@"list"];

        [self.moodArray addObjectsFromArray:st];
        
        NSRange range;
        range.location = (self.pageCount - 1) * 5;
        range.length = [st count];
        
        if ([self.refreshControl isRefreshing]) {
            [self.refreshControl endRefreshing];
        }
   //     NSLog(@"%@", [self indexPathsForRange:range]);
        
        [self.tableView insertRowsAtIndexPaths:[self indexPathsForRange:range] withRowAnimation:UITableViewRowAnimationAutomatic];
//        if (!self.refreshControl.refreshing) {
//            NSLog(@"%@", [self indexPathsForRange:range]);
//            [self.tableView insertRowsAtIndexPaths:[self indexPathsForRange:range] withRowAnimation:UITableViewRowAnimationFade];
//        }else{
//            [self.tableView reloadData];
//            [self.refreshControl endRefreshing];
//
//        }


        self.pageCount++;

    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
#warning wait
    }];
    [self.engine enqueueOperation:op];
    
}

- (void)thumbupWithMood:(LINMood *)mood{
    mood.isthumbup = @"yes";
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
    mood.isthumbup = @"no";
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

/**
 *  根据给的时间返回 多长时间前的字符长. 比如现在是3点, 给2点55返回5分钟前
 *
 *  @param date date
 *
 *  @return nsstring
 */
- (NSString *)timeFlagWithDate:(NSDate *)date{
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:date];
    NSString *result = nil;
    
    if (timeInterval < 60 * 60) { /*        分钟          */
        int minute = ((int)timeInterval) / 60;
        result = [NSString stringWithFormat:@"%i分钟前", minute];
    }else if (timeInterval < 60 * 60 * 24){
        int hour = ((int)timeInterval) / 3600;
        result = [NSString stringWithFormat:@"%i小时前", hour];
    }else{
        int day = ((int)timeInterval) / (3600 * 24);
        result = [NSString stringWithFormat:@"%i天前", day];
    }
    return result;
    
}

#pragma mark -

- (void)thumbupButtonTapped:(id)sender{
    UIButton *button = sender;
    UITableViewCell *cell = (UITableViewCell *)button.superview.superview.superview.superview;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    LINMood *mood = [[LINMood alloc] initWithDictionary: self.moodArray[indexPath.row]];
    
   // [self thumbupWithMood:mood];
   // NSLog(@"%@", mood.moodId);
    if (button.selected) {
        button.selected = false;
        NSString *buttonTitle = [button titleForState:UIControlStateSelected];
        [button setTitle:[NSString stringWithFormat:@"%li",(long)([buttonTitle integerValue] - 1) ] forState:UIControlStateNormal];
        
        [self thumbDownWithMood:mood];
    }else{
        button.selected = true;
        NSString *buttonTitle = [button titleForState:UIControlStateNormal];
        [button setTitle:[NSString stringWithFormat:@"%li",(long)([buttonTitle integerValue] + 1) ]  forState:UIControlStateSelected];
        [self thumbupWithMood:mood];
        
        [UIView animateWithDuration:0.3 animations:^{
            button.imageView.transform = CGAffineTransformMakeScale(2.0, 2.0);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.3 animations:^{
                button.imageView.transform = CGAffineTransformIdentity;
            }];
        }];
    }
}

- (void)commentButtonTapped:(id)sender{
    
}

- (IBAction)newMoodButton:(id)sender {
    LINPostMoodViewController *postMoodVC = [self.storyboard instantiateViewControllerWithIdentifier:@"postMoodVC"];
    [self presentViewController:postMoodVC animated:YES completion:nil];
}

#pragma mark - Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    LINRootVC *rootVC = (LINRootVC *)self.tabBarController;
    [rootVC hideTabbarAnimated:YES];
    if ([segue.identifier isEqualToString:@"moodWallToShowComment"]) {
        NSIndexPath *indexPath = sender;
        id vc = segue.destinationViewController;
        LINMood *mood = [[LINMood alloc] initWithDictionary:self.moodArray[indexPath.row]];
        NSLog(@"%@", mood.moodId);
        [vc setValue:mood forKey:@"mood"];
    }
}
@end






































