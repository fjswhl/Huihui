//
//  LINActivityVC.m
//  Huihui
//
//  Created by Lin on 3/26/14.
//  Copyright (c) 2014 Lin. All rights reserved.
//

#import "LINActivityVC.h"
#import "MKNetworkKit.h"
#import "UIImageView+WebCache.h"
#import "pinyin.h"
//{
//    success =     {
//        activity =         (
//                            {
//                                activitytime = "2014\U5e743\U670825\U65e5(\U5468\U4e8c)\U4e0b\U534814:30";
//                                addr = "\U65b0\U79d1\U6280\U697c609\U4f1a\U8bae\U5ba4";
//                                groupid = 1;
//                                id = 1;
//                                intro = "Ba-ZhongShen received his M.S degree from Xidian University,China and his Oh.D degree from Eindhoven University of Technology...";
//                                organizer = "ISN\U56fd\U5bb6\U91cd\U70b9\U5b9e\U9a8c\U5ba4";
//                                pic = "http://xdhuihui-public.stor.sinaapp.com/upload/img/activity/thumb_";
//                                property = "802.11\U7814\U8ba8\U4f1a\U7cfb\U5217\U62a5\U544a";
//                                title = "\U5343\U4eba\U8ba1\U5212\U6c88\U516b\U4e2d\U6559\U6388\U62a5\U544a\U4f1a";
//                            }
//                            );
//        count = 34;
//        totalPages = 34;
//    };
//}

//success =     {
//    count = 10;
//    group =         (
//                     {
//                         groupname = "\U7231\U7acb\U4fe1\U4ff1\U4e50\U90e8";
//                         id = 1;
//                         intro = "\U7231\U7acb\U4fe1\U4ff1\U4e50\U90e8\U4e00\U53e5\U8bdd\U7b80\U4ecb";
//                         pic = "http://xdhuihui-public.stor.sinaapp.com/upload/img/groups/thumb_5315678bbf5e8.jpg";
//                     },


NSString *const apiFetchActivity = @"index.php/Group/fetchActivity";
NSString *const apiGroupFetchAll = @"index.php/Group/fetchAll";



NSString *const __activitytime = @"activitytime";
NSString *const __addr = @"addr";
NSString *const __groupid = @"groupid";
extern NSString *const __id;
extern NSString *const __intro;
NSString *const __organizer = @"organizer";
extern NSString *const __pic;
NSString *const __property = @"property";
NSString *const __title = @"title";

NSString *const __groupname = @"groupname";



@interface LINActivityVC ()<UISearchDisplayDelegate, UISearchBarDelegate>
@property (weak, nonatomic) MKNetworkEngine *engine;

@property (strong, nonatomic) IBOutlet UISegmentedControl *preferOptions;
@property (strong, nonatomic) NSMutableArray *activities;


@property (strong, nonatomic) NSMutableArray *groups;
@property (strong, nonatomic) NSMutableArray *keys;
@property (strong, nonatomic) NSMutableDictionary *proceessedGroups;

@property (strong, nonatomic) NSArray *filteredActivities;
@property (strong, nonatomic) NSArray *filteredGroups;
@end

@implementation LINActivityVC

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
    [self fetchActivities];
    if([self.tableView respondsToSelector:@selector(setSectionIndexBackgroundColor:)]){
            self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    }
    [self.tableView setContentOffset:CGPointMake(0, 44.0)];
    

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

- (NSMutableArray *)activities{
    if (!_activities) {
        _activities = [NSMutableArray new];
    }
    return _activities;
}

- (NSMutableArray *)groups{
    if (!_groups) {
        _groups = [NSMutableArray new];
    }
    return _groups;
}

- (NSMutableArray *)keys{
    if (!_keys) {
        _keys = [NSMutableArray new];
    }
    return _keys;
}

- (NSMutableDictionary *)proceessedGroups{
    if (!_proceessedGroups) {
        _proceessedGroups = [NSMutableDictionary new];
    }
    return _proceessedGroups;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.preferOptions.selectedSegmentIndex == 0) {
        return 1;
    }else{
        return (tableView == self.searchDisplayController.searchResultsTableView) ? 1 :[self.keys count];
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.preferOptions.selectedSegmentIndex == 0) {
        return (tableView == self.searchDisplayController.searchResultsTableView) ? [self.filteredActivities count]:[self.activities count];
    }else{
        return (tableView == self.searchDisplayController.searchResultsTableView) ? [self.filteredGroups count] : [self.proceessedGroups[self.keys[section]] count];
//        return [self.proceessedGroups[self.keys[section]] count];

    }
    return 0;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    if (self.preferOptions.selectedSegmentIndex == 0 || tableView == self.searchDisplayController.searchResultsTableView) {
        return nil;
    }
    return self.keys;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (self.preferOptions.selectedSegmentIndex == 0 || tableView == self.searchDisplayController.searchResultsTableView) {
        return nil;
    }
    return self.keys[section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.preferOptions.selectedSegmentIndex == 0) {
        UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"activityCell" forIndexPath:indexPath];
        
        UIImageView *imgView = (UIImageView *)[cell.contentView viewWithTag:1];
        imgView.contentMode = UIViewContentModeScaleAspectFit;
        UILabel *titleLabel = (UILabel *)[cell.contentView viewWithTag:2];
        UILabel *introLabel = (UILabel *)[cell.contentView viewWithTag:3];
        UILabel *timeLabel = (UILabel *)[cell.contentView viewWithTag:4];
        UILabel *locationLabel = (UILabel *)[cell.contentView viewWithTag:5];
        UILabel *organizerLabel = (UILabel *)[cell.contentView viewWithTag:6];
        UILabel *propertyLabel = (UILabel *)[cell.contentView viewWithTag:7];
        
        NSDictionary *aActivity = (tableView == self.searchDisplayController.searchResultsTableView) ? self.filteredActivities[indexPath.row] : self.activities[indexPath.row];
        [imgView setImageWithURL:aActivity[__pic]];
        titleLabel.text = aActivity[__title];
        introLabel.text = aActivity[__intro];
        timeLabel.text = aActivity[__activitytime];
        locationLabel.text = aActivity[__addr];
        organizerLabel.text = aActivity[__organizer];
        propertyLabel.text = aActivity[__property];
        return cell;
    }
    else{
        UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"groupCell"];
        
        UIImageView *imgView = (UIImageView *)[cell.contentView viewWithTag:1];
        UILabel *titleLabel = (UILabel *)[cell.contentView viewWithTag:2];
        UILabel *introLabel = (UILabel *)[cell.contentView viewWithTag:3];
        

        NSDictionary *aGroup = (tableView == self.searchDisplayController.searchResultsTableView) ? self.filteredGroups[indexPath.row] : [self.proceessedGroups[self.keys[indexPath.section]] objectAtIndex:indexPath.row];
