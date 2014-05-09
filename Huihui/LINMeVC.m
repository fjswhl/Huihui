//
//  LINMeVC.m
//  Huihui
//
//  Created by Lin on 3/27/14.
//  Copyright (c) 2014 Lin. All rights reserved.
//

#import "LINMeVC.h"
#import "LINRootVC.h"
#import "MBProgressHUD.h"
#import "MKNetworkKit.h"
#import <MessageUI/MessageUI.h>
#import "UIImageView+WebCache.h"
NSString *const __apiUserNumOfSVG = @"index.php/User/numOfSVG";
extern NSString *const __apiGetProfile;

@interface LINMeVC ()<LINRootVCDelegate, UIActionSheetDelegate, MFMessageComposeViewControllerDelegate>
@property (strong, nonatomic) IBOutlet UILabel *infoLabel;
@property (strong, nonatomic) IBOutlet UIButton *logInOrOutButton;
@property (strong, nonatomic) IBOutlet UIButton *signUpButton;


@property (strong, nonatomic) IBOutlet UILabel *vipCardN;
@property (strong, nonatomic) IBOutlet UILabel *favoriteLabel;
@property (strong, nonatomic) IBOutlet UILabel *myGroup;

/*          顶部视图的3个控件           */
@property (strong, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (strong, nonatomic) IBOutlet UILabel *userNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *schoolLabel;
@property (strong, nonatomic) IBOutlet UIView *headerViewContainerView;
@property (strong, nonatomic) IBOutlet UIImageView *disclosureImageView;

/*          顶部视图的手势,点击进入完善资料的界面         */
@property (strong, nonatomic) UITapGestureRecognizer *completeProfileTapGesture;

@property (weak, nonatomic) MKNetworkEngine *engine;


@end

@implementation LINMeVC

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
    LINRootVC *rootVC = (LINRootVC *)self.tabBarController;
    rootVC.rootVCdelegate = self;
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchUserNumOfSVG) forControlEvents:UIControlEventValueChanged];

}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.tableView selectRowAtIndexPath:nil animated:YES scrollPosition:UITableViewScrollPositionNone];
    if ([self.vipCardN.text isEqualToString: @""]) {
        [self updateUIWhenLoginOrOut];
    }



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


- (UITapGestureRecognizer *)completeProfileTapGesture{
    if (!_completeProfileTapGesture) {
        _completeProfileTapGesture =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goCompleteProfile:)];
    }
    return _completeProfileTapGesture;
}

- (UIImageView *)avatarImageView {
    if (_avatarImageView.layer.borderWidth != 2.0f) {
        [_avatarImageView.layer setCornerRadius:(_avatarImageView.frame.size.height/2)];
        [_avatarImageView.layer setMasksToBounds:YES];
        [_avatarImageView setContentMode:UIViewContentModeScaleAspectFill];
        [_avatarImageView setClipsToBounds:YES];
        _avatarImageView.layer.borderColor = [[UIColor whiteColor] CGColor];
        _avatarImageView.layer.borderWidth = 2.0f;
    }
    return _avatarImageView;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    return [super numberOfSectionsInTableView:tableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return [super tableView:tableView numberOfRowsInSection:section];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    LINRootVC *rootVC = (LINRootVC *)self.tabBarController;
    if (![rootVC logged]) {
        [self performSegueWithIdentifier:@"meVCtoLoginVC" sender:nil];
        return;
    }
    
    if (indexPath.row == 0 || indexPath.row == 1) {
        [self performSegueWithIdentifier:@"meVCToVipOrFavourite" sender:indexPath];
    }else if (indexPath.row == 2){
        [self performSegueWithIdentifier:@"meVCToMyOrder" sender:nil];
    }
}

//#pragma mark - ScrollView Delegate
//
//- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
//    scrollView
//}

- (BOOL)isLogged{
    LINRootVC *rootVC = (LINRootVC *)self.tabBarController;
    return rootVC.isLogged;
}




#pragma mark - Interraction With Server

- (void)fetchUserNumOfSVG{
    LINRootVC *rootVC = (LINRootVC *)self.tabBarController;
    if ([rootVC logged] == NO) {
        if (self.refreshControl.refreshing == YES) {
            [self.refreshControl endRefreshing];
        }
        [MBProgressHUD showTextHudToView:self.view text:@"请先登入"];
        return;
    }
    
//    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    MKNetworkOperation *op = [self.engine operationWithPath:__apiUserNumOfSVG params:nil httpMethod:@"POST"];
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
 //       [hud hide:YES];
        if (self.refreshControl.refreshing == YES) {
            [self.refreshControl endRefreshing];
        }
        NSDictionary *dic = [completedOperation responseJSON];
#warning wait
        
        //      如果sessionid已经过期,自动重新登入
        if (dic[@"error"]) {
            NSNumber *errorCode = dic[@"error"];
            if ([errorCode intValue] == 0) {
                LINRootVC *rootVC = (LINRootVC *)self.tabBarController;
                [rootVC loginCompletion:^{
                    [self fetchUserNumOfSVG];
                }failed:nil];
                return;
            }
        }
        
        NSDictionary *detail = dic[@"success"];
        NSNumber *a = detail[@"numV"];
        NSNumber *b = detail[@"numS"];
        NSNumber *c = detail[@"numG"];
        self.vipCardN.text = [NSString stringWithFormat:@"%i个", [a intValue]];
        
        self.favoriteLabel.text = [NSString stringWithFormat:@"%i个", [b intValue]];
        self.myGroup.text = [NSString stringWithFormat:@"%i个", [c intValue]];

        MKNetworkOperation *op2 = [self.engine operationWithPath:__apiGetProfile params:nil httpMethod:@"POST"];
        [op2 addCompletionHandler:^(MKNetworkOperation *completedOperation) {
            NSDictionary *dic = [completedOperation responseJSON];
            self.userInfo = dic[@"success"];
            // NSLog(@"%@", self.userInfo);
            LINRootVC *rootVC = (LINRootVC *)self.tabBarController;
            rootVC.userInfo = self.userInfo;
            
            [self.avatarImageView setImageWithURL:[NSURL URLWithString:self.userInfo[@"pic"]]];
            
            NSString *userName = self.userInfo[@"username"];
          //  NSLog(@"%@", userName);
            if (![userName isEqualToString:@""]) {
                self.userNameLabel.text = self.userInfo[@"username"];
            }
            
            NSNumber *schoolid = self.userInfo[@"schoolid"];
            if ([schoolid integerValue] == 1) {
                self.schoolLabel.text = @"西电新校区";
            }else if([schoolid integerValue] == 2){
                self.schoolLabel.text = @"西电老校区";
            }
            
            
        } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
            [MBProgressHUD showNetworkErrorToView:self.view];
        }];
        [self.engine enqueueOperation:op2];
        
        
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
  //      [hud hide:YES];
        [MBProgressHUD showNetworkErrorToView:self.view];
    }];
    [self.engine enqueueOperation:op];
    

    
}

