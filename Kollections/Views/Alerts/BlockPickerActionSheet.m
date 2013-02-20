//
//  BlockPickerActionSheet.m
//  BlockAlertsDemo
//
//  Created by Kerry Knight on 1/11/13.
//  Copyright (c) 2013 Kerry Knight. All rights reserved.
//

#import "BlockPickerActionSheet.h"

#define kPickerViewHeight   226
#define kPickerViewY        40

@interface BlockPickerActionSheet()
@property(nonatomic, copy) PickerReturnCallBack callBack;
@end

@implementation BlockPickerActionSheet
@synthesize picker, callBack;
@synthesize pickerList;
@synthesize pickerSelection;

+ (BlockPickerActionSheet *)pickerWithTitle:(NSString *)title withChoices:(NSArray*)choices defaultSelection:(NSDictionary*)defaultSelection {
    return [self pickerWithTitle:title withChoices:choices defaultSelection:defaultSelection block:nil];
}

+ (BlockPickerActionSheet *)pickerWithTitle:(NSString *)title withChoices:(NSArray*)choices defaultSelection:(NSDictionary*)defaultSelection block:(PickerReturnCallBack)block {
    return [[[BlockPickerActionSheet alloc] initWithTitle:title withChoices:choices defaultSelection:defaultSelection block:block] autorelease];
}

+ (BlockPickerActionSheet *)pickerWithTitle:(NSString *)title withChoices:(NSArray*)choices pickerSelection:(out NSDictionary**)selection {
    return [self pickerWithTitle:title withChoices:choices pickerSelection:selection block:nil];
}


+ (BlockPickerActionSheet *)pickerWithTitle:(NSString *)title withChoices:(NSArray*)choices pickerSelection:(out NSDictionary**)selection block:(PickerReturnCallBack) block{
    BlockPickerActionSheet *picker = [[[BlockPickerActionSheet alloc] initWithTitle:title withChoices:choices defaultSelection:nil block:block] autorelease];
    
    //set the callback selection's pointer to our uipickerview's selection
    if (selection)*selection = picker.pickerSelection;
    
    return picker;
}

- (id)initWithTitle:(NSString *)title withChoices:(NSArray*)choices defaultSelection:(NSDictionary*)defaultSelection block:(PickerReturnCallBack)block {
    self = [super initWithTitle:title];
    
    if (self) {
        
        CGRect frame = self.view.frame;
        UIPickerView *thePicker = [[[UIPickerView alloc] initWithFrame:CGRectMake(frame.origin.x + 10, kPickerViewY, 298, kPickerViewHeight)] autorelease];
        [thePicker setShowsSelectionIndicator:NO];//our png will contain this
        [thePicker reloadAllComponents];
        
        //create the overlay image view to add on top of the picker
        UIImageView *overlay = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"actionSheet-picker-overlay.png"]] autorelease];
        overlay.frame = thePicker.frame;
        
        //init selection if not available
        if(!self.pickerSelection)self.pickerSelection = [[NSMutableDictionary new] autorelease];
        if(self.pickerList)self.pickerList = [[NSMutableArray new] autorelease];
        
        if ([choices count]) {
            //we have a list to populate the picker with
            self.pickerList = choices;
        } else {
            //TODO: after working
            self.pickerList = [[@[
                                @{@"title":@"Error: Try again",
                                @"objectId":@"1"}] mutableCopy] autorelease];
        }
        
        if (defaultSelection)
            self.pickerSelection = defaultSelection;
        
        if(block){
            thePicker.delegate = self;
        }
        
        [_view addSubview:thePicker];
        [_view addSubview:overlay];
        
        self.picker = thePicker;//set our property equal to our picker
        
        _height += kPickerViewHeight;
        
        self.callBack = block;
    }
    
    return self;
}

- (void)showInView:(UIView *)view {
    [super showInView:view];
}

- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex withObject:(id)object animated:(BOOL)animated {
//    NSLog(@"%s", __FUNCTION__);
    [super dismissWithClickedButtonIndex:buttonIndex withObject:self.pickerSelection animated:animated];
}

#pragma mark - UIPickerView delegate methods
#define PICKER_COMPONENT_WIDTH 278
#define PICKER_LABEL_FONT_SIZE 22
#define PICKER_LABEL_ALPHA 1.0

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    
    return PICKER_COMPONENT_WIDTH;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    
    UIFont *font = [UIFont fontWithName:@"OriyaSangamMN-Bold" size:PICKER_LABEL_FONT_SIZE];
    UILabel *pickerTextLabel = [[[UILabel alloc] initWithFrame:CGRectMake(20, 3, PICKER_COMPONENT_WIDTH - 30, 40)] autorelease];
    pickerTextLabel.textColor = kGray5;
    pickerTextLabel.font = font;
    pickerTextLabel.numberOfLines = 1;
    pickerTextLabel.lineBreakMode = UILineBreakModeWordWrap;
    pickerTextLabel.backgroundColor = [UIColor clearColor];
    pickerTextLabel.opaque = NO;
    
    if (row > 0) {//keep the first row of pickerview blank to make sure user selects an actual entry
        pickerTextLabel.text = [[self.pickerList objectAtIndex:(int)row - 1] objectForKey:kKKCategoryTitleKey];//TODO: key if other lists passed in
    } else {
        pickerTextLabel.text = @"";
        pickerTextLabel.textColor = kGray3;
    }
    
    return pickerTextLabel;
    [self.picker reloadAllComponents];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (row > 0 && component == 0) {
        self.pickerSelection = [self.pickerList objectAtIndex:[pickerView selectedRowInComponent:0]-1];
    }
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [self.pickerList count] + 1;
    [self.picker reloadAllComponents];
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (void)dealloc {
    self.callBack = nil;
    [super dealloc];
}

@end
