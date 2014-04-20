//
//  LINSettingTableViewController.m
//  Huihui
//
//  Created by Lin on 4/15/14.
//  Copyright (c) 2014 Lin. All rights reserved.
//

#import "LINSettingTableViewController.h"
#import "MBProgressHUD.h"
#import "SDImageCache.h"
#import <MessageUI/MessageUI.h>
@interface LINSettingTableViewController ()<MFMessageComposeViewControllerDelegate>
@property (strong, nonatomic) IBOutlet UISwitch *s;

@end

@implementation LINSettingTableViewController

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
     [self.s setOn: [[NSUserDefaults standardUserDefaults] boolForKey:@"showImgOnlyWhenWifi"]];
    
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
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 2) {
        [[SDImageCache sharedImageCache] clearDisk];
        [[SDImageCache sharedImageCache] clearMemory];
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"缓存清理完毕.";
        hud.labelColor = [UIColor blackColor];
        [hud hide:YES afterDelay:1.5f];
    }else if (indexPath.section == 0 && indexPath.row == 1) {
            if ([MFMessageComposeViewController canSendText]) {
                MFMessageComposeViewController *messageCompose = [[MFMessageComposeViewController alloc] init];
                NSString *message = @"我在使用汇惠,校园内外几乎所有商家在这里都有优惠哦,下载地址:https://itunes.apple.com/us/app/hui-hui-nin-dian-zi-hui-yuan/id863986954?ls=1&mt=8";
                [messageCompose setBody:message];
                messageCompose.messageComposeDelegate = self;
                [self presentViewController:messageCompose animated:YES completion:nil];
            }
        }
}
#pragma mark - message delegate

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)showImgInWifiSwitch:(id)sender {
    UISwitch *s = (UISwitch *)sender;
    
    if (s.on == YES) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"showImgOnlyWhenWifi"];
    }else{
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"showImgOnlyWhenWifi"];
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
