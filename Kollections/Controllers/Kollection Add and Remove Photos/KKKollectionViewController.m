//
//  KKKollectionViewController.m
//  Kollections
//
//  Created by Kerry Knight on 1/30/13.
//  Copyright (c) 2013 Kerry Knight. All rights reserved.
//

#import "KKKollectionViewController.h"
#import "KKToolbarButton.h"

@interface KKKollectionViewController () {
    
}
@property (nonatomic, strong) KKKollectionTableViewController *tableView;
@property (nonatomic, strong) KKToolbarButton *editButton;
@property (nonatomic, strong) KKToolbarButton *backButton;
@property (nonatomic, strong) NSMutableArray *subjectList;
@end

@implementation KKKollectionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"kkTitleBarLogo.png"]];
    
    self.tableView = [[KKKollectionTableViewController alloc] initWithKollection:self.kollection];
    self.tableView.view.frame = self.view.bounds;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView.view];
    
    //hide default back button as it's not styled like I want
    self.navigationItem.hidesBackButton = YES;
    //set up our toolbar buttons
    [self configureBackButton];
    [self configureEditButton];
}

- (void)viewWillAppear:(BOOL)animated {
    //    NSLog(@"%s", __FUNCTION__);
    [super viewWillAppear:animated];
    self.backButton.hidden = NO;//this is hidden if we navigate away
    self.editButton.hidden = NO;//this is hidden if we navigate away
}

- (void)viewWillDisappear:(BOOL)animated {
    //    NSLog(@"%s", __FUNCTION__);
    [super viewWillDisappear:animated];
    self.backButton.hidden = YES;
    self.editButton.hidden = YES;
}

#pragma mark - KKEditKollectionViewControllerDelegate methods
- (void)editKollectionViewControllerDidEditKollectionWithInfo:(NSDictionary *)userInfo atIndex:(NSUInteger)index {
    //    NSLog(@"%s", __FUNCTION__);
    self.kollection = (PFObject*)userInfo[@"kollection"];
    self.subjectList = (NSMutableArray*)userInfo[@"subjects"];
    self.tableView.subjectList = self.subjectList;
    
    if (!self.tableView.isNetworkBusy) {
        self.tableView.isNetworkBusy = YES;
        //refresh our object and reload our table once complete
        [self.kollection refreshInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            if (!error) {
                NSLog(@"kollection subjects refreshed");
                self.kollection = object;
                self.tableView.isNetworkBusy = NO;
                
                //now that we have our subjects and all our photos, group them together and reload our table rows
                [self.tableView createSubjectsWithPhotosArrayWithCompletion:^(NSArray *objects) {
                    if (objects) {
                        self.tableView.subjectsWithPhotos = [objects mutableCopy];
                        
                        //reload our table in case any data has changed
                        [self.tableView.tableView reloadData];
                    }
                }];
            }
            
        }];
    }
    
    //reload cover photo
    [self.tableView reloadCoverPhoto];
}

#pragma mark - KKKollectionTableViewControllerDelegate
- (void) kollectionTableViewControllerDidLoadSubjects:(NSArray*)subjects {
    self.subjectList = [subjects mutableCopy];
}

#pragma mark - Custom Methods
//our custom back button
- (void)configureBackButton {
    //    NSLog(@"%s", __FUNCTION__);
    //add button to view
    self.backButton = [[KKToolbarButton alloc] initWithFrame:kKKBarButtonItemLeftFrame isBackButton:YES andTitle:@"Back"];
    [self.backButton addTarget:self action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationController.navigationBar addSubview:self.backButton];
}

- (void)backButtonAction:(id)sender {
    //    NSLog(@"%s", __FUNCTION__);
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)editButtonAction:(id)sender {
    //    NSLog(@"%s", __FUNCTION__);
    
    KKEditKollectionViewController *editKollectionViewController = [[KKEditKollectionViewController alloc] init];
    editKollectionViewController.delegate = self;
    editKollectionViewController.kollection = self.kollection;
    editKollectionViewController.subjectsArrayToCompareAgainst = self.subjectList;
    [self.navigationController pushViewController:editKollectionViewController animated:YES];
}

- (void)configureEditButton {
    //    NSLog(@"%s", __FUNCTION__);
    //add button to view
    self.editButton = [[KKToolbarButton alloc] initWithFrame:kKKBarButtonItemRightFrame isBackButton:NO andTitle:@"Edit"];
    [self.editButton addTarget:self action:@selector(editButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationController.navigationBar addSubview:self.editButton];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
