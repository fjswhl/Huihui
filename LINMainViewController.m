//
//  LINMainViewController.m
//  Huihui
//
//  Created by Lin on 3/24/14.
//  Copyright (c) 2014 Lin. All rights reserved.
//

#import "LINMainViewController.h"
#import "MKNetworkKit.h"
#import "RatingView.h"
#import "UIImageView+WebCache.h"
NSString *const apiGuessULike = @"index.php/Shop/guessULike";
NSString *const __shopname = @"shopname";
NSString *const __discount = @"discount";
NSString *const __location = @"location";
NSString *const __phone = @"phone";
NSString *const __grade = @"grade";
NSString *const __pic = @"pic";
NSString *const __id = @"id";


@interface LINMainViewController ()<UIScrollViewDelegate>

@property (weak, nonatomic) MKNetworkEngine *engine;

@property (strong, nonatomic) NSMutableArray *shops;
@property (nonatomic) BOOL loadMoreCellIsShown;
@property (nonatomic) NSInteger pageCount;


@end

@implementation LINMainViewController

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
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.loadMoreCellIsShown = YES;
    self.pageCount = 1;
    // KVO
    [self.tableView addObserver:self forKeyPath:@"visibleCells" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:NULL];
    
    [self fetchGuessUlikeShopListWithPage:@"1"];

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

#pragma mark - getter
- (MKNetworkEngine *)engine{
    if (!_engine) {
        id delegate = [[UIApplication sharedApplication] delegate];
        _engine = [delegate engine];
    }
    return _engine;
}



- (NSMutableArray *)shops{
    if (!_shops) {
        _shops = [NSMutableArray new];
    }
    return _shops;
}
#pragma mark - TableView Datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return [self.shops count] + 1;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == [self.shops count]) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"moreCell" forIndexPath:indexPath];
        return cell;
    }
    
    
    static NSString *cellIdentifider = @"shopCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifider forIndexPath:indexPath];
    
    UILabel *shopNameLabel = (UILabel *)[cell.contentView viewWithTag:1];
    UILabel *discountLabel = (UILabel *)[cell.contentView viewWithTag:2];
    UILabel *locationLabel = (UILabel *)[cell.contentView viewWithTag:3];
    RatingView *ratingView = (RatingView *)[cell.contentView viewWithTag:4];
    UIImageView *shopImage = (UIImageView *)[cell.contentView viewWithTag:5];
    
    [cell.contentView sendSubviewToBack:ratingView];
    
    if (!ratingView.s1) {
          [ratingView setImagesDeselected:@"0.png" partlySelected:@"1.png" fullSelected:@"2.png" andDelegate:nil];
    }
    




    NSDictionary *aShop = self.shops[indexPath.row];

//    if ([aShop[@"pic"] rangeOfString:@"png"].location != NSNotFound) {
        [shopImage setImageWithURL:aShop[@"pic"]];
//    }else{
//        [shopImage setImage:nil];
//    }
    shopNameLabel.text = aShop[__shopname];
    discountLabel.text = aShop[__discount];
    locationLabel.text = aShop[__location];
    [ratingView displayRating:[aShop[__grade] floatValue]];
   
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == [self.shops count]) {
        return 54.0f;
    }
    return 94.0f;
}
#pragma mark - TableView Delegate

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return @"猜你喜欢";
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"%@", indexPath);
    [self performSegueWithIdentifier:@"showDetail" sender:indexPath];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (self.loadMoreCellIsShown == true) {
        return;
    }
    UITableViewCell *lastVisibleCell = [self.tableView.visibleCells lastObject];
    UILabel *label = (UILabel *)[lastVisibleCell viewWithTag:1];
    if ([label.text isEqualToString:@"正在加载..."]) {
        
        self.loadMoreCellIsShown = true;
        [self fetchGuessUlikeShopListWithPage:[NSString stringWithFormat:@"%i", self.pageCount]];
        
    }
}

#pragma mark - KVO callback
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqualToString:@"visibleCells"]) {
        NSArray *visibleCells = [change objectForKey:NSKeyValueChangeNewKey];
        UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"moreCell"];
        if ([visibleCells containsObject:cell]) {
            NSLog(@"dsffsf");
        }
    }else if ([keyPath isEqualToString:@"count"]){

    }
}


#pragma mark - Interaction With Server
- (void)fetchGuessUlikeShopListWithPage:(NSString *)pages{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[self.shops count] inSection:0]];
    UIActivityIndicatorView *indicator = (UIActivityIndicatorView *)[cell.contentView viewWithTag:2];
    [indicator startAnimating];
    
    MKNetworkOperation *op = [self.engine operationWithPath:apiGuessULike params:@{@"length":@"5", @"page":pages} httpMethod:@"POST"];
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSDictionary *dic = [completedOperation responseJSON];

        if ([dic[@"error"] isEqualToString:@"2"]) {

            UILabel *label = (UILabel *)[cell.contentView viewWithTag:1];
            label.text = @"没有更多了...";
            [indicator stopAnimating];
            return;
        }
        
        NSArray *st = [dic[@"success"] objectForKey:@"shops"];
        
        [self.shops addObjectsFromArray:st];
        [indicator stopAnimating];
        [self.tableView reloadData];
        self.loadMoreCellIsShown = NO;
        self.pageCount++;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        ;
#warning wait for completion
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

#pragma mark - Button Method
- (IBAction)typeButtonFoodTapped:(id)sender {
}
- (IBAction)typeButtonServiceTapped:(id)sender {
}
- (IBAction)typeButtonEntertainmentTapped:(id)sender {
}

@end






























