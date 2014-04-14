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
//#import "UIImageView+WebCache.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "SDWebImage/SDImageCache.h"
#import "IntroControll.h"
#import "LINShowAllVC.h"
#import "LINPickerSchoolViewController.h"
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
@property (strong, nonatomic) NSMutableDictionary *shopImgs;

@property (strong, nonatomic) IBOutlet UIView *adView;
@property (strong, nonatomic) IBOutlet UIButton *changeSchoolidButton;

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
    [self updateTitleButton];
    
    [self fetchGuessUlikeShopListWithPage:@"1"];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem
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

- (NSMutableDictionary *)shopImgs{
    if (!_shopImgs) {
        _shopImgs = [NSMutableDictionary new];
    }
    return _shopImgs;
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
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"moreCell"];
        return cell;
    }
    
    
    static NSString *cellIdentifider = @"shopCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifider];
    
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
    [shopImage setImageWithURL:[NSURL URLWithString: aShop[__pic]]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == [self.shops count]) {
        return 43.0f;
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
    if (indexPath.row != [self.shops count]) {
        [self performSegueWithIdentifier:@"showDetail" sender:indexPath];
    }

}

//- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
//    if (self.loadMoreCellIsShown == true) {
//        return;
//    }
//    UITableViewCell *lastVisibleCell = [self.tableView.visibleCells lastObject];
//    UILabel *label = (UILabel *)[lastVisibleCell viewWithTag:1];
//    if ([label.text isEqualToString:@"正在加载..."]) {
//        
//        self.loadMoreCellIsShown = true;
//        [self fetchGuessUlikeShopListWithPage:[NSString stringWithFormat:@"%i", self.pageCount]];
//        
//    }
//}

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView {
	
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
        if (self.loadMoreCellIsShown == false) {
            self.loadMoreCellIsShown = true;
            [self fetchGuessUlikeShopListWithPage:[NSString stringWithFormat:@"%li", (unsigned long)self.pageCount]];
        }

	}
}

//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
//    NSArray *cells = self.tableView.visibleCells;
//    for (UITableViewCell *cell in cells) {
//        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
//        NSString *imgSt = [self.shops[indexPath.row][__pic] stringByReplacingOccurrencesOfString:@"http://xdhuihui-public.stor.sinaapp.com/upload/img/shop/" withString:@""];
//        NSLog(@"%@", imgSt);
//        [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:self.shops[indexPath.row][__pic]] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
//            ;
//        } completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
//            NSString *doucumentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
//            [UIImageJPEGRepresentation(image, 0) writeToFile:doucumentsPath atomically:YES];
//        }];
//        
//    }
//}

#pragma mark - KVO callback
//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
//    if ([keyPath isEqualToString:@"visibleCells"]) {
//        NSArray *visibleCells = [change objectForKey:NSKeyValueChangeNewKey];
//        UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"moreCell"];
//        if ([visibleCells containsObject:cell]) {
//            NSLog(@"dsffsf");
//        }
//    }else if ([keyPath isEqualToString:@"count"]){
//
//    }
//}


#pragma mark - Interaction With Server
- (void)fetchGuessUlikeShopListWithPage:(NSString *)pages{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[self.shops count] inSection:0]];
    UIActivityIndicatorView *indicator = (UIActivityIndicatorView *)[cell.contentView viewWithTag:2];
    [indicator startAnimating];
    
    NSNumber *schoolid = [[NSUserDefaults standardUserDefaults] valueForKey:@"schoolid"];
    
    MKNetworkOperation *op = [self.engine operationWithPath:apiGuessULike params:@{@"length":@"5", @"page":pages, @"schoolid":schoolid} httpMethod:@"POST"];
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSDictionary *dic = [completedOperation responseJSON];
        NSLog(@"%@", dic);
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
    }else if ([segue.identifier isEqualToString:@"type"]){
        UIButton *button = (UIButton *)sender;
        LINShowAllVC *showAllVC = (LINShowAllVC *)segue.destinationViewController;
        [showAllVC setType:[NSString stringWithFormat:@"%li", (unsigned long)button.tag]];
        
    }
}

