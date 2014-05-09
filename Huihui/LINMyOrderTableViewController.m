//
//  LINMyOrderTableViewController.m
//  Huihui
//
//  Created by Lin on 14-5-7.
//  Copyright (c) 2014年 Lin. All rights reserved.
//

#import "LINMyOrderTableViewController.h"
#import "MKNetworkKit.h"
#import <objc/runtime.h>
#import "LINOrder.h"
#import "LINRootVC.h"

//{
//    count = 27;
//    orders =         (
//                      {
//                          amount = 1;
//                          goodid = 17;
//                          goodname = "\U6b66\U6c49\U70ed\U5e72\U9762";
//                          id = 56;
//                          price = 100;
//                          shopid = 284;
//                          shopname = "\U751c\U54c1\U679c\U884c";
//                          time = 1399472027;
//                          uid = 60;
//                      },
//                      {
//                          amount = 2;
//                          goodid = 19;
//                          goodname = "\U6b66\U6c49\U70ed\U5e72\U9762";
//                          id = 62;
//                          price = 100;
//                          shopid = 284;
//                          shopname = "\U751c\U54c1\U679c\U884c";
//                          time = 1399472027;
//                          uid = 60;
//                      },
//                      {
//                          amount = 1;
//                          goodid = 25;
//                          goodname = "\U6b66\U6c49\U70ed\U5e72\U9762";
//                          id = 65;
//                          price = 100;
//                          shopid = 284;
//                          shopname = "\U751c\U54c1\U679c\U884c";
//                          time = 1399472027;
//                          uid = 60;
//                      },
//                      {
//                          amount = 1;
//                          goodid = 21;
//                          goodname = "\U6b66\U6c49\U70ed\U5e72\U9762";
//                          id = 66;
//                          price = 100;
//                          shopid = 284;
//                          shopname = "\U751c\U54c1\U679c\U884c";
//                          time = 1399472027;
//                          uid = 60;
//                      },
//                      {
//                          amount = 1;
//                          goodid = 20;
//                          goodname = "\U8001\U4e1c\U5bb6\U6ce1\U998d";
//                          id = 67;
//                          price = "";
//                          shopid = 284;
//                          shopname = "\U751c\U54c1\U679c\U884c";
//                          time = 1399472027;
//                          uid = 60;
//                      },
//                      {
//                          amount = 1;
//                          goodid = 23;
//                          goodname = "\U6b66\U6c49\U70ed\U5e72\U9762";
//                          id = 68;
//                          price = 100;
//                          shopid = 284;
//                          shopname = "\U751c\U54c1\U679c\U884c";
//                          time = 1399472027;
//                          uid = 60;
//                      },
//                      {
//                          amount = 1;
//                          goodid = 19;
//                          goodname = "\U6b66\U6c49\U70ed\U5e72\U9762";
//                          id = 69;
//                          price = 100;
//                          shopid = 284;
//                          shopname = "\U751c\U54c1\U679c\U884c";
//                          time = 1399472027;
//                          uid = 60;
//                      },
//                      {
//                          amount = 3;
//                          goodid = 12;
//                          goodname = "\U8001\U4e1c\U5bb6\U6ce1\U998d";
//                          id = 70;
//                          price = 101;
//                          shopid = 284;
//                          shopname = "\U751c\U54c1\U679c\U884c";
//                          time = 1399472027;
//                          uid = 60;
//                      },
//                      {
//                          amount = 2;
//                          goodid = 17;
//                          goodname = "\U6b66\U6c49\U70ed\U5e72\U9762";
//                          id = 71;
//                          price = 100;
//                          shopid = 284;
//                          shopname = "\U751c\U54c1\U679c\U884c";
//                          time = 1399472027;
//                          uid = 60;
//                      },
//                      {
//                          amount = 2;
//                          goodid = 21;
//                          goodname = "\U6b66\U6c49\U70ed\U5e72\U9762";
//                          id = 72;
//                          price = 100;
//                          shopid = 284;
//                          shopname = "\U751c\U54c1\U679c\U884c";
//                          time = 1399472027;
//                          uid = 60;
//                      }
//                      );
//    totalPages = 3;
//};
//}


