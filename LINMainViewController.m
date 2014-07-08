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
#import "MBProgressHUD.h"
#import "ColorButton.h"
#import <objc/runtime.h>
#import <QuartzCore/QuartzCore.h>
#import "LINRootVC.h"
#import "UIColor+LINColor.h"
#import "UIButton+Color.h"


#define kAdsVersionUDKEY @"adsVersion"


NSString *const apiGuessULike  = @"index.php/Shop/guessULike";
NSString *const __apiGetSearch = @"index.php/Shop/getSearch";
NSString *const __apiAdlist = @"index.php/More/adlist";


NSString *const __shopname     = @"shopname";
NSString *const __discount     = @"discount";
NSString *const __location     = @"location";
NSString *const __phone        = @"phone";
NSString *const __grade        = @"grade";
NSString *const __pic          = @"pic";
NSString *const __id           = @"id";


@interface LINMainViewController ()<UIScrollViewDelegate, UISearchBarDelegate>

@property (weak, nonatomic) MKNetworkEngine *engine;

@property (strong, nonatomic) NSMutableArray *shops;
@property (nonatomic) BOOL loadMoreCellIsShown;
@property (nonatomic) NSInteger pageCount;
@property (strong, nonatomic) NSMutableDictionary *shopImgs;

@property (strong, nonatomic) IBOutlet UIView *adView;
@property (strong, nonatomic) IBOutlet UIButton *changeSchoolidButton;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;

@property (strong, nonatomic) NSMutableArray *filterdShops;
@property (strong, nonatomic) UITableView *searchResultTableview;
@property (nonatomic) BOOL ss;

@property (weak, nonatomic) LINPickerSchoolViewController *pickSchoolVC;
/**
 *   这个属性用于解决一个问题: 当用户切换schoolid时, fetchGuessUlikeWithPage:(NSString *)page会被调用两次, 第一次是当[tableview reloadData]后scrollViewDidScroll导致被调用,第二次是切换schoolid时手动调用. 该属性防止scrollviewDidScroll调用fetch方法
 */
@property (nonatomic) BOOL scrollViewDidScrollFlag;


@property (strong, nonatomic) IBOutlet ColorButton *foodButton;
@property (strong, nonatomic) IBOutlet ColorButton *entertainmentButton;
@property (strong, nonatomic) IBOutlet ColorButton *lifeButton;
@property (strong, nonatomic) IBOutlet ColorButton *bookButton;



/**
 *  处理广告的时候, 会存储一个NSUserDefault. @"adsVersion" ,如果检测出adsVersion大于之前的, 则下载新广告;
 *  另一个adsImage ,用于存储已经下载的广告
 */
