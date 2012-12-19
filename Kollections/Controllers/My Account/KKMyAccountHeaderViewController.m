//
//  KKMyAccountHeaderViewController.m
//  Kollections
//
//  Created by Kerry Knight on 12/17/12.
//  Copyright (c) 2012 Kerry Knight. All rights reserved.
//

#import "KKMyAccountHeaderViewController.h"
#import "KKTwoLabelButton.h"

@interface KKMyAccountHeaderViewController () {
    
}

@property (nonatomic, strong) KKTwoLabelButton *koinsEarnedButton;
@property (nonatomic, strong) KKTwoLabelButton *koinsSpentButton;
@property (nonatomic, strong) KKTwoLabelButton *koinsAvailableButton;

@end

@implementation KKMyAccountHeaderViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.view.backgroundColor = [UIColor clearColor];
        //add buttons
        self.koinsEarnedButton = [[KKTwoLabelButton alloc] initWithFrame:CGRectMake(96.0f, 57.0f, 65.0f, 28.0f)];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
