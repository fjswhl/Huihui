//
//  LINPickerSchoolViewController.m
//  Huihui
//
//  Created by Lin on 4/13/14.
//  Copyright (c) 2014 Lin. All rights reserved.
//

#import "LINPickerSchoolViewController.h"
#import "UIColor+LINColor.h"
@interface LINPickerSchoolViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableview1;
@property (strong, nonatomic) IBOutlet UITableView *tableview2;

@property (strong, nonatomic) NSArray *tb1Data;
@property (strong, nonatomic) NSArray *tb2Data;

@property (strong, nonatomic) UIView *ctv;
@end

@implementation LINPickerSchoolViewController

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
    [self.tableview1 selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
    NSNumber *schoolid = [[NSUserDefaults standardUserDefaults] valueForKey:@"schoolid"];
    NSInteger s = [schoolid integerValue] - 1;
    [self.tableview2 selectRowAtIndexPath:[NSIndexPath indexPathForRow:s inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
    UITableViewCell *cell = [self.tableview2 cellForRowAtIndexPath:[NSIndexPath indexPathForRow:s inSection:0]];
    cell.textLabel.textColor = [UIColor preferredColor];
    
//    UIView *shadow = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
//    shadow.backgroundColor = [UIColor clearColor];
//    
    //UIImageView *imgView = [[UIImageView alloc] initWithImage:self.backImage];
    
    //[self.view insertSubview:imgView atIndex:0];
//    [self.view insertSubview:shadow atIndex:0];
    
    
    UIView *bgv = [[UIView alloc] initWithFrame:self.view.frame];
    bgv.backgroundColor = [UIColor clearColor];
    
    [self.view insertSubview:bgv atIndex:0];
    
    // 给背景添加一个手势
    [self.view setBackgroundColor:[UIColor clearColor]];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBackground)];
    [bgv addGestureRecognizer:tapGesture];
    
    

    self.ctv.transform = CGAffineTransformMakeTranslation(0, -500);
}

//- (void)viewWillAppear:(BOOL)animated{
//    [super viewWillAppear:animated];
//    self.ctv.transform = CGAffineTransformMakeTranslation(0, -500);
//}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //UIView *ctv = [self.view viewWithTag:999];
   // ctv.transform = CGAffineTransformMakeTranslation(0, -500);
    [UIView animateWithDuration:0.5 animations:^{
        self.ctv.transform = CGAffineTransformIdentity;
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - getter

- (UIView *)ctv{
    if (!_ctv) {
        _ctv = [self.view viewWithTag:999];
    }
    return _ctv;
}
- (NSArray *)tb1Data{
    if (!_tb1Data) {
        _tb1Data = @[@"陕西省"];
    }
    return _tb1Data;
}

- (NSArray *)tb2Data{
    if (!_tb2Data) {
        _tb2Data = @[@"西电新校区", @"西电老校区"];
    }
    return _tb2Data;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if ([tableView isEqual:self.tableview1]) {
        return [self.tb1Data count];
    }else if ([tableView isEqual:self.tableview2]){
        return [self.tb2Data count];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if ([tableView isEqual:self.tableview1]) {
        cell.textLabel.text = self.tb1Data[indexPath.row];
        cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
        cell.selectedBackgroundView.backgroundColor = [UIColor whiteColor];
    }else if ([tableView isEqual:self.tableview2]){
        cell.textLabel.text = self.tb2Data[indexPath.row];
        
    }
    
    return cell;
}

- (void)tapBackground{
 //   [self dismissViewControllerAnimated:NO completion:nil];
//    [UIView animateWithDuration:0.5 animations:^{
//        self.ctv.transform = CGAffineTransformMakeTranslation(0, -500);
//    } completion:^(BOOL finished) {
//        [self removeFromParentViewController];
//        [self.view removeFromSuperview];
//    }];
    
    [self dismissCompletion:nil];
}

- (void)dismissCompletion:(void (^)(void))block{
    [UIView animateWithDuration:0.5 animations:^{
        self.ctv.transform = CGAffineTransformMakeTranslation(0, -500);
    } completion:^(BOOL finished) {
        [self removeFromParentViewController];
        [self.view removeFromSuperview];
        if (block) {
            block();
        }
    }];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([tableView isEqual:self.tableview2]) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.textLabel.textColor = [UIColor preferredColor];
        
        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInteger:(indexPath.row + 1)] forKey:@"schoolid"];
//        [self dismissViewControllerAnimated:NO completion:^{
//            [self.delegate userDidChangeSchoolid:indexPath.row];
//        }];
        [self dismissCompletion:^{
            [self.delegate userDidChangeSchoolid:indexPath.row];
        }];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([tableView isEqual:self.tableview2]) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.textLabel.textColor = [UIColor blackColor];
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
