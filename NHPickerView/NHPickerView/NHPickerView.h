//
//  NHPickerView.h
//  MiGuIMP
//
//  Created by 牛虎 on 2017/12/11.
//  Copyright © 2017年 MiGu. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NHPickerView;
@protocol NHPickerViewDelegate <NSObject>

@optional
- (void)nh_pickerView:(NHPickerView *)pickerView didSelectRow:(NSInteger)row section:(NSInteger)section;
- (void)nh_pickerView:(NHPickerView *)pickerView disSelectDataSource:(NSArray *)dataArray;

@end

@interface NHPickerView : NSObject

@property (nonatomic) NSArray <NSArray <NSString *>*>*sourceArray;
@property (nonatomic,weak)id <NHPickerViewDelegate> delegate;

- (void)show;
- (void)dismiss;
- (void)pickerViewReloadAllComponents;
- (void)pickerViewReloadComponent:(NSInteger)component;

/**
 * 若需要自定义数据源，需要先设置sourceArray再执行此函数
 * 默认年、月、日日期模式

 @param component component
 @param row       row
 @param animated  animated
 */
- (void)selectPickerViewComponent:(NSInteger)component row:(NSInteger)row animated:(BOOL)animated;

@end
