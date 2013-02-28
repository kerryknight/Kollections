//
//  KKSignUpViewController.m
//  Kollections
//
//  Created by Kerry Knight on 12/10/12.
//  Copyright (c) 2012 Kerry Knight. All rights reserved.
//

#import "KKSignUpViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "NimbusCore.h"
#import "NimbusAttributedLabel.h"

@interface KKSignUpViewController () <NIAttributedLabelDelegate>
@property (nonatomic, strong) UIImageView *fieldsBackground;
@property (nonatomic, strong) UIImageView *navBarBackground;
@property (nonatomic, strong) UIImageView *headerBackground;
@property (nonatomic, strong) UILabel *headerLabel;
@property (nonatomic, strong) UILabel *cancelLabel;
@property (nonatomic, strong) UILabel *passwordFooterLabel;
@property (nonatomic, strong) NIAttributedLabel *agreementLabel;

-(void)formatAgreementAttributedString;

@end

@implementation KKSignUpViewController

- (void)viewDidLoad {
//    NSLog(@"%s", __FUNCTION__);
    [super viewDidLoad];
    
    [self.signUpView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"kkMainBG.png"]]];
    [self.signUpView setLogo:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"kkTitleBarLogo.png"]]];

    // Change button apperance
    [self.signUpView.dismissButton setBackgroundImage:[UIImage imageNamed:@"kkRegularNavBarButton.png"] forState:UIControlStateNormal];
    [self.signUpView.dismissButton setBackgroundImage:[UIImage imageNamed:@"kkRegularNavigationBarSelected.png"] forState:UIControlStateHighlighted];
    [self.signUpView.dismissButton setImage:[UIImage imageNamed:@"xxx.png"] forState:UIControlStateNormal];//fake png so it's invisible
    [self.signUpView.dismissButton setImage:[UIImage imageNamed:@"xxx.png"] forState:UIControlStateHighlighted];//fake png so it's invisible
    [self.signUpView.signUpButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [self.signUpView.signUpButton setTitle:@"Cancel" forState:UIControlStateHighlighted];
    
    //add a custom Cancel label to the cancel button
    self.cancelLabel = [[UILabel alloc] initWithFrame:self.signUpView.dismissButton.frame];
    self.cancelLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
    self.cancelLabel.textAlignment = UITextAlignmentCenter;
    self.cancelLabel.backgroundColor = [UIColor clearColor];
    self.cancelLabel.textColor = kTan1;
    self.cancelLabel.text = @"Cancel";
    //give it some depth
    CALayer *cancelLayer = self.cancelLabel.layer;
    cancelLayer.shadowRadius = 0.4;
    cancelLayer.shadowOffset = CGSizeMake(0, -1);
    cancelLayer.shadowColor = [[UIColor colorWithRed:134.0f/255.0f green:119.0f/255.0f blue:111.0f/255.0f alpha:1.0] CGColor];
    cancelLayer.shadowOpacity = 1.0f;
    [self.view addSubview:self.cancelLabel];

    [self.signUpView.signUpButton setBackgroundImage:[UIImage imageNamed:@"kkSignUpButtonUp.png"] forState:UIControlStateNormal];
    [self.signUpView.signUpButton setBackgroundImage:[UIImage imageNamed:@"kkSignUpButtonDown.png"] forState:UIControlStateHighlighted];
    [self.signUpView.signUpButton setTitle:@"Sign Up" forState:UIControlStateNormal];
    [self.signUpView.signUpButton setTitle:@"Sign Up" forState:UIControlStateHighlighted];
    
    // Add background for fields
    [self setFieldsBackground:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"kkSignUpFieldBG.png"]]];
    [self.signUpView insertSubview:self.fieldsBackground atIndex:1];
    
    // Add nav bar background
    self.navBarBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"kkBackgroundNavBar.png"]];
    [self.signUpView addSubview:self.navBarBackground];
    [self.signUpView sendSubviewToBack:self.navBarBackground];
    
    // Add header bar background
    self.headerBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"kkHeaderBackground.png"]];
    [self.signUpView addSubview:self.headerBackground];
    [self.signUpView sendSubviewToBack:self.headerBackground];
    
    //add the Log in header label
    self.headerLabel = [[UILabel alloc] initWithFrame:self.headerBackground.frame];
    self.headerLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:17];
    self.headerLabel.textAlignment = UITextAlignmentLeft;
    self.headerLabel.backgroundColor = [UIColor clearColor];
    self.headerLabel.textColor = [UIColor colorWithRed:63.0f/255.0f green:63.0f/255.0f blue:64.0f/255.0f alpha:1.0];
    self.headerLabel.text = @" Required sign up details:";
    CALayer *headerLayer = self.headerLabel.layer;
    headerLayer.shadowRadius = 0.5;
    headerLayer.shadowOffset = CGSizeMake(0, -1);
    headerLayer.shadowColor = [[UIColor whiteColor] CGColor];
    headerLayer.shadowOpacity = 1.0f;
    [self.signUpView addSubview:self.headerLabel];
    
    //add the password footer label
    self.passwordFooterLabel = [[UILabel alloc] initWithFrame:self.signUpView.passwordField.frame];
    self.passwordFooterLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:12];
    self.passwordFooterLabel.textAlignment = UITextAlignmentCenter;
    self.passwordFooterLabel.backgroundColor = [UIColor clearColor];
    self.passwordFooterLabel.textColor = [UIColor colorWithRed:63.0f/255.0f green:63.0f/255.0f blue:64.0f/255.0f alpha:0.6];
    self.passwordFooterLabel.text = @"(Must contain at least one number)";
    CALayer *footerLayer = self.passwordFooterLabel.layer;
    footerLayer.shadowOpacity = 0.0f;
    [self.signUpView addSubview:self.passwordFooterLabel];
    
    // Remove text shadow
    CALayer *layer = self.signUpView.usernameField.layer;
    layer.shadowOpacity = 0.0f;
    layer = self.signUpView.passwordField.layer;
    layer.shadowOpacity = 0.0f;
    layer = self.signUpView.emailField.layer;
    layer.shadowOpacity = 0.0f;
    layer = self.signUpView.additionalField.layer;
    layer.shadowOpacity = 0.0f;

    // Set text color
    [self.signUpView.usernameField setTextColor:[UIColor colorWithRed:63.0f/255.0f green:63.0f/255.0f blue:64.0f/255.0f alpha:1.0]];
    [self.signUpView.passwordField setTextColor:[UIColor colorWithRed:63.0f/255.0f green:63.0f/255.0f blue:64.0f/255.0f alpha:1.0]];
    [self.signUpView.emailField setTextColor:[UIColor colorWithRed:63.0f/255.0f green:63.0f/255.0f blue:64.0f/255.0f alpha:1.0]];
    [self.signUpView.additionalField setTextColor:[UIColor colorWithRed:63.0f/255.0f green:63.0f/255.0f blue:64.0f/255.0f alpha:1.0]];
    
    //set keyboard type for username/email field
    [self.signUpView.usernameField setKeyboardType:UIKeyboardTypeEmailAddress];
    
    //use attributed strings to set color of placeholder text to darker
    UIColor *color = [UIColor colorWithRed:101.0f/255.0f green:101.0f/255.0f blue:101.0f/255.0f alpha:1.0];
    //we'll use the username field for collecting the email address (and we'll just set the email address from this value at login)
    self.signUpView.usernameField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Email Address" attributes:@{NSForegroundColorAttributeName: color}];
    self.signUpView.passwordField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Password" attributes:@{NSForegroundColorAttributeName: color}];
    self.signUpView.emailField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"" attributes:@{NSForegroundColorAttributeName: color}];
    self.signUpView.additionalField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Display Name" attributes:@{NSForegroundColorAttributeName: color}];
    
    //set username's delegate so we'll know it's being updated for setting the email address equal to it
    self.signUpView.usernameField.delegate = self;
    self.signUpView.passwordField.delegate = self;
    
    //set up the agreement label with links
    [self formatAgreementAttributedString];
}

