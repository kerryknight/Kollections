//
//  KKKollectionSubjectsTableViewController.m
//  Kollections
//
//  Created by Kerry Knight on 1/9/13.
//  Copyright (c) 2013 Kerry Knight. All rights reserved.
//

#import "KKKollectionSubjectsTableViewController.h"
#import "KKKollectionSubjectsTableCell.h"
#import "KKConstants.h"
#import "KKToolbarButton.h"
#import "NSMutableArray+AddOns.h"

@interface KKKollectionSubjectsTableViewController () {
    NSUInteger selectedSubjectIndex;
}

@property (nonatomic, strong) UITextField *titleField;
@property (nonatomic, strong) UITextView  *descriptionView;
@property (nonatomic, strong) UITextField *payoutField;
@property (nonatomic, strong) KKToolbarButton *doneButton;
@property (nonatomic, strong) KKToolbarButton *cancelButton;

@end

@implementation KKKollectionSubjectsTableViewController

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
 
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"kkTitleBarLogo.png"]];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"kkMainBG.png"]]];//set background image
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    //set the frame of the table view using the window height - navbar height - tabbar height
    id appDelegate = [[UIApplication sharedApplication] delegate];
    UIWindow *window = [appDelegate window];
    float height = window.frame.size.height -
    self.navigationController.navigationBar.frame.size.height -
    self.tabBarController.tabBar.frame.size.height;
    
    self.view.frame = CGRectMake(0, 0, window.frame.size.width, height);
    
    //init the subject array if we haven't created any so far
    if([self.subjects count] == 0)self.subjects = [[NSMutableArray alloc] initWithCapacity:10];
    
    //add toolbar buttons
    self.navigationItem.hidesBackButton = YES;//hide default back button as it's not styled like I want
    [self configureToolbarButtons];//add the done button to upper right
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    NSLog(@"%s", __FUNCTION__);
    self.doneButton.hidden = NO;//this is hidden if we navigate away
    self.cancelButton.hidden = NO;
    [self.tableView reloadData];//in case we updated anything
}

- (void)viewWillDisappear:(BOOL)animated {
//    NSLog(@"%s", __FUNCTION__);
    [super viewWillDisappear:animated];
    self.doneButton.hidden = YES;
    self.cancelButton.hidden = YES;
}

#pragma mark - Custom Methods
- (void)addSubject:(id)sender {
//    NSLog(@"%s", __FUNCTION__);
    KKKollectionSubjectEditViewController *subjectsEditTableVC = [[KKKollectionSubjectEditViewController alloc] init];
    subjectsEditTableVC.delegate = self;
    selectedSubjectIndex = [self.subjects count]; //we'll use this index to update the array later
    [self.navigationController pushViewController:subjectsEditTableVC animated:YES];
}

- (void)editSubject:(id)sender {
//    NSLog(@"%s", __FUNCTION__);
    
    //first, get the index path of the cell whose row button we touched
    UIButton *button = sender;
    CGPoint correctedPoint = [button convertPoint:button.bounds.origin toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:correctedPoint];

    KKKollectionSubjectEditViewController *subjectsEditTableVC = [[KKKollectionSubjectEditViewController alloc] init];
    subjectsEditTableVC.delegate = self;
    subjectsEditTableVC.subject = (PFObject*)self.subjects[indexPath.row - 1];
    selectedSubjectIndex = indexPath.row - 1; //we'll use this index to update the array later
    
    [self.navigationController pushViewController:subjectsEditTableVC animated:YES];
}

