//
//  LINShowAllVC.m
//  Huihui
//
//  Created by Lin on 3/25/14.
//  Copyright (c) 2014 Lin. All rights reserved.
//

#import "LINShowAllVC.h"
#import "MKNetworkKit.h"
#import "UIImageView+WebCache.h"
#import "RatingView.h"
#import "MBProgressHUD.h"
extern NSString *const __shopname;
extern NSString *const __discount;
extern NSString *const __location;
extern NSString *const __phone;
extern NSString *const __grade;
extern NSString *const __pic;
extern NSString *const __id;
//      校内还是校外

typedef enum{
    LINShowAllVCOptionInschool = 1,
    LINShowAllVCOptionOutschool = 2
}LINShowAllVCOption;

NSString *const __apiShopFetchAll = @"index.php/Shop/fetchAll";

@interface LINShowAllVC ()
@property (weak, nonatomic) MKNetworkEngine *engine;

@property (strong, nonatomic) NSArray *shopsInSchool;
@property (strong, nonatomic) NSArray *shopsOutSchool;
@property (strong, nonatomic) IBOutlet UISegmentedControl *preferredOption;
@end

@implementation LINShowAllVC

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
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self fetchAllShopWithOptions:LINShowAllVCOptionInschool];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    

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
    if (self.preferredOption.selectedSegmentIndex == 0) {
        return [self.shopsInSchool count];
    }else if (self.preferredOption.selectedSegmentIndex == 1){
        return [self.shopsOutSchool count];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"shopCell"];
    
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
    
    
    NSDictionary *aShop = nil;
    if (self.preferredOption.selectedSegmentIndex == 0) {
        aShop = self.shopsInSchool[indexPath.row];
    }else if (self.preferredOption.selectedSegmentIndex == 1){
        aShop = self.shopsOutSchool[indexPath.row];
    }
    
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
    [shopImage setImageWithURL:[NSURL URLWithString: aShop[__pic]] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    return cell;
}

#pragma mark - TableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [self performSegueWithIdentifier:@"showAllVCToDetail" sender:indexPath];
}

#pragma mark - Interaction With Server
- (void)fetchAllShopWithOptions:(LINShowAllVCOption)option{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    NSString *type = self.type;
    NSString *inoutSchool = [NSString stringWithFormat:@"%li", (unsigned long)option];
    NSNumber *schoolid = [[NSUserDefaults standardUserDefaults] valueForKey:@"schoolid"];
    MKNetworkOperation *op = [self.engine operationWithPath:__apiShopFetchAll params:@{@"length":@"999",
                                                                                  @"page":@"1",
                                                                                  @"schoolid":schoolid,
                                                                                  @"type":type,
                                                                                  @"inoutschool":inoutSchool
                                                                                   } httpMethod:@"POST"];
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSDictionary *dic = [completedOperation responseJSON];
        
        if (option == LINShowAllVCOptionInschool) {
            self.shopsInSchool = nil;
            [self.tableView reloadData];
            self.shopsInSchool = dic[@"success"][@"shops"];
        }else if (option == LINShowAllVCOptionOutschool){
            self.shopsOutSchool = nil;
            [self.tableView reloadData];
            self.shopsOutSchool = dic[@"success"][@"shops"];
        }
    /*         延迟0.5秒重载表示图(因为在网络好的情况下, 不延迟的话会出现稍微的卡顿)           */
        double delayInSeconds = 0.3;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];

        });
           //   [self.tableView reloadData];
        if (self.refreshControl.refreshing == YES) {
            [self.refreshControl endRefreshing];
        }
        [hud hide:YES];
        
    //    NSLog(@"%@",dic);
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        [hud hide:YES];
        [MBProgressHUD showNetworkErrorToView:self.navigationController.view];
    }];
    [self.engine enqueueOperation:op];
}

- (IBAction)preferOptionChanged:(UISegmentedControl *)sender {
    if ((self.shopsInSchool == nil && (sender.selectedSegmentIndex + 1) == 1) || (self.shopsOutSchool == nil && (sender.selectedSegmentIndex + 1) == 2)) {
        [self fetchAllShopWithOptions:sender.selectedSegmentIndex + 1];
    }else{
        [self.tableView reloadData];
    }
}

#pragma mark - Sague
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"showAllVCToDetail"]) {
        NSIndexPath *indexPath = (NSIndexPath *)sender;
        
        NSDictionary *aShop = nil;
        if (self.preferredOption.selectedSegmentIndex == 0) {
            aShop = self.shopsInSchool[indexPath.row];
        }else if (self.preferredOption.selectedSegmentIndex == 1){
            aShop = self.shopsOutSchool[indexPath.row];
        }
        
        [segue.destinationViewController setValue:aShop forKey:@"aShop"];
    }
}

- (IBAction)pop:(id)sender {
        [self.navigationController popViewControllerAnimated:YES];
}

- (void)refresh{
    [self fetchAllShopWithOptions:self.preferredOption.selectedSegmentIndex + 1];
}


@end
