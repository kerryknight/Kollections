//
//  KKLogInViewController.m
//  Kollections
//
//  Created by Kerry Knight on 12/10/12.
//  Copyright (c) 2012 Kerry Knight. All rights reserved.
//

#import "KKLogInViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface KKLogInViewController () {
    
}

@property (nonatomic, strong) UIImageView *fieldsBackground;
@property (nonatomic, strong) UIImageView *navBarBackground;
@property (nonatomic, strong) UIImageView *headerBackground;
@property (nonatomic, strong) UILabel *headerLabel;
@property (nonatomic, strong) UILabel *otherLoginsLabel;
@property (nonatomic, strong) UILabel *signupLabel;

@end

@implementation KKLogInViewController

- (void)viewDidLoad {
//    NSLog(@"%s", __FUNCTION__);
    [super viewDidLoad];
    
    [self.logInView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"kkMainBG.png"]]];
    [self.logInView setLogo:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"kkTitleBarLogo.png"]]];
    
    // Set buttons appearance
    [self.logInView.passwordForgottenButton setBackgroundImage:[UIImage imageNamed:@"xxx.png"] forState:UIControlStateNormal];//fake; so it's invisible
    [self.logInView.passwordForgottenButton setBackgroundImage:[UIImage imageNamed:@"xxx.png"] forState:UIControlStateHighlighted];//fake; so it's invisible
    [self.logInView.passwordForgottenButton setTitle:@"Forgot Password?" forState:UIControlStateNormal];
    [self.logInView.passwordForgottenButton setTitle:@"Forgot Password?" forState:UIControlStateHighlighted];
    
    [self.logInView.signUpButton setBackgroundImage:[UIImage imageNamed:@"kkSignUpButtonUp.png"] forState:UIControlStateNormal];
    [self.logInView.signUpButton setBackgroundImage:[UIImage imageNamed:@"kkSignUpButtonDown.png"] forState:UIControlStateHighlighted];
    [self.logInView.signUpButton setTitle:@"Sign Up" forState:UIControlStateNormal];
    [self.logInView.signUpButton setTitle:@"Sign Up" forState:UIControlStateHighlighted];
    
    [self.logInView.logInButton setBackgroundImage:[UIImage imageNamed:@"kkLoginButtonUp.png"] forState:UIControlStateNormal];
    [self.logInView.logInButton setBackgroundImage:[UIImage imageNamed:@"kkLoginButtonDown.png"] forState:UIControlStateHighlighted];
    [self.logInView.logInButton setTitle:@"Log in" forState:UIControlStateNormal];
    [self.logInView.logInButton setTitle:@"Log in" forState:UIControlStateHighlighted];
    
    // Add login field background
    self.fieldsBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"kkLoginFieldBG.png"]];
    [self.logInView addSubview:self.fieldsBackground];
    [self.logInView sendSubviewToBack:self.fieldsBackground];
    [self.logInView sendSubviewToBack:self.logInView.passwordForgottenButton];
    
    // Add nav bar background
    self.navBarBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"kkBackgroundNavBar.png"]]; 
    [self.logInView addSubview:self.navBarBackground];
    [self.logInView sendSubviewToBack:self.navBarBackground];
    
    // Add header bar background
    self.headerBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"kkHeaderBackground.png"]];
    [self.logInView addSubview:self.headerBackground];
    [self.logInView sendSubviewToBack:self.headerBackground];
    
    //add the Log in header label
    self.headerLabel = [[UILabel alloc] initWithFrame:self.headerBackground.frame];
    self.headerLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:17];
    self.headerLabel.textAlignment = UITextAlignmentLeft;
    self.headerLabel.backgroundColor = [UIColor clearColor];
    self.headerLabel.textColor = [UIColor colorWithRed:63.0f/255.0f green:63.0f/255.0f blue:64.0f/255.0f alpha:1.0];
    self.headerLabel.text = @" Please log in:";
    CALayer *headerLayer = self.headerLabel.layer;
    headerLayer.shadowRadius = 0.5;
    headerLayer.shadowOffset = CGSizeMake(0, -1);
    headerLayer.shadowColor = [[UIColor whiteColor] CGColor];
    headerLayer.shadowOpacity = 1.0f;
    [self.logInView addSubview:self.headerLabel];
    
    //was having trouble modifying pre-defined small labels so creating my own here
    //add the Log in header label
    self.otherLoginsLabel = [[UILabel alloc] initWithFrame:self.logInView.externalLogInLabel.frame];
    self.otherLoginsLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:13];
    self.otherLoginsLabel.textAlignment = UITextAlignmentCenter;
    self.otherLoginsLabel.backgroundColor = [UIColor clearColor];
    self.otherLoginsLabel.textColor = [UIColor colorWithRed:63.0f/255.0f green:63.0f/255.0f blue:64.0f/255.0f alpha:1.0];
    self.otherLoginsLabel.text = @"You can also log in with:";
    [self.logInView addSubview:self.otherLoginsLabel];
    
    //add the Log in header label
    self.signupLabel = [[UILabel alloc] initWithFrame:self.logInView.signUpLabel.frame];
    self.signupLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:13];
    self.signupLabel.textAlignment = UITextAlignmentCenter;
    self.signupLabel.backgroundColor = [UIColor clearColor];
    self.signupLabel.textColor = [UIColor colorWithRed:63.0f/255.0f green:63.0f/255.0f blue:64.0f/255.0f alpha:1.0];
    self.signupLabel.text = @"Don't have an account yet?";
    [self.logInView addSubview:self.signupLabel];
    
    // Set field text color
    [self.logInView.usernameField setTextColor:[UIColor whiteColor]];
    [self.logInView.passwordField setTextColor:[UIColor whiteColor]];
    [self.logInView.usernameField setTextColor:[UIColor colorWithRed:63.0f/255.0f green:63.0f/255.0f blue:64.0f/255.0f alpha:1.0]];
    [self.logInView.passwordField setTextColor:[UIColor colorWithRed:63.0f/255.0f green:63.0f/255.0f blue:64.0f/255.0f alpha:1.0]];
    
    //set keyboard type for username/email field
    [self.logInView.usernameField setKeyboardType:UIKeyboardTypeEmailAddress];
    
    //hide pre-defined labels
    self.logInView.externalLogInLabel.hidden = YES;
    self.logInView.signUpLabel.hidden = YES;
    
    //use attributed strings to set color of placeholder text to darker
    UIColor *color = [UIColor colorWithRed:101.0f/255.0f green:101.0f/255.0f blue:101.0f/255.0f alpha:1.0];
    //username == email address for logging in
    self.logInView.usernameField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Email Address" attributes:@{NSForegroundColorAttributeName: color}];
    self.logInView.passwordField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Password" attributes:@{NSForegroundColorAttributeName: color}];
    self.logInView.passwordForgottenButton.titleLabel.textColor = [UIColor darkGrayColor];
    self.logInView.passwordForgottenButton.titleLabel.textAlignment = UITextAlignmentRight;
    self.logInView.passwordForgottenButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
    CALayer *forgotLayer = self.logInView.passwordForgottenButton.titleLabel.layer;
    forgotLayer.shadowRadius = 0.4;
    forgotLayer.shadowOffset = CGSizeMake(0, -1);
    forgotLayer.shadowOpacity = 0.6f;
    
    // Remove text shadows
    CALayer *layer = self.logInView.usernameField.layer;
    layer.shadowOpacity = 0.0f;
    layer = self.logInView.passwordField.layer;
    layer.shadowOpacity = 0.0f;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidLayoutSubviews {
    //    NSLog(@"%s", __FUNCTION__);
    // Set frame for elements
    [self.logInView.signUpButton setFrame:CGRectMake(35.0f, 385.0f, 245.0f, 44.0f)];
    self.signupLabel.frame = self.logInView.signUpLabel.frame;
    [self.fieldsBackground setFrame:CGRectMake(35.0f, 85.0f, 250.0f, 100.0f)];
    [self.headerBackground setFrame:CGRectMake(self.fieldsBackground.frame.origin.x + 1,
                                               self.fieldsBackground.frame.origin.y - self.headerBackground.frame.size.height + 1,
                                               self.fieldsBackground.frame.size.width - 2, 26.0f)];
    self.headerLabel.frame = self.headerBackground.frame;
    [self.navBarBackground setFrame:CGRectMake(0.0f, 0.0f, 320.0f, 44.0f)];
    
    //position the "Kollections" logo above brown nav bar graphic
    [self.logInView.logo setFrame:CGRectMake(self.navBarBackground.frame.size.width/2 - self.logInView.logo.frame.size.width/2,
                                             self.navBarBackground.frame.size.height/2 - self.logInView.logo.frame.size.height/2, 102.0f, 36.0f)];
    
    //position Log in button
    CGRect loginButtonFrame = self.logInView.logInButton.frame;
    [self.logInView.logInButton setFrame:CGRectMake(loginButtonFrame.origin.x,
                                                    self.fieldsBackground.frame.origin.y + self.fieldsBackground.frame.size.height + 3,
                                                    loginButtonFrame.size.width,
                                                    loginButtonFrame.size.height)];
    
    //position forgot password button just below Log in button
    [self.logInView.passwordForgottenButton setFrame:CGRectMake(self.logInView.logInButton.frame.origin.x + self.logInView.logInButton.frame.size.width - 120.0f,
                                                                self.logInView.logInButton.frame.origin.y + self.logInView.logInButton.frame.size.height,
                                                                120.0f,
                                                                20.0f)];
    
    // Move all fields down
    float yOffset = 0.0f;
    CGRect fieldFrame = self.logInView.usernameField.frame;
    [self.logInView.usernameField setFrame:CGRectMake(fieldFrame.origin.x+5.0f,
                                                      fieldFrame.origin.y-8.0f+yOffset,
                                                      fieldFrame.size.width-10.0f,
                                                      fieldFrame.size.height)];
    yOffset += fieldFrame.size.height - 10;
    
    [self.logInView.passwordField setFrame:CGRectMake(fieldFrame.origin.x+5.0f,
                                                      fieldFrame.origin.y+0.0f+yOffset,
                                                      fieldFrame.size.width-10.0f,
                                                      fieldFrame.size.height)];
    
    //move other login label and other login buttons down a little bit
    CGRect otherLoginFrame = self.logInView.externalLogInLabel.frame;
    [self.otherLoginsLabel setFrame:CGRectMake(otherLoginFrame.origin.x,
                                               otherLoginFrame.origin.y + 10.0f,
                                               otherLoginFrame.size.width,
                                               otherLoginFrame.size.height)];
    
    //fb button
    CGRect fbButtonFrame = self.logInView.facebookButton.frame;
    [self.logInView.facebookButton setFrame:CGRectMake(fbButtonFrame.origin.x,
                                                       fbButtonFrame.origin.y + 10.0f,
                                                       fbButtonFrame.size.width,
                                                       fbButtonFrame.size.height)];
    
    //twitter button
    CGRect twitterButtonFrame = self.logInView.twitterButton.frame;
    [self.logInView.twitterButton setFrame:CGRectMake(twitterButtonFrame.origin.x,
                                                      twitterButtonFrame.origin.y + 10.0f,
                                                      twitterButtonFrame.size.width,
                                                      twitterButtonFrame.size.height)];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
