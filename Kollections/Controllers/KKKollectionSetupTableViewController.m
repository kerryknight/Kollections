//
//  KKKollectionSetupTableViewController.m
//  Kollections
//
//  Created by Kerry Knight on 1/9/13.
//  Copyright (c) 2013 Kerry Knight. All rights reserved.
//

#import "KKKollectionSetupTableViewController.h"
#import "MBProgressHUD.h"
#import "KKConstants.h"
#import "BlockAlertView.h"
#import "BlockPickerActionSheet.h"
//custom cells
#import "KKSetupTableShareCell.h"
#import "KKSetupTableBaseCell.h"
#import "KKSetupTableLongStringCell.h"
#import "KKSetupTableSegmentCell.h"
#import "KKSetupTableNumberCell.h"
#import "KKSetupTableNavigateCell.h"
#import "KKSetupTableCategoryCell.h"

@interface KKKollectionSetupTableViewController () {
    BOOL shouldShareNewKollectionToFacebook;
}
/// The kollection displayed in the view; redeclare so we can edit locally
@property (nonatomic, strong, readwrite) PFObject *kollection;
@end

@implementation KKKollectionSetupTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
//    NSLog(@"%s", __FUNCTION__);
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    self.view.backgroundColor = [UIColor clearColor];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    //set the frame of the table view using the window height - navbar height - tabbar height
    id appDelegate = [[UIApplication sharedApplication] delegate];
    UIWindow *window = [appDelegate window];
    float height = window.frame.size.height -
                   self.navigationController.navigationBar.frame.size.height -
                   self.tabBarController.tabBar.frame.size.height - 20;
    
    self.view.frame = CGRectMake(0, 0, window.frame.size.width, height);
    
    //initialize kollections
    self.kollection = [PFObject objectWithClassName:kKKKollectionClassKey];
    
    //add notifications
    //this notification is called whenever a user edits a kollection and then adds/updates the subjects array for that kollection
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subjectListUpdated:) name:@"SetupTableViewControllerSubjectListUpdated" object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
//    NSLog(@"%s", __FUNCTION__);
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"SetupTableViewControllerSubjectListUpdated" object:nil];
}

#define kSETUP_SAVE_NEW_KOLLECTION @"Save Kollection"

#pragma mark - Custom Methods
- (void)submit:(id)sender {
//    NSLog(@"%s", __FUNCTION__);
    //dismiss any keyboard
    [self.view endEditing:YES];
    
    UIButton *button = (UIButton*)sender;
    if ([button.titleLabel.text isEqualToString:kSETUP_SAVE_NEW_KOLLECTION]) {
        
        // Show HUD view
        [MBProgressHUD showHUDAddedTo:self.view.superview animated:YES];
        
        //we're adding a new kollection instead of updating an old one
        [self.kollection setObject:[PFUser currentUser] forKey:kKKKollectionUserKey];
        
        //check if we've filled everything in
        BOOL infoIsGood = [self isRequiredInfoFilledIn];
        
        if (!infoIsGood) {
            return;//exit without continuing if we still need to fill stuff in
        }
        
        NSLog(@"should share to fb = %i", shouldShareNewKollectionToFacebook);
        //UPDATE need to determine if public/private before setting ACL here
        
        // kollections are public, but may only be modified by the user who uploaded them
        PFACL *kollectionACL = [PFACL ACLWithUser:[PFUser currentUser]];
        [kollectionACL setPublicReadAccess:YES];
        self.kollection.ACL = kollectionACL;
        
        //save on main thread as don't want to dismiss the view unless saved successfully
        
        [self.kollection saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                //save succeeded
                NSLog(@"save succeeded; dismiss view");
                [[NSNotificationCenter defaultCenter] postNotificationName:KKKollectionSetupTableDidCreateKollectionNotification object:nil];
            } else {
                NSString *message = [NSString stringWithFormat:@"%@", error];
                UIAlertView *alertView = [[UIAlertView alloc]
                                          initWithTitle:@"Error Creating Kollection"
                                          message:message delegate:nil
                                          cancelButtonTitle:@"OK" otherButtonTitles:nil];
                
                [alertView show];
            }
            
            // Remove hud
            [MBProgressHUD hideHUDForView:self.view.superview animated:YES];
        }];
        
    }
}

- (BOOL)isRequiredInfoFilledIn {
    //check if we've set a category, exit if not
    if (!self.kollection[kKKKollectionCategoryKey]) {
        alertMessage(@"Please select a category for your kollection.");
        return NO;
    }
    
    //check if we've set a category, exit if not
    if (!self.kollection[kKKKollectionTitleKey]) {
        alertMessage(@"Please enter a title for your kollection.");
        return NO;
    }
    
    return YES;
}

- (void)dismissView {
    NSLog(@"%s", __FUNCTION__);
}

- (IBAction)segmentedControlSegmentChosen:(id)sender {
    NSLog(@"%s", __FUNCTION__);
    //get the cell that was touched
    UISegmentedControl *segmentBar = sender;
    KKSetupTableSegmentCell *cell = (KKSetupTableSegmentCell*)[[segmentBar superview] superview];
    
    //get the indexpath of the cell that was touched and store in our table items array the response so we can keep track throughout the question process or our answers
    NSIndexPath *pathOfSelectedCellRow = [self.tableView indexPathForCell:cell];
    //fill in entry label text from kollection property if available, if not, check for historical response
    NSString *columnName = (NSString*)self.tableObjects[pathOfSelectedCellRow.row - 1][@"objectColumn"];
    BOOL isPrivateValue = NO;
    //set our isPrivate property based on what we've just set the selected segment index to
    if ([cell.segmentedControl selectedSegmentIndex] == 1) {
        isPrivateValue = YES;
    } else {
        isPrivateValue = NO;
    }
    
    //key-value coding only accepts objects so wrap the bool in an nsnumber
    [self.kollection setObject:[NSNumber numberWithBool:isPrivateValue] forKey:columnName];
}

