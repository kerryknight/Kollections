//
//  KKEditKollectionViewController.m
//  Kollections
//
//  Editd by Kerry Knight on 1/9/13.
//  Copyright (c) 2013 Kerry Knight. All rights reserved.
//

#import "KKEditKollectionViewController.h"
#import "KKKollectionSubjectsTableViewController.h"
#import "KKToolbarButton.h"

@interface KKEditKollectionViewController () {
    
}
@property (nonatomic, strong) KKKollectionSetupTableViewController *tableView;
@property (nonatomic, strong) KKToolbarButton *backButton;
@end

@implementation KKEditKollectionViewController

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
    
    self.tableView.tableObjects = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"EditPublicKollectionSetupItems" ofType:@"plist"]];
    NSLog(@"KKEditKollectionViewController edit here if slightly different questions are ever asked once a kollection has already been created");
    
    [self.view addSubview:self.tableView.view];
    
    //attach notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissViewWithNewKollectionNotification:) name:KKKollectionSetupTableDidEditKollectionNotification object:nil];
    
    //add toolbar buttons
    self.navigationItem.hidesBackButton = YES;//hide default back button as it's not styled like I want
    [self configureBackButton];//add our custom back button
    
    //give our table view the passed in kollection object to work with
    self.tableView.kollection = self.kollection;
    self.tableView.kollectionSetupType = KKKollectionSetupTypeEdit;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (void)dismissViewWithNewKollectionNotification:(NSNotification*)notification {
//    NSLog(@"%s", __FUNCTION__);
    NSDictionary *userInfo = notification.userInfo;
    PFObject *editedKollection = (PFObject*)userInfo[@"kollection"];
    [self.delegate editKollectionViewControllerDidEditKollection:editedKollection atIndex:self.kollectionToLoadIndex];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)viewDidUnload {
//    NSLog(@"%s", __FUNCTION__);
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KKKollectionSetupTableDidEditKollectionNotification object:nil];
}

@end