//        NSDictionary *aGroup = [self.proceessedGroups[self.keys[indexPath.section]] objectAtIndex:indexPath.row];
        
        [imgView setImageWithURL:aGroup[__pic]];
        titleLabel.text = aGroup[__groupname];
        introLabel.text = aGroup[__intro];
        return cell;
    }
    return nil;
}

#pragma mark - TableView delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.preferOptions.selectedSegmentIndex == 0) {
        return 128.0f;
    }else{
        return 64.0f;
    }
    return 0;
}
#pragma mark - Interaction With Server
- (void)fetchActivities{
    MKNetworkOperation *op = [self.engine operationWithPath:apiFetchActivity params:@{@"length":@"99", @"page":@"1"} httpMethod:@"POST"];
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSDictionary *dic = [completedOperation responseJSON];
        NSArray *st = [dic[@"success"] valueForKey:@"activity"];
        [self.activities addObjectsFromArray:st];
        [self.tableView reloadData];
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
#warning wait
    }];
    [self.engine enqueueOperation:op];
}

- (void)fetchGroup{
    MKNetworkOperation *op = [self.engine operationWithPath:apiGroupFetchAll params:@{@"length":@"999", @"page":@"1"} httpMethod:@"POST"];
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSDictionary *dic = [completedOperation responseJSON];
        NSArray *st = [dic[@"success"] valueForKey:@"group"];
        [self.groups addObjectsFromArray:st];
        [self processGroupNames];
//        NSLog(@"%@\n", self.keys);
//        NSLog(@"%@\n", self.proceessedGroups);
        [self.tableView reloadData];
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
#warning wait
    }];
    [self.engine enqueueOperation:op];
}

- (void)processGroupNames{
    if (self.groups != nil) {
        NSMutableString *indexString = [NSMutableString new];
        for (NSDictionary *aGroup in self.groups) {
            NSString *c = [[HTFirstLetter firstLetter:aGroup[__groupname]] uppercaseString];
           // NSLog(@"%@", c);
            if ([indexString rangeOfString:c].location == NSNotFound) {
                [indexString appendString:c];
                [self.keys addObject:c];
                NSMutableArray *oneSection = [NSMutableArray new];
                self.proceessedGroups[c] = oneSection;
                [oneSection addObject:aGroup];
            }else{
                [self.proceessedGroups[c] addObject:aGroup];
            }
        }

        self.keys = [[self.keys sortedArrayUsingSelector:@selector(compare:)] mutableCopy];

    }
}
#pragma mark - Search
- (void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView{
    tableView.sectionHeaderHeight = 0;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{

    NSPredicate *p = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        NSString *s = evaluatedObject;
        return ([s rangeOfString:searchText].location != NSNotFound);
    }];
    
    if (self.preferOptions.selectedSegmentIndex == 0) {
        NSMutableArray *filteredData = [NSMutableArray new];
        for (NSDictionary *aActivity in self.activities) {

            if ([p evaluateWithObject:aActivity[__title]]) {
                [filteredData addObject:aActivity];
            }
        }
        self.filteredActivities = filteredData;
        NSLog(@"%@", filteredData);
    }else if (self.preferOptions.selectedSegmentIndex == 1){
        NSMutableArray *filteredData = [NSMutableArray new];
        for (NSString *key in self.keys) {
            NSArray *groups = self.proceessedGroups[key];
            
            
//            [filteredData addObject: [groups filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
//                NSDictionary *eva = evaluatedObject;
//                if ([eva[__groupname] rangeOfString:searchText].location != NSNotFound) {
//                    return YES;
//                }
//                return NO;
//            }]]];
            for (NSDictionary *aGroup in groups) {
                if ([p evaluateWithObject:aGroup[__groupname]]) {
                    [filteredData addObject:aGroup];
                }
            }
        }

        self.filteredGroups = filteredData;
        NSLog(@"%@", self.filteredGroups);
    }
    
}
#pragma mark - UI button
- (IBAction)optionChanged:(UISegmentedControl *)sender {
    [self.tableView reloadData];
    if (sender.selectedSegmentIndex == 1 && [self.groups count] == 0) {
        [self fetchGroup];
    }
}

@end




















