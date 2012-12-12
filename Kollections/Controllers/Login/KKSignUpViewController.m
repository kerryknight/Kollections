//
//  KKSignUpViewController.m
//  Kollections
//
//  Created by Kerry Knight on 12/10/12.
//  Copyright (c) 2012 Kerry Knight. All rights reserved.
//

#import "KKSignUpViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface KKSignUpViewController ()
@property (nonatomic, strong) UIImageView *fieldsBackground;
@property (nonatomic, strong) UIImageView *navBarBackground;
@property (nonatomic, strong) UIImageView *headerBackground;
@property (nonatomic, strong) UILabel *headerLabel;
@property (nonatomic, strong) UILabel *cancelLabel;
@property (nonatomic, strong) UILabel *passwordFooterLabel;
@end

@implementation KKSignUpViewController

- (void)viewDidLoad {
//    NSLog(@"%s", __FUNCTION__);
    [super viewDidLoad];
    
    [self.signUpView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"mainBG.png"]]];
    [self.signUpView setLogo:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"titleBarLogo.png"]]];

    // Change button apperance
    [self.signUpView.dismissButton setBackgroundImage:[UIImage imageNamed:@"regularNavBarButton.png"] forState:UIControlStateNormal];
    [self.signUpView.dismissButton setBackgroundImage:[UIImage imageNamed:@"regularNavigationBarSelected.png"] forState:UIControlStateHighlighted];
    [self.signUpView.dismissButton setImage:[UIImage imageNamed:@"xxx.png"] forState:UIControlStateNormal];//so it's invisible
    [self.signUpView.dismissButton setImage:[UIImage imageNamed:@"xxx.png"] forState:UIControlStateHighlighted];//so it's invisible
    [self.signUpView.signUpButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [self.signUpView.signUpButton setTitle:@"Cancel" forState:UIControlStateHighlighted];
    
    //add a custom Cancel label to the cancel button
    self.cancelLabel = [[UILabel alloc] initWithFrame:self.signUpView.dismissButton.frame];
    self.cancelLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
    self.cancelLabel.textAlignment = UITextAlignmentCenter;
    self.cancelLabel.backgroundColor = [UIColor clearColor];
    self.cancelLabel.textColor = [UIColor colorWithRed:190.0f/255.0f green:182.0f/255.0f blue:166.0f/255.0f alpha:1.0];
    self.cancelLabel.text = @"Cancel";
    //give it some depth
    CALayer *cancelLayer = self.cancelLabel.layer;
    cancelLayer.shadowRadius = 0.4;
    cancelLayer.shadowOffset = CGSizeMake(0, -1);
    cancelLayer.shadowColor = [[UIColor colorWithRed:134.0f/255.0f green:119.0f/255.0f blue:111.0f/255.0f alpha:1.0] CGColor];
    cancelLayer.shadowOpacity = 1.0f;
    [self.view addSubview:self.cancelLabel];

    [self.signUpView.signUpButton setBackgroundImage:[UIImage imageNamed:@"signUpButtonUp.png"] forState:UIControlStateNormal];
    [self.signUpView.signUpButton setBackgroundImage:[UIImage imageNamed:@"signUpButtonDown.png"] forState:UIControlStateHighlighted];
    [self.signUpView.signUpButton setTitle:@"Sign Up" forState:UIControlStateNormal];
    [self.signUpView.signUpButton setTitle:@"Sign Up" forState:UIControlStateHighlighted];
    
    // Add background for fields
    [self setFieldsBackground:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"signUpFieldBG.png"]]];
    [self.signUpView insertSubview:self.fieldsBackground atIndex:1];
    
    // Add nav bar background
    self.navBarBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"backgroundNavBar.png"]];
    [self.signUpView addSubview:self.navBarBackground];
    [self.signUpView sendSubviewToBack:self.navBarBackground];
    
    // Add header bar background
    self.headerBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"headerBackground.png"]];
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
    
    //use attributed strings to set color of placeholder text to darker
    UIColor *color = [UIColor colorWithRed:101.0f/255.0f green:101.0f/255.0f blue:101.0f/255.0f alpha:1.0];
    self.signUpView.usernameField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Username" attributes:@{NSForegroundColorAttributeName: color}];
    self.signUpView.passwordField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Password" attributes:@{NSForegroundColorAttributeName: color}];
    self.signUpView.emailField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Email" attributes:@{NSForegroundColorAttributeName: color}];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //ensure fields are cleared whenever we return to this view
    self.signUpView.usernameField.text = @"";
    self.signUpView.passwordField.text = @"";
    self.signUpView.emailField.text = @"";
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
    float yOffset = 0.0f;
    CGRect fieldFrame = self.signUpView.usernameField.frame;
    [self.signUpView.usernameField setFrame:CGRectMake(fieldFrame.origin.x+5.0f,
                                                       fieldFrame.origin.y-60.0f+yOffset,
                                                       fieldFrame.size.width-10.0f,
                                                       fieldFrame.size.height)];
    yOffset += fieldFrame.size.height - 3;
    
    [self.signUpView.passwordField setFrame:CGRectMake(fieldFrame.origin.x+5.0f,
                                                       fieldFrame.origin.y-50.0f+yOffset,
                                                       fieldFrame.size.width-10.0f,
                                                       fieldFrame.size.height)];
    yOffset += fieldFrame.size.height - 1;
    
    [self.signUpView.emailField setFrame:CGRectMake(fieldFrame.origin.x+5.0f,
                                                    fieldFrame.origin.y-40.0f+yOffset,
                                                    fieldFrame.size.width-10.0f,
                                                    fieldFrame.size.height)];
    
    CGRect signInButtonFrame = self.signUpView.signUpButton.frame;
    [self.signUpView.signUpButton setFrame:CGRectMake(signInButtonFrame.origin.x,
                                                    self.fieldsBackground.frame.origin.y + self.fieldsBackground.frame.size.height + 3,
                                                    self.signUpView.signUpButton.frame.size.width,
                                                    signInButtonFrame.size.height)];
    
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
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
