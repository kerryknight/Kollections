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
#import "BlockAlertView.h"

@interface KKEditKollectionViewController () {
    
}
@property (nonatomic, strong) KKKollectionSetupTableViewController *tableView;
@property (nonatomic, strong) KKToolbarButton *backButton;
@property (nonatomic, strong) KKToolbarButton *deleteButton;
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
    
    //give our table view the passed in kollection object to work with
    self.tableView.kollection = self.kollection;
    self.tableView.kollectionSetupType = KKKollectionSetupTypeEdit;
    
    [self.view addSubview:self.tableView.view];
    
    //remove any outstanding observers
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //attach notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissViewWithEditedKollectionNotification:) name:KKKollectionSetupTableDidEditKollectionNotification object:nil];
    
    //add toolbar buttons
    self.navigationItem.hidesBackButton = YES;//hide default back button as it's not styled like I want
    [self configureBackButton];//add our custom back button
    [self configureDeleteButton];//add the delete button
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KKKollectionSetupTableDidEditKollectionNotification object:nil];
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
    self.deleteButton.hidden = YES;
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
    [self.navigationController popViewControllerAnimated:YES];
}

//our custom delete button
- (void)configureDeleteButton {
    //    NSLog(@"%s", __FUNCTION__);
    //add button to view
    self.deleteButton = [[KKToolbarButton alloc] initWithFrame:kKKBarButtonItemRightFrame isBackButton:NO andTitle:@"Delete"];
    [self.deleteButton addTarget:self action:@selector(deleteButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationController.navigationBar addSubview:self.deleteButton];
    self.deleteButton.hidden = YES;//default to hidden
    
    //allow the kollection's owner to fully delete the kollection
    PFUser *kollectionOwner = (PFUser*)self.kollection[kKKKollectionUserKey];
    if ([kollectionOwner.objectId isEqualToString:[PFUser currentUser].objectId]) {
        //we own this kollection so enable the delete button
        self.deleteButton.hidden = NO;
    }
}

- (void)deleteButtonAction:(id)sender {
    //    NSLog(@"%s", __FUNCTION__);
    
    [self showAlert:sender];
}

- (void)showAlert:(id)sender {
    BlockAlertView *alert = [BlockAlertView alertWithTitle:@"Are you sure?" message:@"Deleting a kollection is permanent and can't be reversed."];
    
    [alert setCancelButtonWithTitle:@"Cancel" block:nil];
    [alert setDestructiveButtonWithTitle:@"Delete" block:^{
        //delete the kollection
        //show hud
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view.superview animated:NO];
        [hud setDimBackground:YES];
        [hud setLabelText:@"Deleting Kollection"];
        
        PFQuery *subjectQuery = [PFQuery queryWithClassName:kKKSubjectClassKey];
        [subjectQuery whereKey:kKKSubjectKollectionKey equalTo:self.kollection];
        [subjectQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                for (PFObject *subject in objects) {
                    //delete each subject eventually
                    [subject deleteEventually];
                }
                
                //need to update our cache
            }
        }];
        
        //now we can delete the kollection since we've successfully queued our subjects for deletion
        [self.kollection deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                //pop nav controller and hide hud and refresh tables
                [[NSNotificationCenter defaultCenter] postNotificationName:@"MyAccountViewRefreshTableByLoadingObjects" object:nil];
                [self.navigationController popToRootViewControllerAnimated:YES];
                [MBProgressHUD hideHUDForView:self.view.superview animated:YES];
                
                //need to update our cache
            } else {
                [MBProgressHUD hideHUDForView:self.view.superview animated:YES];
            }
        }];
    }];
    
    [alert show];
}

- (void)dismissViewWithEditedKollectionNotification:(NSNotification*)notification {
//    NSLog(@"%s", __FUNCTION__);
    NSDictionary *userInfo = notification.userInfo;
    PFObject *editedKollection = (PFObject*)userInfo[@"kollection"];
    [self.delegate editKollectionViewControllerDidEditKollection:editedKollection atIndex:self.kollectionToLoadIndex];
    [self.navigationController popViewControllerAnimated:YES];
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
