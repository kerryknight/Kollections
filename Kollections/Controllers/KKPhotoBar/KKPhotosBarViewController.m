//
//  KKPhotosBarViewController.m
//  Photos
//
//  Created by Kerry Knight on 1/8/13.
//  Copyright (c) 2013 Kerry Knight. All rights reserved.
//

#import "KKPhotosBarViewController.h"
#import "UIImage+Colorization.h"

@interface KKPhotosBarViewController () {
    //need to track the index of the tool we've selected so that we don't allow selecting the same tool
    //twice in a row; i.e., if it's already selected, do nothing further on additional touches
    NSInteger selectedIndex;
}
@end

@implementation KKPhotosBarViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#define TOOLBAR_COLLECTION_ITEM_WIDTH   158.0
#define TOOLBAR_COLLECTION_ITEM_HEIGHT  112.0
#define KK_PHOTO_CELL @"KKPhotoBarCell"
#define kPhotoImageViewTag         100
#define kNO_SUBJECT_SUBMISSIONS_LABEL 98

- (void)viewDidLoad {
//    NSLog(@"%s", __FUNCTION__);
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //load the nib for each collection view cell
    //the photo cell
    UINib *cellNib = [UINib nibWithNibName:KK_PHOTO_CELL bundle:nil];
    [self.collectionView registerNib:cellNib forCellWithReuseIdentifier:KK_PHOTO_CELL];
    
    //remove any extraneous observers
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //add notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadPhotoData:) name:@"PhotosBarViewControllerReloadPhotosData" object:nil];
    
    //set to first cell by default
    selectedIndex = 0;
    
}

- (void)viewWillAppear:(BOOL)animated {
//    NSLog(@"%s", __FUNCTION__);
    [super viewWillAppear:animated];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) dealloc {
    [self setCollectionView:nil];
}

#pragma mark - Custom Methods
- (void)reloadPhotoData:(NSNotification*)notification {
//    NSLog(@"%s", __FUNCTION__);
    [self.collectionView reloadData];
    
    //reload the collection view data and scroll back to our newly created object
    [self.collectionView scrollToItemAtIndexPath:0 atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
}

#pragma mark - UICollectionView Datasource
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    
    if ([self.photos count] > 0) {
        return [self.photos count];
    }
    
    return 0;//we'll show a "no photos yet" label
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSUInteger photoItemCount = [self.photos count];
    UICollectionViewCell *cell;
    
    if (!self.photos || photoItemCount == 0 || indexPath.row == photoItemCount) {
        //don't show anything here
        return cell;
    }
    
    //else, we show a regular cell
    cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:KK_PHOTO_CELL forIndexPath:indexPath];
    
    //set each button's (e.g. collection view cell) text from the photo object passed in
    PFObject *photo = [self.photos objectAtIndex:indexPath.row];

    //now add a PFImageView to the cell to load the kollection's cover photo in the background
    //add image view to hold the kollections cover photo
    PFImageView *photoThumbnailImageView = [[PFImageView alloc] initWithFrame:CGRectMake(11.0f, 11.0f, 135.0f, 90.0f)];
    photoThumbnailImageView.tag = kPhotoImageViewTag;
    [cell.contentView addSubview:photoThumbnailImageView];
    [photoThumbnailImageView setContentMode:UIViewContentModeScaleAspectFill];
    CALayer *layer = [photoThumbnailImageView layer];
    layer.masksToBounds = YES;
    photoThumbnailImageView.alpha = 0.0f;
    
    //now, lazily load all our kollection cover pictures, if we have them
    PFFile *imageFile = photo[kKKPhotoThumbnailKey];
    
    if (imageFile) {
        [photoThumbnailImageView setFile:imageFile];
        [photoThumbnailImageView loadInBackground:^(UIImage *image, NSError *error) {
            if (!error) {
                [UIView animateWithDuration:0.200f animations:^{
                    photoThumbnailImageView.alpha = 1.0f;//load the photo into the imageview
                    //add a new touch down background
                    //also, change the down image of the image so we darken the whole thing and don't show the down placeholder image
                    UIImage *downImage = [UIImage darkenImage:image toLevel:1.2];
                    [photoThumbnailImageView setHighlightedImage:downImage];
                }];
            } else {
                NSLog(@"error loading in background for index %i = \n\n%@", indexPath.row, [error localizedDescription]);
            }
        }];
    
    }
    
    return cell;
}

//- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
//
//    return [[UICollectionReusableView alloc] init];
//}

#pragma mark - UICollectionViewDelegate
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    //    //only allow selection of an item if it's not already selected
    //    if (selectedIndex != indexPath.row) {
    //        return YES;
    //    } else {
    //        return NO;
    //    }
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    //    NSLog(@"%s", __FUNCTION__);
    //set the selectedIndex to the newly selected item
    selectedIndex = indexPath.row;
    
    BOOL createNew = NO;
    
    if (([self.photos count] == 0) || [self.photos count] == selectedIndex) {
        //we clicked the Add New item
        createNew = YES;
    } else {
        createNew = NO;
    }
    
    //deselect the selected item
    [self.collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    //tell the delegate what item was touched on what row so i can load the proper follow-up view
    [self.delegate didSelectPhotoBarItemAtIndex:selectedIndex];
}

#pragma mark – UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return CGSizeMake(TOOLBAR_COLLECTION_ITEM_WIDTH, TOOLBAR_COLLECTION_ITEM_HEIGHT);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

@end
