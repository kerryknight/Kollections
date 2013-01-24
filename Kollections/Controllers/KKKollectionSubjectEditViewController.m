//
//  KKKollectionSubjectEditViewController.m
//  Kollections
//
//  Created by Kerry Knight on 1/9/13.
//  Copyright (c) 2013 Kerry Knight. All rights reserved.
//

#import "KKKollectionSubjectEditViewController.h"
#import "KKConstants.h"
#import "KKToolbarButton.h"

@interface KKKollectionSubjectEditViewController () {
}
@property (nonatomic, strong) KKToolbarButton *backButton;
@end

@implementation KKKollectionSubjectEditViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
 
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"kkTitleBarLogo.png"]];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"kkMainBG.png"]]];//set background image
    
    //set the frame of the table view using the window height - navbar height - tabbar height
    id appDelegate = [[UIApplication sharedApplication] delegate];
    UIWindow *window = [appDelegate window];
    float height = window.frame.size.height -
                   self.navigationController.navigationBar.frame.size.height -
                   self.tabBarController.tabBar.frame.size.height - 20;
    
    self.scrollView.frame = CGRectMake(0, 0, window.frame.size.width, height);

    self.titleField.backgroundColor = [UIColor colorWithRed:251 green:251 blue:250 alpha:1.0];//almost white
    self.titleField.textColor = kMint4;
    self.titleField.delegate = self;
    
    //put border on entry field
    self.titleField.layer.borderColor = kGray3.CGColor;
    self.titleField.layer.borderWidth = 0.75f;
    
    self.descriptionField.backgroundColor = [UIColor colorWithRed:251 green:251 blue:250 alpha:1.0];//almost white
    self.descriptionField.textColor = kMint4;
    self.descriptionField.delegate = self;
    
    //put border on entry field
    self.descriptionField.layer.borderColor = kGray3.CGColor;
    self.descriptionField.layer.borderWidth = 0.75f;
    
//    self.payoutField.backgroundColor = [UIColor colorWithRed:251 green:251 blue:250 alpha:1.0];//almost white
//    self.payoutField.textColor = kMint4;
//    self.payoutField.delegate = self;
    
//    //put border on entry field
//    self.payoutField.layer.borderColor = kGray3.CGColor;
//    self.payoutField.layer.borderWidth = 0.75f;
    
    //add a header label to top of view
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(15.0f, 13.0f, [self.scrollView viewWithTag:200].bounds.size.width - 20.0f, 20.0f)];
    [self.scrollView addSubview:headerLabel];
    [headerLabel setTextColor:kGray6];
    [headerLabel setShadowColor:kCreme];
    [headerLabel setShadowOffset:CGSizeMake( 0.0f, 1.0f)];
    [headerLabel setFont:[UIFont fontWithName:@"OriyaSangamMN-Bold" size:16]];
    [headerLabel setBackgroundColor:[UIColor clearColor]];
    headerLabel.text = @"Add a New Kollection Subject";
    
    //set the submit button up
    UIButton *addButton = [[UIButton alloc] init];
    [addButton setBackgroundImage:[UIImage imageNamed:@"kkSignUpButtonUp.png"] forState:UIControlStateNormal];
    [addButton setBackgroundImage:[UIImage imageNamed:@"kkSignUpButtonDown.png"] forState:UIControlStateHighlighted];
    [addButton setTitle:@"Done" forState:UIControlStateNormal];
    [addButton setTitle:@"Done" forState:UIControlStateHighlighted];
    [addButton addTarget:self action:@selector(submit:) forControlEvents:UIControlEventTouchUpInside];
    CGSize buttonSize = CGSizeMake(245, 44);
    [addButton setFrame:CGRectMake((self.scrollView.frame.size.width/2 - buttonSize.width/2),
                                   300,
                                   buttonSize.width,
                                   buttonSize.height)];
    [self.scrollView addSubview:addButton];
    
    //add a gesture recognizer to the scrollview so we can dismiss the keyboard if it's showing and we tap outside a text field
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    // prevents the scroll view from swallowing up the touch event of child buttons
    tapGesture.cancelsTouchesInView = NO;
    [self.scrollView addGestureRecognizer:tapGesture];
    
    //add toolbar buttons
    self.navigationItem.hidesBackButton = YES;//hide default back button as it's not styled like I want
    [self configureBackButton];//add our custom back button
    
    [self fillInData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [self setScrollView:nil];
    [self setDelegate:nil];
    [self setSubject:nil];
    [self setDivider:nil];
    [self setTitleField:nil];
    [self setDescriptionField:nil];
//    [self setPayoutField:nil];
}

