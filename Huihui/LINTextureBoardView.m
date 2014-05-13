//
//  LINTextureBoardView.m
//  test
//
//  Created by Lin on 14-5-12.
//  Copyright (c) 2014年 WeAround. All rights reserved.
//

#import "LINTextureBoardView.h"
#import "UIColor+MLPFlatColors.h"
#import "UIButton+Color.h"

@interface LINTextureBoardView ()<UIScrollViewDelegate>

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIPageControl *pageControl;

@property (strong, nonatomic) NSArray *colorArray;


@end

@implementation LINTextureBoardView



- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

#pragma mark - Getter

- (NSArray *)colorArray{
    if (!_colorArray) {
        _colorArray = @[[UIColor flatRedColor], [UIColor flatBlueColor], [UIColor flatTealColor], [UIColor flatGrayColor]
                        ,[UIColor flatBlackColor], [UIColor flatGreenColor], [UIColor flatWhiteColor], [UIColor flatOrangeColor]];
    }
    return _colorArray;
}


- (id)init{
    self = [super initWithFrame:CGRectMake(0, 0, 320, 105)];
    if (self) {
       // self.backgroundColor = [UIColor colorWithRed:236.0/255.0 green:236.0/255.0 blue:236.0/255.0 alpha:1];
        
        
        _scrollView = [[UIScrollView alloc] initWithFrame:self.frame];
        [_scrollView setPagingEnabled:YES];
        _scrollView.contentSize = self.frame.size;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.delegate = self;
        
        for (int i = 0; i < [self.colorArray count]; i++) {
            UIButton *textureButton = [UIButton buttonWithType:UIButtonTypeCustom];
            textureButton.tag = i;
            
            [textureButton addTarget:self
                              action:@selector(textureButtonTapped:)
                    forControlEvents:UIControlEventTouchUpInside];
            
            CGFloat x = (i % 8 % 4) * 75 + 23;
            CGFloat y = (i % 8) / 4 * 45 + 15;
            textureButton.frame = CGRectMake(x, y, 50, 30);
            
            [textureButton setBackgroundImageWithColor:self.colorArray[i] forState:UIControlStateNormal];
            [textureButton setBackgroundImageWithColor:self.colorArray[i] forState:UIControlStateHighlighted];
            [textureButton setBackgroundImageWithColor:self.colorArray[i] forState:UIControlStateSelected];
            
            [_scrollView addSubview:textureButton];
        }
        
        
//        self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(110, 90, 100, 20)];
//        self.pageControl.numberOfPages = 1;
//        self.pageControl.currentPage = 0;
//        self.pageControl.currentPageIndicatorTintColor = [UIColor grayColor];
//        self.pageControl.pageIndicatorTintColor = [UIColor grayColor];
//        [self addSubview:self.pageControl];
        [self addSubview:_scrollView];
    }
    return self;
}
//停止滚动的时候
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    [self.pageControl setCurrentPage:self.scrollView.contentOffset.x / 320];
    [self.pageControl updateCurrentPageDisplay];
}


- (void)textureButtonTapped:(id)sender{
    UIButton *button = sender;
    
    UIColor *color = self.colorArray[button.tag];
    NSLog(@"%li", (long)button.tag);
    
    [self.delegate textureBoardView:self didClickedButtonWithColor:color];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
