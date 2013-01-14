//
//  AlertPickerView.m
//  Custom Alert View
//
//  Created by Kerry Knight on 15Feb2011.
//  With Custom Alert View code courtesy of http://iphonedevelopment.blogspot.com/2010/05/custom-alert-views.html

#import "AlertPickerView.h"
#import "UIView-AlertAnimations.h"
#import <QuartzCore/QuartzCore.h>
#import "CDUser.h"

@interface AlertPickerView()
- (void)alertDidFadeOut;
@end

@implementation AlertPickerView {
    NSString *pickerAnswer;
    BOOL sortAscending;
}

@synthesize alertView;
@synthesize myPickerView;
@synthesize delegate, backgroundView;
@synthesize cancelButton;
@synthesize doneButton;
@synthesize pickerList;
@synthesize pickerSelection;
@synthesize firstEntryLabel;
@synthesize isAnswerList;
@synthesize isUserList;
@synthesize selectedUser;
@synthesize isSorting;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (void)changeUIOrientation:(NSNotification *)notification {
    [self hidePicker];
}

#pragma mark -
#pragma mark IBActions
- (IBAction)show {
//    NSLog(@"%s", __FUNCTION__);
    // Retaining self is odd, but we do it to make this "fire and forget"
    [self retain];
    
    // We need to add it to the window, which we can get from the delegate
    id appDelegate = [[UIApplication sharedApplication] delegate];
    UIWindow *window = [appDelegate window];
    [window addSubview:self.view];
    
    // Make sure the alert covers the whole window
    self.view.frame = window.frame;
    self.view.center = window.center;
    
    // "Pop in" animation for alert
    [alertView doPopInAnimationWithDelegate:self];
    
    // fade in animation for background
    [backgroundView doFadeInAnimation];
    
    //tell the buttons what they're selected images should be
    [self.cancelButton setImage:[UIImage imageNamed:@"alertViewCancelButtonDown@2x"] forState:UIControlStateHighlighted];
    [self.doneButton setImage:[UIImage imageNamed:@"alertViewDoneButtonDown@2x"] forState:UIControlStateHighlighted];
    
	// position the picker 
	[myPickerView setShowsSelectionIndicator:YES];    
    [myPickerView reloadAllComponents];
    
    pickerSelection = [[NSMutableDictionary alloc] initWithCapacity:8];
}

- (IBAction)dismiss:(id)sender {
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(alertDidFadeOut)];
    self.view.alpha = 0.0;
    [UIView commitAnimations];
    
    if (sender == self || [sender tag] == AlertPickerViewButtonTagOk)
        //check what type of list we're using so we'll know what called this alert view
        if (!isAnswerList) {
            if ([firstEntryLabel isEqualToString:@"sort"]) {
                [delegate AlertPickerView:self wasDismissedWithSortEntry:pickerSelection isAscending:sortAscending];
            } else if (([firstEntryLabel isEqualToString:@"filter"])){
                [delegate AlertPickerView:self wasDismissedWithFilterEntry:pickerSelection];
            } else {
                [delegate AlertPickerView:self wasDismissedWithSelection:pickerSelection];
            }
        } else {
            if (!isUserList) {
                //choosing regular answer
                [delegate AlertPickerView:self wasDismissedWithAnswer:pickerAnswer];
            } else {
                [delegate AlertPickerView:self wasDismissedWithUser:selectedUser];
            }
            
        }
        
    else {
        if ([delegate respondsToSelector:@selector(AlertPickerViewWasCancelled:)])
            [delegate AlertPickerViewWasCancelled:self];
    }
    
}

- (void)hidePicker {
    
    //let's dismiss what's the view that's already showing
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(alertDidFadeOut)];
    [UIView commitAnimations];
    
}

#define FIRST_COMPONENT_WIDTH 165
#define SECOND_COMPONENT_WIDTH 75

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    
    if (isSorting){
        if (component == 0) {
            return FIRST_COMPONENT_WIDTH;
        } else {
            return SECOND_COMPONENT_WIDTH;
        }
        
    }
    //only the sorting view has more than one component so make them all the same
    return FIRST_COMPONENT_WIDTH + SECOND_COMPONENT_WIDTH;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
