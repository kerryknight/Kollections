//
//  KKCreateKollectionViewController.m
//  Kollections
//
//  Created by Kerry Knight on 1/9/13.
//  Copyright (c) 2013 Kerry Knight. All rights reserved.
//

#import "KKCreateKollectionViewController.h"

@interface KKCreateKollectionViewController () {
    
}
@property (nonatomic, strong) KKKollectionSetupTableViewController *tableView;
@end

@implementation KKCreateKollectionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
//    NSLog(@"%s", __FUNCTION__);
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"kkTitleBarLogo.png"]];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"kkMainBG.png"]]];//set background image
    
    self.tableView = [[KKKollectionSetupTableViewController alloc] initWithStyle:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.tableObjects = [@[@"one", @"two", @"three", @"four", @"five", @"six", @"seven"] mutableCopy];
    [self.view addSubview:self.tableView.view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - KKKollectionSetupTableViewController delegate
- (void)setupTableViewDidSelectRowAtIndexPath:(NSIndexPath*)indexPath {
    NSLog(@"%s %@", __FUNCTION__, indexPath);
}

@end
