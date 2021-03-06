//
//  LINShopDetailVC.m
//  Huihui
//
//  Created by Lin on 3/24/14.
//  Copyright (c) 2014 Lin. All rights reserved.
//

#import "LINShopDetailVC.h"
#import "MKNetworkKit.h"
#import "RatingView.h"
#import "LINRootVC.h"
#import "LINCommentVC.h"
#import "UIImageView+WebCache.h"
#import "MBProgressHUD.h"
#import "LINComplainTableViewController.h"
//
//{
//    success =     {
//        discount = "4.1-4.20\U5168\U573a8\U6298\Uff0c\U5176\U4ed6\U65f6\U95f49\U6298";
//        "grade_p" = "4.5";
//        "grade_pc" = 4;
//        "grade_s" = 5;
//        id = 229;
//        inoutschool = 2;
//        intro = "\U6682\U65e0\U5546\U5bb6\U7b80\U4ecb\Uff01";
//        location = "\U5317\U95e8\U5916\U5411\U4e1c200\U7c73";
//        master = "\U5f20\U5e7f";
//        phone = 15934896247;
//        pic = "http://xdhuihui-public.stor.sinaapp.com/upload/img/shop/thumb_";
//        shopname = "\U96c5\U5c45\U4e50\U5ddd\U83dc";
//        type = 1;
//    };
//}
NSString *const apiFetchOne = @"index.php/Shop/fetchOne";
NSString *const __apiBecomeVIP = @"index.php/Shop/becomeVIP";
NSString *const __apiIsVIP = @"index.php/Shop/isVIP";
NSString *const __apiFetchComments = @"index.php/Shop/fetchShopComment";
extern NSString *const __discount;
NSString *const __discount_detail = @"discount_detail";
NSString *const __grade_p = @"grade_p";
NSString *const __grade_pc = @"grade_pc";
NSString *const __grade_s = @"grade_s";
extern NSString *const __id;
NSString *const __inoutschool = @"inoutschool";
NSString *const __intro = @"intro";
extern NSString *const __location;
NSString *const __master = @"master";
extern NSString *const __phone;
extern NSString *const __pic;
extern NSString *const __shopname;
NSString *const __type = @"type";



@interface LINShopDetailVC ()<LINRootVCDelegate, UIActionSheetDelegate>


@property (weak, nonatomic) MKNetworkEngine *engine;
@property (strong, nonatomic) IBOutlet UILabel *discountLabel;

@property (strong, nonatomic) IBOutlet UILabel *discountDetailLabel;

@property (strong, nonatomic) IBOutlet UILabel *locationLabel;
@property (strong, nonatomic) IBOutlet UILabel *contactLabel;
@property (strong, nonatomic) IBOutlet UILabel *contactMethodLabel;
@property (strong, nonatomic) IBOutlet UILabel *introLabel;
@property (strong, nonatomic) IBOutlet UILabel *commentCount;

@property (strong, nonatomic) NSDictionary *shopDetail;

@property (strong, nonatomic) IBOutlet RatingView *grade_p;
@property (strong, nonatomic) IBOutlet RatingView *grade_pc;
@property (strong, nonatomic) IBOutlet RatingView *grade_s;


@property (strong, nonatomic) IBOutlet UILabel *becomeVIPLabel;
@property (assign, nonatomic) BOOL isVip;
@property (strong, nonatomic) IBOutlet UIImageView *shopPic;

@property (strong, nonatomic) IBOutlet UIButton *becomVIPButton;
@property (strong, nonatomic) IBOutlet UIImageView *vipImgView;

@property (nonatomic) BOOL needUpdateTableViewHeight;

@end

@implementation LINShopDetailVC



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
   // NSLog(@"%@", self.aShop);
    [self fetchDetailInfo];
    [self.grade_p setUserInteractionEnabled:NO];
    [self.grade_pc setUserInteractionEnabled:NO];
    [self.grade_s setUserInteractionEnabled:NO];
    
    self.navigationItem.title = self.aShop[__shopname];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchDetailInfo) forControlEvents:UIControlEventValueChanged];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.tableView selectRowAtIndexPath:nil animated:YES scrollPosition:UITableViewScrollPositionNone];
}
#pragma mark - Getter