@property (strong, nonatomic) NSMutableArray *adsArray;
@property (strong, nonatomic) NSMutableArray *adsURLArray;
@property (strong, nonatomic) NSMutableArray *adsModelArray;
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
    
    [self setupUI];
    
    self.refreshControl = [UIRefreshControl new];
    [self.refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    
    /**
     *  加载已经存储的广告
     */
//    NSArray *adsImg = [[NSUserDefaults standardUserDefaults] valueForKey:@"adsImage"];
//    if (adsImg) {
//        for (int i = 0; i < [adsImg count]; i++) {
//            UIImage *img = adsImg[i];
//            if (img) {
//                IntroModel *model = self.adsModelArray[i];
//                model.image = img;
//            }
//        }
//    }
    NSMutableArray *adsURLArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"adsURLArray"];
    if (adsURLArray) {
        SDWebImageDownloader *manager = [SDWebImageDownloader sharedDownloader];
        
        for (int i = 0; i < [adsURLArray count]; i++) {
            [manager downloadImageWithURL:[NSURL URLWithString: adsURLArray[i]] options:0 progress:nil completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                if (image) {
                    IntroModel *model = self.adsModelArray[i];
                    model.image = image;
                }
            }];
        }
    }
    
    [self fetchAdListSuccess:^{
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        
        //NSMutableArray *adsImgs = [NSMutableArray new];
        NSMutableArray *arr = [@[@"123",@"456",@"789"] mutableCopy];
        NSArray *arr1 = self.adsURLArray;
        NSLog(@"%@", arr);
        NSLog(@"%@", arr1);
        [[NSUserDefaults standardUserDefaults] setObject:arr1 forKey:@"adsURLArray"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        for (int i = 0; i < [self.adsURLArray count]; i++) {
            [manager downloadWithURL:[NSURL URLWithString: adsURLArray[i]] options:0 progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished) {
                if (image) {
                    IntroModel *model = self.adsModelArray[i];
                    model.image = image;
    
                   // [adsImgs addObject:image];
                }
            }];
        }
        //[[NSUserDefaults standardUserDefaults] setValue:adsImgs forKey:@"adsImage"];
    } failed:nil];
    
    

  //  [self setHidesBottomBarWhenPushed:YES];
    // 修改searchbar的取消按钮

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem
 //   [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(searchBarResign)]];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    LINRootVC *rootVC = (LINRootVC *)self.tabBarController;
    [rootVC showTabbarAnimated:YES];
    if (self.searchBar.text != nil || ![self.searchBar isFirstResponder]) {
        self.searchBar.text = nil;
        [self updateTitleViewUI];
    }

}
- (void)searchBarResign{
    [self.searchBar resignFirstResponder];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupUI{
    [self.foodButton setBackgroundImageWithColor:[UIColor whiteColor] forState:(UIControlStateNormal | UIControlStateHighlighted)];
        [self.entertainmentButton setBackgroundImageWithColor:[UIColor whiteColor] forState:(UIControlStateNormal | UIControlStateHighlighted)];
     //   [self.entertainmentButton setBackgroundImageWithColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [self.lifeButton setBackgroundImageWithColor:[UIColor whiteColor] forState:(UIControlStateNormal | UIControlStateHighlighted)];
        [self.bookButton setBackgroundImageWithColor:[UIColor whiteColor] forState:(UIControlStateNormal | UIControlStateHighlighted)];

}

- (void)refresh:(id)sender{
    self.loadMoreCellIsShown = YES;
    self.pageCount = 1;
    self.shops = [NSMutableArray new];
    [self.tableView reloadData];
    [self fetchGuessUlikeShopListWithPage:@"1"];
}
#pragma mark - getter
- (MKNetworkEngine *)engine{
    if (!_engine) {
        id delegate = [[UIApplication sharedApplication] delegate];
        _engine = [delegate engine];
    }
    return _engine;
}

- (NSMutableArray *)filterdShops{
    if (!_filterdShops) {
        _filterdShops = [NSMutableArray new];
    }
    return _filterdShops;
}

- (UITableView *)searchResultTableview{
    if (!_searchResultTableview) {
        CGRect frame = self.view.frame;
        frame.origin.y += 64;
        _searchResultTableview = [[UITableView alloc] initWithFrame:frame];
        _searchResultTableview.delegate = self;
        _searchResultTableview.dataSource = self;
    }
    return _searchResultTableview;
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

- (LINPickerSchoolViewController *)pickSchoolVC{
    if (!_pickSchoolVC) {
        _pickSchoolVC = [self.storyboard instantiateViewControllerWithIdentifier:@"linpicker"];
        _pickSchoolVC.delegate = self;
    }
    return _pickSchoolVC;
}

- (NSMutableArray *)adsArray{
    if (!_adsArray) {
        _adsArray = [NSMutableArray new];
    }
    return _adsArray;
}

- (NSMutableArray *)adsURLArray{
    if (!_adsURLArray) {
        _adsURLArray = [NSMutableArray new];
    }
    return _adsURLArray;
}

- (NSMutableArray *)adsModelArray{
    if (!_adsModelArray) {
        _adsModelArray = [NSMutableArray new];
    }
    return _adsModelArray;
}

#pragma mark - TableView Datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == self.searchResultTableview) {
        return [self.filterdShops count];
    }
    if (section == 0) {
        return [self.shops count] + 1;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
/**
 *  当用户点击搜索时执行下面的if
 */
    if (tableView == self.searchResultTableview) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"searchCell"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"searchCell"];
        }
        NSDictionary *aShop = self.filterdShops[indexPath.row];
        cell.textLabel.text = aShop[__shopname];
        return cell;
    }
    
    if (indexPath.row == [self.shops count]) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"moreCell"];
        return cell;
    }
    
    
    static NSString *cellIdentifider = @"shopCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifider];
    UIView *contentView = [cell.contentView viewWithTag:999];
    
    /**
     *  lineView. 只加在第一个cell上
     */

    if (indexPath.row == 0) {
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)];
        lineView.backgroundColor = [UIColor preferredColor];
        lineView.tag = 987;
        
        UIView *v = [cell.contentView viewWithTag:987];
        if (!v) {
            [cell.contentView addSubview:lineView];
        }
    }else{
        UIView *v = [cell.contentView viewWithTag:987];
        if (v) {
            [v removeFromSuperview];
        }
    }
    

