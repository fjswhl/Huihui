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

    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    if (self.) {
//        <#statements#>
//    }
//    return [];
    return 0;
}

#pragma mark - Interaction With Server
- (void)fetchAllShopWithOptions:(LINShowAllVCOption)option{
    NSString *type = self.type;
    NSString *inoutSchool = [NSString stringWithFormat:@"%li", (unsigned long)option];
    MKNetworkOperation *op = [self.engine operationWithPath:__apiShopFetchAll params:@{@"length":@"999",
                                                                                  @"page":@"1",
                                                                                  @"schoolid":@"1",
                                                                                  @"type":type,
                                                                                  @"inoutschool":inoutSchool
                                                                                   } httpMethod:@"POST"];
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSDictionary *dic = [completedOperation responseJSON];
        
        if (option == LINShowAllVCOptionInschool) {
            self.shopsInSchool = dic[@"success"][@"shops"];
        }else if (option == LINShowAllVCOptionOutschool){
            self.shopsOutSchool = dic[@"success"][@"shops"];
        }
        [self.tableView reloadData];
        NSLog(@"%@",dic);
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
#warning wait
    }];
    [self.engine enqueueOperation:op];
}

- (IBAction)preferOptionChanged:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex == 1) {
        [self fetchAllShopWithOptions:sender.selectedSegmentIndex];
    }
}





@end