#pragma mark - Attributed String Agreement label
- (void)formatAgreementAttributedString {
    
    //add the password footer label
    self.agreementLabel = [[NIAttributedLabel alloc] initWithFrame:self.signUpView.passwordField.frame];
    self.agreementLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:12];
    self.agreementLabel.textAlignment = UITextAlignmentCenter;
    self.agreementLabel.backgroundColor = [UIColor clearColor];
    self.agreementLabel.textColor = [UIColor colorWithRed:63.0f/255.0f green:63.0f/255.0f blue:64.0f/255.0f alpha:0.6];
    CALayer *agreementLayer = self.agreementLabel.layer;
    agreementLayer.shadowOpacity = 0.0f;
    
    
#if __IPHONE_OS_VERSION_MIN_REQUIRED < NIIOS_6_0
    self.agreementLabel.lineBreakMode = UILineBreakModeWordWrap;
#else
    self.agreementLabel.lineBreakMode = NSLineBreakByWordWrapping;
#endif
    self.agreementLabel.autoresizingMask = UIViewAutoresizingFlexibleDimensions;
//    label.frame = CGRectInset(self.view.bounds, 20, 20);
//    label.font = [UIFont fontWithName:@"AmericanTypewriter" size:15];
    
    self.agreementLabel.numberOfLines = 0;
    
    // Set link's color
    self.agreementLabel.linkColor = [UIColor colorWithRed:63.0f/255.0f green:63.0f/255.0f blue:64.0f/255.0f alpha:1.0];
    
    // When the user taps a link we can change the way the link text looks.
    self.agreementLabel.attributesForHighlightedLink = [NSDictionary dictionaryWithObject:(id)RGBCOLOR(10, 0, 0).CGColor forKey:(NSString *)kCTForegroundColorAttributeName];
    
    // In order to handle the events generated by the user tapping a link we must implement the
    // delegate.
    self.agreementLabel.delegate = self;
    
    // By default the label will not automatically detect links. Turning this on will cause the label
    // to pass through the text with an NSDataDetector, highlighting any detected URLs.
    self.agreementLabel.autoDetectLinks = YES;
    
    // By default links do not have underlines and this is generally accepted as the standard on iOS.
    // If, however, you do wish to show underlines, you can enable them like so:
