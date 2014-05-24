//
//  LINCommentVC.m
//  Huihui
//
//  Created by Lin on 4/9/14.
//  Copyright (c) 2014 Lin. All rights reserved.
//

#import "LINCommentVC.h"
#import "UIColor+LINColor.h"
#import "RatingView.h"
#import "MKNetworkKit.h"
#import "MBProgressHUD.h"
#import "LINRootVC.h"
#import "XXNavigationController.h"
extern NSString *const __discount;
extern NSString *const __grade_p;
extern NSString *const __grade_pc;
extern NSString *const __grade_s;
extern NSString *const __id;
extern NSString *const __inoutschool;
extern NSString *const __intro;
extern NSString *const __location;
extern NSString *const __master;
extern NSString *const __phone;
extern NSString *const __pic;
extern NSString *const __shopname;
extern NSString *const __type;
NSString *const __apiEvaluate = @"index.php/Shop/evaluate";

@interface LINCommentVC ()
@property (weak, nonatomic) MKNetworkEngine *engine;
@property (strong, nonatomic) IBOutlet RatingView *grade_p;
@property (strong, nonatomic) IBOutlet RatingView *grade_pc;
@property (strong, nonatomic) IBOutlet RatingView *grade_s;
@property (strong, nonatomic) IBOutlet UITextView *commentText;

@end

@implementation LINCommentVC

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
    [self.grade_p setImagesDeselected:@"0.png" partlySelected:@"1.png" fullSelected:@"2.png" andDelegate:nil];
    [self.grade_pc setImagesDeselected:@"0.png" partlySelected:@"1.png" fullSelected:@"2.png" andDelegate:nil];
    [self.grade_s setImagesDeselected:@"0.png" partlySelected:@"1.png" fullSelected:@"2.png" andDelegate:nil];
    [self.grade_p displayRating:4.0];
    [self.grade_pc displayRating:4.0];
    [self.grade_s displayRating:4.0];
    
    self.commentText.layer.borderWidth = 1;
    self.commentText.layer.borderColor = [UIColor preferredColor].CGColor;
    [self.commentText becomeFirstResponder];
    
    XXNavigationController *nav = (XXNavigationController *)self.navigationController;
    [nav.panGestureRecognizer setEnabled:NO];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    XXNavigationController *nav = (XXNavigationController *)self.navigationController;
    [nav.panGestureRecognizer setEnabled:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Getter

- (MKNetworkEngine *)engine{
    if (!_engine) {
        id delegate = [UIApplication sharedApplication].delegate;
        _engine = [delegate engine];
    }
    return _engine;
    
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
- (IBAction)postComment:(UIBarButtonItem *)sender {
    if ([self.commentText.text isEqualToString: @""]) {
        MBProgressHUD *huderror = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        huderror.labelText = @"评论内容不能为空";
        huderror.mode = MBProgressHUDModeText;
        [huderror hide:YES afterDelay:1.5f];
        return;
    }
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    hud.labelText = @"发送中...";
    MKNetworkOperation *op = [self.engine operationWithPath:__apiEvaluate params:@{@"shopid":self.aShop[__id],
                                                                                   @"comment":self.commentText.text,
                                                                                   @"grade_s":@([self.grade_s rating]),
                                                                                   @"grade_p":@([self.grade_p rating]),
                                                                                   @"grade_pc":@([self.grade_pc rating])
                                                                                   } httpMethod:@"POST"];
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSDictionary *dic = [completedOperation responseJSON];
        [hud hide:YES];
        if (dic[@"error"]) {
            NSNumber *errorCode = dic[@"error"];
            if ([errorCode intValue] == 0) {
                LINRootVC *rootVC = (LINRootVC *)self.tabBarController;
                [rootVC loginCompletion:^{
                    [self postComment:nil];
                } failed:nil];
                return;
            }else if ([errorCode intValue] == 3){
                MBProgressHUD *huderror = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
                huderror.labelText = @"您已经评论过该商家了.";
                huderror.mode = MBProgressHUDModeText;
                [huderror hide:YES afterDelay:1.5f];
                [self.navigationController popViewControllerAnimated:YES];
                return;
            }
        }
        MBProgressHUD *huderror = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        huderror.labelText = @"评论成功";
        huderror.mode = MBProgressHUDModeText;
        [huderror hide:YES afterDelay:1.5f];
        [self.navigationController popViewControllerAnimated:YES];
        NSLog(@"%@", dic);
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        [hud hide:YES];
        [MBProgressHUD showNetworkErrorToView:self.navigationController.view];
    }];
    [self.engine enqueueOperation:op];
}
- (IBAction)pop:(id)sender {
        [self.navigationController popViewControllerAnimated:YES];
}

@end
