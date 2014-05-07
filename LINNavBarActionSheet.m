//
//  LINNavBarActionSheet.m
//  LINNavBarActionSheet
//
//  Created by Lin on 14-5-6.
//  Copyright (c) 2014年 Lin. All rights reserved.
//

#import "LINNavBarActionSheet.h"

@interface LINNavBarActionSheet ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIView *bg2;
@property (nonatomic) BOOL actionSheetIsShown;
@end

@implementation LINNavBarActionSheet


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    
    return self;
}

- (instancetype)initWithDelegate:(id<LINNavBarActionSheetDelegate>)delegate
                    buttonTitles:(NSArray *)buttonTitles{
    self = [super initWithFrame:[[UIScreen mainScreen] bounds]];
    if (self) {
        _delegate = delegate;
        _buttonTitles = buttonTitles;
        
        self.backgroundView = [[UIView alloc] initWithFrame:self.frame];
        [self.backgroundView setUserInteractionEnabled:YES];
        [self addSubview:self.backgroundView];
        self.backgroundView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
        self.bg2 = [[UIView alloc] initWithFrame:CGRectMake(0, 64, 320, 504)];
        self.bg2.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
        [self.backgroundView addSubview:self.bg2];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tappedBackground:)];
        [self.backgroundView addGestureRecognizer:tapGesture];
        
        [self setup];
    }
    return self;
}


- (void)setup{

    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, 320, 0) style:UITableViewStylePlain];
        [self addSubview:self.tableView];
    self.tableView.separatorInset = UIEdgeInsetsZero;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setScrollEnabled:NO];
    [self addSubview:self.tableView];
}



- (void)showInViewController:(UIViewController *)viewController{
    
    [viewController.view addSubview:self];
    CGRect frame = self.tableView.frame;
    frame.size.height = 44.0f * [self.buttonTitles count];
    [UIView animateWithDuration:0.4f animations:^{
        self.tableView.frame = frame;
    }];
    
}

- (void)tappedBackground:(UITapGestureRecognizer *)sender{
    [self dismissAnimated:YES];
}

- (void)dismissAnimated:(BOOL)animated{
    self.isShown = false;
    CGRect frame = self.tableView.frame;
    frame.size.height = 0;
    if (animated) {
        [UIView animateWithDuration:0.4f animations:^{
            self.tableView.frame = frame;
            self.bg2.alpha = 0;
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
    }else{
        [self removeFromSuperview];
    }
    

}

- (void)dismissAnimated:(BOOL)animated completion:(void (^)(void))block{
    self.isShown = false;
    CGRect frame = self.tableView.frame;
    frame.size.height = 0;
    
    if (animated) {
        [UIView animateWithDuration:0.4f animations:^{
            self.tableView.frame = frame;
            self.bg2.alpha = 0;
        } completion:^(BOOL finished) {
            block();
            [self removeFromSuperview];
        }];
    }else{
        block();
        [self removeFromSuperview];
    }

}
#pragma mark - TableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.buttonTitles count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.contentView.backgroundColor = [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1.0];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = self.buttonTitles[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //[self dismissAnimated:YES];
    [self.delegate navBarActionSheet:self clickedButtonAtIndex:indexPath.row];
}


@end