- (MKNetworkEngine *)engine{
    if (!_engine) {
        id delegate = [UIApplication sharedApplication].delegate;
        _engine = [delegate engine];
    }
    return _engine;
    
}


#pragma mark - Interaction With Server


- (void)fetchDetailInfo{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    
    
    MKNetworkOperation *op = [self.engine operationWithPath:apiFetchOne params:@{@"shopid":self.aShop[@"id"]} httpMethod:@"POST"];
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        [hud hide:YES];
        if (self.refreshControl.refreshing) {
            [self.refreshControl endRefreshing];
        }
        NSDictionary *detail = [completedOperation responseJSON];
        self.shopDetail = detail[@"success"];
        //self.privilegeLabel.text = self.shopDetail[__discount];
        self.discountLabel.text = self.shopDetail[__discount];
        self.discountDetailLabel.text = self.shopDetail[__discount_detail];
        self.introLabel.text = self.shopDetail[__intro];
        self.locationLabel.text = self.shopDetail[__location];
        self.contactLabel.text = self.aShop[__master];
        self.contactMethodLabel.text = self.aShop[__phone];
        [self.shopPic setImageWithURL:[NSURL URLWithString:self.aShop[__pic]]];
        
        
        if (!self.grade_p.s1) {
            [self.grade_p setImagesDeselected:@"0.png" partlySelected:@"1.png" fullSelected:@"2.png" andDelegate:nil];
            [self.grade_pc setImagesDeselected:@"0.png" partlySelected:@"1.png" fullSelected:@"2.png" andDelegate:nil];
            [self.grade_s setImagesDeselected:@"0.png" partlySelected:@"1.png" fullSelected:@"2.png" andDelegate:nil];
        }
        [self.grade_p displayRating:[self.shopDetail[__grade_p] floatValue]];
        [self.grade_pc displayRating:[self.shopDetail[__grade_pc] floatValue]];
        [self.grade_s displayRating:[self.shopDetail[__grade_s] floatValue]];
        
        self.needUpdateTableViewHeight = true;
        [self.tableView reloadData];
        [self checkIsVip];
        [self fetchComments];
        
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        [MBProgressHUD showNetworkErrorToView:self.navigationController.view];
    }];
    [self.engine enqueueOperation:op];
}

- (void)fetchComments{
    MKNetworkOperation *op = [self.engine operationWithPath:__apiFetchComments params:@{
                                                                                        @"shopid":self.aShop[__id],
                                                                                        @"length":@"1",
                                                                                        @"page":@"1"} httpMethod:@"POST"];
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        
        NSDictionary *dic = [completedOperation responseJSON];
        NSLog(@"%@", dic);
        NSNumber *count = dic[@"success"][@"count"];
        if ([count integerValue] > 0) {
            self.commentCount.text = [NSString stringWithFormat:@"共有%@人评论", count];
        }else{
            self.commentCount.text = @"暂时还没有评论";
        }


 
        
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        [MBProgressHUD showNetworkErrorToView:self.navigationController.view];
    }];
    
    [self.engine enqueueOperation:op];
    
}


#pragma mark - tableview delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    if (indexPath.section == 0 && indexPath.row == 1 && self.needUpdateTableViewHeight == true) {
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.font = [UIFont systemFontOfSize:14.0f];
        cell.textLabel.text = self.shopDetail[__discount_detail];
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 3) {           //点击我要点评

//        if (self.isVip == NO) {
//            [self becomeVip];
//        }else{
        LINRootVC *rootVC = (LINRootVC *)self.tabBarController;
        if ([rootVC logged] == YES) {
            [self performSegueWithIdentifier:@"shopDetailToComment" sender:nil];
        }
        else{
            [MBProgressHUD showTextHudToView:self.view text:@"请先登入"];
            //[self postComment];
        }
    }else if (indexPath.section == 2 && indexPath.row == 0){            //点击我要投诉
        [self performSegueWithIdentifier:@"shopDetailVCToComplainVC" sender:nil];
    }else if (indexPath.section == 0 && indexPath.row == 2){
        [self performSegueWithIdentifier:@"showdetailvctocommentvc" sender:nil];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat height = [super tableView:tableView heightForRowAtIndexPath:indexPath];
    
    if (indexPath.section == 0 && indexPath.row == 1 && self.needUpdateTableViewHeight == true) {
        NSString *discountDetail = self.shopDetail[__discount_detail];
        
        CGSize constraint = CGSizeMake(280, 20000);
        CGSize size = [discountDetail boundingRectWithSize:constraint options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14]} context:nil].size;
        return size.height + 15;
    }

    return height;
    
}