//    static char contentViewKey;
//    NSString *setted = objc_getAssociatedObject(contentView, &contentViewKey);
//    if (!setted) {
//        objc_setAssociatedObject(contentView, &contentViewKey, @"0", OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//        contentView.layer.borderColor = [UIColor colorWithRed:225/255.0 green:225/255.0 blue:225/255.0 alpha:1.0f].CGColor;
//        contentView.layer.borderWidth = 1;
//        contentView.layer.cornerRadius = 2;
//    }


    UILabel *shopNameLabel = (UILabel *)[contentView viewWithTag:1];
    UILabel *discountLabel = (UILabel *)[contentView viewWithTag:2];
    UILabel *locationLabel = (UILabel *)[contentView viewWithTag:3];
    RatingView *ratingView = (RatingView *)[contentView viewWithTag:4];
    UIImageView *shopImage = (UIImageView *)[contentView viewWithTag:5];
    UIImageView *vipFlag = (UIImageView *)[contentView viewWithTag:98];
    UIImageView *bookFlag = (UIImageView *)[contentView viewWithTag:99];
    
    
    
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
    //NSLog(@"%@", aShop);
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
    
    if ([aShop[@"isreserve"] integerValue] == 1) {
        bookFlag.hidden = NO;
    }else{
        bookFlag.hidden = YES;
    }
    
    if ([aShop[@"isvip"] integerValue] == 1) {
        vipFlag.hidden = NO;
    }else{
        vipFlag.hidden = YES;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == self.searchResultTableview) {
        return 44;
    }
    if (indexPath.row == [self.shops count]) {
        return 43.0f;
    }
    return 85.0f;
}
#pragma mark - TableView Delegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (tableView == self.searchResultTableview) {
        return nil;
    }
    if (section == 0) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 26)];
        //view.backgroundColor = [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:0.87];
        view.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.87];
        UILabel *label = [UILabel new];
        label.font = [UIFont systemFontOfSize:14.0f];
        label.text = @"猜你喜欢";
        [label sizeToFit];
        label.center = CGPointMake(40, CGRectGetMidY(view.frame));
        [view addSubview:label];
        view.clipsToBounds = NO;
//        view.layer.shadowColor = [UIColor blackColor].CGColor;
//        view.layer.shadowOffset = CGSizeMake(0, -10);
//        view.layer.shadowOpacity = 0.3;

        return view;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (tableView == self.tableView && section == 0) {
        return 26;
    }
    return 0;
}
//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
//    if (tableView == self.searchResultTableview) {
//        return nil;
//    }
//    if (section == 0) {
//        return @"猜你喜欢";
//    }
//    return nil;
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == self.searchResultTableview) {
        [self performSegueWithIdentifier:@"showDetail" sender:indexPath];
        return;
    }
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

/**
 *    当scrollView滚到最下面的时候执行第二个if里的操作,即加载更多数据
 */
