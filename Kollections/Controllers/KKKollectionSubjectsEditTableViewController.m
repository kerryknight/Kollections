//
//  KKKollectionSubjectsEditTableViewController.m
//  Kollections
//
//  Created by Kerry Knight on 1/9/13.
//  Copyright (c) 2013 Kerry Knight. All rights reserved.
//

#import "KKKollectionSubjectsEditTableViewController.h"
#import "KKSubjectEntryTableCell.h"
#import "KKConstants.h"

@interface KKKollectionSubjectsEditTableViewController () {
    
}
@property (nonatomic, strong) UITextField *titleField;
@property (nonatomic, strong) UITextView  *descriptionView;
@property (nonatomic, strong) UITextField *payoutField;
@end

@implementation KKKollectionSubjectsEditTableViewController

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
 
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"kkTitleBarLogo.png"]];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"kkMainBG.png"]]];//set background image
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

#pragma mark - Custom Methods
- (void)submit:(id)sender {
    NSLog(@"%s", __FUNCTION__);
    
    [self.delegate subjectEditTableViewControllerDidSubmitSubject:self.subject];
}

- (void)dismissView {
    NSLog(@"%s", __FUNCTION__);
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
    
    NSInteger sectionRows = 4;//inner content rows + a header and footer row + submit button row
    NSInteger row = [indexPath row];
    
    if (row == 0 && row == sectionRows - 1) {
        //single row; will this ever happen?
        return 0;
    }
    else if (row == 0) {
        //top row
        return kDisplayTableHeaderHeight;
    } else if (row == sectionRows - 2) {
        //Add new subject button row
        return 52;
    }
    else if (row == sectionRows - 1) {
        //bottom row
        return kDisplayTableFooterHeight;
    }
    else {
        //middle row
        return 380;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 4; //inner content rows + add new subject button row + a header and footer row
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
        headerLabel.text = @"Edit Subject";
        
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
        UIButton *addButton = [[UIButton alloc] init];
        [addButton setBackgroundImage:[UIImage imageNamed:@"kkSignUpButtonUp.png"] forState:UIControlStateNormal];
        [addButton setBackgroundImage:[UIImage imageNamed:@"kkSignUpButtonDown.png"] forState:UIControlStateHighlighted];
        [addButton setTitle:@"Save Subject" forState:UIControlStateNormal];
        [addButton setTitle:@"Save Subject" forState:UIControlStateHighlighted];
        [addButton addTarget:self action:@selector(submit:) forControlEvents:UIControlEventTouchUpInside];
        CGSize buttonSize = CGSizeMake(245, 44);
        [addButton setFrame:CGRectMake((cell.contentView.frame.size.width/2 - buttonSize.width/2),
                                          cell.contentView.frame.origin.y + 4,
                                          buttonSize.width,
                                          buttonSize.height)];
        [cell.contentView addSubview:addButton];
        
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
        static NSString *CustomCellIdentifier = @"KKSubjectEntryTableCell";
        
        KKSubjectEntryTableCell *cell = (KKSubjectEntryTableCell *) [tableView dequeueReusableCellWithIdentifier:CustomCellIdentifier];
        
        if (cell == nil) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"KKSubjectEntryTableCell" owner:self options:nil];
            for (id oneObject in nib)
                if ([oneObject isKindOfClass:[KKSubjectEntryTableCell class]])
                    cell = (KKSubjectEntryTableCell *)oneObject;
            [cell formatCell];//tell it to format itself
            cell.titleField.delegate = self;
            cell.descriptionField.delegate = self;
            cell.payoutField.delegate = self;
        }
        
        if ([self.subject count]) {
            cell.titleField.text = self.subject[kKKKollectionSubjectTitleKey];
            cell.descriptionField.text = self.subject[kKKKollectionSubjectDescriptionKey];
            cell.payoutField.text = [NSString stringWithFormat:@"K: %@", self.subject[kKKKollectionSubjectPayoutKey]];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
        
//        static NSString *CellIdentifier = @"Celld";
//        
//        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//        
//        if (cell == nil) {
//            cell = [self tableViewCellWithReuseIdentifier:CellIdentifier];
//        }
//        
//        rowBackground = [UIColor colorWithPatternImage:[UIImage imageNamed:@"kkTableBodyBG.png"]];
//        [cell.contentView setBackgroundColor:rowBackground];
//        
//        return cell;
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
    [self.view endEditing:YES];
    
    //tell the superclass table to set the insets back to default 0 and scroll
    [self resetTableContentInsetsWithIndexPath:indexPath];
}

