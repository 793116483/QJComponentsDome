//
//  PPSlideInOutViewController.m
//  PatPat
//
//  Created by 杰 on 2022/4/20.
//  Copyright © 2022 http://www.patpat.com. All rights reserved.
//

#import "PPSlideInOutViewController.h"
#import "UIViewController+PPOtherMessage.h"
#import "PPSlideOutPanGestureRecognizer.h"
#import "UIViewController+PPPresentTransition.h"
#import "UIView+UIViewExtension.h"
#import <Masonry/Masonry.h>
#import "NSObject+PPObserver.h"

static CGFloat kAnimationUnitDuration = 0.0004;

@interface PPSlideInOutViewController ()

@property (nonatomic , assign) BOOL showNeedAnimation ;
/// 动画时长
@property (nonatomic , assign) NSTimeInterval animateDuration ;

@property (nonatomic , assign) BOOL viewControllerShowed ;

@property (nonatomic , strong) PPSlideOutPanGestureRecognizer * slideOutPan;

@property (nonatomic , strong) UIView * blackBgView;
@property (nonatomic , strong) UIView * contentView;

/// 需要弹出控制器
@property (nonatomic , strong) UIViewController * viewController ;

/// 记录键盘升起前的 contentOffset.y
@property (nonatomic , assign) CGFloat startOffsetY;
@property (nonatomic , assign) BOOL keyboardShowed ;
@property (nonatomic , assign) CGFloat keyboardHeight;

@end

#define kContentViewMaxHeight (kSlideInOutViewControllerMaxHeight + kSlideInOutNavigationBarHeight)

@implementation PPSlideInOutViewController

-(instancetype)initWithViewController:(UIViewController *)viewController {
    if (self = [super init]) {
        self.showNeedAnimation = YES;
        self.hiddenSystemNavigationBarWhenAppear = YES;
        self.viewControllerSize = viewController.slideInOutViewSize;
        self.snapshotView = [[UIApplication sharedApplication].keyWindow snapshotViewAfterScreenUpdates:YES];
        
        self.viewController = viewController;
        viewController.slideInOutFatherViewController = self ;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    NSAssert(self.viewController, @"viewController 不能为空");
    
    [self initUI];
    
    // 设置主scrollView
    [self.slideOutPan setMainScrollViewFromView:self.viewController.view];
    if (self.slideOutPan.mainScrollView) {
        // 头部添加手势,单独添加这个手势是为了不让 slideOutPan.mainScrollView 影响头部手势下拉
        PPSlideOutPanGestureRecognizer * headerSlideOutPan = [PPSlideOutPanGestureRecognizer new];
        headerSlideOutPan.fromVc = self;
        headerSlideOutPan.targetView = self.contentView;
        [self.viewController.slideInOutNavigationBar addGestureRecognizer:headerSlideOutPan];
        // view 添加手势
        [self.viewController.view addGestureRecognizer:self.slideOutPan];
    }else{
        // 添加收起滑动手势
        [self.contentView addGestureRecognizer:self.slideOutPan];
    }
    
    // 监听键盘
    [self addObserverKeyboardShowAndHideNotification];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;

    [self showViewControllerAnimated:self.showNeedAnimation complation:^{}];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}

#pragma mark - 布局UI
-(void)initUI {
    [self.view insertSubview:self.snapshotView atIndex:0];
    [self.view addSubview:self.blackBgView];
    [self.view addSubview:self.contentView];
    [self.contentView addSubview:self.viewController.view];
    [self.contentView addSubview:self.viewController.slideInOutNavigationBar];

    // 布局
    self.blackBgView.frame = self.view.bounds;
    self.blackBgView.alpha = 0;
        
    CGFloat height = self.viewController.slideInOutNavigationBar.height + self.viewController.slideInOutViewSize.height;
    [self changeContentViewFrameWithHeight:height];
    self.contentView.y = self.view.height;

    [self.viewController.slideInOutNavigationBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.equalTo(self.contentView);
        make.height.mas_equalTo(self.viewController.slideInOutNavigationBar.height);
    }];
    [self.viewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.viewController.slideInOutNavigationBar.mas_bottom);
        make.leading.trailing.equalTo(self.contentView);
        make.height.mas_equalTo(self.viewController.slideInOutViewSize.height);
    }];
    
    // 监听高度变化
    __weak typeof(self) weakSelf = self ;
    [self.viewController.slideInOutNavigationBar addObserverForKeyPath:@"frame" userInfo:nil didChangedValueBlock:^(PPObjectObserverModel * _Nonnull observerModel) {
        
        CGFloat height = weakSelf.viewController.slideInOutNavigationBar.height + weakSelf.viewController.slideInOutViewSize.height;
        [weakSelf changeContentViewFrameWithHeight:height];
    } removeObserverWhenTargetDalloc:self];
    
    [self addObserverForKeyPath:@"slideInOutViewSize" userInfo:nil didChangedValueBlock:^(PPObjectObserverModel * _Nonnull observerModel) {
        
        CGFloat height = weakSelf.viewController.slideInOutNavigationBar.height + weakSelf.viewController.slideInOutViewSize.height;
        [weakSelf changeContentViewFrameWithHeight:height];
    } removeObserverWhenTargetDalloc:self];
}