- (void)scrollViewDidScroll:(UIScrollView *)aScrollView {
    if (self.scrollViewDidScrollFlag) {
        self.scrollViewDidScrollFlag = false;
        return;
    }
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
            if (self.loadMoreCellIsShown == false) {
                self.loadMoreCellIsShown = true;
                [self fetchGuessUlikeShopListWithPage:[NSString stringWithFormat:@"%li", (unsigned long)self.pageCount]];
            }
            
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
#pragma mark - Searchbar delegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
//    [self.changeSchoolidButton setHidden:YES];
    [searchBar setShowsCancelButton:YES animated:YES];
    //NSLog(@"%@", [searchBar subviews]);
    UIView *contentView = [[searchBar subviews] objectAtIndex:0];
    for (id cc in [contentView subviews]) {
        if ([cc isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)cc;
            [button setTitle:@"取消" forState:UIControlStateNormal];
        }
    }
    [UIView animateWithDuration:0.3 animations:^{
        [searchBar setFrame:CGRectMake(0, -5, 311, 44)];
        [self.changeSchoolidButton setAlpha:0.0];
    }];
    [self.tableView setScrollEnabled:NO];
    self.ss = true;
    [self.navigationController.view addSubview:self.searchResultTableview];
    [self.searchResultTableview reloadData];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
//    [self.changeSchoolidButton setHidden:NO];
    [searchBar setShowsCancelButton:NO animated:YES];
//    [UIView animateWithDuration:0.3 animations:^{
//        [searchBar setFrame:CGRectMake(105, -5, 202, 44)];
//        [self.changeSchoolidButton setAlpha:1.0];
//    }];
    [self.tableView setScrollEnabled:YES];
    self.ss = false;
    [self.searchResultTableview removeFromSuperview];
    [searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    //    [self.changeSchoolidButton setHidden:NO];
    [searchBar setShowsCancelButton:NO animated:YES];
    [UIView animateWithDuration:0.3 animations:^{
        [searchBar setFrame:CGRectMake(105, -5, 202, 44)];
        [self.changeSchoolidButton setAlpha:1.0];
    }];
    [self.tableView setScrollEnabled:YES];
    self.ss = false;
    [self.searchResultTableview removeFromSuperview];
    [searchBar resignFirstResponder];
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    MKNetworkOperation *op = [self.engine operationWithPath:__apiGetSearch params:@{
                                                                                    @"keyword":searchText,
                                                                                    @"length":@(20),
                                                                                    @"page":@(1)} httpMethod:@"POST"];
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSDictionary *dic = [completedOperation responseJSON];
       // NSLog(@"%@", dic);
        if (dic[@"error"]) {
            self.filterdShops = nil;
            [self.searchResultTableview reloadData];
            return;
        }
        self.filterdShops = dic[@"success"][@"shops"];
        [self.searchResultTableview reloadData];
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
#warning wait
    }];
    [self.engine enqueueOperation:op];
}

- (void)updateTitleViewUI{
    [self.searchBar setShowsCancelButton:NO animated:YES];
    [UIView animateWithDuration:0.3 animations:^{
        [self.searchBar setFrame:CGRectMake(105, -5, 202, 44)];
        [self.changeSchoolidButton setAlpha:1.0];
    }];
    [self.tableView setScrollEnabled:YES];
    self.ss = false;
    [self.searchResultTableview removeFromSuperview];
    [self.searchBar resignFirstResponder];
}
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
      //  NSLog(@"%@", self.shops);
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[self.shops count] inSection:0]];
    UILabel *label = (UILabel *)[cell.contentView viewWithTag:1];
    label.text = @"正在加载...";
    UIActivityIndicatorView *indicator = (UIActivityIndicatorView *)[cell.contentView viewWithTag:2];
  //  [indicator startAnimating];
    
    NSNumber *schoolid = [[NSUserDefaults standardUserDefaults] valueForKey:@"schoolid"];
    
    MKNetworkOperation *op = [self.engine operationWithPath:apiGuessULike params:@{@"length":@"5", @"page":pages, @"schoolid":schoolid} httpMethod:@"POST"];
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSDictionary *dic = [completedOperation responseJSON];
       // NSLog(@"%@", dic);
        if ([dic[@"error"] isEqualToString:@"2"]) {
            label.text = @"没有更多了...";
            [indicator stopAnimating];
            return;
        }
        
        NSArray *st = [dic[@"success"] objectForKey:@"shops"];
       // NSLog(@"%@", st);
        [self.shops addObjectsFromArray:st];
        
           // NSLog(@"%@", self.shops);
        
   //     [indicator stopAnimating];
        
        NSRange range;
        range.location = (self.pageCount - 1) * 5;
        range.length = [st count];
        [self.tableView insertRowsAtIndexPaths:[self indexPathsForRange:range] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        label.text = @"上拉加载更多";
        self.loadMoreCellIsShown = NO;
        self.pageCount++;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        
        if(self.refreshControl.isRefreshing){
            [self.refreshControl endRefreshing];
        }
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        [MBProgressHUD showNetworkErrorToView:self.navigationController.view];
    }];
    [self.engine enqueueOperation:op];
}