#pragma mark - UIViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //    NSLog(@"%s", __FUNCTION__);
    self.backButton.hidden = NO;//this is hidden if we navigate away
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.backButton.hidden = YES;
}

#pragma mark - Custom Methods
//our custom back button
- (void)configureBackButton {
    //    NSLog(@"%s", __FUNCTION__);
    //add button to view
    self.backButton = [[KKToolbarButton alloc] initWithFrame:kKKBarButtonItemLeftFrame isBackButton:YES andTitle:@"Cancel"];
    [self.backButton addTarget:self action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationController.navigationBar addSubview:self.backButton];
}

- (void)backButtonAction:(id)sender {
    //    NSLog(@"%s", __FUNCTION__);
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)fillInData {
    //make sure we have a subject to fill stuff in with
    if (self.subject) {
        if (self.subject[kKKKollectionTitleKey])self.titleField.text = self.subject[kKKKollectionTitleKey];
        if (self.subject[kKKKollectionDescriptionKey])self.descriptionField.text = self.subject[kKKKollectionDescriptionKey];
//        if (self.subject[kKKKollectionPayoutKey])self.payoutField.text = [self.subject[kKKKollectionPayoutKey] stringValue];
    } else {
        //no subject set or it's a new subject
        self.subject = [PFObject objectWithClassName:kKKSubjectClassKey];//there are 3 fields we're concerned with
    }
    
    if ([self.descriptionField.text isEqualToString:@"100-character limit"]) {
        //set the description field's color to look like a placeholder
        self.descriptionField.textColor = kGray3;
    }
}

- (BOOL)extractData {
    //ensure we've filled in a title; payout and description are optional
    if ([self.titleField.text length] == 0) {
        alertMessage(@"Please enter a subject title.");
        return NO;
    }
    
    //set all the subject values in it's dictionary
    self.subject[kKKKollectionTitleKey] = self.titleField.text;
//    self.subject[kKKKollectionPayoutKey] = [NSNumber numberWithInt:[self.payoutField.text intValue]];
    if ([self.descriptionField.text isEqualToString:@"100-character limit"]) {
        self.subject[kKKKollectionDescriptionKey] = @"";
    } else {
        self.subject[kKKKollectionDescriptionKey] = self.descriptionField.text;
    }
    
    return YES;
}

- (void)submit:(id)sender {
//    NSLog(@"%s", __FUNCTION__);
    if ([self extractData]) {
        //send the subject to the delegate
        [self.delegate subjectEditViewControllerDidSubmitSubject:self.subject];
    }
}

#pragma mark - Scrollview delegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
//    CGPoint bottomOffset = CGPointMake(0, 0);//reset
//    [self.scrollView setContentOffset:bottomOffset animated:YES];
}

- (void)hideKeyboard {
    [self.view endEditing:YES];
    CGPoint bottomOffset = CGPointMake(0, 0);//reset 
    [self.scrollView setContentOffset:bottomOffset animated:YES];
}

