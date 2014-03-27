//
//  LINShowAllVC.m
//  Huihui
//
//  Created by Lin on 3/25/14.
//  Copyright (c) 2014 Lin. All rights reserved.
//

#import "LINShowAllVC.h"
#import "MKNetworkKit.h"


//      校内还是校外

typedef enum{
    LINShowAllVCOptionInschool = 1,
    LINShowAllVCOptionOutschool = 2
}LINShowAllVCOption;

NSString *const apiShopFetchAll = @"index.php/Shop/fetchAll";

@interface LINShowAllVC ()
@property (weak, nonatomic) MKNetworkEngine *engine;
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
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 0;
}

#pragma mark - Interaction With Server
- (void)fetchAllShopWithOptions:(LINShowAllVCOption)option{
}

- (IBAction)preferOptionChanged:(id)sender {
}





@end