#pragma mark - Button Method
- (IBAction)typeButtonFoodTapped:(UIButton *)sender {
    [self performSegueWithIdentifier:@"type" sender:sender];
}
- (IBAction)typeButtonServiceTapped:(UIButton *)sender {
    [self performSegueWithIdentifier:@"type" sender:sender];
}
- (IBAction)typeButtonEntertainmentTapped:(UIButton *)sender {
    [self performSegueWithIdentifier:@"type" sender:sender];
}

- (IBAction)changeSchool:(id)sender {
    LINPickerSchoolViewController *pickVC = [self.storyboard instantiateViewControllerWithIdentifier:@"linpicker"];
    UIGraphicsBeginImageContext(self.view.frame.size);
    [self.tabBarController.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *im = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    pickVC.backImage = im;
    pickVC.delegate = self;
    

    [self presentViewController:pickVC animated:NO completion:nil];
    
}

//- (void)startImgDownload:(NSDictionary *)aShop forIndexPath:(NSIndexPath *)indexPath{
//    [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:aShop[__pic]] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
//        ;
//    } completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
//        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
//        UIImageView *imgView = (UIImageView *)[cell.contentView viewWithTag:5];
//        imgView.image = image;
//        if (image != nil) {
//                    self.shopImgs[indexPath] = image;
//        }
//
//    }];
//}
//
//- (void)loadImagesForOnscreenRows{
//    if ([self.shops count] > 0) {
//        NSArray *visblePaths = [self.tableView indexPathsForVisibleRows];
//        // 如果滚动到最下面, 加载更多的cell也会在这里面
//        
//        for (NSInteger i = 0; i < [visblePaths count] - 1; i++) {
//            NSIndexPath *indexPath = visblePaths[i];
//            NSDictionary *aShop = self.shops[indexPath.row];
//            if (!self.shopImgs[indexPath]) {
//                [self startImgDownload:aShop forIndexPath:indexPath];
//            }
//        }
//    }
//}
//
//- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
//    if (!decelerate) {
//        [self loadImagesForOnscreenRows];
//    }
//}
//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
//    [self loadImagesForOnscreenRows];
//}

- (void)loadView{
    [super loadView];
    IntroModel *model1 = [[IntroModel alloc] initWithTitle:nil description:@"汇你所需,惠及你我" image:@"ads1.png"];
    IntroModel *model2 = [[IntroModel alloc] initWithTitle:nil description:@"一步注册,即享优惠" image:@"ads2.png"];
    IntroModel *model3 = [[IntroModel alloc]initWithTitle:nil description:@"预享实惠,推荐汇惠" image:@"ads3.png"];
    IntroControll *c = [[IntroControll alloc] initWithFrame:self.adView.frame pages:@[model1,model2,model3]];
    [self.adView addSubview:c];
}

#pragma mark - LINPickerDelegate

- (void)userDidChangeSchoolid:(NSInteger)schoolid{
    if (schoolid == 0) {

        [self.changeSchoolidButton setTitle:@"西电新校区" forState:        UIControlStateNormal];
    }else{
        [self.changeSchoolidButton setTitle:@"西电老校区" forState:        UIControlStateNormal];
    }
    self.shops = nil;
    self.pageCount = 1;
    [self.tableView reloadData];
    [self fetchGuessUlikeShopListWithPage:@"1"];
}

- (void)updateTitleButton{
    NSNumber *schoolid = [[NSUserDefaults standardUserDefaults] valueForKey:@"schoolid"];
    if ([schoolid integerValue] == 0) {
        
        [self.changeSchoolidButton setTitle:@"西电新校区" forState:        UIControlStateNormal];
    }else{
        [self.changeSchoolidButton setTitle:@"西电老校区" forState:        UIControlStateNormal];
    }
}
@end






