// 修改 contentView.frame
-(void)changeContentViewFrameWithHeight:(CGFloat)height {
    if (self.contentView.height == height) {
        return;
    }
    height = height > kContentViewMaxHeight ? kContentViewMaxHeight:height;
    CGFloat width = self.viewController.slideInOutViewSize.width;
    CGFloat x = (self.view.width - width) / 2;
    CGFloat y = self.contentView.y;
    if (self.viewControllerShowed) {
        y = self.view.height - height;
    }
    self.contentView.frame = CGRectMake(x, y, width, height);
    self.animateDuration = height * kAnimationUnitDuration;
    
    [self.viewController.view mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(self.viewController.slideInOutViewSize.height);
    }];
}

#pragma mark - 监听键盘，改变高度
-(void)addObserverKeyboardShowAndHideNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:)name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:)name:UIKeyboardWillHideNotification object:nil];
}

-(void)keyboardWillShow:(NSNotification*)notification {
    if (!self.viewControllerShowed) {
        return;
    }
    self.keyboardShowed = YES;
    self.startOffsetY = self.slideOutPan.mainScrollView.contentOffset.y ;
    self.keyboardHeight = [notification.userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height;
    
    // 监听viewController.view位置更变:键盘弹出 和 隐藏
    [self.viewController.view addObserverForKeyPath:@"frame" userInfo:nil target:self action:@selector(observerChangeFrameForViewController)];
    [self.slideOutPan.mainScrollView addObserverForKeyPath:@"contentOffset" userInfo:nil target:self action:@selector(observerChangeContentOffsetForMainScrollView)];
}
-(void)keyboardWillHide:(NSNotification*)notification {
    self.keyboardShowed = NO;
    
    [self.viewController.view removeObserverForKeyPath:@"frame" target:self];
    [self.slideOutPan.mainScrollView removeObserverForKeyPath:@"contentOffset" target:self];
    
    //键盘收起时 contentView 还原高度和位置
    CGFloat height = self.viewController.slideInOutNavigationBar.height + self.viewController.slideInOutViewSize.height;
    [self changeContentViewFrameWithHeight:height];
    
}

-(void)observerChangeContentOffsetForMainScrollView {
    if (!self.keyboardShowed || self.slideOutPan.mainScrollView.contentOffset.y <= self.startOffsetY ||
        self.viewController.slideInOutViewSize.height > (self.keyboardHeight+280) ) {
        return;
    }
    
    CGFloat height = self.viewController.slideInOutNavigationBar.height + self.keyboardHeight;
    if (self.viewController.slideInOutViewSize.height > 280) {
        height+= 280 ;
    }else{
        height+= self.viewController.slideInOutViewSize.height;
    }
    
    // 键盘升起时高度只增加
    if (self.contentView.height < height) {
        [self changeContentViewFrameWithHeight:height];
    }
}

// 监听viewController.view位置更变
-(void)observerChangeFrameForViewController {
    if (!self.keyboardShowed) {
        return;
    }
    
    // 先移除监听，防止这段代码循环调用
    [self.viewController.view removeObserverForKeyPath:@"frame" target:self];

    CGFloat height = self.viewController.slideInOutNavigationBar.height + self.viewController.slideInOutViewSize.height + self.viewController.slideInOutViewMoveOffsetYWhenKeyboardShow;
    // viewController.view.y 位置移动时，contentView 适应高度
    height += self.viewController.slideInOutNavigationBar.bottom - self.viewController.view.y;
    
    if (height > kContentViewMaxHeight) {
        // 说明底部的输入框向上升，才能不被档住
        self.viewController.view.y += height - kContentViewMaxHeight;
    }else{
        // 输入框完全能展示， viewController.view.y 保持位置要保证不变
        self.viewController.view.y = self.viewController.slideInOutNavigationBar.bottom;
    }
    
    // 键盘升起时高度只增加
    if (self.contentView.height < height) {
        [self changeContentViewFrameWithHeight:height];
    }
    
    // 添加监听
    [self.viewController.view addObserverForKeyPath:@"frame" userInfo:nil target:self action:@selector(observerChangeFrameForViewController)];
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 显示 与 隐藏动画

-(void)showViewControllerAnimated:(BOOL)animation complation:(void(^)(void))complation {
    
    if ([self isViewLoaded]) {
        [self.viewController viewWillAppear:YES];
        self.blackBgView.userInteractionEnabled = NO;

        [UIView animateWithDuration:animation?self.animateDuration:0 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.contentView.y = self.view.height - self.contentView.height;
            self.blackBgView.alpha = 1;
        }completion:^(BOOL finished) {
            
            [self.viewController viewDidAppear:YES];
            self.viewControllerShowed = YES ;
            self.blackBgView.userInteractionEnabled = YES;

            // 防止动画失效
            self.contentView.y = self.view.height - self.contentView.height;
            self.blackBgView.alpha = 1;

            if (complation) {
                complation();
            }
        }];
    }else {
        self.showNeedAnimation = animation ;
        [[self pp_currentTopNavigationController] pushViewController:self animated:NO];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((animation?self.animateDuration :0)* NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            self.showNeedAnimation = YES;
            
            if (complation) {
                complation();
            }
        });
    }
    
}