- (IBAction)facebookSharingToggled:(id)sender {
//    NSLog(@"%s", __FUNCTION__);
    //get the cell where the button was touched
    UIButton *button = sender;
    KKSetupTableShareCell *cell = (KKSetupTableShareCell*)[[button superview] superview];
    
    BOOL selected = shouldShareNewKollectionToFacebook;
    shouldShareNewKollectionToFacebook = !selected;//take the opposite
    shouldShareNewKollectionToFacebook ? [cell.fbButton setSelected:YES] : [cell.fbButton setSelected:NO];
}

- (void)subjectListUpdated:(NSNotification*)notification {
//    NSLog(@"%s\n", __FUNCTION__);
    NSDictionary *notificationInfo = [notification userInfo];
    self.kollection[kKKKollectionSubjectsKey] = notificationInfo[kKKKollectionSubjectsKey];
    [self.tableView reloadData];
}

#pragma mark - AlertView and ActionSheet methods
- (void)queryParseForCategoryList {
//    NSLog(@"%s\n", __FUNCTION__);
    //put up a spinner to prevent further progress until our query is finished as we can't show the picker view until
    //we have our list of categories to show and we don't want the user doing anything else once they kick off the query
    // Show HUD view
    [MBProgressHUD showHUDAddedTo:self.view.superview animated:YES];
    
    //create a mutable array to add the returned objects to
    NSMutableArray *categories = [NSMutableArray new];
    
    //create the query for the category list
    PFQuery *queryAllCategories = [PFQuery queryWithClassName:kKKCategoryClassKey];//get all rows in Category class
    queryAllCategories.maxCacheAge = (60 * 60)/*1hr*/ * 24/*hrs/day*/ * 5/*days*/; //expire the cache in 5 days and requery
    [queryAllCategories orderByAscending:kKKCategoryTitleKey];
    [queryAllCategories setCachePolicy:kPFCachePolicyCacheElseNetwork];
    
    //kick off the query
    [queryAllCategories findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            if (objects.count > 0) {
                for (PFObject *object in objects) {
                    [categories addObject:object];
                }
            }
            
            //load UIPickerActionSheet view with our list of categories
            [self showPickerActionSheetWithPickerList:(NSArray*)categories];
        } else {
            //clear the cache in event of error so we can try again
            [queryAllCategories clearCachedResult];
        }
        
        //dismiss spinner
        [MBProgressHUD hideHUDForView:self.view.superview animated:YES];
    }];
}

- (IBAction)showAlert:(id)sender {
    BlockAlertView *alert = [BlockAlertView alertWithTitle:@"Alert Title" message:@"This is a very long message, designed just to show you how smart this class is"];
    
    [alert setCancelButtonWithTitle:@"Cancel" block:nil];
    [alert setDestructiveButtonWithTitle:@"Kill!" block:nil];
    [alert addButtonWithTitle:@"Show Action Sheet on top" block:^{
        [self showActionSheet:nil];
    }];
    [alert addButtonWithTitle:@"Show another alert" block:^{
        [self showAlert:nil];
    }];
    [alert show];
}

- (IBAction)showActionSheet:(id)sender {
    BlockActionSheet *sheet = [BlockActionSheet sheetWithTitle:@"This is a sheet title that will span more than one line"];
    [sheet setCancelButtonWithTitle:@"Cancel Button" block:nil];
    [sheet setDestructiveButtonWithTitle:@"Destructive Button" block:nil];
    
    //set our completion block to pass in
    BlockPickerButtonCallback completion = ^(id result) {
        if (result) {
            [self showActionSheet:nil];
        }
    };
    
    [sheet addButtonWithTitle:@"Show Action Sheet on top" block:completion];
    
    //set another completion block
    completion = ^(id result) {
        if (result) {
            [self showAlert:nil];
        }
    };
    
    [sheet addButtonWithTitle:@"Show another alert" block:completion];
    [sheet showInView:self.view];
}

- (void)showPickerActionSheetWithPickerList:(NSArray*)list {
//    NSLog(@"%s\n", __FUNCTION__);
    //create a dictionary to pass a pointer into our action sheet for
    NSDictionary *selectionResult;
    BlockPickerActionSheet *sheet = [BlockPickerActionSheet pickerWithTitle:@"Choose Category" withChoices:list pickerSelection:&selectionResult block:^(BlockPickerActionSheet *alert) {
        return YES;
    }];
    
    [sheet setCancelButtonWithTitle:@"Cancel" block:nil];
    
    BlockPickerButtonCallback completion = ^(id result) {
        //get our picked category result and tell the tableview to reload so it appears in the cell's textfield
        NSDictionary *selectionResult = (NSDictionary*)result;
        [self.kollection setObject:selectionResult[kKKCategoryTitleKey] forKey:kKKKollectionCategoryKey];
        [self.tableView reloadData];
    };
    
    [sheet addButtonWithTitle:@"Save" block:completion];
    [sheet showInView:self.view];
}

#pragma mark - Table view delegate
- (void)scrollTableFromSender:(id)sender withInset:(CGFloat)bottomInset {
//    NSLog(@"%s %0.0f", __FUNCTION__, bottomInset);
    CGPoint correctedPoint;
    
    if ([sender isKindOfClass:[UITextField class]]) {
        UITextField *textField = sender;
        correctedPoint = [textField convertPoint:textField.bounds.origin toView:self.tableView];
    } else {
        UITextView *textView = sender;
        correctedPoint = [textView convertPoint:textView.bounds.origin toView:self.tableView];
    }
    
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:correctedPoint];
    self.tableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, bottomInset, 0.0f);
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
}

