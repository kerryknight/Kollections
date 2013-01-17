//
//  BlockPickerActionSheet.h
//  BlockAlertsDemo
//
//  Created by Kerry Knight on 1/11/13.
//  Copyright (c) 2013 Kerry Knight. All rights reserved.
//

#import "BlockActionSheet.h"

@class BlockPickerActionSheet;

typedef BOOL(^PickerReturnCallBack)(BlockPickerActionSheet *);

@interface BlockPickerActionSheet : BlockActionSheet <UIPickerViewDataSource, UIPickerViewDelegate> {
}

@property (nonatomic, retain) UIPickerView *picker;
@property (nonatomic, retain) NSArray *pickerList;
@property (nonatomic, retain) NSDictionary *pickerSelection;

+ (BlockPickerActionSheet *)pickerWithTitle:(NSString *)title withChoices:(NSArray*)choices defaultSelection:(NSDictionary*)defaultSelection;
+ (BlockPickerActionSheet *)pickerWithTitle:(NSString *)title withChoices:(NSArray*)choices defaultSelection:(NSDictionary*)defaultSelection block:(PickerReturnCallBack)block;

+ (BlockPickerActionSheet *)pickerWithTitle:(NSString *)title withChoices:(NSArray*)choices pickerSelection:(out NSDictionary**)selection;

+ (BlockPickerActionSheet *)pickerWithTitle:(NSString *)title withChoices:(NSArray*)choices pickerSelection:(out NSDictionary**)selection block:(PickerReturnCallBack)block;


- (id)initWithTitle:(NSString *)title withChoices:(NSArray*)choices defaultSelection:(NSDictionary*)defaultSelection block:(PickerReturnCallBack)block;


@end