-(void)hiddenViewControllerAnimated:(BOOL)animation complation:(void(^)(void))complation {
    
    if ([self isViewLoaded]) {
        // 关闭可能出现的键盘
        [self.view endEditing:YES];
    }
    
    [self.viewController viewWillDisappear:YES];
    self.blackBgView.userInteractionEnabled = NO;
    
    [UIView animateWithDuration:animation?self.animateDuration:0 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.contentView.y = self.view.height;
        self.blackBgView.alpha = 0;
    }completion:^(BOOL finished) {
        
        [self.viewController viewDidDisappear:YES];
        self.viewControllerShowed = NO ;
        self.blackBgView.userInteractionEnabled = YES;

        if (complation){
            complation();
        }
    }];
}

#pragma mark - action

-(void)closeAction {
    // 关闭可能出现的键盘
    [self.view endEditing:YES];
    
    [self disappearViewController];
}

#pragma mark getter

-(UIView *)blackBgView {
    if (!_blackBgView) {
        _blackBgView = [UIView new];
        _blackBgView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
        [_blackBgView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeAction)]];
    }
    return _blackBgView;
}

-(UIView *)contentView {
    if (!_contentView) {
        _contentView = [UIView new];
        _contentView.backgroundColor = [UIColor whiteColor];
        _contentView.clipsToBounds = YES;
    }
    return _contentView;
}

-(PPSlideOutPanGestureRecognizer *)slideOutPan {
    if (!_slideOutPan) {
        _slideOutPan = [PPSlideOutPanGestureRecognizer new];
        _slideOutPan.fromVc = self;
        _slideOutPan.targetView = self.contentView;
    }
    return _slideOutPan;
}

@end
