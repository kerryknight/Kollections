//
//  KKMyAccountHeaderViewController.h
//  Kollections
//
//  Created by Kerry Knight on 12/17/12.
//  Copyright (c) 2012 Kerry Knight. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KKSideScrollToolBarViewController.h"

@interface KKMyAccountHeaderViewController : UIViewController {
    
}

@property (nonatomic, strong) KKSideScrollToolBarViewController *toolBarViewController;

@property (weak, nonatomic) IBOutlet UIButton *koinsEarnedButton;
@property (weak, nonatomic) IBOutlet UIButton *koinsSpentButton;
@property (weak, nonatomic) IBOutlet UIButton *koinsAvailableButton;
@property (weak, nonatomic) IBOutlet UILabel *displayNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *followerCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *followingCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *kollectionCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *submissionCountLabel;
@property (weak, nonatomic) IBOutlet UIButton *followersButton;
@property (weak, nonatomic) IBOutlet UIButton *followingButton;
@property (weak, nonatomic) IBOutlet UIButton *kollectionsButton;
@property (weak, nonatomic) IBOutlet UIButton *submissionsButton;

@end
 