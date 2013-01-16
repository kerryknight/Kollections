//
//  KKKollectionSubjectEditViewController.h
//  Kollections
//
//  Created by Kerry Knight on 1/9/13.
//  Copyright (c) 2013 Kerry Knight. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlightIndentTextField.h"


@protocol KKKollectionSubjectEditViewControllerDelegate <NSObject>
@optional
- (void)subjectEditViewControllerDidSubmitSubject:(NSMutableDictionary*)subject;
@end

@interface KKKollectionSubjectEditViewController : UIViewController <UIScrollViewDelegate, UITextViewDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate> {
}

@property (nonatomic, strong) id<KKKollectionSubjectEditViewControllerDelegate> delegate;
@property (nonatomic, strong) NSMutableDictionary *subject;
@property (weak, nonatomic) IBOutlet UIImageView *divider;
@property (weak, nonatomic) IBOutlet SlightIndentTextField *titleField;
@property (weak, nonatomic) IBOutlet UITextView *descriptionField;
@property (weak, nonatomic) IBOutlet UITextField *payoutField;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

@end
