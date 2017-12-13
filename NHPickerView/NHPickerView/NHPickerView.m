//
//  NHPickerView.m
//  MiGuIMP
//
//  Created by 牛虎 on 2017/12/11.
//  Copyright © 2017年 MiGu. All rights reserved.
//

#import "NHPickerView.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

static const CGFloat kAnimateDurationOfBackgroundView = 0.25;
static const CGFloat kHeightForPickerView = 216;
static const CGFloat kHeightForPickerViewTool = 40;

static char * const kObjcPickerViewRetainKey = "kObjcPickerViewRetainKey";

#pragma mark **********  NHPickerViewTool
@interface NHPickerViewTool : UIView

- (void)confirmButtonActionBolock:(void (^)(UIButton *button))confirmBlock;
- (void)cancelButtonActionBolock:(void (^)(UIButton *button))confirmBlock;

@end

@interface NHPickerViewTool ()

@property (nonatomic) UIButton * confirmButton;
@property (nonatomic) UIButton * cancelButton;

@property (nonatomic,copy) void (^confirmButtonBlock)(UIButton *button);
@property (nonatomic,copy) void (^cancelButtonBlock)(UIButton *button);

@end

@implementation NHPickerViewTool

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setupUI];
    }
    return self;
}
- (void)setupUI{
    
    self.backgroundColor = [UIColor colorWithRed:0 green:187/255.0 blue:255/255.0 alpha:1];
    [self addSubview:self.confirmButton];
    [self addSubview:self.cancelButton];
    
    self.confirmButton.frame = CGRectMake(CGRectGetWidth(self.frame)-60, 0, 60, CGRectGetHeight(self.frame));
    self.cancelButton.frame = CGRectMake(0, 0, 60, CGRectGetHeight(self.frame));
    
}
#pragma mark Block
- (void)confirmButtonActionBolock:(void (^)(UIButton *button))confirmBlock{
    NSAssert(confirmBlock, @"block can not be nil");
    self.confirmButtonBlock = [confirmBlock copy];
}
- (void)cancelButtonActionBolock:(void (^)(UIButton *button))confirmBlock{
    NSAssert(confirmBlock, @"block can not be nil");
    self.cancelButtonBlock = [confirmBlock copy];
}
- (void)confirmButtonAction:(UIButton *)button{
    NSAssert(self.confirmButtonBlock, @"block can not be nil");
    self.confirmButtonBlock(button);
}
- (void)cancelButtonAction:(UIButton *)button{
    NSAssert(self.cancelButtonBlock, @"block can not be nil");
    self.cancelButtonBlock(button);
}
#pragma mark Lazy Load
- (UIButton *)configPropertiesForButtonWithTitle:(NSString *)title{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    return button;
}
-(UIButton *)confirmButton{
    return _confirmButton ? : (_confirmButton = ({
        UIButton *button = [self configPropertiesForButtonWithTitle:@"确定"];
        [button addTarget:self action:@selector(confirmButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        button;
    }));
}
-(UIButton *)cancelButton{
    return _cancelButton ? : (_cancelButton = ({
        UIButton *button = [self configPropertiesForButtonWithTitle:@"取消"];
        [button addTarget:self action:@selector(cancelButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        button;
    }));
}

@end

#pragma mark **********  NHPickerView

@interface NHPickerView ()<UIPickerViewDelegate,UIPickerViewDataSource>

@property (nonatomic) NHPickerViewTool *pickerViewTool;
@property (nonatomic) UIPickerView *pickerView;
@property (nonatomic) UIView *backGroundView;
@property (nonatomic) NSMutableArray *dataArray;

@end

@implementation NHPickerView

-(instancetype)init{
    if (self = [super init]) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI{
    
    objc_setAssociatedObject(self, &kObjcPickerViewRetainKey, self, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [[UIApplication sharedApplication].keyWindow addSubview:self.backGroundView];
    [self.backGroundView addSubview:self.pickerView];
    [self.backGroundView addSubview:self.pickerViewTool];
    
}

#pragma mark PickerView Delegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return self.sourceArray.count;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return self.sourceArray[component].count;
}
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return self.sourceArray[component][row];
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    if (self.delegate && [self.delegate respondsToSelector:@selector(nh_pickerView:didSelectRow:section:)]) {
        [self.delegate nh_pickerView:self didSelectRow:row section:component];
    }
    self.dataArray[component] = self.sourceArray[component][row];
}
#pragma mark Method
- (void)configCalendarData{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy/MM/dd"];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSCalendarUnit unit = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday;
    
    NSMutableArray *arrayForYear = [NSMutableArray array];
    NSMutableArray *arrayForMonth = [NSMutableArray array];
    NSMutableArray *arrayForDay = [NSMutableArray array];
    
    NSDateComponents *component = [calendar components:unit fromDate:[NSDate date]];
    
    //year
    for (NSInteger i = component.year - 5; i < component.year + 5; i++) {
        [arrayForYear addObject:[NSString stringWithFormat:@"%zd",i]];
    }
    //month
    for (NSInteger i = 1; i<=12; i++) {
        [arrayForMonth addObject:[NSString stringWithFormat:@"%zd",i]];
    }
    //day
    NSDate *date = [formatter dateFromString:[NSString stringWithFormat:@"%zd/%zd/1",component.year,component.month]];
    NSRange range = [calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date];
    
    for (NSInteger j = 1; j <= range.length; j++) {
        [arrayForDay addObject:[NSString stringWithFormat:@"%zd",j]];
    }
    
    self.sourceArray = @[arrayForYear,arrayForMonth,arrayForDay];
    
    NSUInteger selectedYearIndex = [arrayForYear indexOfObject:[NSString stringWithFormat:@"%zd",component.year]];
    NSUInteger selectedMonthIndex = [arrayForMonth indexOfObject:[NSString stringWithFormat:@"%zd",component.month]];
    NSUInteger selectedDayIndex = [arrayForDay indexOfObject:[NSString stringWithFormat:@"%zd",component.day]];
    [self selectPickerViewComponent:0 row:selectedYearIndex animated:NO];
    [self selectPickerViewComponent:1 row:selectedMonthIndex animated:NO];
    [self selectPickerViewComponent:2 row:selectedDayIndex animated:NO];
}
- (void)show{
    
    if (self.sourceArray.count <= 0) {
        [self configCalendarData];
    }
    
    CGRect toolFrame = self.pickerViewTool.frame;
    CGRect pickerViewFrame = self.pickerView.frame;
    toolFrame.origin.y = toolFrame.origin.y - kHeightForPickerView - kHeightForPickerViewTool;
    pickerViewFrame.origin.y = pickerViewFrame.origin.y - kHeightForPickerView - kHeightForPickerViewTool;
    [UIView animateWithDuration:kAnimateDurationOfBackgroundView animations:^{
        self.backGroundView.alpha = 1;
        self.pickerViewTool.frame = toolFrame;
        self.pickerView.frame = pickerViewFrame;
    }];
}
-(void)dismiss{
    CGRect toolFrame = self.pickerViewTool.frame;
    CGRect pickerViewFrame = self.pickerView.frame;
    toolFrame.origin.y = toolFrame.origin.y + kHeightForPickerView + kHeightForPickerViewTool;
    pickerViewFrame.origin.y = pickerViewFrame.origin.y + kHeightForPickerView + kHeightForPickerViewTool;
    [UIView animateWithDuration:kAnimateDurationOfBackgroundView animations:^{
        self.backGroundView.alpha = 0;
        self.pickerViewTool.frame = toolFrame;
        self.pickerView.frame = pickerViewFrame;
    } completion:^(BOOL finished) {
        [self.backGroundView removeFromSuperview];
        objc_setAssociatedObject(self, &kObjcPickerViewRetainKey, nil, OBJC_ASSOCIATION_ASSIGN);
    }];
}
- (void)confirmButtonAction{
    if (self.delegate && [self.delegate respondsToSelector:@selector(nh_pickerView:disSelectDataSource:)]) {
        [self.delegate nh_pickerView:self disSelectDataSource:self.dataArray];
    }
}
- (void)pickerViewReloadAllComponents{
    [self.pickerView reloadAllComponents];
}
- (void)pickerViewReloadComponent:(NSInteger)component{
    [self.pickerView reloadComponent:component];
}
- (void)selectPickerViewComponent:(NSInteger)component row:(NSInteger)row animated:(BOOL)animated{
    if (component <= self.sourceArray.count && row <= self.sourceArray[component].count) {
        [self.pickerView selectRow:row inComponent:component animated:animated];
        self.dataArray[component] = self.sourceArray[component][row];
    }else{
        if (self.sourceArray.count > 0) {
            NSAssert(nil, @"check your component or row");
        }
    }
}
#pragma mark setter
-(void)setSourceArray:(NSArray<NSArray *> *)sourceArray{
    _sourceArray = sourceArray;
    for (int i = 0; i < sourceArray.count; i ++) {
        [self selectPickerViewComponent:i row:sourceArray.count/2 animated:NO];
    }
    [self.pickerView reloadAllComponents];
}
#pragma mark Lazy Load
-(UIPickerView *)pickerView{
    return _pickerView ? : (_pickerView = ({
        UIPickerView *pickerView = [[UIPickerView alloc]initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height + kHeightForPickerViewTool, [UIScreen mainScreen].bounds.size.width, kHeightForPickerView)];
        pickerView.backgroundColor = [UIColor whiteColor];
        pickerView.delegate = self;
        pickerView.dataSource = self;
        pickerView;
    }));
}
- (UIView *)backGroundView{
    return _backGroundView ? : (_backGroundView = ({
        UIView *bg = [[UIView alloc]initWithFrame:[UIApplication sharedApplication].keyWindow.frame];
        bg.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.5];
        bg.alpha = 0;
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [bg addSubview:btn];
        btn.frame = [UIApplication sharedApplication].keyWindow.frame;
        
        [btn addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
        
        bg;
    }));
}
- (NSMutableArray *)dataArray{
    return _dataArray ? : (_dataArray = ({
        NSMutableArray *mArray = [NSMutableArray array];
        for (int i = 0 ; i < self.sourceArray.count; i ++) {
            [mArray addObject:@""];
        }
        mArray;
    }));
}
- (NHPickerViewTool *)pickerViewTool{
    return _pickerViewTool ? : (_pickerViewTool = ({
        NHPickerViewTool *tool = [[NHPickerViewTool alloc]initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, kHeightForPickerViewTool)];
        __weak typeof(self) weakSelf = self;
        [tool confirmButtonActionBolock:^(UIButton *button) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf confirmButtonAction];
            [strongSelf dismiss];
        }];
        [tool cancelButtonActionBolock:^(UIButton *button) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf dismiss];
        }];
        tool;
    }));
}
@end