//    NSLog(@"%s", __FUNCTION__);
#define PICKER_LABEL_FONT_SIZE 16
#define SORT_PICKER_LABEL_FONT_SIZE 15
#define PICKER_LABEL_ALPHA 0.7
    
    if (component == 0) {
        
        UILabel *pickerTextLabel = [[[UILabel alloc] initWithFrame:CGRectMake(40, 0, (FIRST_COMPONENT_WIDTH + SECOND_COMPONENT_WIDTH - 40), 40)] autorelease];
        UIFont *font = [UIFont systemFontOfSize:PICKER_LABEL_FONT_SIZE];
        
        if (isSorting) {
            
            //different sizes
            pickerTextLabel.frame = CGRectMake(50, 0, FIRST_COMPONENT_WIDTH - 20, 40);
            font = [UIFont systemFontOfSize:SORT_PICKER_LABEL_FONT_SIZE];
        }
        
        pickerTextLabel.textColor = [UIColor blackColor];
        pickerTextLabel.font = font;
        pickerTextLabel.numberOfLines = 1;
        pickerTextLabel.lineBreakMode = UILineBreakModeWordWrap;
        pickerTextLabel.backgroundColor = [UIColor clearColor];
        pickerTextLabel.opaque = NO;
        
        //check what type of list we're using so we'll know what called this alert view
        if (!isAnswerList) {
            if (row > 0) {//keep the first row of pickerview blank to make sure user selects an actual entry
                pickerTextLabel.text = [[pickerList objectAtIndex:(int)row - 1] objectForKey:@"name"];
            } else {
                if ([firstEntryLabel isEqualToString:@"sort"]) {
                    pickerTextLabel.text = @"Default Sorting";
                } else if ([firstEntryLabel isEqualToString:@"filter"]){
                    pickerTextLabel.text = @"No Filtering";
                } else {
                    
                }
                pickerTextLabel.textColor = [UIColor colorWithRed:16/255.0f green:86/255.0f blue:144/255.0f alpha:1.000];//dk blue
            }
        } else {
            if (!isUserList) {
                if (row > 0) {//keep the first row of pickerview blank to make sure user selects an actual item
                    pickerTextLabel.text = [pickerList objectAtIndex:(int)row - 1];
                } 
            } else {
                //we're trying to select a user
                if (row > 0) {//keep the first row of pickerview blank to make sure user selects an actual item
                    CDUser *user = (CDUser*)[pickerList objectAtIndex:(int)row - 1];
                    pickerTextLabel.text = user.name;
                } 
            }
        }
        
        [view addSubview:pickerTextLabel];
        return pickerTextLabel;	
        
        
    } else if (component == 1) { //only available when Sorting
        UIFont *font = [UIFont systemFontOfSize:SORT_PICKER_LABEL_FONT_SIZE];
        UILabel *pickerTextLabel2 = [[[UILabel alloc] initWithFrame:CGRectMake(40, 0, SECOND_COMPONENT_WIDTH - 20, 40)] autorelease];
        pickerTextLabel2.textColor = [UIColor blackColor];
        pickerTextLabel2.font = font;
        pickerTextLabel2.numberOfLines = 1;
        pickerTextLabel2.lineBreakMode = UILineBreakModeWordWrap;
        pickerTextLabel2.backgroundColor = [UIColor clearColor];
        pickerTextLabel2.opaque = NO;
        
        //ensure we're sorting
        if (isSorting) {
            if (row == 1) {
                pickerTextLabel2.text = @"ASC";
            } else if (row == 2) {
                pickerTextLabel2.text = @"DESC";
            } else {
                pickerTextLabel2.text = @"";
            }
        } 
        
        [view addSubview:pickerTextLabel2];
        return pickerTextLabel2;
    }
    else {
        return 0;  
    }
    
    [myPickerView reloadAllComponents];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
//    NSLog(@"%s", __FUNCTION__);
    
    if (!isAnswerList) {
        if (row > 0 && component == 0) {
            pickerSelection = [pickerList objectAtIndex:[pickerView selectedRowInComponent:0]-1];
            
        }
        if (component == 1) { //it's the sorting view
            if (row == 1) {
                sortAscending = YES;
            } else if (row == 2) {
                sortAscending = NO;
            } else {
                sortAscending = YES;
            }
        }
        
    } else {
        if (!isUserList) {
            if (row > 0) {
                pickerAnswer = [pickerList objectAtIndex:[pickerView selectedRowInComponent:0]-1];
                
            } else {
                pickerAnswer = nil;
            }
        } else {
            if (row > 0) {
                selectedUser = (CDUser*)[pickerList objectAtIndex:[pickerView selectedRowInComponent:0]-1];
                
            } else {
                selectedUser = nil;
            }
        }
    }
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{    
//    NSLog(@"%s", __FUNCTION__);
    if (component == 0)
        return [pickerList count] + 1;
    
    //for a sorting popover
    if (isSorting)
        return 3;
    
    return 0;
    [myPickerView reloadAllComponents];
    
}


#pragma mark -
#pragma mark Picker Formatting Methods

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
//    NSLog(@"%s", __FUNCTION__);
    
    //check if it's a sort popover where we need to allow selecting the direction of sort too
    if (isSorting) {
        return 2;
    }
    
    return 1;
	
}

#pragma mark -
- (void)viewDidLoad {
    [super viewDidLoad];
//    NSLog(@"%s", __FUNCTION__);
}

- (void)viewDidUnload 
{
    self.alertView = nil;
    self.backgroundView = nil;
    [self setCancelButton:nil];
    [self setDoneButton:nil];
    self.pickerList = nil;
    [super viewDidUnload];
    
}
- (void)dealloc 
{
    
    [alertView release];
    [myPickerView release];
    [backgroundView release];
    [doneButton release];
    [cancelButton release];
    [super dealloc];
}
#pragma mark -
#pragma mark Private Methods
- (void)alertDidFadeOut
{    
    [self.view removeFromSuperview];
    [self autorelease];
}

#pragma mark -
#pragma mark CAAnimation Delegate Methods
- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag {
//    NSLog(@"%s", __FUNCTION__);
//    
//    if (dateToShow) {
//        pickerView.date = dateToShow;
//        return;
//    }
//    
//    NSDate *now = [NSDate date];
//    pickerView.date = now; //set the date picker to today's date initially
    
    [myPickerView reloadAllComponents];
}

@end
