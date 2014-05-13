//
//  LINMoodWallViewController.m
//  Huihui
//
//  Created by Lin on 4/23/14.
//  Copyright (c) 2014 Lin. All rights reserved.
//

//success =     {
//    count = 52;
//    list =         (
//                    {
//                        bg = "-3549200";
//                        content = "%E5%90%83%E9%A5%AD%E3%80%82%E3%80%82%E3%80%82";
//                        id = 61;
//                        isthumbup = no;
//                        numofcomment = 0;
//                        numofthumbup = 1;
//                        time = 1399888637;
//                    },
//                    {
//                        bg = "-10000";
//                        content = "%E4%BB%8A%E5%A4%A9%E5%90%83%E5%95%A5%E5%AD%90%E5%91%A2%EF%BC%9F";
//                        id = 60;
//                        isthumbup = no;
//                        numofcomment = 0;
//                        numofthumbup = 0;
//                        time = 1399886070;
//                    },
//                    {
//                        bg = "-10000";
//                        content = "%E9%9D%9E%E6%B3%95%E8%AF%8D%E6%B1%87%E9%9D%9E%E6%B3%95%E8%AF%8D%E6%B1%87%E9%9D%9E%E6%B3%95%E8%AF%8D%E6%B1%87%E9%9D%9E%E6%B3%95%E8%AF%8D%E6%B1%87%E9%9D%9E%E6%B3%95%E8%AF%8D%E6%B1%87%E9%9D%9E%E6%B3%95%E8%AF%8D%E6%B1%87%E3%80%82%E3%80%82%E3%80%82%E6%B2%A1%E6%9C%89%E8%A2%AB%E5%B1%8F%E8%94%BD%E8%80%B6%E5%A5%BD%E5%BC%80%E5%BF%83%E3%80%82%E3%80%82%E3%80%82%E7%A8%8D%E7%AD%89%E6%88%91%E5%8E%BB%E5%BC%80%E4%B8%AA%E9%97%A8%EF%BC%8C%E5%9B%9E%E8%81%8A%E3%80%82";
//                        id = 59;
//                        isthumbup = no;
//                        numofcomment = 0;
//                        numofthumbup = 1;
//                        time = 1399877062;
//                    },
//                    {
//                        bg = "-10000";
//                        content = "%E5%90%90%E6%A7%BD%E4%B8%80%E5%8F%A5%E3%80%82%E3%80%82%E3%80%82%E3%80%82%E7%9D%A1%E8%A7%89%E5%8E%BB%E3%80%82%E3%80%82%E3%80%82";
//                        id = 58;
//                        isthumbup = no;
//                        numofcomment = 0;
//                        numofthumbup = 0;
//                        time = 1399822755;
//                    },
//                    {
//                        bg = "-10000";
//                        content = "%E6%89%93%E9%85%B1%E6%B2%B9%E3%80%82%E3%80%82%EF%BC%9F";
//                        id = 57;
//                        isthumbup = no;
//                        numofcomment = 3;
//                        numofthumbup = 1;
//                        time = 1399818334;
//                    }
//                    );
//    totalPages = 11;
//};
//}

#import "LINMoodWallViewController.h"
#import "MKNetworkKit.h"


NSString *const __apiFetchMood = @"index.php/Mood/fetchmood";

@interface LINMoodWallViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) MKNetworkEngine *engine;

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSMutableArray *moodArray;
@end

@implementation LINMoodWallViewController

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
    
    [self fetchMoodWithPage:1];
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

- (NSMutableArray *)moodArray{
    if (!_moodArray) {
        _moodArray = [NSMutableArray new];
    }
    return _moodArray;
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
        }else{
            textView.textColor = [UIColor blackColor];
        }
    }
    
}

#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"secretCell"];
    UITextView *textView = (UITextView *)[cell.contentView viewWithTag:1];
    [textView addObserver:self forKeyPath:@"contentSize" options:(NSKeyValueObservingOptionNew) context:NULL];
    [textView addObserver:self forKeyPath:@"backgroundColor" options:(NSKeyValueObservingOptionNew) context:NULL];
    return cell;
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

#pragma mark - Server

- (void)fetchMoodWithPage:(NSInteger)page{
    MKNetworkOperation *op = [self.engine operationWithPath:__apiFetchMood params:@{@"length":@(5), @"page":@(page)} httpMethod:@"POST"];
    
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSDictionary *dic = [completedOperation responseJSON];
        
        NSArray *st = dic[@"success"][@"list"];
        NSDictionary *d = st[0];
        
        NSString *string = d[@"content"];
        NSLog(@"%@", [string stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]);
        
        NSString *decoded = (__bridge NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault, (__bridge CFStringRef)@"%E6%AF", CFSTR(""), kCFStringEncodingUTF8);
        
        NSLog(@"%@", decoded);
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
#warning wait
    }];
    [self.engine enqueueOperation:op];
    
}

@end






































