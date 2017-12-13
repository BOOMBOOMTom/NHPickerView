//
//  ViewController.m
//  NHPickerView
//
//  Created by 牛虎 on 2017/12/13.
//  Copyright © 2017年 Tom. All rights reserved.
//

#import "ViewController.h"
#import "NHPickerView.h"

@interface ViewController ()<NHPickerViewDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (IBAction)showAction:(UIButton *)sender {
    
    NHPickerView *pickerView = [[NHPickerView alloc]init];
    pickerView.delegate = self;
    pickerView.sourceArray = @[@[@"2017",@"2018",@"2019"],@[@"咪咕动漫",@"咪咕音乐",@"咪咕视频"]];
    [pickerView show];
    
}
- (void)nh_pickerView:(NHPickerView *)pickerView didSelectRow:(NSInteger)row section:(NSInteger)section{
    NSLog(@"%zd---%zd",section,row);
}
- (void)nh_pickerView:(NHPickerView *)pickerView disSelectDataSource:(NSArray *)dataArray{
    NSLog(@"dataArray---%@",dataArray);
}
@end
