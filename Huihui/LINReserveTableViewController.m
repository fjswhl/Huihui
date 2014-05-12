//
//  LINReserveTableViewController.m
//  Huihui
//
//  Created by Lin on 14-5-7.
//  Copyright (c) 2014年 Lin. All rights reserved.
//

#import "LINReserveTableViewController.h"
#import "MKNetworkKit.h"
#import "LINGood.h"
#import "UIColor+LINColor.h"
#import "LINRootVC.h"
#import "MBProgressHUD.h"
NSString *const __apiFetchByShop = @"index.php/Goods/fetchByShop";
NSString *const __apiReserve = @"index.php/Order/reserve";
@interface LINReserveTableViewController ()<UIAlertViewDelegate>
@property (strong, nonatomic) UIView *containerView;
@property (weak, nonatomic) MKNetworkEngine *engine;

@property (strong, nonatomic) NSArray *foods;

@property (strong, nonatomic) NSMutableDictionary *orderForPost;
@property (strong, nonatomic) UILabel *totalPriceLabel;

@property (strong, nonatomic) NSMutableArray *amountArray;
@end

@implementation LINReserveTableViewController

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
    
    self.aShop[@"reserve"] = [self.aShop[@"reserve"] stringByReplacingOccurrencesOfString:@"\\n" withString:@"\r"];
    
    UIEdgeInsets tableViewIndicatorEdgeInsets = self.tableView.scrollIndicatorInsets;
    tableViewIndicatorEdgeInsets.bottom = -47;
    self.tableView.scrollIndicatorInsets = tableViewIndicatorEdgeInsets;
    
    UIEdgeInsets tableViewContentInsets = self.tableView.contentInset;
    tableViewContentInsets.bottom = -47;
    self.tableView.contentInset = tableViewContentInsets;
    
    
    self.navigationController.toolbarHidden = NO;
    self.navigationController.toolbar.transform = CGAffineTransformMakeTranslation(0, 49);
    UIView *t = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 49)];
    t.backgroundColor = [UIColor whiteColor];
    [self.navigationController.toolbar addSubview:t];
    
    UILabel *label1 = [UILabel new];
    label1.text = @"总计:";
    label1.font = [UIFont systemFontOfSize:16.0f];
    label1.translatesAutoresizingMaskIntoConstraints = NO;
    [t addSubview:label1];
    [t addConstraint:[NSLayoutConstraint constraintWithItem:label1
                                                      attribute:NSLayoutAttributeCenterY
                                                      relatedBy:NSLayoutRelationEqual
                                                         toItem:t
                                                      attribute:NSLayoutAttributeCenterY
                                                 multiplier:1.0f constant:0.0f]];
    [t addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[label1(>=41)]"
                                                            options:0
                                                            metrics:nil
                                                               views:NSDictionaryOfVariableBindings(label1)]];
    
    UIButton *button = [UIButton new];
    [button setTitle:@"提交" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(postOrder:) forControlEvents:UIControlEventTouchUpInside];
    button.backgroundColor = [UIColor preferredColor];
    button.translatesAutoresizingMaskIntoConstraints = NO;
    [t addSubview:button];
    [t addConstraint:[NSLayoutConstraint constraintWithItem:button
                                                 attribute:NSLayoutAttributeCenterY
                                                 relatedBy:NSLayoutRelationEqual
                                                    toItem:t
                                                 attribute:NSLayoutAttributeCenterY
                                                multiplier:1.0f
                                                   constant:0.0f]];
    [t addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[button(==90)]-(8)-|"
                                                             options:0
                                                             metrics:nil
                                                                views:NSDictionaryOfVariableBindings(button)]];
    [t addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[button(==40)]"
                                                              options:0
                                                              metrics:nil
                                                                views:NSDictionaryOfVariableBindings(button)]];
    
    self.totalPriceLabel = [UILabel new];
    _totalPriceLabel.text = @"0";
    _totalPriceLabel.textColor = [UIColor colorWithRed:252/255.0 green:13/255.0 blue:153/255.0 alpha:1.0f];
    _totalPriceLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [t addSubview:_totalPriceLabel];
    [t addConstraint:[NSLayoutConstraint constraintWithItem:_totalPriceLabel
                                                  attribute:NSLayoutAttributeCenterY
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:t
                                                  attribute:NSLayoutAttributeCenterY
                                                 multiplier:1.0f
                                                   constant:0.0f]];
    [t addConstraint:[NSLayoutConstraint constraintWithItem:_totalPriceLabel
                                                  attribute:NSLayoutAttributeCenterX
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:t
                                                  attribute:NSLayoutAttributeCenterX
                                                 multiplier:1.0f
                                                   constant:0.0f]];
    
    
    

    [self fetchGoods];
    NSLog(@"%@", self.aShop);
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    self.navigationController.toolbarHidden = YES;
}

#pragma mark - Getter

- (MKNetworkEngine *)engine{
    if (!_engine) {
        id delegate = [UIApplication sharedApplication].delegate;
        _engine = [delegate engine];
    }
    return _engine;
    
}

- (NSArray *)foods{
    if (!_foods) {
        _foods = [NSArray new];
    }
    return _foods;
}

- (NSMutableDictionary *)orderForPost{
    if (!_orderForPost) {
        _orderForPost = [NSMutableDictionary new];
    }
    return _orderForPost;
}

