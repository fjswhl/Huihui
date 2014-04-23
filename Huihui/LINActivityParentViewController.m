//
//  LINActivityParentViewController.m
//  Huihui
//
//  Created by Lin on 4/23/14.
//  Copyright (c) 2014 Lin. All rights reserved.
//

#import "LINActivityParentViewController.h"
#import "LINActivityVC.h"
#import "LINMoodWallViewController.h"
@interface LINActivityParentViewController ()

/**
 *  这个属性决定一个NSUserDefaults: activityTabPreferredView
 */
@property (strong, nonatomic) IBOutlet UISegmentedControl *tab;


@property (strong, nonatomic) LINActivityVC *activityVC;
@property (strong, nonatomic) LINMoodWallViewController *moodWallVC;
@end

@implementation LINActivityParentViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self addChildViewController:self.activityVC];
    [self addChildViewController:self.moodWallVC];
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    if (![ud valueForKey:@"activityTabPreferredView"]) {
        [ud setValue:@(self.tab.selectedSegmentIndex) forKey:@"activityTabPreferredView"];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 *  segmentedControl选择0时, 显示activityVC的View, 并把moodWallVC的view移除
 *  选择1时,显示moodWallVC的view,并把activityVC的view移除
 */
- (IBAction)tabChanged:(UISegmentedControl *)sender {
    /**     先移除所有subview    */
    for (UIView *aView in self.view.subviews) {
        [aView removeFromSuperview];
    }
    
    if (sender.selectedSegmentIndex == 0) {
        [self.view addSubview:self.activityVC.view];
    }else if (sender.selectedSegmentIndex == 1){
        [self.view addSubview:self.moodWallVC.view];
    }
    
}

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
