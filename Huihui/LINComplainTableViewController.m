//
//  LINComplainTableViewController.m
//  Huihui
//
//  Created by Lin on 4/16/14.
//  Copyright (c) 2014 Lin. All rights reserved.
//

NSString *const __apiFComplaint = @"index.php/More/complaint";

#import "LINComplainTableViewController.h"
#import "MKNetworkKit.h"
#import "MBProgressHUD.h"
#import "LINRootVC.h"

extern NSString *const __id;


@interface LINComplainTableViewController ()<UIScrollViewDelegate, UIActionSheetDelegate>
@property (weak ,nonatomic) MKNetworkEngine *engine;
@property (strong, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) IBOutlet UITextField *textField;

@end

@implementation LINComplainTableViewController

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
    [self.textView becomeFirstResponder];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView selectRowAtIndexPath:nil animated:YES scrollPosition:UITableViewScrollPositionNone];
    if (indexPath.section == 2 && indexPath.row == 0) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"客服热线" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"185-7709-2300", nil];
        [actionSheet showInView:self.view];
    }
}

- (IBAction)push:(id)sender {
    [self pushComplaint];
}

- (void)pushComplaint{
    [self.textField resignFirstResponder];
    [self.textView resignFirstResponder];
    if ([self.textView.text isEqualToString:@""]) {
        [MBProgressHUD showTextHudToView:self.navigationController.view text:@"意见内容不能为空"];
        [self.textView becomeFirstResponder];
        return;
    }
    
    MBProgressHUD *hud1 = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    
    MKNetworkOperation *op = [self.engine operationWithPath:__apiFComplaint params:@{
                                                                                   @"complaint":self.textView.text,
                                                                                   @"shopid":self.aShop[__id],
                                                                                   @"contact":self.textField.text} httpMethod:@"POST"];
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        [hud1 hide:YES];
        NSDictionary *dic = [completedOperation responseJSON];
        NSLog(@"%@",dic);
        if (dic[@"error"]) {
            NSNumber *errorCode = dic[@"error"];
            if ([errorCode intValue] == 0) {
                LINRootVC *rootVC = (LINRootVC *)self.tabBarController;
                [rootVC loginCompletion:^{
                    [self pushComplaint];
                } failed:nil];
                return;
            }
        }
        MBProgressHUD *hud2 = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        hud2.mode = MBProgressHUDModeText;
        hud2.labelText = @"发送成功";
        [hud2 hide:YES afterDelay:1.5f];
        [self.navigationController popViewControllerAnimated:YES];
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        [MBProgressHUD showNetworkErrorToView:self.view];
    }];
    
    [self.engine enqueueOperation:op];
}



- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if ([self.textField isFirstResponder]) {
        [self.textField resignFirstResponder];
    }
    if ([self.textView isFirstResponder]) {
        [self.textView resignFirstResponder];
    }
}


#pragma mark - ActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tel://185-7709-2300"]];
        [actionSheet dismissWithClickedButtonIndex:buttonIndex animated:YES];
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
