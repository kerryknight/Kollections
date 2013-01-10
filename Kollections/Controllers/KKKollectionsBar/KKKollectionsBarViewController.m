//
//  KKKollectionsBarViewController.m
//  Kollections
//
//  Created by Kerry Knight on 1/8/13.
//  Copyright (c) 2013 Kerry Knight. All rights reserved.
//

#import "KKKollectionsBarViewController.h"

@interface KKKollectionsBarViewController () {
    //need to track the index of the tool we've selected so that we don't allow selecting the same tool
    //twice in a row; i.e., if it's already selected, do nothing further on additional touches
    NSInteger selectedIndex;
}

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
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

#define TOOLBAR_COLLECTION_ITEM_WIDTH   94.0
#define TOOLBAR_COLLECTION_ITEM_HEIGHT  94.0
#define KK_NORMAL_CELL @"KKKollectionsCell"
#define KK_ADD_CELL @"KKKollectionsAddCell"

- (void)viewDidLoad {
//    NSLog(@"%s", __FUNCTION__);
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //load the nib for each collection view cell
    //the add new cell
    UINib *cellNib = [UINib nibWithNibName:KK_ADD_CELL bundle:nil];
    [self.collectionView registerNib:cellNib forCellWithReuseIdentifier:KK_ADD_CELL];
    
    
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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    UICollectionViewCell *cell;
    
    if (!self.kollections || [self.kollections count] == 0) {
        //only show the Add button if there are no kollections to display
        cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:KK_ADD_CELL forIndexPath:indexPath];
    } else {
        cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:KK_NORMAL_CELL forIndexPath:indexPath];
        
        UILabel *titleLabel = (UILabel *)[cell viewWithTag:100];//we just added a tag to the nib, no property necessary
        
        //set each button's (e.g. collection view cell) text from the array values we pass in
        NSString *cellData = [self.kollections objectAtIndex:indexPath.row];
        [titleLabel setText:cellData];
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
    
    NSLog(@"didSelectCollectionView kollectiontype = %i", self.kollectionType);
    NSLog(@"didSelectCollectionView identifier = %@", self.identifier);
    
    //deselect the selected item
    [self.collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    //tell the delegate what item was touched on what row so i can load the proper follow-up view
    [self.delegate didSelectKollectionBarItemAtIndex:selectedIndex ofKollectionType:self.kollectionType];
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
    [super viewDidUnload];
}
@end
