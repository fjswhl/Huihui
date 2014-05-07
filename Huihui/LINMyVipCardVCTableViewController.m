//
//  LINMyVipCardVCTableViewController.m
//  Huihui
//
//  Created by Lin on 4/11/14.
//  Copyright (c) 2014 Lin. All rights reserved.
//

#import "LINMyVipCardVCTableViewController.h"
#import "MKNetworkKit.h"
#import "RatingView.h"
#import "UIImageView+WebCache.h"
#import "LINRootVC.h"
#import "MBProgressHUD.h"
#import <objc/runtime.h>
NSString *const __apiMyVip = @"index.php/Shop/myVIP";
NSString *const __apiMyLike = @"index.php/User/fetchLike";

extern NSString *const __shopname;
extern NSString *const __discount;
extern NSString *const __location;
extern NSString *const __phone;
extern NSString *const __grade;
extern NSString *const __pic;
extern NSString *const __id;

@interface LINMyVipCardVCTableViewController ()
@property (weak, nonatomic) MKNetworkEngine *engine;

@property (strong, nonatomic) NSArray *shops;
@end

@implementation LINMyVipCardVCTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([self.type integerValue] == 0) {
        self.navigationItem.title = @"我的电子会员卡";
        [self fetMyVipCardInfo];
    }else if ([self.type integerValue] == 1){
        self.navigationItem.title = @"我的收藏";
        [self fetchMyFavorite];
    }

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return [self.shops count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellIdentifider = @"shopCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifider];
    
    
    UIView *contentView = [cell.contentView viewWithTag:999];
    static char contentViewKey;
    NSString *setted = objc_getAssociatedObject(contentView, &contentViewKey);
    if (!setted) {
        objc_setAssociatedObject(contentView, &contentViewKey, @"0", OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        contentView.layer.borderColor = [UIColor colorWithRed:225/255.0 green:225/255.0 blue:225/255.0 alpha:1.0f].CGColor;
        contentView.layer.borderWidth = 1;
        contentView.layer.cornerRadius = 2;
    }
    
    UILabel *shopNameLabel = (UILabel *)[cell.contentView viewWithTag:1];
    UILabel *discountLabel = (UILabel *)[cell.contentView viewWithTag:2];
    UILabel *locationLabel = (UILabel *)[cell.contentView viewWithTag:3];
    RatingView *ratingView = (RatingView *)[cell.contentView viewWithTag:4];
    UIImageView *shopImage = (UIImageView *)[cell.contentView viewWithTag:5];
    
    [cell.contentView sendSubviewToBack:ratingView];
    
    if (!ratingView.s1) {
        [ratingView setImagesDeselected:@"0.png" partlySelected:@"1.png" fullSelected:@"2.png" andDelegate:nil];
        [ratingView setUserInteractionEnabled:NO];
    }

    
    UIView *view = [cell.contentView viewWithTag:101];
    if ([self.type integerValue] == 0) {
        [view setHidden:NO];
    }
    
    
    NSDictionary *aShop = self.shops[indexPath.row];
    
    //    [shopImage setImage:nil];
    //    if ([aShop[@"pic"] rangeOfString:@"png"].location != NSNotFound) {
    //        NSLog(@"%@", aShop[__pic]);
    //       // [shopImage setImageWithURL:[NSURL URLWithString:aShop[__pic]]];
    //        NSFileManager *fm = [NSFileManager new];
    //        NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    //        NSString *d = [aShop[__pic] stringByReplacingOccurrencesOfString:@"http://xdhuihui-public.stor.sinaapp.com/upload/img/shop/" withString:@""];
    //        NSLog(@"%@", d);
    //        NSString *desSt = [docPath stringByAppendingFormat:@"/%@",d];
    //        if ([fm fileExistsAtPath:desSt]) {
    //            UIImage *img = [[UIImage alloc] initWithContentsOfFile:desSt];
    //            shopImage.image = img;
    //        }
    //
    //    }
    //    }else{
    //        [shopImage setImage:nil];
    //    }
    //  [shopImage setImageWithURL:[NSURL URLWithString:aShop[__pic]]];
    shopNameLabel.text = aShop[__shopname];
    discountLabel.text = aShop[__discount];
    locationLabel.text = aShop[__location];
    [ratingView displayRating:[aShop[__grade] floatValue]];
    //    shopImage.image = nil;
    //    if (!self.shopImgs[indexPath]) {
    //        if (self.tableView.dragging == NO && self.tableView.decelerating == NO) {
    //            [self startImgDownload:aShop forIndexPath:indexPath];
    //        }
    //    }else{
    //        shopImage.image = self.shopImgs[indexPath];
    //    }
    [shopImage setImage:[UIImage imageNamed:@"placeholder.png"]];
    [shopImage setImageWithURL:[NSURL URLWithString: aShop[__pic]]];
    
    return cell;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
            [self performSegueWithIdentifier:@"showDetail" sender:indexPath];
}
- (IBAction)pop:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Server

- (void)fetMyVipCardInfo{
    MKNetworkOperation *op = [self.engine operationWithPath:__apiMyVip params:@{@"length": @(99),
                                                                                @"page":@(1)} httpMethod:@"POST"];
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSDictionary *dic = [completedOperation responseJSON];
        if (dic[@"error"]) {
            NSNumber *errorCode = dic[@"error"];
            if ([errorCode intValue] == 0) {
                LINRootVC *rootVC = (LINRootVC *)self.tabBarController;
                [rootVC loginCompletion:^{
                    [self fetMyVipCardInfo];
                } failed:nil];
                return;
            }
        }        NSLog(@"%@", dic);
        self.shops = dic[@"success"];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationRight];
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        [MBProgressHUD showNetworkErrorToView:self.navigationController.view];
    }];
    [self.engine enqueueOperation:op];
}

- (void)fetchMyFavorite{
    MKNetworkOperation *op = [self.engine operationWithPath:__apiMyLike params:nil httpMethod:@"POST"];
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSDictionary *dic = [completedOperation responseJSON];
        if (dic[@"error"]) {
            NSNumber *errorCode = dic[@"error"];
            if ([errorCode intValue] == 0) {
                LINRootVC *rootVC = (LINRootVC *)self.tabBarController;
                [rootVC loginCompletion:^{
                    [self fetchMyFavorite];
                } failed:nil];
                return;
            }
        }        NSLog(@"%@", dic);
        self.shops = dic[@"success"][@"like"];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationLeft];
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        [MBProgressHUD showNetworkErrorToView:self.navigationController.view];
    }];
    [self.engine enqueueOperation:op];
}

#pragma mark - Sague
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = (NSIndexPath *)sender;
        NSDictionary *aShop = self.shops[indexPath.row];
        [segue.destinationViewController setValue:aShop forKey:@"aShop"];
    }
}

@end