- (NSArray *)indexPathsForRange:(NSRange)range{
    NSMutableArray *result = [NSMutableArray new];
    for (int i = range.location; i < (range.location + range.length); i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        [result addObject:indexPath];
    }
    return [result copy];
}


- (void)fetchAdListSuccess:(void (^)(void))successBlock failed:(void (^)(void))failedBlock{
    MKNetworkOperation *op = [self.engine operationWithPath:__apiAdlist params:nil httpMethod:@"POST"];
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSDictionary *dic = [completedOperation responseJSON];
        NSLog(@"%@", dic);
        if (dic[@"error"]) {
            if (failedBlock) {
                failedBlock();
            }
            return;
        }
        
        NSDictionary *ads = dic[@"success"];
        
        
        NSNumber *oldVersion = [[NSUserDefaults standardUserDefaults] valueForKey:kAdsVersionUDKEY];
        if (!oldVersion) {
            oldVersion = @(0);
        }
        
        NSNumber *newVersion = nil;
        
        NSArray *keys = [ads allKeys];
        for (NSString *key in keys) {
            if ([key isEqualToString:@"version"]) {
                newVersion = ads[key];
                continue;
            }
            NSString *urlString = ads[key];
            [self.adsURLArray addObject:urlString];
        }
        
        /**
         * 新广告的版本号大于旧版本的版本号的话, 就更新广告.
         */
        if (successBlock && ([newVersion integerValue] > [oldVersion integerValue])) {
            [[NSUserDefaults standardUserDefaults] setValue:newVersion forKey:kAdsVersionUDKEY];
            successBlock();
        }
        
    } errorHandler:nil];
    
    [self.engine enqueueOperation:op];
}


#pragma mark - Sague
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    LINRootVC *rootVC = (LINRootVC *) self.tabBarController;
    [rootVC hideTabbarAnimated:YES];
     if ([segue.identifier isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = (NSIndexPath *)sender;
        NSDictionary *aShop = self.shops[indexPath.row];
        if (self.ss == true) {
            aShop = self.filterdShops[indexPath.row];
        }
        [segue.destinationViewController setValue:aShop forKey:@"aShop"];
    }else if ([segue.identifier isEqualToString:@"type"]){
        UIButton *button = (UIButton *)sender;
        LINShowAllVC *showAllVC = (LINShowAllVC *)segue.destinationViewController;
        [showAllVC setType:[NSString stringWithFormat:@"%li", (unsigned long)button.tag]];
        
    }
}

#pragma mark - Button Method
- (IBAction)typeButtonTapped:(UIButton *)sender {
    [self performSegueWithIdentifier:@"type" sender:sender];
}


