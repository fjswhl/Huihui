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
                        ,[UIColor flatBlackColor], [UIColor flatGreenColor], [UIColor flatWhiteColor], [UIColor flatOrangeColor], UIColorFromRGB(0xf1fafa), UIColorFromRGB(0xe8ffe8), UIColorFromRGB(0xe8e8ff), UIColorFromRGB(0x8080c0), UIColorFromRGB(0xe8d098), UIColorFromRGB(0xefefda),UIColorFromRGB(0x336699), UIColorFromRGB(0x6699cc), UIColorFromRGB(0x66cccc), UIColorFromRGB(0xb45b3e), UIColorFromRGB(0x479ac7), UIColorFromRGB(0x00b271), UIColorFromRGB(0xfbfbea), UIColorFromRGB(0xd5f3f4), UIColorFromRGB(0xd7fff0), UIColorFromRGB(0xf0dad2)];
    }
    return _colorArray;
}


- (id)init{
    self = [super initWithFrame:CGRectMake(0, 0, 320, 168)];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        
        _scrollView = [[UIScrollView alloc] initWithFrame:self.frame];
        [_scrollView setPagingEnabled:YES];
        _scrollView.contentSize = CGSizeMake(320 * 2, self.frame.size.height);
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.delegate = self;
        
        for (int i = 0; i < [self.colorArray count]; i++) {
            UIButton *textureButton = [UIButton buttonWithType:UIButtonTypeCustom];
            textureButton.tag = i;
            
            [textureButton addTarget:self
                              action:@selector(textureButtonTapped:)
                    forControlEvents:UIControlEventTouchUpInside];
            
            CGFloat x = (i % 12 % 4) * 75 + 23 + i / 12 * 320;
            CGFloat y = (i % 12) / 4 * 45 + 15;
            textureButton.frame = CGRectMake(x, y, 50, 30);
            
            [textureButton setBackgroundImageWithColor:self.colorArray[i] forState:UIControlStateNormal];
            [textureButton setBackgroundImageWithColor:self.colorArray[i] forState:UIControlStateHighlighted];
            [textureButton setBackgroundImageWithColor:self.colorArray[i] forState:UIControlStateSelected];
            
            [_scrollView addSubview:textureButton];
        }
        
        
        self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(110, 150, 100, 20)];
        self.pageControl.numberOfPages = 2;
        self.pageControl.currentPage = 0;
        self.pageControl.currentPageIndicatorTintColor = [UIColor grayColor];
        self.pageControl.pageIndicatorTintColor = [UIColor groupTableViewBackgroundColor];
        [self addSubview:self.pageControl];
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
