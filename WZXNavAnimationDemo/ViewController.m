//
//  ViewController.m
//  WZXNavAnimationDemo
//
//  Created by wordoor－z on 16/1/12.
//  Copyright © 2016年 wzx. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

/**
 *  状态栏状态
 */
@property(nonatomic,assign) BOOL statusBarHide;

/**
 *  弹出来的view
 */
@property(nonatomic,strong) UIView * popView;

/**
 *  弹出来的子view
 */
@property(nonatomic,strong) UIView * popSubView;

/**
 *  控制弹出的按钮
 */
@property(nonatomic,strong) UIButton * popBtn;

/**
 *  退出的按钮
 */
@property(nonatomic,strong) UIButton * backBtn;

@end

@implementation ViewController

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = YES;
    self.title = @"Pop";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _statusBarHide = NO;
    
    self.view.backgroundColor = [UIColor blackColor];
    
    self.view.userInteractionEnabled = YES;
    
    //创建按钮
    [self createBtn];
}

- (void)createBtn
{
    self.popBtn = ({
        UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, self.view.frame.size.height - 50, self.view.frame.size.width, 50);
        btn.backgroundColor = [UIColor whiteColor];
        [btn setTitle:@"Pop" forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        btn;
    });
    [self.view addSubview:_popBtn];
}

- (void)btnClick:(UIButton *)sender
{
    if (_statusBarHide)
    {
        [self hidePopView];
    }
    else
    {
        [self showPopView];
    }
}

- (void)changeBarStatus
{
    _statusBarHide = !_statusBarHide;
    
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        
        [self prefersStatusBarHidden];
        
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    }
}

- (void)showPopView
{
    //如果_popView不存在 创建
    if (!_popView)
    {
        _popView = ({
            UIView * popView = [[UIView alloc]initWithFrame:CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height)];
            
            popView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.1];
            
            popView.userInteractionEnabled = YES;
            
            popView;
        });
        
        _popSubView = ({
            UIView * popSubView = [[UIView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height)];
            
            [popSubView addGestureRecognizer:[[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(pan:)]];
            
            popSubView.backgroundColor = [UIColor whiteColor];
            
            popSubView;
        });
        [_popView addSubview:_popSubView];
    }
    
    [self.view addSubview:_popView];
    
    //如果不存在backbtn 创建
    if (!_backBtn)
    {
        _backBtn = ({
        
            UIButton * backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            
            backBtn.frame = CGRectMake(10, 10, 13, self.navigationController.navigationBar.frame.size.height - 20);
            
            [backBtn addTarget:self action:@selector(hidePopView) forControlEvents:UIControlEventTouchUpInside];
            
            [backBtn setBackgroundImage:[UIImage imageNamed:@"back(white)"] forState:UIControlStateNormal];
            
            backBtn;
        });
        
    }
        [[UIApplication sharedApplication].windows[0] addSubview:_backBtn];
    
    [self changeBarStatus];
    
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        CGRect rect    = _popSubView.frame;
        rect.origin.y  = self.view.frame.size.height/3.0;
        _popSubView.frame = rect;
        
    } completion:^(BOOL finished) {
        
    }];
}

- (void)hidePopView
{
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        CGRect rect    = _popSubView.frame;
        rect.origin.y  = self.view.frame.size.height;
        _popSubView.frame = rect;
        if (self.navigationController.navigationBarHidden == NO)
        {
            [self.navigationController setNavigationBarHidden:YES animated:YES];
        }
        [_backBtn removeFromSuperview];
        
    } completion:^(BOOL finished) {
        
        [self changeBarStatus];
        [_popView removeFromSuperview];
        
    }];
}

- (void)pan:(UIPanGestureRecognizer *)sender
{
    //手指在self.view上的偏移量
    CGPoint trans = [sender translationInView:sender.view];
    
    CGPoint oldCenter = sender.view.center;
    
    oldCenter.y += trans.y;
    
    //设置view最高点
    if (oldCenter.y <= self.view.center.y + self.navigationController.navigationBar.frame.size.height)
    {
        oldCenter.y = self.view.center.y + self.navigationController.navigationBar.frame.size.height;
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        [_backBtn setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    }
    else
    {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        [_backBtn setBackgroundImage:[UIImage imageNamed:@"back(white)"] forState:UIControlStateNormal];
    }
    
    //设置view最低点 ＋50是为了回弹效果
    if(oldCenter.y  > self.view.center.y + self.view.frame.size.height/3.0 + 50)
    {
        oldCenter.y = self.view.center.y + self.view.frame.size.height/3.0 + 50;
    }
    
    //回弹效果
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        if(oldCenter.y  >= self.view.center.y + self.view.frame.size.height/3.0)
        {
            oldCenter.y = self.view.center.y + self.view.frame.size.height/3.0;
        }
        
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            sender.view.center = oldCenter;
        } completion:^(BOOL finished) {
            
        }];
    }
    else
    {
        sender.view.center = oldCenter;
    }

    
    [sender setTranslation:CGPointZero inView:sender.view];
}

//改变状态栏是否隐藏
- (BOOL)prefersStatusBarHidden
{
    return _statusBarHide;//隐藏为YES，显示为NO
}
//将状态栏字体颜色改为白色
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