- (IBAction)changeSchool:(id)sender {
    UIButton *btn = sender;
    /*      tag=0表示未打开, =999已打开         */
    for (id aView in btn.subviews) {
        if ([aView isKindOfClass:[UIImageView class]]) {
            UIImageView *imgView = aView;
            CGAffineTransform desTransform = CGAffineTransformIdentity;
            if (btn.tag == 0) {
                desTransform = CGAffineTransformMakeRotation(M_PI);
            }
            [UIView animateWithDuration:0.4 animations:^{
                imgView.transform = desTransform;
            }];
        }
    }
    if (btn.tag == 0) {
        btn.tag = 999;
    }else{
        btn.tag = 0;
        [self.pickSchoolVC dismissCompletion:nil];
    }

    
    
//    LINPickerSchoolViewController *pickVC = [self.storyboard instantiateViewControllerWithIdentifier:@"linpicker"];
//    UIGraphicsBeginImageContext(self.view.frame.size);
//    [self.tabBarController.view.layer renderInContext:UIGraphicsGetCurrentContext()];
//    UIImage *im = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    pickVC.backImage = im;
//    pickVC.delegate = self;
    

  //  [self presentViewController:pickVC animated:NO completion:nil];
//    self.navigationController
//    [self.navigationController.view addSubview:pickVC.view];

    [self.tabBarController addChildViewController:self.pickSchoolVC];
    [self.navigationController.view insertSubview:self.pickSchoolVC.view belowSubview:self.navigationController.navigationBar];
//    [self.pickSchoolVC viewDidAppear:YES];
 //   [self.navigationController addChildViewController:pickVC];
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

#pragma mark - 配置广告栏
- (void)loadView{
    [super loadView];
    IntroModel *model1 = [[IntroModel alloc] initWithTitle:nil description:@"汇你所需,惠及你我" image:@"广告1.png"];
    IntroModel *model2 = [[IntroModel alloc] initWithTitle:nil description:@"一步注册,即享优惠" image:@"广告2.png"];
    IntroModel *model3 = [[IntroModel alloc]initWithTitle:nil description:@"预享实惠,推荐汇惠" image:@"广告3.png"];
    
    self.adsModelArray = [@[model1, model2, model3] mutableCopy];
    IntroControll *c = [[IntroControll alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.adView.frame), CGRectGetHeight(self.adView.frame)) pages:self.adsModelArray];
    c.layer.shadowColor = [UIColor blackColor].CGColor;
    c.layer.shadowOffset = CGSizeMake(2, 2);
    c.layer.shadowOpacity = 0.2f;
    [self.adView addSubview:c];
}

#pragma mark - LINPickerDelegate
/**
 *  -1表示不更改
 */
- (void)userDidChangeSchoolid:(NSInteger)schoolid{
    if (self.changeSchoolidButton.tag == 0) {
        self.changeSchoolidButton.tag = 999;
    }else{
        self.changeSchoolidButton.tag = 0;
    }
    for (id aView in self.changeSchoolidButton.subviews) {
        if ([aView isKindOfClass:[UIImageView class]]) {
            UIImageView *imgView = aView;
            [UIView animateWithDuration:0.4 animations:^{
                imgView.transform = CGAffineTransformIdentity;
            }];
        }
    }
    if (schoolid == -1) {
        return;
    }
    
    if (schoolid == 0) {

        [self.changeSchoolidButton setTitle:@"西电新校区" forState:        UIControlStateNormal];
    }else{
        [self.changeSchoolidButton setTitle:@"西电老校区" forState:        UIControlStateNormal];
    }
    self.shops = nil;
    self.pageCount = 1;
    
    self.scrollViewDidScrollFlag = true;
    [self.tableView reloadData];

        [self fetchGuessUlikeShopListWithPage:@"1"];
    
    

}

- (void)updateTitleButton{
    NSNumber *schoolid = [[NSUserDefaults standardUserDefaults] valueForKey:@"schoolid"];
    if ([schoolid integerValue] == 1) {
        
        [self.changeSchoolidButton setTitle:@"西电新校区" forState:        UIControlStateNormal];
    }else{
        [self.changeSchoolidButton setTitle:@"西电老校区" forState:        UIControlStateNormal];
    }
}


@end






























