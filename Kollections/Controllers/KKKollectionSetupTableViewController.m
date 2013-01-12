//
//  KKKollectionSetupTableViewController.m
//  Kollections
//
//  Created by Kerry Knight on 1/9/13.
//  Copyright (c) 2013 Kerry Knight. All rights reserved.
//

#import "KKKollectionSetupTableViewController.h"
#import "KKSetupTableBaseCell.h"
#import "KKSetupTableLongStringCell.h"
#import "MBProgressHUD.h"
#import "KKConstants.h"

@interface KKKollectionSetupTableViewController () {
    
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

- (void)viewDidLoad
{
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
    
//    NSLog(@"self.tableObjects at load = %@", self.tableObjects);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Custom Methods
- (void)submit:(id)sender {
    
    //dismiss any keyboard
    [self.view endEditing:YES];
    
    UIButton *button = (UIButton*)sender;
    if ([button.titleLabel.text isEqualToString:@"Submit"]) {
        
        // Show HUD view
        [MBProgressHUD showHUDAddedTo:self.view.superview animated:YES];
        
        //we're adding a new kollection instead of updating an old one
        [self.kollection setObject:[PFUser currentUser] forKey:kKKKollectionUserKey];
        
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

- (void)dismissView {
    NSLog(@"%s", __FUNCTION__);
}

#pragma mark - Table view delegate
- (void)scrollTableFromSender:(id)sender withInset:(CGFloat)bottomInset {
//    NSLog(@"%s %0.0f", __FUNCTION__, bottomInset);
    UITextView *textView = sender;
    CGPoint correctedPoint = [textView convertPoint:textView.bounds.origin toView:self.tableView];
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
    NSUInteger defaultRowHeight = 87.0f;
    if (datatype == KKKollectionSetupCellDataTypeNumber) {
        //number picker
    } else if (datatype == KKKollectionSetupCellDataTypeToggle) {
        //toggle on/off
    } else if (datatype == KKKollectionSetupCellDataTypeString) {
        NSLog(@"short string height");
        //short string
    } else if (datatype == KKKollectionSetupCellDataTypeShare) {
        //share with friends
    } else if (datatype == KKKollectionSetupCellDataTypeKeywords) {
        //enter keywords
    } else if (datatype == KKKollectionSetupCellDataTypePhoto) {
        //choose photo
    } else if (datatype == KKKollectionSetupCellDataTypeLongString) {
        NSLog(@"long string height");
        //enter long string
        defaultRowHeight = 128.0f;
    } else if (datatype == KKKollectionSetupCellDataTypePicker) {
        //segmented control or picker
    } else if (datatype == KKKollectionSetupCellDataTypeNavigate) {
        //drill down in table
    } else {
        //do nothing
    }
    
    //Get label height
    NSString *labelLength = (NSString*)self.tableObjects[indexPath.row - 1][@"hint"];
    NSString *entryLength = (NSString*)self.tableObjects[indexPath.row - 1][@"response"];//UPDATE; this doesn't exist yet until pulled from parse
    
    CGSize constraint = CGSizeMake(kSETUP_TEXT_OBJECT_WIDTH, 20000.0f);
    CGSize labelSize = [labelLength sizeWithFont:kSetupFooterFont constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
    CGSize entrySize = [entryLength sizeWithFont:kSetupEntryFont constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
    
    CGFloat height = MAX(labelSize.height + entrySize.height + 67, defaultRowHeight); //67 is the size of the cell minus the label
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
        [submitButton setTitle:@"Submit" forState:UIControlStateNormal];
        [submitButton setTitle:@"Submit" forState:UIControlStateHighlighted];
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
        
        if (datatype == KKKollectionSetupCellDataTypeNumber) {
            //number picker
        } else if (datatype == KKKollectionSetupCellDataTypeToggle) {
            //toggle on/off
        } else if (datatype == KKKollectionSetupCellDataTypeString) {
            //short string
            NSLog(@"short string cell");
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
            NSLog(@"[self.kollection objectForKey:columnName] = %@ = %@", columnName, [self.kollection objectForKey:columnName]);
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
        } else if (datatype == KKKollectionSetupCellDataTypeKeywords) {
            //enter keywords
        } else if (datatype == KKKollectionSetupCellDataTypePhoto) {
            //choose photo
        } else if (datatype == KKKollectionSetupCellDataTypeLongString) {
            //enter long string
            NSLog(@"long string cell");
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
            NSLog(@"[self.kollection objectForKey:columnName] = %@ = %@", columnName, [self.kollection objectForKey:columnName]);
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
        } else if (datatype == KKKollectionSetupCellDataTypePicker) {
            //segmented control or picker
        } else if (datatype == KKKollectionSetupCellDataTypeNavigate) {
            //drill down in table
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

#pragma mark -
#pragma mark UITextFieldDelegate methods
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
    
    //determine which textview we finished editing
    NSLog(@"textView.frame.origin.x = %0.0f", textView.frame.origin.x);
    NSLog(@"textView.frame.origin.y = %0.0f", textView.frame.origin.y);
    
//    CGPoint textViewPoint = CGPointMake(textView.frame.origin.x, textView.frame.origin.y + 20);
    CGPoint correctedPoint = [textView convertPoint:textView.bounds.origin toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:correctedPoint];
    NSLog(@"self.tableObjects[indexPath.row - 1] = %@", self.tableObjects[indexPath.row - 1]);
    //once we have that, we can determine which column we need to update with the data's value on our PFObject
    NSString *columnName = (NSString*)self.tableObjects[indexPath.row - 1][@"objectColumn"];
    
    NSLog(@"set %@ for kollection column = %@", textViewtext, columnName);
    [self.kollection setObject:textViewtext forKey:columnName];
}

@end
