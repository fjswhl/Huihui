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

extern NSString *const __discount;
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



@interface LINShopDetailVC ()<LINRootVCDelegate>


@property (weak, nonatomic) MKNetworkEngine *engine;
@property (strong, nonatomic) IBOutlet UILabel *introLabel;

@property (strong, nonatomic) IBOutlet UILabel *privilegeLabel;
@property (strong, nonatomic) IBOutlet UILabel *locationLabel;
@property (strong, nonatomic) IBOutlet UILabel *contactLabel;
@property (strong, nonatomic) IBOutlet UILabel *contactMethodLabel;

@property (strong, nonatomic) NSDictionary *shopDetail;

@property (strong, nonatomic) IBOutlet RatingView *grade_p;
@property (strong, nonatomic) IBOutlet RatingView *grade_pc;
@property (strong, nonatomic) IBOutlet RatingView *grade_s;


@property (strong, nonatomic) IBOutlet UILabel *becomeVIPLabel;
@property (assign, nonatomic) BOOL isVip;

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
        id delegate = [UIApplication sharedApplication].delegate;
        _engine = [delegate engine];
    }
    return _engine;
    
}


#pragma mark - Interaction With Server


- (void)fetchDetailInfo{
    MKNetworkOperation *op = [self.engine operationWithPath:apiFetchOne params:@{@"shopid":self.aShop[@"id"]} httpMethod:@"POST"];
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSDictionary *detail = [completedOperation responseJSON];
        self.shopDetail = detail[@"success"];
        NSLog(@"%@", self.shopDetail);
        self.introLabel.text = self.shopDetail[__intro];
        self.privilegeLabel.text = self.shopDetail[__discount];
        self.locationLabel.text = self.shopDetail[__location];
        self.contactLabel.text = self.aShop[__master];
        self.contactMethodLabel.text = self.aShop[__phone];
        
        [self.grade_p setImagesDeselected:@"0.png" partlySelected:@"1.png" fullSelected:@"2.png" andDelegate:nil];
        [self.grade_pc setImagesDeselected:@"0.png" partlySelected:@"1.png" fullSelected:@"2.png" andDelegate:nil];
        [self.grade_s setImagesDeselected:@"0.png" partlySelected:@"1.png" fullSelected:@"2.png" andDelegate:nil];
        
        [self.grade_p displayRating:[self.shopDetail[__grade_p] floatValue]];
        [self.grade_pc displayRating:[self.shopDetail[__grade_pc] floatValue]];
        [self.grade_s displayRating:[self.shopDetail[__grade_s] floatValue]];
        
        MKNetworkOperation *checkIsVIP = [self.engine operationWithPath:__apiIsVIP params:@{@"shopid":self.aShop[__id]} httpMethod:@"POST"];
        [checkIsVIP addCompletionHandler:^(MKNetworkOperation *completedOperation) {
            NSDictionary *dic = [completedOperation responseJSON];
            NSNumber *rc = dic[@"success"];
            if ([rc intValue] == 1) {
                self.becomeVIPLabel.text = @"秀照片, 发点评";
                self.isVip = YES;
            }else{
                self.becomeVIPLabel.text = @"成为会员, 立享优惠";
                self.isVip = NO;
            }
            
        } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
#warning wait
        }];
        [self.engine enqueueOperation:checkIsVIP];
        
        
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        ;
#warning Imcomplete method implementation
    }];
    [self.engine enqueueOperation:op];
}

#pragma mark - tableview delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 3) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        if (self.isVip == NO) {
            [self becomeVip];
        }else{
            [self postComment];
        }
    }
}

#pragma mark - Interraction With Server

- (void)becomeVip{
    LINRootVC *rootVC = (LINRootVC *)self.tabBarController;
    if (rootVC.isLogged == NO) {
        NSLog(@"没有登入");
        return;
    }
    
    MKNetworkOperation *op = [self.engine operationWithPath:__apiBecomeVIP params:@{@"shopid":self.aShop[__id]} httpMethod:@"POST"];
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSDictionary *dic = [completedOperation responseJSON];
        
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
        
        NSLog(@"%@", dic);
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        #warning wait
    }
     ];
    [self.engine enqueueOperation:op];
}



- (void)postComment{
    NSLog(@"$$$$");
}


@end





