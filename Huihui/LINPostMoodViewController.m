//
//  LINPostMoodViewController.m
//  Huihui
//
//  Created by Lin on 14-5-14.
//  Copyright (c) 2014年 Lin. All rights reserved.
//

#import "LINPostMoodViewController.h"
#import "LINTextureBoardView.h"
#import "MKNetworkKit.h"
#import "UIColor+MLPFlatColors.h"
#import "LINMoodWallViewController.h"
#import "LINMood.h"
#import "LINRootVC.h"
#import "MBProgressHUD.h"
NSString *const __apiNewMood = @"index.php/Mood/newmood";

@interface LINPostMoodViewController ()<LINTextureBoardViewDelegate, UINavigationBarDelegate, UITextViewDelegate>
@property (weak, nonatomic) MKNetworkEngine *engine;

@property (strong, nonatomic) IBOutlet UIView *toolBar;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *postMoodButton;
@property (strong, nonatomic) IBOutlet UIView *bottomView;
@property (strong, nonatomic) IBOutlet UIView *containerView;
@property (strong, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) IBOutlet UILabel *textViewPlaceHolder;
@property (strong, nonatomic) LINTextureBoardView *textureBoardView;
@property (nonatomic) BOOL keyboardIsShown;
@property (nonatomic) BOOL needShowTextureBoard;
@property (nonatomic) BOOL textureBoardIsShown;
@property (nonatomic) CGFloat keyboardHeight;
@end

@implementation LINPostMoodViewController

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
    [self.textView addObserver:self forKeyPath:@"contentSize" options:(NSKeyValueObservingOptionNew) context:NULL];
    [self.textView addObserver:self forKeyPath:@"backgroundColor" options:(NSKeyValueObservingOptionNew) context:NULL];
    
    self.textureBoardView = [[LINTextureBoardView alloc] init];
    self.textureBoardView.delegate = self;
    CGRect frame = self.textureBoardView.frame;
    frame.origin.y += self.bottomView.frame.size.height;
    self.textureBoardView.frame = frame;
    [self.bottomView addSubview:self.textureBoardView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardFrameWillChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc{
    [self.textView removeObserver:self forKeyPath:@"contentSize"];
    [self.textView removeObserver:self forKeyPath:@"backgroundColor"];
}

- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar{
    return UIBarPositionTopAttached;
}

#pragma mark - Getter
- (MKNetworkEngine *)engine{
    if (!_engine) {
        id delegate = [[UIApplication sharedApplication] delegate];
        _engine = [delegate engine];
    }
    return _engine;
}
#pragma mark - KVO and Notification

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"contentSize"]) {
        UITextView *txtview = object;
        CGFloat topoffset = ([txtview bounds].size.height - [txtview contentSize].height * [txtview zoomScale])/2.0;
        topoffset = ( topoffset < 0.0 ? 0.0 : topoffset );
        txtview.contentOffset = (CGPoint){.x = 0, .y = -topoffset};
    }else if ([keyPath isEqualToString:@"backgroundColor"]){
        UITextView *textView = object;
        CGFloat saturation;
        [textView.backgroundColor getHue:NULL saturation:&saturation brightness:NULL alpha:NULL];
        if (saturation >= 0.5) {
            textView.textColor = [UIColor whiteColor];
            self.textViewPlaceHolder.textColor = [UIColor whiteColor];
        }else{
            textView.textColor = [UIColor blackColor];
            self.textViewPlaceHolder.textColor = [UIColor blackColor];
        }
    }
    
}

