//
//  LINMoodWallViewController.h
//  Huihui
//
//  Created by Lin on 4/23/14.
//  Copyright (c) 2014 Lin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LINMoodWallViewController : UIViewController
@property (nonatomic) NSInteger pageCount;
@property (strong, nonatomic) NSMutableArray *moodArray;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

- (void)fetchMoodWithPage:(NSInteger)page;
@end