- (NSMutableArray *)amountArray{
    if (!_amountArray) {
        _amountArray = [NSMutableArray new];
        for (int i = 0; i < [self.foods count]; i++) {
            [_amountArray addObject:@(0)];
        }
    }
    return _amountArray;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Server
- (void)fetchGoods{
    MKNetworkOperation *op = [self.engine operationWithPath:__apiFetchByShop params:@{
                                                                                      @"shopid":self.aShop[@"id"],
                                                                                      @"length":@(999),
                                                                                      @"page":@(1)} httpMethod:@"POST"];
    
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSDictionary *dic = [completedOperation responseJSON];
        self.foods = dic[@"success"][@"goods"];
//        NSLog(@"%@", self.foods);
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        [MBProgressHUD showNetworkErrorToView:self.view];
    }];
    [self.engine enqueueOperation:op];
}

- (void)postOrderToServer{
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"正在提交订单...";
    
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:@{@"shopid":self.aShop[@"id"],
                                                                 @"order":self.orderForPost
                                                                 }
                                                       options:kNilOptions
                                                         error:nil];
    
    
    MKNetworkOperation *op = [self.engine operationWithPath:__apiReserve params:@{@"reserve": [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]} httpMethod:@"POST"];
    
    
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSDictionary *dic = [completedOperation responseJSON];
        [hud hide:YES];
        [MBProgressHUD showTextHudToView:self.view text:@"订单已成功提交!"];
        double delayInSeconds = 1.6;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self.navigationController popViewControllerAnimated:YES];
        });
        NSLog(@"%@", dic);
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        [hud hide:YES];
        [MBProgressHUD showNetworkErrorToView:self.view];
    }];
    
    [self.engine enqueueOperation:op];
}
#pragma mark - Table view data source


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat height = [super tableView:tableView heightForRowAtIndexPath:indexPath];
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        NSString *discountDetail = self.aShop[@"reserve"];
        
        CGSize constraint = CGSizeMake(280, 20000);
        CGSize size = [discountDetail boundingRectWithSize:constraint options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:13]} context:nil].size;
        return size.height + 15;
    }
    
    return height;
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 1) {
        return @"美食列表";
    }else if (section == 0){
        return @"送餐说明";
    }
    return nil;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 1;
    }else if (section == 1){
        return  [self.foods count];
    }
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"title"];
        UILabel *timeAcceptedLabel = (UILabel *)[cell.contentView viewWithTag:1];
        timeAcceptedLabel.text = self.aShop[@"reserve"];
        return cell;
    }else if (indexPath.section == 1){
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"food"];
        LINGood *aGood = [[LINGood alloc] initWithDictionary: self.foods[indexPath.row]];
        UILabel *goodNameLabel = (UILabel *)[cell.contentView viewWithTag:1];
        UILabel *priceLabel = (UILabel *)[cell.contentView viewWithTag:2];
        
        goodNameLabel.text = aGood.goodName;
        priceLabel.text = [NSString stringWithFormat:@"￥ %@", aGood.price];
        
        
        /*          如果数量为0,隐藏数量的标签      */
        UILabel *mountLabel = (UILabel *)[cell.contentView viewWithTag:3];
        
        NSNumber *amount = self.amountArray[indexPath.row];
        mountLabel.text = [NSString stringWithFormat:@"%@", amount];
        
        if ([mountLabel.text isEqualToString:@"0"]) {
            mountLabel.alpha = 0;
        }else{
            mountLabel.alpha = 1;
        }
        return cell;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];

    UILabel *mountLabel = (UILabel *)[cell.contentView viewWithTag:3];
    mountLabel.text = [NSString stringWithFormat:@"%i", [mountLabel.text integerValue] + 1];
    
    LINGood *good = [[LINGood alloc] initWithDictionary: self.foods[indexPath.row]];
    [self.orderForPost setValue:mountLabel.text forKey:[NSString stringWithFormat:@"%@", good.goodId]];
    self.amountArray[indexPath.row] = @([mountLabel.text integerValue]);
    
    self.totalPriceLabel.text = [NSString stringWithFormat:@"%li",(long)([_totalPriceLabel.text integerValue] + [good.price integerValue])];
    if (mountLabel.alpha == 0) {
        [UIView animateWithDuration:0.3 animations:^{
            mountLabel.alpha = 1.0f;
        }];
    }
    
}




- (void)postOrder:(id)sender{
    if ([self.totalPriceLabel.text integerValue] == 0) {
        [MBProgressHUD showTextHudToView:self.view text:@"你还没选择任何美食哦"];
        return;
    }
    NSLog(@"%@", self.orderForPost);
    
    LINRootVC *rootVC = (LINRootVC *)self.tabBarController;
    NSDictionary *userInfo = rootVC.userInfo;
    id louhao = userInfo[@"building"];
    id quhao = userInfo[@"buildingarea"];
    id sushehao = userInfo[@"houseid"];
    
    NSString *title = @"亲你还没完善个人资料, 请到个人中心填写宿舍信息";
    if (louhao && quhao && sushehao) {
           title = [NSString stringWithFormat:@"订单总价:%@元\n您的地址:%@%@%@\n", self.totalPriceLabel.text, userInfo[@"building"], userInfo[@"buildingarea"], userInfo[@"houseid"]];
    }

    

    NSLog(@"%@", rootVC.userInfo);
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"确认订单" message:title delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alertView show];
}

#pragma mark - AlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        [self postOrderToServer];
    }
}
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
//{
//    favour = 2;
//    goodname = "\U8001\U4e1c\U5bb6\U6ce1\U998d";
//    id = 12;
//    isfavour = 0;
//    price = 101;
//    shopid = 284;
//    stored = 0;
//},
@end