#pragma mark - UITextFieldDelegate methods
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (textField == self.titleField) {
        NSString *trimmedValue = textField.text;
        trimmedValue = [trimmedValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSUInteger stringLimit = kSetupStringCharacterLimit;
        NSString *stringPlaceholder;
        
        //set the message with text limit
        stringPlaceholder = [NSString stringWithFormat:@"%i-character limit", stringLimit];
        
        //reset the placeholder if we didn't put in anything or it's the same as before
        if ([trimmedValue isEqualToString:@""] || [trimmedValue isEqualToString:stringPlaceholder]) {
            //reset the placeholder if we didn't enter anything
            textField.text = stringPlaceholder;
        } else if (textField.text.length > stringLimit) {
            NSString *message = [NSString stringWithFormat:@"This field is limited to %i characters.", stringLimit];
            UIAlertView *alertView = [[UIAlertView alloc]
                                      initWithTitle:@"Character limit"
                                      message:message delegate:nil
                                      cancelButtonTitle:@"OK" otherButtonTitles:nil];
            
            [alertView show];
            return NO; // return NO to not exit field
        }
    } else if (textField == self.payoutField) {
        NSCharacterSet *set = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet];
        if ([textField.text rangeOfCharacterFromSet:set].location != NSNotFound) {
            alertMessage(@"Please use only whole numbers.");
            return NO;
        }
    }
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
  
    [self scrollTableFromSender:textField withInset:240.0f];
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    if (textField == self.titleField) {
        NSString *trimmedValue = textField.text;
        trimmedValue = [trimmedValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSUInteger stringLimit = kSetupStringCharacterLimit;
        NSString *stringPlaceholder;
        
        //set the message with text limit
        stringPlaceholder = [NSString stringWithFormat:@"%i-character limit", stringLimit];
        
        //reset the placeholder if we didn't put in anything or it's the same as before
        if ([trimmedValue isEqualToString:@""] || [trimmedValue isEqualToString:stringPlaceholder]) {
            //reset the placeholder if we didn't enter anything
            textField.text = stringPlaceholder;
        } else if (textField.text.length > stringLimit) {
            NSString *message = [NSString stringWithFormat:@"This field is limited to %i characters.", stringLimit];
            UIAlertView *alertView = [[UIAlertView alloc]
                                      initWithTitle:@"Character limit"
                                      message:message delegate:nil
                                      cancelButtonTitle:@"OK" otherButtonTitles:nil];
            
            [alertView show];
            return NO; // return NO to not exit field
        }
    } else if (textField == self.payoutField) {
        NSCharacterSet *set = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet];
        if ([textField.text rangeOfCharacterFromSet:set].location != NSNotFound) {
            alertMessage(@"Please use only whole numbers.");
            return NO;
        }
    }
    
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    NSString *textFieldtext = textField.text;
    
    if (textField == self.titleField) {
        [self.subject setObject:textFieldtext forKey:kKKKollectionSubjectTitleKey];
    } else if (textField == self.payoutField) {
        [self.subject setObject:textFieldtext forKey:kKKKollectionSubjectPayoutKey];
    }
}

#pragma mark - UITextViewDelegate methods
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
//    NSLog(@"%s", __FUNCTION__);
    NSUInteger stringLimit = kSetupLongStringCharacterLimit;
    
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
    NSUInteger stringLimit = kSetupLongStringCharacterLimit;
    NSString *stringPlaceholder;
    
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
    
    [textView resignFirstResponder];
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
//    NSLog(@"textView super view class = %@", [[[textView superview] superview]class]);
    //check our cell type to determine our character limits
    NSUInteger stringLimit = kSetupLongStringCharacterLimit;
    
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
    NSUInteger stringLimit  = kSetupLongStringCharacterLimit;
    
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
    
    [self.subject setObject:textViewtext forKey:kKKKollectionSubjectDescriptionKey];
}

@end
