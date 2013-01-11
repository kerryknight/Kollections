//
//  KKKollectionSetupTableViewController.m
//  Kollections
//
//  Created by Kerry Knight on 1/9/13.
//  Copyright (c) 2013 Kerry Knight. All rights reserved.
//

#import "KKKollectionSetupTableViewController.h"
#import "KKSetupTableBaseCell.h"

@interface KKKollectionSetupTableViewController () {
    
}
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        
        
        
        //Get label height
        NSString *labelLength = (NSString*)self.tableObjects[indexPath.row - 1][@"hint"];
        NSString *entryLength = (NSString*)self.tableObjects[indexPath.row - 1][@"response"];//UPDATE; this doesn't exist yet until pulled from parse
        
        CGSize constraint = CGSizeMake(kSETUP_TEXT_OBJECT_WIDTH, 20000.0f);
        CGSize labelSize = [labelLength sizeWithFont:kSetupFooterFont constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
        CGSize entrySize = [entryLength sizeWithFont:kSetupEntryFont constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
        
        CGFloat footerHeight = MAX(labelSize.height, 18.0f); //57 is the size of the cell minus the label
        [cell.footnoteLabel setFrame:CGRectMake(0, cell.entryField.frame.origin.y + cell.entryField.frame.size.height, kSETUP_TEXT_OBJECT_WIDTH, footerHeight)];
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

#pragma mark - Table view delegate
- (void)scrollTableFromSender:(id)sender withInset:(CGFloat)bottomInset {
    
    UITextView *textView = sender;
    CGPoint correctedPoint = [textView convertPoint:textView.bounds.origin toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:correctedPoint];
    
    self.tableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, bottomInset, 0.0f);
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
}

- (void)resetTableContentInsetsWithIndexPath:(NSIndexPath *)indexPath {
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
    //determine row height based on the cell's datatype and length of text entries
    //Get label height
    NSString *labelLength = (NSString*)self.tableObjects[indexPath.row - 1][@"hint"];
    NSString *entryLength = (NSString*)self.tableObjects[indexPath.row - 1][@"response"];//UPDATE; this doesn't exist yet until pulled from parse
    
    CGSize constraint = CGSizeMake(kSETUP_TEXT_OBJECT_WIDTH, 20000.0f);
    CGSize labelSize = [labelLength sizeWithFont:kSetupFooterFont constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
    CGSize entrySize = [entryLength sizeWithFont:kSetupEntryFont constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
    
    CGFloat height = MAX(labelSize.height + entrySize.height + 67, 87.0f); //67 is the size of the cell minus the label
//    NSLog(@"height = %0.0f", height);
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    // Navigation logic may go here. Create and push another view controller.
//    /*
//     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
//     // ...
//     // Pass the selected object to the new view controller.
//     [self.navigationController pushViewController:detailViewController animated:YES];
//     */
    
    [self.delegate setupTableViewDidSelectRowAtIndexPath:indexPath];
}

#pragma mark -
#pragma mark UITextFieldDelegate methods
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    [textView setReturnKeyType:UIReturnKeyDone];
    [self scrollTableFromSender:textView withInset:240.0f];
    
    textView.textColor = kMint4;
    
    if ([textView.text isEqualToString:@"30-character limit"]) {
        //clear the placeholder
        textView.text = @"";
    }
    
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    
    NSString *trimmedValue = textView.text;
    trimmedValue = [trimmedValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([trimmedValue isEqualToString:@""] || [trimmedValue isEqualToString:@"30-character limit"]) {
        //reset the placeholder if we didn't enter anything
        textView.text = @"30-character limit";
        textView.textColor = kGray3;
    }
    
    [self scrollTableFromSender:textView withInset:0.0f];
    [textView resignFirstResponder];
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    
    //check how long we can make the fields here based on the cell datatype
    return YES;
}

@end