NSString *const __apiFetchOrder = @"index.php/Order/fetch";

@interface LINMyOrderTableViewController ()

@property (weak, nonatomic) MKNetworkEngine *engine;

@property (strong, nonatomic) NSMutableArray *orderList;

@property (nonatomic) NSInteger pageCount;
@property (nonatomic) BOOL loadMoreCellIsShown;

@end

@implementation LINMyOrderTableViewController

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
    self.pageCount = 1;
   // [self fetchOrderWithPage:self.pageCount];
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

- (NSMutableArray *)orderList{
    if (!_orderList) {
        _orderList = [NSMutableArray new];
    }
    return _orderList;
}


- (void)fetchOrderWithPage:(NSInteger)page{

    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[self.orderList count] inSection:0]];
    UILabel *label = (UILabel *)[cell.contentView viewWithTag:1];
    
//    if ([label.text isEqualToString:@"没有更多了"]) {
//        return;
//    }
    label.text = @"正在加载...";
    
    MKNetworkOperation *op = [self.engine operationWithPath:__apiFetchOrder params:@{
                                                                                     @"length":@(10),
                                                                                     @"page":@(page)} httpMethod:@"POST"];
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSDictionary *dic = [completedOperation responseJSON];
        NSMutableArray *orders = dic[@"success"][@"orders"];
        
        [self.orderList addObjectsFromArray:orders];
        
        NSRange range;
        range.location = (self.pageCount - 1) * 10;
        range.length = [orders count];
        
        NSLog(@"%@", [self indexPathsForRange:range]);
        [self.tableView insertRowsAtIndexPaths:[self indexPathsForRange:range] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        label.text = @"上拉加载更多";
        if ([orders count] > 0) {
                    self.loadMoreCellIsShown = NO;
        }else{
            label.text = @"没有更多了";
        }

        self.pageCount++;
        
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        ;
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

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView {
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
                [self fetchOrderWithPage:self.pageCount];
            }
            
        }
    }
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.orderList count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == [self.orderList count]) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"moreCell"];
        return cell;
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"order"];
    UIView *contentView = [cell.contentView viewWithTag:999];

    static char contentViewKey;
    NSString *setted = objc_getAssociatedObject(contentView, &contentViewKey);
    if (!setted) {
        objc_setAssociatedObject(contentView, &contentViewKey, @"0", OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        contentView.layer.borderColor = [UIColor colorWithRed:225/255.0 green:225/255.0 blue:225/255.0 alpha:1.0f].CGColor;
        contentView.layer.borderWidth = 1;
        contentView.layer.cornerRadius = 2;
    }
    
    UILabel *goodNameLabel = (UILabel *)[contentView viewWithTag:1];
    UILabel *shopNameLabel = (UILabel *)[contentView viewWithTag:2];
    UILabel *priceLabel = (UILabel *)[contentView viewWithTag:3];
    UILabel *mountLabel = (UILabel *)[contentView viewWithTag:4];
    UILabel *timeLabel = (UILabel *)[contentView viewWithTag:5];
    
    NSLog(@"%@", self.orderList[indexPath.row]);
    LINOrder *aOrder = [[LINOrder alloc] initWithDictionary:self.orderList[indexPath.row]];
    if (aOrder.goodname != [NSNull null]) {
        goodNameLabel.text = aOrder.goodname;
    }else{
        goodNameLabel.text = @"商品名缺失";
    }

    shopNameLabel.text = aOrder.shopname;
    priceLabel.text = [NSString stringWithFormat:@"%@元/1份", aOrder.price];
    mountLabel.text = [NSString stringWithFormat:@"%@份", aOrder.amount];
    timeLabel.text = aOrder.createTime;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == [self.orderList count]) {
        return 30;
    }else{
        return 59;
    }
}




/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
