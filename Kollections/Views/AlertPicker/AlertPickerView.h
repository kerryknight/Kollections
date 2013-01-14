//
//  AlertPickerView.h
//  Custom Alert View
//
//  Created by Kerry Knight on 15Feb2011.
//  With Custom Alert View code courtesy of http://iphonedevelopment.blogspot.com/2010/05/custom-alert-views.html
//  Copyright 2010-2012 PPD. All rights reserved.
//  mIP Version 1.0

#import <UIKit/UIKit.h>
#import "CDUser.h"

enum 
{
    AlertPickerViewButtonTagOk = 1001,
    AlertPickerViewBG = 99,
    AlertPickerViewButtonTagCancel
};

@class AlertPickerView;

@protocol AlertPickerViewDelegate
@optional
- (void) AlertPickerView:(AlertPickerView *)alert wasDismissedWithFilterEntry:(NSDictionary *)selection;
- (void) AlertPickerView:(AlertPickerView *)alert wasDismissedWithSortEntry:(NSDictionary *)selection isAscending:(BOOL)ascending;
- (void) AlertPickerView:(AlertPickerView *)alert wasDismissedWithSelection:(NSDictionary *)selection;
- (void) AlertPickerView:(AlertPickerView *)alert wasDismissedWithUser:(CDUser *)selection;
- (void) AlertPickerView:(AlertPickerView *)alert wasDismissedWithAnswer:(NSString *)answer;
- (void) AlertPickerViewWasCancelled:(AlertPickerView *)alert;
@end


@interface AlertPickerView : UIViewController 
{
    UIView                                  *alertView;
    UIView                                  *backgroundView;
    IBOutlet UIPickerView *myPickerView;
    id<NSObject, AlertPickerViewDelegate>   delegate;
}
@property (nonatomic, retain) IBOutlet  UIView *alertView;
@property (nonatomic, retain) IBOutlet  UIView *backgroundView;
@property (nonatomic, retain) IBOutlet  UIPickerView *myPickerView;
@property (retain, nonatomic) IBOutlet UIButton *cancelButton;
@property (retain, nonatomic) IBOutlet UIButton *doneButton;
@property (nonatomic, retain) NSMutableArray *pickerList;
@property (nonatomic, retain) NSMutableDictionary *pickerSelection;
@property (nonatomic, retain) CDUser *selectedUser;
@property (nonatomic, retain) NSString *firstEntryLabel;
@property (nonatomic, assign) BOOL isAnswerList;
@property (nonatomic, assign) BOOL isUserList;
@property (nonatomic, assign) BOOL isSorting;

@property (nonatomic, assign) IBOutlet id<AlertPickerViewDelegate, NSObject> delegate;
- (IBAction)dismiss:(id)sender;
- (void)hidePicker;
- (void)changeUIOrientation:(NSNotification *)notification;
- (IBAction)show;
@end