#pragma mark - LINRootVCDelegate
- (void)userDidLogin{
    [self fetchUserNumOfSVG];
}

- (IBAction)loginOrOut:(UIButton *)sender {
    LINRootVC *rootVC = (LINRootVC *)self.tabBarController;
    if (rootVC.logged == NO) {
        [self performSegueWithIdentifier:@"meVCtoLoginVC" sender:nil];
    }else{
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"确认注销吗?" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"确定" otherButtonTitles: nil];
        [actionSheet showInView:self.view];

    }
}

#pragma mark - ActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == actionSheet.destructiveButtonIndex) {
         LINRootVC *rootVC = (LINRootVC *)self.tabBarController;
        [rootVC setLogged:NO];
        [self updateUIWhenLoginOrOut];
        [actionSheet dismissWithClickedButtonIndex:actionSheet.destructiveButtonIndex animated:YES];
    }
}
- (void)updateUIWhenLoginOrOut{
    LINRootVC *rootVC = (LINRootVC *)self.tabBarController;
    if ([rootVC logged]) {
//        self.infoLabel.text = [NSString stringWithFormat:@"用户名:%@", rootVC.userPhoneNumber];
        self.logInOrOutButton.tag = 999;    //      999表示已登入, 0表示未登入
        [self.logInOrOutButton setTitle:@"注销" forState:UIControlStateNormal];
        [self.logInOrOutButton setTitle:@"注销" forState:UIControlStateHighlighted];
        [self.logInOrOutButton setTitle:@"注销" forState:UIControlStateSelected];
        
//        self.signUpButton.hidden = YES;
//        CGRect f = CGRectMake(0, 0, 159, 40);
////        self.logInOrOutButton.transform = CGAffineTransformMakeTranslation(-320, 0);
//        self.logInOrOutButton.frame = f;
        
        self.userNameLabel.text = [NSString stringWithFormat:@"用户名:%@", rootVC.userPhoneNumber];
        self.schoolLabel.text = @"(尚未完善资料)";
        self.avatarImageView.image = [UIImage imageNamed:@"placeholder.png"];
        [self.logInOrOutButton setHidden:YES];
        [self.signUpButton setHidden:YES];
        [self.avatarImageView setHidden:NO];
        [self.userNameLabel setHidden:NO];
        [self.schoolLabel setHidden:NO];
        [self.infoLabel setHidden:YES];
        [self.disclosureImageView setHidden:NO];
        
        [self.headerViewContainerView addGestureRecognizer:self.completeProfileTapGesture];
        
        [self fetchUserNumOfSVG];
    }else{
        self.infoLabel.text = @"欢迎使用汇惠,登入后使用更多功能";
        self.logInOrOutButton.tag = 0;    //      999表示已登入, 0表示未登入
        [self.logInOrOutButton setTitle:@"登入" forState:UIControlStateNormal];
        [self.logInOrOutButton setTitle:@"登入" forState:UIControlStateHighlighted];
        [self.logInOrOutButton setTitle:@"登入" forState:UIControlStateSelected];
        self.vipCardN.text = @"";
        self.favoriteLabel.text = @"";
        self.myGroup.text = @"";
        
        
        [self.logInOrOutButton setHidden:NO];
        [self.signUpButton setHidden:NO];
        [self.avatarImageView setHidden:YES];
        [self.userNameLabel setHidden:YES];
        [self.schoolLabel setHidden:YES];
        [self.infoLabel setHidden:NO];
        [self.disclosureImageView setHidden:YES];
        
        [self.headerViewContainerView removeGestureRecognizer:self.completeProfileTapGesture];
//        self.signUpButton.hidden = NO;
//        CGRect f = self.logInOrOutButton.frame;
//        f.origin.x = 161;
//        f.size.width = 159;
//        self.logInOrOutButton.frame = f;
    }
}


- (void)goCompleteProfile:(UITapGestureRecognizer *)sender{
    [self performSegueWithIdentifier:@"meVCtoCompleteProfileVC" sender:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"meVCtoCompleteProfileVC"]) {
        id vc = segue.destinationViewController;
        [vc setValue:self.userInfo forKey:@"UserInfo"];
    }else if ([segue.identifier isEqualToString:@"meVCToVipOrFavourite"]){
        id vc = segue.destinationViewController;
        NSIndexPath *indexPath = sender;
        [vc setValue:@(indexPath.row) forKey:@"Type"];
    }
}
@end




















