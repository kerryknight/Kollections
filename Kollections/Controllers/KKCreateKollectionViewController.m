//
//  KKCreateKollectionViewController.m
//  Kollections
//
//  Created by Kerry Knight on 1/9/13.
//  Copyright (c) 2013 Kerry Knight. All rights reserved.
//

#import "KKCreateKollectionViewController.h"
#import "KKKollectionSubjectsTableViewController.h"
#import "KKToolbarButton.h"

@interface KKCreateKollectionViewController () {
    
}
@property (nonatomic, strong) KKKollectionSetupTableViewController *tableView;
/// The kollection displayed in the view; redeclare so we can edit locally
@property (nonatomic, strong, readwrite) PFObject *kollection;
@property (nonatomic, strong) KKToolbarButton *backButton;
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
    
    self.tableView.tableObjects = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"NewPublicKollectionSetupItems" ofType:@"plist"]];
    
    //give our table view a kollection object to work with
    self.tableView.kollection = [PFObject objectWithClassName:kKKKollectionClassKey];
    self.tableView.kollectionSetupType = KKKollectionSetupTypeNew;
    self.tableView.shouldInitializeAsPrivate = self.shouldInitializeAsPrivate;//determine what way the segment should be set to to start
    
    [self.view addSubview:self.tableView.view];
    
    //remove any outstanding observers
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //attach notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissViewWithNewKollectionNotification:) name:KKKollectionSetupTableDidCreateKollectionNotification object:nil];
    
    //add toolbar buttons
    self.navigationItem.hidesBackButton = YES;//hide default back button as it's not styled like I want
    [self configureBackButton];//add our custom back button
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

-(void)dealloc {
    //remove observers
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KKKollectionSetupTableDidCreateKollectionNotification object:nil];
}

#pragma mark - UIViewController

- (void)viewWillAppear:(BOOL)animated {
//    NSLog(@"%s", __FUNCTION__);
    [super viewWillAppear:animated];
    self.backButton.hidden = NO;//this is hidden if we navigate away
}

- (void)viewWillDisappear:(BOOL)animated {
//    NSLog(@"%s", __FUNCTION__);
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
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)dismissViewWithNewKollectionNotification:(NSNotification*)notification {
    //    NSLog(@"%s", __FUNCTION__);
    NSDictionary *userInfo = notification.userInfo;
    PFObject *newKollection = (PFObject*)userInfo[@"kollection"];
    [self.delegate createKollectionViewControllerDidCreateNewKollection:newKollection];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - KKKollectionSetupTableViewController delegate
- (void)pushSubjectsViewControllerWithKollection:(NSArray *)subjectList {
//    NSLog(@"%s %@", __FUNCTION__, kollection);
    
    KKKollectionSubjectsTableViewController *subjectsTableVC = [[KKKollectionSubjectsTableViewController alloc] init];
    //pass our subjectList in
    NSArray *subjects = subjectList;
    subjectsTableVC.subjects = [NSMutableArray arrayWithArray:subjects];
    
    [self.navigationController pushViewController:subjectsTableVC animated:YES];
}

- (void)setupTableViewDidSelectRowAtIndexPath:(NSIndexPath*)indexPath {
//    NSLog(@"%s %@", __FUNCTION__, indexPath);
    
    [self.view endEditing:YES];
    
    //tell the superclass table to set the insets back to default 0 and scroll
    [self.tableView resetTableContentInsetsWithIndexPath:indexPath];
}

@end