- (void)resetTableContentInsetsWithIndexPath:(NSIndexPath *)indexPath {
//    NSLog(@"%s %@", __FUNCTION__, indexPath);
    NSIndexPath *pathToUpdateTo = indexPath;
    self.tableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
    [self.tableView scrollToRowAtIndexPath:pathToUpdateTo atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    //    NSLog(@"%s\n", __FUNCTION__);
    
    NSInteger sectionRows = [self.tableObjects count] + 3;//inner content rows + a header and footer row + submit button row
    NSInteger row = [indexPath row];
    
    if (row == 0 && row == sectionRows - 1) {
        //single row; will this ever happen?
        return 0;
    }
    else if (row == 0) {
        //top row
        return kDisplayTableHeaderHeight;
    } else if (row == sectionRows - 2) {
        //submit button row
        return 52;
    }
    else if (row == sectionRows - 1) {
        //bottom row
        return kDisplayTableFooterHeight;
    }
    else {
        //middle row
        return [self determineTableRowHeightForIndexPath:indexPath];
    }
}

- (CGFloat)determineTableRowHeightForIndexPath:(NSIndexPath*)indexPath {
//    NSLog(@"%s", __FUNCTION__);
    //determine row height based on the cell's datatype and length of text entries
    NSUInteger datatype = [(NSNumber*)self.tableObjects[indexPath.row - 1][@"datatype"] integerValue];
    NSUInteger defaultRowHeight = 88.0f;
    if (datatype == KKKollectionSetupCellDataTypeNumber) {
        //number picker
        defaultRowHeight = 64.0f;
    } else if (datatype == KKKollectionSetupCellDataTypeToggle) {
        //toggle on/off
    } else if (datatype == KKKollectionSetupCellDataTypeString) {
        //short string
    } else if (datatype == KKKollectionSetupCellDataTypeShare) {
        //share with friends
        defaultRowHeight = 92.0f;
    } else if (datatype == KKKollectionSetupCellDataTypeCategory) {
        //enter category
        //use default
    } else if (datatype == KKKollectionSetupCellDataTypePhoto) {
        //choose photo
    } else if (datatype == KKKollectionSetupCellDataTypeLongString) {
        //enter long string
        defaultRowHeight = 128.0f;
    } else if (datatype == KKKollectionSetupCellDataTypeSegment) {
        //segmented control or picker
        defaultRowHeight = 59.0f;
    } else if (datatype == KKKollectionSetupCellDataTypeNavigate) {
        //drill down in table
        //use default
    } else {
        //default
    }
    
    //Get label height
    NSString *labelLength = (NSString*)self.tableObjects[indexPath.row - 1][@"hint"];
    NSString *entryLength = (NSString*)self.tableObjects[indexPath.row - 1][@"response"];//UPDATE; this doesn't exist yet until pulled from parse
    
    CGSize constraint = CGSizeMake(kSETUP_TEXT_OBJECT_WIDTH, 20000.0f);
    CGSize labelSize = [labelLength sizeWithFont:kSetupFooterFont constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
    CGSize entrySize = [entryLength sizeWithFont:kSetupEntryFont constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
    CGFloat height;
    
    //check if it's a cell type without an entry label, like one with the segmented control cell
    if (datatype == KKKollectionSetupCellDataTypeSegment || datatype == KKKollectionSetupCellDataTypeToggle || datatype == KKKollectionSetupCellDataTypeNumber) {
        //no entry field to worry about
        height = MAX(labelSize.height + 46, defaultRowHeight); //38 for top single row (with segmented control or toggle switch) is 30 + (8 * 2) for padding
    } else {
        //we have an entry field to account for
        height = MAX(labelSize.height + entrySize.height + 67, defaultRowHeight); //67 is the size of the base cell minus the label
    }
    
    return height;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.tableObjects count] + 3; //inner content rows + submit button row + a header and footer row
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    NSLog(@"%s", __FUNCTION__);
    //set up background image of cell as well as determine when to show/hide label and disclosure
    UIColor *rowBackground;
    NSInteger sectionRows = [tableView numberOfRowsInSection:[indexPath section]];
    NSInteger row = [indexPath row];
    
    if (row == 0 && row == sectionRows - 1) {
        //single row; will this ever happen?
        static NSString *CellIdentifier = @"CellA";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            cell = [self tableViewCellWithReuseIdentifier:CellIdentifier];
        }
        
        rowBackground = [UIColor colorWithPatternImage:[UIImage imageNamed:@"kkTableBodyBG.png"]];
        [cell.contentView setBackgroundColor:rowBackground];
        
        return cell;
    }
    else if (row == 0) {
        //top row
        static NSString *CellIdentifier = @"CellB";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            cell = [self tableViewCellWithReuseIdentifier:CellIdentifier];
        }
        
        //add a header label to it
        UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(15.0f, 13.0f, cell.contentView.bounds.size.width - 20.0f, 20.0f)];
        [cell.contentView addSubview:headerLabel];
        [headerLabel setTextColor:kGray6];
        [headerLabel setShadowColor:kCreme];
        [headerLabel setShadowOffset:CGSizeMake( 0.0f, 1.0f)];
        [headerLabel setFont:[UIFont fontWithName:@"OriyaSangamMN-Bold" size:16]];
        [headerLabel setBackgroundColor:[UIColor clearColor]];
        
        //set the header title text based on the type of kollection we're modifying
        if (self.kollectionSetupType == KKKollectionSetupTypeNew) {
            headerLabel.text = @"Create New Kollection";
        } else if (self.kollectionSetupType == KKKollectionSetupTypeEdit) {
            headerLabel.text = @"Edit Kollection";
        } else {
        }
        
        rowBackground = [UIColor colorWithPatternImage:[UIImage imageNamed:@"headerBG.png"]];
        [cell.contentView setBackgroundColor:rowBackground];
        
        return cell;
    } else if (row == sectionRows - 2) {
        //it's the next to last row, so add a submit button
        static NSString *CellIdentifier = @"CellD";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            cell = [self tableViewCellWithReuseIdentifier:CellIdentifier];
        }
        
        rowBackground = [UIColor colorWithPatternImage:[UIImage imageNamed:@"kkTableBodyBG.png"]];
        [cell.contentView setBackgroundColor:rowBackground];
        UIButton *submitButton = [[UIButton alloc] init];
        [submitButton setBackgroundImage:[UIImage imageNamed:@"kkSignUpButtonUp.png"] forState:UIControlStateNormal];
        [submitButton setBackgroundImage:[UIImage imageNamed:@"kkSignUpButtonDown.png"] forState:UIControlStateHighlighted];
        [submitButton setTitle:kSETUP_SAVE_NEW_KOLLECTION forState:UIControlStateNormal];
        [submitButton setTitle:kSETUP_SAVE_NEW_KOLLECTION forState:UIControlStateHighlighted];
        [submitButton addTarget:self action:@selector(submit:) forControlEvents:UIControlEventTouchUpInside];
        CGSize buttonSize = CGSizeMake(245, 44);
        [submitButton setFrame:CGRectMake((cell.contentView.frame.size.width/2 - buttonSize.width/2),
                                          cell.contentView.frame.origin.y + 4,
                                          buttonSize.width,
                                          buttonSize.height)];
        [cell.contentView addSubview:submitButton];
        
        return cell;
    }
    else if (row == sectionRows - 1) {
        //bottom row
        static NSString *CellIdentifier = @"CellC";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            cell = [self tableViewCellWithReuseIdentifier:CellIdentifier];
        }
        
        rowBackground = [UIColor colorWithPatternImage:[UIImage imageNamed:@"footerBGNoActions.png"]];
        [cell.contentView setBackgroundColor:rowBackground];
        
        return cell;
    }
    else {
        //middle row cell
        //determine what type of cell we need to show
        
        NSUInteger datatype = [(NSNumber*)self.tableObjects[indexPath.row - 1][@"datatype"] integerValue];
//        NSLog(@"datatype = %i", datatype);
//        NSLog(@"self.tableObjects[indexPath.row - 1]label = %@", self.tableObjects[indexPath.row - 1][@"question"]);
#pragma mark Number Cell
        if (datatype == KKKollectionSetupCellDataTypeNumber) {
            //number picker
            static NSString *CustomCellIdentifier = @"KKSetupTableNumberCell";
            
            KKSetupTableNumberCell *cell = (KKSetupTableNumberCell *) [tableView dequeueReusableCellWithIdentifier:CustomCellIdentifier];
            
            if (cell == nil) {
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"KKSetupTableNumberCell" owner:self options:nil];
                for (id oneObject in nib)
                    if ([oneObject isKindOfClass:[KKSetupTableNumberCell class]])
                        cell = (KKSetupTableNumberCell *)oneObject;
                [cell formatCell];//tell it to format itself
                cell.headerLabel.text = self.tableObjects[indexPath.row - 1][@"question"]; //subtract 1 to account for header row
                cell.numberField.delegate = self;
                cell.footnoteLabel.text = self.tableObjects[indexPath.row - 1][@"hint"];
            }
            
            cell.numberField.textColor = kMint4;//set to mint color
            
            //fill in entry label text from kollection property if available, if not, check for historical response
            NSString *columnName = (NSString*)self.tableObjects[indexPath.row - 1][@"objectColumn"];
            if ([self.kollection objectForKey:columnName]) {
                cell.numberField.text = [[self.kollection objectForKey:columnName] stringValue];
            } else if([(NSString*)self.tableObjects[indexPath.row - 1][@"response"] length] > 0){
                cell.numberField.text = (NSString*)self.tableObjects[indexPath.row - 1][@"response"];
            }
            
            //Get label height
            NSString *labelLength = (NSString*)self.tableObjects[indexPath.row - 1][@"hint"];
            
            CGSize constraint = CGSizeMake(kSETUP_TEXT_OBJECT_WIDTH, 20000.0f);
            CGSize labelSize = [labelLength sizeWithFont:kSetupFooterFont constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
            
            CGFloat footerHeight = MAX(labelSize.height, 18.0f); //57 is the size of the cell minus the label
            [cell.footnoteLabel setFrame:CGRectMake(cell.headerLabel.frame.origin.x, cell.numberField.frame.origin.y + cell.numberField.frame.size.height, kSETUP_TEXT_OBJECT_WIDTH, footerHeight)];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        } else if (datatype == KKKollectionSetupCellDataTypeToggle) {
            //toggle on/off
        } else if (datatype == KKKollectionSetupCellDataTypeString) {
           //short string
#pragma mark Base Cell
            static NSString *CustomCellIdentifier = @"KKSetupTableBaseCell";
            
            KKSetupTableBaseCell *cell = (KKSetupTableBaseCell *) [tableView dequeueReusableCellWithIdentifier:CustomCellIdentifier];
            
            if (cell == nil) {
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"KKSetupTableBaseCell" owner:self options:nil];
                for (id oneObject in nib)
                    if ([oneObject isKindOfClass:[KKSetupTableBaseCell class]])
                        cell = (KKSetupTableBaseCell *)oneObject;
                [cell formatCell];//tell it to format itself
                cell.headerLabel.text = self.tableObjects[indexPath.row - 1][@"question"]; //subtract 1 to account for header row
                cell.entryField.delegate = self;
                cell.footnoteLabel.text = self.tableObjects[indexPath.row - 1][@"hint"];
            }
            
            //fill in entry label text from kollection property if available, if not, check for historical response
            NSString *columnName = (NSString*)self.tableObjects[indexPath.row - 1][@"objectColumn"];
//            NSLog(@"[self.kollection objectForKey:columnName] = %@ = %@", columnName, [self.kollection objectForKey:columnName]);
            if ([self.kollection objectForKey:columnName]) {
                cell.entryField.text = [self.kollection objectForKey:columnName];
                cell.entryField.textColor = kMint4;//set to mint color text if we have a pre-entered response
            } else if([(NSString*)self.tableObjects[indexPath.row - 1][@"response"] length] > 0){
                cell.entryField.text = (NSString*)self.tableObjects[indexPath.row - 1][@"response"];
                cell.entryField.textColor = kMint4;//set to mint color text if we've entered a response
            }
            
            //Get label height
            NSString *labelLength = (NSString*)self.tableObjects[indexPath.row - 1][@"hint"];
            
            CGSize constraint = CGSizeMake(kSETUP_TEXT_OBJECT_WIDTH, 20000.0f);
            CGSize labelSize = [labelLength sizeWithFont:kSetupFooterFont constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
            
            CGFloat footerHeight = MAX(labelSize.height, 18.0f); //57 is the size of the cell minus the label
            [cell.footnoteLabel setFrame:CGRectMake(0, cell.entryField.frame.origin.y + cell.entryField.frame.size.height, kSETUP_TEXT_OBJECT_WIDTH, footerHeight)];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell; 
        } else if (datatype == KKKollectionSetupCellDataTypeShare) {
            //share with friends
#pragma mark Share Cell
            //this option is only available at the time of creation of the kollection and doesn't need to
            //follow the kollection around as a property beyond initial saving, so we'll only track it with a
            //local boolean variable to be check at time of save
            static NSString *CustomCellIdentifier = @"KKSetupTableShareCell";
            
            KKSetupTableShareCell *cell = (KKSetupTableShareCell *) [tableView dequeueReusableCellWithIdentifier:CustomCellIdentifier];
            
            if (cell == nil) {
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"KKSetupTableShareCell" owner:self options:nil];
                for (id oneObject in nib)
                    if ([oneObject isKindOfClass:[KKSetupTableShareCell class]])
                        cell = (KKSetupTableShareCell *)oneObject;
                [cell formatCell];//tell it to format itself
                cell.headerLabel.text = self.tableObjects[indexPath.row - 1][@"question"]; //subtract 1 to account for header row
                cell.footnoteLabel.text = self.tableObjects[indexPath.row - 1][@"hint"];
            }
            
            //add selectors here to each of the buttons as necessary
            [cell.fbButton addTarget:self action:@selector(facebookSharingToggled:) forControlEvents:UIControlEventTouchUpInside];
            
            //set the button to the proper state if we've already set it previously
            NSNumber *selected = [NSNumber numberWithBool:shouldShareNewKollectionToFacebook];
            cell.fbButton.selected = ([selected boolValue]) ? YES : NO;
            
            //Get footer label height
            NSString *labelLength = (NSString*)self.tableObjects[indexPath.row - 1][@"hint"];
            
            CGSize constraint = CGSizeMake(kSETUP_TEXT_OBJECT_WIDTH, 20000.0f);
            CGSize labelSize = [labelLength sizeWithFont:kSetupFooterFont constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
            
            CGFloat footerHeight = MAX(labelSize.height, 18.0f); //57 is the size of the cell minus the label
            [cell.footnoteLabel setFrame:CGRectMake(cell.headerLabel.frame.origin.x, cell.fbButton.frame.origin.y + cell.fbButton.frame.size.height, kSETUP_TEXT_OBJECT_WIDTH, footerHeight)];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        } else if (datatype == KKKollectionSetupCellDataTypeCategory) {
            //enter category
#pragma mark Category Cell
            static NSString *CustomCellIdentifier = @"KKSetupTableCategoryCell";
            
            KKSetupTableCategoryCell *cell = (KKSetupTableCategoryCell *)[tableView dequeueReusableCellWithIdentifier:CustomCellIdentifier];
            
            if (cell == nil) {
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"KKSetupTableCategoryCell" owner:self options:nil];
                for (id oneObject in nib)
                    if ([oneObject isKindOfClass:[KKSetupTableCategoryCell class]])
                        cell = (KKSetupTableCategoryCell *)oneObject;
                [cell formatCell];//tell it to format itself
                cell.headerLabel.text = self.tableObjects[indexPath.row - 1][@"question"]; //subtract 1 to account for header row
                cell.entryField.delegate = self;
                cell.footnoteLabel.text = self.tableObjects[indexPath.row - 1][@"hint"];
            }
            
            //add selectors here to each of the buttons as necessary
            [cell.button addTarget:self action:@selector(queryParseForCategoryList) forControlEvents:UIControlEventTouchUpInside];
            
            //fill in entry label text from kollection property if available, if not, check for historical response
            NSString *columnName = (NSString*)self.tableObjects[indexPath.row - 1][@"objectColumn"];
            if ([self.kollection objectForKey:columnName]) {
                cell.entryField.text = [self.kollection objectForKey:columnName];
                cell.entryField.textColor = kMint4;//set to mint color text if we have a pre-entered response
            } else if([(NSString*)self.tableObjects[indexPath.row - 1][@"response"] length] > 0){
                cell.entryField.text = (NSString*)self.tableObjects[indexPath.row - 1][@"response"];
                cell.entryField.textColor = kMint4;//set to mint color text if we've entered a response
            }
            
            //Get label height
            NSString *labelLength = (NSString*)self.tableObjects[indexPath.row - 1][@"hint"];
            CGSize constraint = CGSizeMake(kSETUP_TEXT_OBJECT_WIDTH, 20000.0f);
            CGSize labelSize = [labelLength sizeWithFont:kSetupFooterFont constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
            
            CGFloat footerHeight = MAX(labelSize.height, 18.0f); //57 is the size of the cell minus the label
            [cell.footnoteLabel setFrame:CGRectMake(0, cell.entryField.frame.origin.y + cell.entryField.frame.size.height, kSETUP_TEXT_OBJECT_WIDTH, footerHeight)];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
#pragma mark Photo Cell
        } else if (datatype == KKKollectionSetupCellDataTypePhoto) {
            //choose photo
#pragma mark Long String Cell
        } else if (datatype == KKKollectionSetupCellDataTypeLongString) {
            //enter long string
//            NSLog(@"long string cell");
            static NSString *CustomCellIdentifier = @"KKSetupTableLongStringCell";
            
            KKSetupTableLongStringCell *cell = (KKSetupTableLongStringCell *) [tableView dequeueReusableCellWithIdentifier:CustomCellIdentifier];
            
            if (cell == nil) {
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"KKSetupTableLongStringCell" owner:self options:nil];
                for (id oneObject in nib)
                    if ([oneObject isKindOfClass:[KKSetupTableLongStringCell class]])
                        cell = (KKSetupTableLongStringCell *)oneObject;
                [cell formatCell];//tell it to format itself
                cell.headerLabel.text = self.tableObjects[indexPath.row - 1][@"question"]; //subtract 1 to account for header row
                cell.entryField.delegate = self;
                cell.footnoteLabel.text = self.tableObjects[indexPath.row - 1][@"hint"];
            }
            
            //fill in entry label text from kollection property if available, if not, check for historical response
            NSString *columnName = (NSString*)self.tableObjects[indexPath.row - 1][@"objectColumn"];
            if ([self.kollection objectForKey:columnName]) {
                cell.entryField.text = [self.kollection objectForKey:columnName];
                cell.entryField.textColor = kMint4;//set to mint color text if we have a pre-entered response
            } else if([(NSString*)self.tableObjects[indexPath.row - 1][@"response"] length] > 0){
                cell.entryField.text = (NSString*)self.tableObjects[indexPath.row - 1][@"response"];
                cell.entryField.textColor = kMint4;//set to mint color text if we've entered a response
            }
            
            //Get label height
            NSString *labelLength = (NSString*)self.tableObjects[indexPath.row - 1][@"hint"];
//        NSString *entryLength = (NSString*)self.tableObjects[indexPath.row - 1][@"response"];//UPDATE; this doesn't exist yet until pulled from parse
            
            CGSize constraint = CGSizeMake(kSETUP_TEXT_OBJECT_WIDTH, 20000.0f);
            CGSize labelSize = [labelLength sizeWithFont:kSetupFooterFont constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
//        CGSize entrySize = [entryLength sizeWithFont:kSetupEntryFont constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
            
            CGFloat footerHeight = MAX(labelSize.height, 18.0f); //57 is the size of the cell minus the label
            [cell.footnoteLabel setFrame:CGRectMake(0, cell.entryField.frame.origin.y + cell.entryField.frame.size.height, kSETUP_TEXT_OBJECT_WIDTH, footerHeight)];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        } else if (datatype == KKKollectionSetupCellDataTypeSegment) {
//            NSLog(@"segment cell");
#pragma mark Segment Cell
            //segmented control or picker
            static NSString *CustomCellIdentifier = @"KKSetupTableSegmentCell";
            
            KKSetupTableSegmentCell *cell = (KKSetupTableSegmentCell *) [tableView dequeueReusableCellWithIdentifier:CustomCellIdentifier];
            
            if (cell == nil) {
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"KKSetupTableSegmentCell" owner:self options:nil];
                for (id oneObject in nib)
                    if ([oneObject isKindOfClass:[KKSetupTableSegmentCell class]])
                        cell = (KKSetupTableSegmentCell *)oneObject;
                [cell formatCell];//tell it to format itself
                cell.headerLabel.text = self.tableObjects[indexPath.row - 1][@"question"]; //subtract 1 to account for header row
                cell.footnoteLabel.text = self.tableObjects[indexPath.row - 1][@"hint"];
            }
            
            //add selectors here to each of the buttons as necessary
            [cell.segmentedControl addTarget:self action:@selector(segmentedControlSegmentChosen:) forControlEvents:UIControlEventValueChanged];
            
            //fill in entry label text from kollection property if available, if not, check for historical response
            NSString *columnName = (NSString*)self.tableObjects[indexPath.row - 1][@"objectColumn"];
            BOOL isPrivateValue = NO;
            if ([self.kollection objectForKey:columnName]) {
                //check if we've set the isPrivate property to YES; if not, default to Public segment selected
                [[self.kollection objectForKey:columnName] boolValue] != YES ? [cell.segmentedControl setSelectedSegmentIndex:0] : [cell.segmentedControl setSelectedSegmentIndex:1];
            }
            
            //set our isPrivate property based on what we've just set the selected segment index to
            if ([cell.segmentedControl selectedSegmentIndex] == 1) {
                isPrivateValue = YES;
            } else {
                isPrivateValue = NO;
            }
            
            //key-value coding only accepts objects so wrap the bool in an nsnumber
            [self.kollection setObject:[NSNumber numberWithBool:isPrivateValue] forKey:columnName];
            
            //Get footer label height
            NSString *labelLength = (NSString*)self.tableObjects[indexPath.row - 1][@"hint"];
            
            CGSize constraint = CGSizeMake(kSETUP_TEXT_OBJECT_WIDTH, 20000.0f);
            CGSize labelSize = [labelLength sizeWithFont:kSetupFooterFont constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
            
            CGFloat footerHeight = MAX(labelSize.height, 18.0f); //57 is the size of the cell minus the label
            [cell.footnoteLabel setFrame:CGRectMake(cell.headerLabel.frame.origin.x, cell.segmentedControl.frame.origin.y + cell.segmentedControl.frame.size.height, kSETUP_TEXT_OBJECT_WIDTH, footerHeight)];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        } else if (datatype == KKKollectionSetupCellDataTypeNavigate) {
            //drill down in table
#pragma mark Navigate Cell
            static NSString *CustomCellIdentifier = @"KKSetupTableNavigateCell";
            
            KKSetupTableNavigateCell *cell = (KKSetupTableNavigateCell *) [tableView dequeueReusableCellWithIdentifier:CustomCellIdentifier];
            
            if (cell == nil) {
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"KKSetupTableNavigateCell" owner:self options:nil];
                for (id oneObject in nib)
                    if ([oneObject isKindOfClass:[KKSetupTableNavigateCell class]])
                        cell = (KKSetupTableNavigateCell *)oneObject;
                [cell formatCell];//tell it to format itself
                cell.headerLabel.text = self.tableObjects[indexPath.row - 1][@"question"]; //subtract 1 to account for header row
                cell.footnoteLabel.text = self.tableObjects[indexPath.row - 1][@"hint"];
                [cell.rowButton addTarget:self action:@selector(goToSubjectsList:) forControlEvents:UIControlEventTouchUpInside];
            }
            
            //fill in entry label text from kollection property if available, if not, check for historical response
            NSString *columnName = (NSString*)self.tableObjects[indexPath.row - 1][@"objectColumn"];
            if ([self.kollection objectForKey:columnName]) {
                NSMutableArray *kollectionSubjects = [NSMutableArray new];
                //enumerate over all dict objects to extract the subject titles into a single array to the comma separate them
                for (NSDictionary *subject in (NSArray*)[self.kollection objectForKey:columnName]) {
                    NSString *titleString = (NSString*)[subject objectForKey:kKKKollectionTitleKey];
                    [kollectionSubjects addObject:titleString];
                }
                
                NSString *subjectList = [kollectionSubjects componentsJoinedByString:@", "];
                cell.entryField.text = subjectList;
            } else if([(NSString*)self.tableObjects[indexPath.row - 1][@"response"] length] > 0){
                cell.entryField.text = (NSString*)self.tableObjects[indexPath.row - 1][@"response"];
            }
            
            //Get label height
            NSString *labelLength = (NSString*)self.tableObjects[indexPath.row - 1][@"hint"];
            CGSize constraint = CGSizeMake(kSETUP_TEXT_OBJECT_WIDTH, 20000.0f);
            CGSize labelSize = [labelLength sizeWithFont:kSetupFooterFont constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
            
            CGFloat footerHeight = MAX(labelSize.height, 18.0f); //57 is the size of the cell minus the label
            if ([cell.entryField.text length] == 0) {
                cell.entryField.text = @"--";
            } else {
                cell.entryField.textColor = kMint4;
            }
            
            [cell.footnoteLabel setFrame:CGRectMake(cell.headerLabel.frame.origin.x, cell.entryField.frame.origin.y + cell.entryField.frame.size.height, kSETUP_TEXT_OBJECT_WIDTH, footerHeight)];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        } else {
            //do nothing
        }
        
        //UPDATE and remove this when all cell type accounted for
        static NSString *CellIdentifier = @"CellZ";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            cell = [self tableViewCellWithReuseIdentifier:CellIdentifier];
        }
        
        rowBackground = [UIColor colorWithPatternImage:[UIImage imageNamed:@"kkTableBodyBG.png"]];
        [cell.contentView setBackgroundColor:rowBackground];
        
        return cell;
    }
}

