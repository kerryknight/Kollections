//
//  KKKollectionsBarViewController.m
//  Kollections
//
//  Created by Kerry Knight on 1/8/13.
//  Copyright (c) 2013 Kerry Knight. All rights reserved.
//

#import "KKKollectionsBarViewController.h"
#import "UIImage+Colorization.h"

@interface KKKollectionsBarViewController () {
    //need to track the index of the tool we've selected so that we don't allow selecting the same tool
    //twice in a row; i.e., if it's already selected, do nothing further on additional touches
    NSInteger selectedIndex;
}

@property (nonatomic, assign) KKKollectionType kollectionType;
@end

@implementation KKKollectionsBarViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#define TOOLBAR_COLLECTION_ITEM_WIDTH   111.0
#define TOOLBAR_COLLECTION_ITEM_HEIGHT  93.0
#define KK_NORMAL_CELL @"KKKollectionsCell"
#define KK_ADD_CELL @"KKKollectionsAddCell"
#define kKollectionIconTitleTag         99
#define kCoverPhotoImageViewTag         100
#define kNoCoverPhotoLabelTag           101

- (void)viewDidLoad {
//    NSLog(@"%s", __FUNCTION__);
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //load the nib for each collection view cell
    //the add new cell
    UINib *cellNib1 = [UINib nibWithNibName:KK_ADD_CELL bundle:nil];
    [self.collectionView registerNib:cellNib1 forCellWithReuseIdentifier:KK_ADD_CELL];
    
    //the regular cell
    UINib *cellNib2 = [UINib nibWithNibName:KK_NORMAL_CELL bundle:nil];
    [self.collectionView registerNib:cellNib2 forCellWithReuseIdentifier:KK_NORMAL_CELL];
    
    
    //set the kollection type based on the identifier we passed in
    switch ([self.identifier intValue]) {
        case KKKollectionTypeMyPublic:
            self.kollectionType = KKKollectionTypeMyPublic;
            break;
        case KKKollectionTypeMyPrivate:
            self.kollectionType = KKKollectionTypeMyPrivate;
            break;
        case KKKollectionTypeSubscribedPublic:
            self.kollectionType = KKKollectionTypeSubscribedPublic;
            break;
        case KKKollectionTypeSubscribedPrivate:
            self.kollectionType = KKKollectionTypeSubscribedPrivate;
            break;
        default:
            break;
    }
    
    //add notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadKollectionData:) name:@"KollectionsBarViewControllerReloadKollectionsData" object:nil];
    
    //set to first cell by default
    selectedIndex = 0;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.collectionView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Custom Methods
- (void)reloadKollectionData:(NSNotification*)notification {
    NSLog(@"%s", __FUNCTION__);
    [self.collectionView reloadData];
}

#pragma mark - UICollectionView Datasource
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    
    if ([self.kollections count] > 0) {
        return [self.kollections count] + 1; //+1 to show the add/find buttons at the end of the list
    }
    
    return 1;//just show the add button if no kollections to display
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSUInteger kollectionItemCount = [self.kollections count];
    UICollectionViewCell *cell;
    
    if (!self.kollections || kollectionItemCount == 0 || indexPath.row == kollectionItemCount) {
        //show the Add button if there are no kollections to display or it's the last cell in the row
        cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:KK_ADD_CELL forIndexPath:indexPath];
//        NSLog(@"cell for add before = %@", cell);
        return cell;
    }
    
    //else, we show a regular cell
    cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:KK_NORMAL_CELL forIndexPath:indexPath];
    
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:kKollectionIconTitleTag];//we just added a tag to the nib, no property necessary
    titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:13.0];
    UILabel *noPhotoLabel = (UILabel*)[cell viewWithTag:kNoCoverPhotoLabelTag];
    noPhotoLabel.hidden = YES;//default
    
    //set each button's (e.g. collection view cell) text from the kollection object passed in
    PFObject *kollection = [self.kollections objectAtIndex:indexPath.row];
    [titleLabel setText:kollection[kKKKollectionTitleKey]];
    
    if ([titleLabel.text length] > 10) {
        //make it a smaller font
        titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:9.0];
    }
    
    //now add a PFImageView to the cell to load the kollection's cover photo in the background
    //add image view to hold the kollections cover photo
    PFImageView *coverPhotoImageView = [[PFImageView alloc] initWithFrame:CGRectMake(16.0f, 14.0f, 78.0f, 53.0f)];
    coverPhotoImageView.tag = kCoverPhotoImageViewTag;
    [cell.contentView addSubview:coverPhotoImageView];
    [coverPhotoImageView setContentMode:UIViewContentModeScaleAspectFill];
    CALayer *layer = [coverPhotoImageView layer];
    layer.masksToBounds = YES;
    coverPhotoImageView.alpha = 0.0f;
    
    //now, lazily load all our kollection cover pictures, if we have them
    PFFile *imageFile = kollection[kKKKollectionCoverPhotoThumbnailKey];
    if (imageFile) {
        [coverPhotoImageView setFile:imageFile];
        [coverPhotoImageView loadInBackground:^(UIImage *image, NSError *error) {
            if (!error) {
                [UIView animateWithDuration:0.200f animations:^{
                    coverPhotoImageView.alpha = 1.0f;//load the photo into the imageview
                    //add a new touch down background
                    //also, change the down image of the image so we darken the whole thing and don't show the down placeholder image
                    UIImage *downImage = [UIImage darkenImage:image toLevel:1.2];
                    [coverPhotoImageView setHighlightedImage:downImage];
                }];
            }
        }];
    } else {
        //show the "no photo" label
        UILabel *noPhotoLabel = (UILabel*)[cell viewWithTag:kNoCoverPhotoLabelTag];
        noPhotoLabel.hidden = NO;
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
    
    if (([self.kollections count] == 0) || [self.kollections count] == selectedIndex) {
        NSLog(@"clicked on add new item");
        //we clicked the Add New item
        createNew = YES;
    } else {
        NSLog(@"clicked on existing item");
        createNew = NO;
    }
    
//    NSLog(@"didSelectCollectionView kollectiontype = %i", self.kollectionType);
//    NSLog(@"didSelectCollectionView identifier = %@", self.identifier);
    
    //deselect the selected item
    [self.collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    //tell the delegate what item was touched on what row so i can load the proper follow-up view
    [self.delegate didSelectKollectionBarItemAtIndex:selectedIndex ofKollectionType:self.kollectionType shouldCreateNew:createNew];
}

#pragma mark – UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
//    NSString *searchTerm = self.searches[indexPath.section];
//    FlickrPhoto *photo =
//    self.searchResults[searchTerm][indexPath.row];
//    // 2
//    CGSize retval = photo.thumbnail.size.width > 0 ? photo.thumbnail.size : CGSizeMake(100, 100);
//    retval.height += 35; retval.width += 35;
//    return retval;
    
    return CGSizeMake(TOOLBAR_COLLECTION_ITEM_WIDTH, TOOLBAR_COLLECTION_ITEM_HEIGHT);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (void)viewDidUnload {
    [self setCollectionView:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"KollectionsBarViewControllerReloadKollectionsData" object:nil];
    [super viewDidUnload];
}
@end
