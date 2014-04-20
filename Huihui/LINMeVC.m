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
NSString *const __apiUserNumOfSVG = @"index.php/User/numOfSVG";

@interface LINMeVC ()<LINRootVCDelegate, UIActionSheetDelegate, MFMessageComposeViewControllerDelegate>
@property (strong, nonatomic) IBOutlet UILabel *infoLabel;
@property (strong, nonatomic) IBOutlet UIButton *logInOrOutButton;
@property (strong, nonatomic) IBOutlet UIButton *signUpButton;


@property (strong, nonatomic) IBOutlet UILabel *vipCardN;
@property (strong, nonatomic) IBOutlet UILabel *favoriteLabel;
@property (strong, nonatomic) IBOutlet UILabel *myGroup;

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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    return [super numberOfSectionsInTableView:tableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return [super tableView:tableView numberOfRowsInSection:section];
}




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
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    MKNetworkOperation *op = [self.engine operationWithPath:__apiUserNumOfSVG params:nil httpMethod:@"POST"];
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        [hud hide:YES];
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
                }];
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

    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        [hud hide:YES];
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
        self.infoLabel.text = [NSString stringWithFormat:@"用户名:%@", rootVC.userPhoneNumber];
        self.logInOrOutButton.tag = 999;    //      999表示已登入, 0表示未登入
        [self.logInOrOutButton setTitle:@"注销" forState:UIControlStateNormal];
        [self.logInOrOutButton setTitle:@"注销" forState:UIControlStateHighlighted];
        [self.logInOrOutButton setTitle:@"注销" forState:UIControlStateSelected];
        
//        self.signUpButton.hidden = YES;
//        CGRect f = CGRectMake(0, 0, 159, 40);
////        self.logInOrOutButton.transform = CGAffineTransformMakeTranslation(-320, 0);
//        self.logInOrOutButton.frame = f;
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
        
//        self.signUpButton.hidden = NO;
//        CGRect f = self.logInOrOutButton.frame;
//        f.origin.x = 161;
//        f.size.width = 159;
//        self.logInOrOutButton.frame = f;
    }
}
@end




