- (void)goToSubjectsList:(id)sender {
//    NSLog(@"%s %@", __FUNCTION__, self.kollection);
    //tell the delegate to navigate to the subjects list so we can edit it
    [self.delegate pushSubjectsViewControllerWithKollection:self.kollection];
}

- (UITableViewCell *)tableViewCellWithReuseIdentifier:(NSString *)identifier {
    //	NSLog(@"%s", __FUNCTION__);
	UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    
    //make the cell highlight gray instead of blue
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    //blank out generic stuff
    cell.textLabel.text = @"";
    cell.detailTextLabel.text = @"";
    
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    //tell the delegate to dismiss the keyboard and reset the tableview's contentInsets
    [self.delegate setupTableViewDidSelectRowAtIndexPath:indexPath];
}

#pragma mark - UITextFieldDelegate methods
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([[[textField superview] superview] isKindOfClass:[KKSetupTableNumberCell class]]) {
        NSCharacterSet *set = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet];
        if ([textField.text rangeOfCharacterFromSet:set].location != NSNotFound) {
            alertMessage(@"Please use only whole numbers.");
            return NO;
        }
        return YES;
    } else {
        return YES;
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
  
    [self scrollTableFromSender:textField withInset:240.0f];
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    if ([[[textField superview] superview] isKindOfClass:[KKSetupTableNumberCell class]]) {
        NSCharacterSet *set = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet];
        if ([textField.text rangeOfCharacterFromSet:set].location != NSNotFound) {
            alertMessage(@"Please use only whole numbers.");
            return NO;
        }
        return YES;
    } else {
        return YES;
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    if ([[[textField superview] superview] isKindOfClass:[KKSetupTableNumberCell class]]) {
        //set what the placeholder string should be
        NSString *stringPlaceholder = @"";
        
        if ([textField.text isEqualToString:stringPlaceholder]) {
            //reset the placeholder if we didn't enter anything
            return;//exit without saving anything
        }
        
        NSString *textFieldtext = textField.text;
        CGPoint correctedPoint = [textField convertPoint:textField.bounds.origin toView:self.tableView];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:correctedPoint];
        //once we have that, we can determine which column we need to update with the data's value on our PFObject
        NSString *columnName = (NSString*)self.tableObjects[indexPath.row - 1][@"objectColumn"];
        [self.kollection setObject:[NSNumber numberWithInt:[textFieldtext intValue]] forKey:columnName]; //convert text to object
    } else {
    }
    
    
}