#pragma mark - UITextFieldDelegate methods
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (textField == self.titleField) {
        NSString *trimmedValue = textField.text;
        trimmedValue = [trimmedValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSUInteger stringLimit = kSetupStringCharacterLimit;
        if (textField.text.length > stringLimit) {
            textField.text = [textField.text substringToIndex:stringLimit - 1];
            NSString *message = [NSString stringWithFormat:@"This field is limited to %i characters.", stringLimit];
            
            //knightka replaced a regular alert view with our custom subclass
            BlockAlertView *alert = [BlockAlertView alertWithTitle:@"Character Limit" message:message];
            [alert setCancelButtonWithTitle:@"OK" block:nil];
            [alert show];
            
            return NO; // return NO to not exit field
        }
    }/* else if (textField == self.payoutField) {
        NSCharacterSet *set = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet];
        if ([textField.text rangeOfCharacterFromSet:set].location != NSNotFound) {
            alertMessage(@"Please use only whole numbers.");
            return NO;
        }
    }*/
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
  
//    if (textField == self.payoutField) {
//        CGPoint bottomOffset = CGPointMake(0, 200);//scroll the scroll view to show the field
//        [self.scrollView setContentOffset:bottomOffset animated:YES];
//    }
    
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    if (textField == self.titleField) {
        NSString *trimmedValue = textField.text;
        trimmedValue = [trimmedValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSUInteger stringLimit = kSetupStringCharacterLimit;
        if (textField.text.length > stringLimit) {
            textField.text = [textField.text substringToIndex:stringLimit - 1];
            NSString *message = [NSString stringWithFormat:@"This field is limited to %i characters.", stringLimit];
            
            //knightka replaced a regular alert view with our custom subclass
            BlockAlertView *alert = [BlockAlertView alertWithTitle:@"Character Limit" message:message];
            [alert setCancelButtonWithTitle:@"OK" block:nil];
            [alert show];
            
            return NO; // return NO to not exit field
        }
    }/* else if (textField == self.payoutField) {
        NSCharacterSet *set = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet];
        if ([textField.text rangeOfCharacterFromSet:set].location != NSNotFound) {
            alertMessage(@"Please use only whole numbers.");
            return NO;
        }
    }*/
    
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    NSString *textFieldtext = textField.text;
    
    if (textField == self.titleField) {
        [self.subject setObject:textFieldtext forKey:kKKSubjectTitleKey];
    }/* else if (textField == self.payoutField) {
        [self.subject setObject:textFieldtext forKey:kKKSubjectPayoutKey];
    }*/
    
}

#pragma mark - UITextViewDelegate methods
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
//    NSLog(@"%s", __FUNCTION__);
    NSUInteger stringLimit = kSetupLongStringCharacterLimit;
    
    if ([textView.text isEqualToString:[NSString stringWithFormat:@"%i-character limit", stringLimit]]) {
        //clear the placeholder
        textView.text = @"";
    }
    
    [textView setReturnKeyType:UIReturnKeyDone];
    
    if (textView == self.descriptionField) {
        CGPoint bottomOffset = CGPointMake(0, 75);//scroll the scroll view to show the field
        [self.scrollView setContentOffset:bottomOffset animated:YES];
    }
    
    textView.textColor = kMint4;
    
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
//    NSLog(@"%s", __FUNCTION__);
    
    NSString *trimmedValue = textView.text;
    trimmedValue = [trimmedValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSUInteger stringLimit = kSetupLongStringCharacterLimit;
    NSString *stringPlaceholder;
    
    //set the message with text limit
    stringPlaceholder = [NSString stringWithFormat:@"%i-character limit", stringLimit];
    
    //reset the placeholder if we didn't put in anything or it's the same as before
    if ([trimmedValue isEqualToString:@""] || [trimmedValue isEqualToString:stringPlaceholder]) {
        //reset the placeholder if we didn't enter anything
        textView.text = stringPlaceholder;
    } else if (textView.text.length > stringLimit) {
        NSString *message = [NSString stringWithFormat:@"This field is limited to %i characters.", stringLimit];
        
        //knightka replaced a regular alert view with our custom subclass
        BlockAlertView *alert = [BlockAlertView alertWithTitle:@"Character Limit" message:message];
        [alert setCancelButtonWithTitle:@"OK" block:nil];
        [alert show];
        
        return NO; // return NO to not exit field
    }
    
    [textView resignFirstResponder];
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
//    NSLog(@"textView super view class = %@", [[[textView superview] superview]class]);
    //check our cell type to determine our character limits
    NSUInteger stringLimit = kSetupLongStringCharacterLimit;
    
    if (textView.text.length > stringLimit && range.length == 0) {
        textView.text = [textView.text substringToIndex:stringLimit - 1];
        NSString *message = [NSString stringWithFormat:@"This field is limited to %i characters.", stringLimit];
        
        //knightka replaced a regular alert view with our custom subclass
        BlockAlertView *alert = [BlockAlertView alertWithTitle:@"Character Limit" message:message];
        [alert setCancelButtonWithTitle:@"OK" block:nil];
        [alert show];
        
        return NO; // return NO to not change text
    }
    else {
        //dismiss if we've hit the enter key
        if([text isEqualToString:@"\n"]) {
            [textView resignFirstResponder];
            return NO;
        }
        
        return YES;
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
//    NSLog(@"%s", __FUNCTION__);
    
    //first, determine what type of cell (short string/long string) we're dealing with and trim down the text
    //to prevent any problems where a user might have copy and pasted into the textview instead of typing directly
    NSUInteger stringLimit  = kSetupLongStringCharacterLimit;
    
    //set what the placeholder string should be
    NSString *stringPlaceholder = [NSString stringWithFormat:@"%i-character limit", stringLimit];
    
    if ([textView.text isEqualToString:stringPlaceholder]) {
        //reset the placeholder if we didn't enter anything
        textView.textColor = kGray3;
        return;//exit without saving anything
    }
    
    //set the text and then the range to trim out
    NSString *textViewtext = textView.text;
    NSRange range = NSMakeRange(0, stringLimit);
    if ([textViewtext length] > stringLimit) {
        textViewtext = [textViewtext substringWithRange:range];
    }
    
    [self.subject setObject:textViewtext forKey:kKKSubjectDescriptionKey];
    
}

@end