- (void)configureToolbarButtons {
//    NSLog(@"%s", __FUNCTION__);
    //add save button to view
    self.doneButton = [[KKToolbarButton alloc] initWithFrame:kKKBarButtonItemRightFrame isBackButton:NO andTitle:@"Done"];
    [self.doneButton addTarget:self action:@selector(doneButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationController.navigationBar addSubview:self.doneButton];
    
    //add cancel button
    self.cancelButton = [[KKToolbarButton alloc] initWithFrame:kKKBarButtonItemLeftFrame isBackButton:YES andTitle:@"Cancel"];
    [self.cancelButton addTarget:self action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationController.navigationBar addSubview:self.cancelButton];
}

- (void)doneButtonAction:(id)sender {
//    NSLog(@"%s", __FUNCTION__);
    NSDictionary *userData = @{@"subjects" : self.subjects};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"KollectionSetupTableViewControllerSubjectListUpdated" object:nil userInfo:userData];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)backButtonAction:(id)sender {
//    NSLog(@"%s", __FUNCTION__);
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - KKKollectionSubjectEditViewController delegate
- (void)subjectEditViewControllerDidSubmitSubject:(PFObject*)subject {
    
    if (selectedSubjectIndex < [self.subjects count]) {
        //we were editing an existing subject so replace the existing object with our updated one
        [self.subjects replaceObjectAtIndex:selectedSubjectIndex withObject:subject];
    } else {
        
        //we added a new subject so just append the end of the array if it's unique
        if ([self shouldAddSubjectToArray:subject]) {
            [self.subjects addUniqueObject:subject];
        } else {
            //knightka replaced a regular alert view with our custom subclass
            BlockAlertView *alert = [BlockAlertView alertWithTitle:@"Subject Exists" message:@"The subject you tried to add already exists and will not be added."];
            [alert setCancelButtonWithTitle:@"OK" block:nil];
            [alert show];
        }
    }
    
    //add additional scrollable area
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, ([self.subjects count] * 88), 0);
    [self.tableView reloadData];
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)shouldAddSubjectToArray:(PFObject*)subject {
    
    //we need to do some finagling to determine if the subject is unique
    //since we haven't saved it yet, it won't have an objectId so we can't compare
    //the existing objects in self.subjects to see if it contains it b/c they'll
    //never appear to be equal; so, we'll just enumerate through all the subjects,
    //concatenating their title + description and only add the object if we get through
    //them all and none are equal
    
    //create the string from our new subject;
    NSString *newSubjectConcat = [NSString stringWithFormat:@"%@%@", subject[kKKSubjectTitleKey], subject[kKKSubjectDescriptionKey]];
    newSubjectConcat = [newSubjectConcat stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    //loop through all our subjects in the array and do the same
    for (PFObject *subject in self.subjects) {
        NSString *subjectConcat = [NSString stringWithFormat:@"%@%@", subject[kKKSubjectTitleKey], subject[kKKSubjectDescriptionKey]];
        subjectConcat = [subjectConcat stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        //now compare with our new subject
        if ([subjectConcat isEqualToString:newSubjectConcat]) {
            //they are equal so exit and don't save the new subject
            return NO;
        }
    }
    
    return YES;
}

#define kSUBJECTS_FOOTER_HEIGHT 180.0f

#pragma mark - Table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    //    NSLog(@"%s\n", __FUNCTION__);
    
    NSInteger sectionRows = [self.subjects count] + 4;//inner content rows + a header and footer row + submit button row + pseudo footer
    NSInteger row = [indexPath row];
    
    if (row == 0 && row == sectionRows - 1) {
        //single row; will this ever happen?
        return 0;
    }
    else if (row == 0) {
        //top row
        return kDisplayTableHeaderHeight;
    } else if (row == sectionRows - 3) {
        //Add new subject button row
        return 52;
    } else if (row == sectionRows - 2) {
        //bottom row
        return kDisplayTableFooterHeight;
    }
    else if (row == sectionRows - 1) {
        //psuedo footer row; didn't add as actual footer b/c i need it to scroll off screen
        return kSUBJECTS_FOOTER_HEIGHT;
    }
    else {
        //middle row
        return 88;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    
    return [self.subjects count] + 4; //inner content rows + add new subject button row + a header and footer row + pseudo footer
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
        headerLabel.text = @"Kollection Subjects";
        
        rowBackground = [UIColor colorWithPatternImage:[UIImage imageNamed:@"headerBG.png"]];
        [cell.contentView setBackgroundColor:rowBackground];
        
        return cell;
    } else if (row == sectionRows - 3) {
        //it's the next to last row, so add a submit button
        static NSString *CellIdentifier = @"CellC";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            cell = [self tableViewCellWithReuseIdentifier:CellIdentifier];
        }
        
        rowBackground = [UIColor colorWithPatternImage:[UIImage imageNamed:@"kkTableBodyBG.png"]];
        [cell.contentView setBackgroundColor:rowBackground];
        UIButton *addButton = [[UIButton alloc] init];
        [addButton setBackgroundImage:[UIImage imageNamed:@"kkSignUpButtonUp.png"] forState:UIControlStateNormal];
        [addButton setBackgroundImage:[UIImage imageNamed:@"kkSignUpButtonDown.png"] forState:UIControlStateHighlighted];
        [addButton setTitle:@"Add New Subject" forState:UIControlStateNormal];
        [addButton setTitle:@"Add New Subject" forState:UIControlStateHighlighted];
        [addButton addTarget:self action:@selector(addSubject:) forControlEvents:UIControlEventTouchUpInside];
        CGSize buttonSize = CGSizeMake(245, 44);
        [addButton setFrame:CGRectMake((cell.contentView.frame.size.width/2 - buttonSize.width/2),
                                          cell.contentView.frame.origin.y + 4,
                                          buttonSize.width,
                                          buttonSize.height)];
        [cell.contentView addSubview:addButton];
        
        return cell;
    }
    else if (row == sectionRows - 2) {
        //bottom row
        static NSString *CellIdentifier = @"CellD";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            cell = [self tableViewCellWithReuseIdentifier:CellIdentifier];
        }
        
        rowBackground = [UIColor colorWithPatternImage:[UIImage imageNamed:@"footerBGNoActions.png"]];
        [cell.contentView setBackgroundColor:rowBackground];
        
        return cell;
    }
    else if (row == sectionRows - 1) {
        //pseudo footer row
        static NSString *CellIdentifier = @"CellE";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            cell = [self tableViewCellWithReuseIdentifier:CellIdentifier];
        }
        
        //add a pseudo footer row; do this because adding as an actual footer causes the footer to not scroll with the rest of the table
        UILabel *footerLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 0, 300, kSUBJECTS_FOOTER_HEIGHT)];
        footerLabel.numberOfLines = 10;
        footerLabel.text = @"Think of subjects as kollection sub-headings to narrow the scope of your kollection. Contributors can then submit items for these specific subjects and not just the kollection as a whole.\n\nExample subject uses might be:\n- Clues in a scavenger hunt kollection\n- Wedding shot requests for a wedding event kollection\n- Specific location requests for a travel kollection";
        [footerLabel setTextColor:kGray5];
        [footerLabel setFont:[UIFont fontWithName:@"HelveticaNeue-LightItalic" size:14]];
        [footerLabel setBackgroundColor:[UIColor clearColor]];
        [cell.contentView addSubview:footerLabel];
        
        [cell.contentView setBackgroundColor:[UIColor clearColor]];
        
        return cell;
    }
    else {
        //middle row cell
        static NSString *CustomCellIdentifier = @"KKKollectionSubjectsTableCell";
        
        KKKollectionSubjectsTableCell *cell = (KKKollectionSubjectsTableCell *) [tableView dequeueReusableCellWithIdentifier:CustomCellIdentifier];
        
        if (cell == nil) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"KKKollectionSubjectsTableCell" owner:self options:nil];
            for (id oneObject in nib)
                if ([oneObject isKindOfClass:[KKKollectionSubjectsTableCell class]])
                    cell = (KKKollectionSubjectsTableCell *)oneObject;
            [cell formatCell];//tell it to format itself
            [cell.rowButton addTarget:self action:@selector(editSubject:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        cell.headerLabel.text = self.subjects[indexPath.row - 1][kKKSubjectTitleKey]; //subtract 1 to account for header row
        //determine if we have a description to display
        if ([self.subjects[indexPath.row - 1][kKKSubjectDescriptionKey] length]) {
            cell.descriptionLabel.text = self.subjects[indexPath.row - 1][kKKSubjectDescriptionKey]; //subtract 1 to account for header row
        } else {
            //nothing to show
            cell.descriptionLabel.text = @"No description entered";
        }
        
        //determine what the payout is; first, check if we have an individual payout for a subject. if not, default to overall kollection's payout
        if (self.subjects[indexPath.row - 1][kKKSubjectPayoutKey] > 0) {
            //we have an individual payout
            cell.koinsLabel.text = [NSString stringWithFormat:@"K: %i", [self.subjects[indexPath.row - 1][kKKSubjectPayoutKey] intValue]]; //subtract 1 to account for header row
        } else {
            //set to 0
            cell.koinsLabel.text = @"K: Default";
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
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
    //this functionality is performed by the editSubject: or addSubject: methods attached directly to the cell buttons
}

#pragma mark - table editing methods
- (BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ((indexPath.row < [self.subjects count] + 1) && indexPath.row > 0) { //add 1 to account for first row header
        return YES;
    } else {
        return  NO;
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ((indexPath.row < [self.subjects count] + 1) && indexPath.row > 0) { //add 1 to account for first row header
        return UITableViewCellEditingStyleDelete;
    } else {
        return  UITableViewCellEditingStyleNone;
    }
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    //delete the selected row and refresh the table
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        //delete our subject from Parse
        PFObject *subjectToDelete = (PFObject*)[self.subjects objectAtIndex:(indexPath.row - 1)];
        [subjectToDelete deleteInBackground];
        
        //delete object from array
        [self.subjects removeObjectAtIndex:(indexPath.row - 1)];
        //delete row from table
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView reloadData]; 
    }
}

@end