//    self.agreementLabel.linksHaveUnderlines = YES;
    
    self.agreementLabel.text = @"By signing up, you accept Kollection's\nTerms of Service and Privacy Policy.";
    
    NSRange linkRange = [self.agreementLabel.text rangeOfString:@"Terms of Service"];
    
    // Explicitly adds a link at a given range.
    [self.agreementLabel addLink:[NSURL URLWithString:@"http://www.startakollection.com/terms"] range:linkRange];
    
    NSRange linkRange2 = [self.agreementLabel.text rangeOfString:@"Privacy Policy"];
    
    // Explicitly adds a link at a given range.
    [self.agreementLabel addLink:[NSURL URLWithString:@"http://www.startakollection.com/privacy"] range:linkRange2];
    
    [self.signUpView addSubview:self.agreementLabel];
}

//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
//    return NIIsSupportedOrientation(interfaceOrientation);
//}

#pragma mark - NIAttributedLabelDelegate

- (void)attributedLabel:(NIAttributedLabel*)attributedLabel didSelectTextCheckingResult:(NSTextCheckingResult *)result atPoint:(CGPoint)point {
    // In a later example we will show how to push a Nimbus web controller onto the navigation stack
    // rather than punt the user out of the application to Safari.
    [[UIApplication sharedApplication] openURL:result.URL];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //ensure fields are cleared whenever we return to this view
    self.signUpView.usernameField.text = @"";
    self.signUpView.passwordField.text = @"";
    self.signUpView.emailField.text = @"";
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
//    NSLog(@"%s", __FUNCTION__);
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidEndEditing:(UITextField *)textField {
    //set the email address
    if (textField == self.signUpView.usernameField) {
        //we're using the username field as our sign-up/login mechanism so also set the email address from this for correspondence as well
        self.signUpView.emailField.text = self.signUpView.usernameField.text;
    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    //set the email address
    if (textField == self.signUpView.usernameField) {
        //we're using the username field as our sign-up/login mechanism so also set the email address from this for correspondence as well
        self.signUpView.emailField.text = self.signUpView.usernameField.text;
    }
    
    return YES;
}


- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    
    //to prevent tabbing into the hidden email address field
    if (textField == self.signUpView.passwordField) {
        [self.signUpView.additionalField becomeFirstResponder];
        return YES;
    }
    
    return [super textFieldShouldReturn:textField];
} 

- (void)viewDidLayoutSubviews {
    // Set frame for elements
    [self.signUpView.dismissButton setFrame:CGRectMake(10.0f, 10.0f, 87.5f, 45.5f)];
    [self.fieldsBackground setFrame:CGRectMake(35.0f, 85.0f, 250.0f, 174.0f)];
    [self.headerBackground setFrame:CGRectMake(self.fieldsBackground.frame.origin.x + 1,
                                               self.fieldsBackground.frame.origin.y - self.headerBackground.frame.size.height + 1,
                                               self.fieldsBackground.frame.size.width - 2, 26.0f)];
    self.headerLabel.frame = self.headerBackground.frame;
    [self.navBarBackground setFrame:CGRectMake(0.0f, 0.0f, 320.0f, 44.0f)];
    [self.signUpView.logo setFrame:CGRectMake(self.navBarBackground.frame.size.width/2 - self.signUpView.logo.frame.size.width/2,
                                             self.navBarBackground.frame.size.height/2 - self.signUpView.logo.frame.size.height/2, 102.0f, 36.0f)];
    
    // Move all fields down
    float yOffset = 46.0f;
    CGRect fieldFrame = self.signUpView.usernameField.frame;
    [self.signUpView.usernameField setFrame:CGRectMake(fieldFrame.origin.x+5.0f,
                                                       fieldFrame.origin.y-32.0f,
                                                       fieldFrame.size.width-10.0f,
                                                       fieldFrame.size.height)];
    
    [self.signUpView.passwordField setFrame:CGRectMake(self.signUpView.usernameField.frame.origin.x,
                                                       self.signUpView.usernameField.frame.origin.y + yOffset,
                                                       self.signUpView.usernameField.frame.size.width,
                                                       self.signUpView.usernameField.frame.size.height)];
    
    [self.signUpView.additionalField setFrame:CGRectMake(self.signUpView.passwordField.frame.origin.x,
                                                         self.signUpView.passwordField.frame.origin.y + yOffset + 9,
                                                         self.signUpView.passwordField.frame.size.width,
                                                         self.signUpView.passwordField.frame.size.height)];
    
    //set the email field out of view as we'll just be auto-collecting it from the username
    [self.signUpView.emailField setFrame:CGRectMake(0,0,1,1)];
    
    //position the dismiss button and label
    [self.signUpView.dismissButton setFrame:CGRectMake(10, 5, 63, 33)];
    [self.cancelLabel setFrame:CGRectMake(self.signUpView.dismissButton.frame.origin.x,
                                          self.signUpView.dismissButton.frame.origin.y - 1,
                                          self.signUpView.dismissButton.frame.size.width,
                                          self.signUpView.dismissButton.frame.size.height)];
    
    //position password footer text label
    CGRect passwordFooterFrame = self.signUpView.passwordField.frame;
    [self.passwordFooterLabel setFrame:CGRectMake(passwordFooterFrame.origin.x,
                                                      passwordFooterFrame.origin.y + 20,
                                                      passwordFooterFrame.size.width,
                                                      passwordFooterFrame.size.height)];
    
    //position agreement label below signup footer text label
    CGRect agreementFrame = self.fieldsBackground.frame;
    [self.agreementLabel setFrame:CGRectMake(agreementFrame.origin.x - 5,
                                                  265,
                                                  self.fieldsBackground.frame.size.width + 10,
                                                  40)];
    
    //position sign up button below agreement label
    CGRect signInButtonFrame = self.signUpView.signUpButton.frame;
    [self.signUpView.signUpButton setFrame:CGRectMake(signInButtonFrame.origin.x,
                                                      self.agreementLabel.frame.origin.y + 40,
                                                      signInButtonFrame.size.width,
                                                      signInButtonFrame.size.height)];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