#pragma mark - Button

- (IBAction)becomVipButtonPressed:(UIButton *)sender {
    [self becomeVip];
}

- (IBAction)phoneCallButtonPressed:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"%@的电话", self.shopDetail[__shopname]] delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:[NSString stringWithFormat:@"%@", self.shopDetail[__phone]], nil];
    
    [actionSheet showInView:self.view];
    
}

#pragma mark - Actionsheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        [actionSheet dismissWithClickedButtonIndex:buttonIndex animated:YES];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", self.shopDetail[__phone]]]];
    }

}
#pragma mark - Interraction With Server

- (void)becomeVip{
    LINRootVC *rootVC = (LINRootVC *)self.tabBarController;
    if (rootVC.isLogged == NO) {
        [MBProgressHUD showTextHudToView:self.view text:@"请先登入"];
        return;
    }
    
    MKNetworkOperation *op = [self.engine operationWithPath:__apiBecomeVIP params:@{@"shopid":self.aShop[__id]} httpMethod:@"POST"];
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSDictionary *dic = [completedOperation responseJSON];
        
        // 如果sessionid超时, 重新登入
        if (dic[@"error"]) {
            NSNumber *errorCode = dic[@"error"];
            if ([errorCode intValue] == 0) {
                LINRootVC *rootVC = (LINRootVC *)self.tabBarController;
                [rootVC loginCompletion:^{
                    [self becomeVip];
                }];
                return;
            }
        }
        [self fetchDetailInfo];
        NSLog(@"%@", dic);
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        [MBProgressHUD showNetworkErrorToView:self.navigationController.view];
    }
     ];
    [self.engine enqueueOperation:op];
}

- (void)checkIsVip{
    LINRootVC *rootVC = (LINRootVC *)self.tabBarController;
    if ([rootVC logged] == NO) {
        //[MBProgressHUD showTextHudToView:self.view text:@"请先登入"];
        return;
    }
    
    MKNetworkOperation *op = [self.engine operationWithPath:__apiIsVIP params:@{
                                                                                @"shopid":self.aShop[__id] } httpMethod:@"POST"];
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSDictionary *dic = [completedOperation responseJSON];
        
        if (dic[@"error"]) {
            NSNumber *errorCode = dic[@"error"];
            if ([errorCode intValue] == 0) {
                LINRootVC *rootVC = (LINRootVC *)self.tabBarController;
                [rootVC loginCompletion:^{
                    [self checkIsVip];
                }];
                return;
            }
        }
        
        NSNumber *code = dic[@"success"];
        if ([code intValue] == 1) {
           // self.becomeVIPLabel.text = @"秀照片, 发点评";
            self.isVip = YES;
//            UIImageView *vipView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
//            vipView.image = [UIImage imageNamed:@"ic_is_vip_large.png"];
            [self.becomVIPButton setHidden:YES];
            [self.vipImgView setHidden:NO];
//            [self.shopPic addSubview:vipView];
            
        }else{
           // self.becomeVIPLabel.text = @"成为会员, 立享优惠";
            [self.vipImgView setHidden:YES];
            [self.becomVIPButton setHidden:NO];
            self.isVip = NO;
        }
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        [MBProgressHUD showNetworkErrorToView:self.navigationController.view];
    }];
    [self.engine enqueueOperation:op];
}

- (IBAction)pop:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)postComment{
    NSLog(@"$$$$");
}

#pragma mark - Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
//    if ([segue.identifier isEqualToString:@"shopDetailToComment"]) {
//        LINCommentVC *commentVC = (LINCommentVC *)segue.destinationViewController;
//        [commentVC setAShop:self.aShop];
//    }else if ([segue.identifier isEqualToString:@"shopDetailVCToComplainVC"]){
//        LINComplainTableViewController *ctv = (LINComplainTableViewController *)segue.destinationViewController;
//        [ctv setAShop:self.aShop];
//    }
    id deVC = segue.destinationViewController;
    [deVC setValue:self.aShop forKey:@"AShop"];
}
@end





