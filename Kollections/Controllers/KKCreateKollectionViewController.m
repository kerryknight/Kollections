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
/// The kollection displayed in the view; redeclare so we can edit locally
@property (nonatomic, strong, readwrite) PFObject *kollection;
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
    
    self.tableView.tableObjects = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"PublicKollectionSetupItems" ofType:@"plist"]];
    
    [self.view addSubview:self.tableView.view];
    
    //attach notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissView) name:KKKollectionSetupTableDidCreateKollectionNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - KKKollectionSetupTableViewController delegate
- (void)setupTableViewDidSelectRowAtIndexPath:(NSIndexPath*)indexPath {
//    NSLog(@"%s %@", __FUNCTION__, indexPath);
    
    [self.view endEditing:YES];
    
    //tell the superclass table to set the insets back to default 0 and scroll
    [self.tableView resetTableContentInsetsWithIndexPath:indexPath];
}

- (void)dismissView {
//    NSLog(@"%s", __FUNCTION__);
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KKKollectionSetupTableDidCreateKollectionNotification object:nil];
}

@end
