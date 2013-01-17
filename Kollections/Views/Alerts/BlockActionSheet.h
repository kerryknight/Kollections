//
//  BlockActionSheet.h
//
//

#import <UIKit/UIKit.h>

/**
 * A simple block-enabled API wrapper on top of UIActionSheet.
 */

typedef void (^BlockPickerButtonCallback) (id result);

@interface BlockActionSheet : NSObject {
@protected
    UIView *_view;
    NSMutableArray *_blocks;
    CGFloat _height;
}

@property (nonatomic, readonly) UIView *view;
@property (nonatomic, readwrite) BOOL vignetteBackground;

+ (id)sheetWithTitle:(NSString *)title;

- (id)initWithTitle:(NSString *)title;

- (void)setCancelButtonWithTitle:(NSString *) title block:(BlockPickerButtonCallback)completion;
- (void)setDestructiveButtonWithTitle:(NSString *) title block:(BlockPickerButtonCallback)completion;
- (void)addButtonWithTitle:(NSString *) title block:(BlockPickerButtonCallback)completion;

- (void)setCancelButtonWithTitle:(NSString *) title atIndex:(NSInteger)index block:(BlockPickerButtonCallback)completion;
- (void)setDestructiveButtonWithTitle:(NSString *) title atIndex:(NSInteger)index block:(BlockPickerButtonCallback)completion;
- (void)addButtonWithTitle:(NSString *) title atIndex:(NSInteger)index block:(BlockPickerButtonCallback)completion;
- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex withObject:(id)object animated:(BOOL)animated;
- (void)showInView:(UIView *)view;

- (NSUInteger)buttonCount;

@end
