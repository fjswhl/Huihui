//
//  LINShowCommentTableViewController.m
//  Huihui
//
//  Created by Lin on 4/16/14.
//  Copyright (c) 2014 Lin. All rights reserved.
//

#import "LINShowCommentTableViewController.h"
#import "MKNetworkKit.h"
#import "MBProgressHUD.h"

//{
//    success =     {
//        comment =         (
//                           {
//                               comment = "\U5f88\U4e0d\U9519\Uff0c\U4e09\U4e2a\U4eba\U6d88\U8d3969\Uff0c\U4f7f\U7528\U8fd9\U4e2a\U8f6f\U4ef6\U4e4b\U540e\U603b\U517159\Uff0c\U8282\U7ea610\U5143\Uff0c\U4e0d\U9519\U4e0d\U9519\U3002";
//                               grade =                 {
//                                   "grade_p" = 5;
//                                   "grade_pc" = 5;
//                                   "grade_s" = 4;
//                               };
//                               id = 32;
//                               shopid = 308;
//                               time = 1396429795;
//                               uid = 12;
//                           }
//                           );
//        count = 1;
//        totalPages = 1;
//    };
//}

extern NSString *const __id;
extern NSString *const __apiFetchComments;


@interface LINShowCommentTableViewController ()
@property (weak, nonatomic) MKNetworkEngine *engine;

@property (strong, nonatomic) NSMutableArray *comments;
@end

@implementation LINShowCommentTableViewController

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
    [self fetchComments];
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

- (NSMutableArray *)comments{
    if (!_comments) {
        _comments = [NSMutableArray new];
    }
    return _comments;
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return [self.comments count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    UILabel *grade_p = (UILabel *)[cell.contentView viewWithTag:3];
    UILabel *grade_pc = (UILabel *)[cell.contentView viewWithTag:4];
    UILabel *grade_s = (UILabel *)[cell.contentView viewWithTag:5];
    UILabel *time = (UILabel *)[cell.contentView viewWithTag:2];
    
    UILabel *commentLabel = (UILabel *)[cell.contentView viewWithTag:6];
    
    NSNumber *p = self.comments[indexPath.row][@"grade"][@"grade_p"];
    NSNumber *pc = self.comments[indexPath.row][@"grade"][@"grade_pc"];
    NSNumber *s = self.comments[indexPath.row][@"grade"][@"grade_s"];
    
    grade_p.text = [NSString stringWithFormat:@"服务态度:%@", p];
    grade_pc.text = [NSString stringWithFormat:@"产品质量:%@", pc];
    grade_s.text = [NSString stringWithFormat:@"性价比:%@", s];
    commentLabel.text = self.comments[indexPath.row][@"comment"];
    
    NSNumber *timeNumber = self.comments[indexPath.row][@"time"];
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[timeNumber intValue]];
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm";
    time.text = [dateFormatter stringFromDate:date];
//    CGSize constraint = CGSizeMake(302, 20000);
//    CGSize size = [commentLabel.text boundingRectWithSize:constraint options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14]} context:nil].size;
//    commentLabel.frame = CGRectMake(10, 62, 302, size.height);
//    NSLog(@"%lf", size.height);
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *comment = self.comments[indexPath.row][@"comment"];
    
    CGSize constraint = CGSizeMake(302, 20000);
    CGSize size = [comment boundingRectWithSize:constraint options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14]} context:nil].size;
    return MAX(86, size.height + 65);
}
#pragma mark - Server

- (void)fetchComments{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    MKNetworkOperation *op = [self.engine operationWithPath:__apiFetchComments params:@{
                                                                                        @"shopid":self.aShop[__id],
                                                                                        @"length":@"99",
                                                                                        @"page":@"1"} httpMethod:@"POST"];
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        [hud hide:YES];
        NSDictionary *dic = [completedOperation responseJSON];
        self.comments = dic[@"success"][@"comment"];
        [self.tableView reloadData];
  
        
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        [hud hide:YES];
        [MBProgressHUD showNetworkErrorToView:self.navigationController.view];
    }];
    
    [self.engine enqueueOperation:op];
    
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