#pragma mark - UITextViewDelegate methods
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
//    NSLog(@"%s", __FUNCTION__);
    NSUInteger stringLimit;
    
    if ([[[textView superview] superview] isKindOfClass:[KKSetupTableBaseCell class]]) {
        stringLimit = kSetupStringCharacterLimit;
    } else {
        stringLimit = kSetupLongStringCharacterLimit;
    }
    
    if ([textView.text isEqualToString:[NSString stringWithFormat:@"%i-character limit", stringLimit]]) {
        //clear the placeholder
        textView.text = @"";
    }
    
    [textView setReturnKeyType:UIReturnKeyDone];
    [self scrollTableFromSender:textView withInset:240.0f];
    
    textView.textColor = kMint4;
    
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
//    NSLog(@"%s", __FUNCTION__);
    
    NSString *trimmedValue = textView.text;
    trimmedValue = [trimmedValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSUInteger stringLimit;
    NSString *stringPlaceholder;
    
    //set our string limit based on the type of cell we're dealing with
    if ([[[textView superview] superview] isKindOfClass:[KKSetupTableBaseCell class]]) {
        stringLimit = kSetupStringCharacterLimit;
    } else {
        stringLimit = kSetupLongStringCharacterLimit;
    }
    
    //set the message with text limit
    stringPlaceholder = [NSString stringWithFormat:@"%i-character limit", stringLimit];
    
    //reset the placeholder if we didn't put in anything or it's the same as before
    if ([trimmedValue isEqualToString:@""] || [trimmedValue isEqualToString:stringPlaceholder]) {
        //reset the placeholder if we didn't enter anything
        textView.text = stringPlaceholder;
    } else if (textView.text.length > stringLimit) {
        textView.text = [textView.text substringToIndex:stringLimit - 1];
        NSString *message = [NSString stringWithFormat:@"This field is limited to %i characters.", stringLimit];
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Character limit"
                                  message:message delegate:nil
                                  cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [alertView show];
        return NO; // return NO to not exit field
    }
    
//    [self scrollTableFromSender:textView withInset:0.0f];
    [textView resignFirstResponder];
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
//    NSLog(@"textView super view class = %@", [[[textView superview] superview]class]);
    //check our cell type to determine our character limits
    NSUInteger stringLimit;
    
    //set our string limit based on the type of cell we're dealing with
    if ([[[textView superview] superview] isKindOfClass:[KKSetupTableBaseCell class]]) {
        stringLimit = kSetupStringCharacterLimit;
    } else {
        stringLimit = kSetupLongStringCharacterLimit;
    }
    
    if (textView.text.length > stringLimit && range.length == 0) {
        NSString *message = [NSString stringWithFormat:@"This field is limited to %i characters.", stringLimit];
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Character limit"
                                  message:message delegate:nil
                                  cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [alertView show];
        return NO; // return NO to not change text
    }
    else {
        //dismiss if we've hit the enter key
        if([text isEqualToString:@"\n"]) {
            [textView resignFirstResponder];
            return NO;
        }
        
        return YES;
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
//    NSLog(@"%s", __FUNCTION__);
    
    //first, determine what type of cell (short string/long string) we're dealing with and trim down the text
    //to prevent any problems where a user might have copy and pasted into the textview instead of typing directly
    NSUInteger stringLimit;
    
    //set our string limit based on the type of textView cell we're dealing with
    if ([[[textView superview] superview] isKindOfClass:[KKSetupTableBaseCell class]]) {
        stringLimit = kSetupStringCharacterLimit;
    } else {
        stringLimit = kSetupLongStringCharacterLimit;
    }
    
    //set what the placeholder string should be
    NSString *stringPlaceholder = [NSString stringWithFormat:@"%i-character limit", stringLimit];
    
    if ([textView.text isEqualToString:stringPlaceholder]) {
        //reset the placeholder if we didn't enter anything
        textView.textColor = kGray3;
        return;//exit without saving anything
    }
    
    //set the text and then the range to trim out
    NSString *textViewtext = textView.text;
    NSRange range = NSMakeRange(0, stringLimit);
    if ([textViewtext length] > stringLimit) {
        textViewtext = [textViewtext substringWithRange:range];
    }
    
    CGPoint correctedPoint = [textView convertPoint:textView.bounds.origin toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:correctedPoint];
    //once we have that, we can determine which column we need to update with the data's value on our PFObject
    NSString *columnName = (NSString*)self.tableObjects[indexPath.row - 1][@"objectColumn"];
    [self.kollection setObject:textViewtext forKey:columnName];
}

@end