- (void)keyboardFrameWillChange:(NSNotification *)notification{
    NSDictionary *userInfo = [notification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    CGRect keyboardRect = [aValue CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    if (keyboardRect.size.height > self.keyboardHeight) {
        [UIView animateWithDuration:animationDuration animations:^{
            CGRect frame = self.toolBar.frame;
            if (self.keyboardIsShown) {
                frame.origin.y = frame.origin.y - (keyboardRect.size.height - self.keyboardHeight);
            }else{
                frame.origin.y = frame.origin.y - (keyboardRect.size.height - self.keyboardHeight) + self.bottomView.frame.size.height;
            }
            self.toolBar.frame = frame;
            
            if (self.textureBoardIsShown) {
                frame = self.textureBoardView.frame;
                frame.origin.y += self.textureBoardView.frame.size.height;
              //  NSLog(@"%@", NSStringFromCGRect(frame));
                self.textureBoardView.frame = frame;
            }
                        NSLog(@"%@", NSStringFromCGRect(self.textureBoardView.frame));
        }];
    }else{
        [UIView animateWithDuration:animationDuration animations:^{
            CGRect frame = self.toolBar.frame;
            frame.origin.y = frame.origin.y + (self.keyboardHeight - keyboardRect.size.height);
            self.toolBar.frame = frame;
                        NSLog(@"%@", NSStringFromCGRect(self.textureBoardView.frame));
        }];
        
    }
    
    self.keyboardIsShown = true;
    self.keyboardHeight = keyboardRect.size.height;
}

- (void)keyboardWillHide:(NSNotification *)notification{
    NSDictionary *userInfo = [notification userInfo];
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    
    
    [UIView animateWithDuration:animationDuration animations:^{
        CGRect frame = self.toolBar.frame;
        frame.origin.y = frame.origin.y + self.keyboardHeight - self.bottomView.frame.size.height;
        self.toolBar.frame = frame;
        
        [self.scrollView layoutIfNeeded];
        
        if (self.needShowTextureBoard) {
            self.needShowTextureBoard = false;
            self.textureBoardIsShown = YES;
            frame = self.textureBoardView.frame;
            frame.origin.y -= self.textureBoardView.frame.size.height;
            NSLog(@"%@", NSStringFromCGRect(frame));
            self.textureBoardView.frame = frame;
            frame = self.toolBar.frame;
            frame.origin.y += (self.bottomView.frame.size.height - self.textureBoardView.frame.size.height);
                        NSLog(@"%@", NSStringFromCGRect(self.textureBoardView.frame));
            self.toolBar.frame = frame;
        }
    }];
    self.keyboardHeight = 0;
    self.keyboardIsShown = false;
}

- (void)keyboardDidHide:(NSNotification *)notification{
    
}

- (void)keyboardWillShow:(NSNotification *)notification{
    self.textureBoardIsShown = NO;
}

#pragma mark - 
- (void)textViewDidChange:(UITextView *)textView{
    if ([[[textView.text stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@"　" withString:@""] isEqualToString:@""]) {
        [self.postMoodButton setEnabled:NO];
        [self.textViewPlaceHolder setHidden:NO];
    }else{
        [self.postMoodButton setEnabled:YES];
        [self.textViewPlaceHolder setHidden:YES];
    }
    if ([textView.text length] > 70) {
        textView.text = [textView.text substringToIndex:5];
    }
    
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    NSString *st = [textView.text stringByReplacingCharactersInRange:range withString:text];
    return [st length] <= 70;
}

- (void)textureBoardView:(LINTextureBoardView *)textureBoardView didClickedButtonWithColor:(UIColor *)color{
    self.textView.backgroundColor = color;
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


- (IBAction)dismissVC:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)showTextureBoard:(id)sender {
    if (self.keyboardIsShown) {
        self.needShowTextureBoard = true;
        [self.textView resignFirstResponder];
    }else{
       // self.needShowTextureBoard = true;
        if (self.textureBoardIsShown) {
            [UIView animateWithDuration:0.25f animations:^{
                self.textureBoardIsShown = NO;
                CGRect frame;
                frame = self.textureBoardView.frame;
                frame.origin.y += self.textureBoardView.frame.size.height;
                //NSLog(@"%@", NSStringFromCGRect(frame));
                self.textureBoardView.frame = frame;
                
            }];
        }else{
            [UIView animateWithDuration:0.25f animations:^{
                    self.textureBoardIsShown = YES;
                CGRect frame;
                    frame = self.textureBoardView.frame;
                    frame.origin.y -= self.textureBoardView.frame.size.height;
                    //NSLog(@"%@", NSStringFromCGRect(frame));
                    self.textureBoardView.frame = frame;

            }];

        }
        //[self.textView becomeFirstResponder];
    }
}
- (IBAction)postMood:(id)sender {
    
    NSString *bgCode = [NSString stringWithFormat:@"%li", (long)([UIColor intergerFromUIColor:self.textView.backgroundColor] - 10000)];
   // NSLog(@"%@", bgCode);
    MKNetworkOperation *op = [self.engine operationWithPath:__apiNewMood params:@{@"content":[self.textView.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                                                                                  @"bg":bgCode} httpMethod:@"POST"];
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
#warning TODO :ERROR HANDLEING
        NSDictionary *dic = [completedOperation responseJSON];
        NSLog(@"%@", dic);
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        [MBProgressHUD showNetworkErrorToView:self.view];
    }];
    
    [self.engine enqueueOperation:op];
    
    LINRootVC *rootVC = (LINRootVC *)self.presentingViewController;
    LINMoodWallViewController *moodWallVC = (LINMoodWallViewController *)[rootVC.viewControllers[1] topViewController];
    moodWallVC.pageCount = 1;
    [moodWallVC fetchMoodWithPage:1];
    [self dismissViewControllerAnimated:YES completion:^{
      //  LINMoodWallViewController *moodWallVC = (LINMoodWallViewController *)self.presentingViewController;
//        LINMood *newMood                      = [LINMood new];
//        newMood.content                       = self.textView.text;
//        newMood.date                          = [NSDate date];
//        newMood.bgColor                       = self.textView.backgroundColor;
//        newMood.isthumbup                     = @"no";
//        newMood.numofcomment                  = @(0);
//        newMood.numofthumbup                  = @(0);
//        [moodWallVC.moodArray insertObject:newMood atIndex:0];
//        
//        [moodWallVC.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    }];
}





@end






































