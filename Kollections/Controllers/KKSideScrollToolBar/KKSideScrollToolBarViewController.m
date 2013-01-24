//
//  KKSideScrollToolBarViewController.m
//  Kollections
//
//  Created by Kerry Knight on 1/3/13.
//  Copyright (c) 2013 Kerry Knight. All rights reserved.
//

#import "KKSideScrollToolBarViewController.h"

@interface KKSideScrollToolBarViewController () {
    //need to track the index of the tool we've selected so that we don't allow selecting the same tool
    //twice in a row; i.e., if it's already selected, do nothing further on additional touches
    NSInteger selectedIndex;
}

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
- (void)selectFirstToolbarItemAtLoad;
@end

@implementation KKSideScrollToolBarViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc {
    [self setCollectionView:nil];
}

#define TOOLBAR_COLLECTION_ITEM_WIDTH 94.0

- (void)viewDidLoad {
//    NSLog(@"%s", __FUNCTION__);
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //load the nib for the collection view cell
    UINib *cellNib = [UINib nibWithNibName:@"KKToolbarCell" bundle:nil];
    [self.collectionView registerNib:cellNib forCellWithReuseIdentifier:@"KKToolbarCell"];
    
    //start the toolbar loaded all the way to the right so that we can animate it back to the left
    //so the user knows there are multiple options for them to access
    CGPoint offset = CGPointMake(self.collectionView.frame.size.width, 1);
    [self.collectionView setContentOffset:offset animated:NO];
    
    //calling the method directly was resulting in a crash, so using a selector with slight delay to alleviate
    //retarded that doing it this way works and [self selectFirstToolbarItemAtLoad] doesn't as well as ensure user sees animation
    [self performSelector:@selector(selectFirstToolbarItemAtLoad) withObject:nil afterDelay:0.65];
}

- (void)selectFirstToolbarItemAtLoad {
//    NSLog(@"%s", __FUNCTION__);
    //always select the first item when loading the toolbar
    NSIndexPath *myIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    [self.collectionView selectItemAtIndexPath:myIndexPath animated:YES scrollPosition:UICollectionViewScrollPositionLeft];
    selectedIndex = 0; //set the initial selected index to 0
    [self.delegate didTouchToolbarItemAtIndex:selectedIndex];//we'll initially load the Kollections table sections
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionView Datasource
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return [self.segmentTitles count];
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"KKToolbarCell" forIndexPath:indexPath];
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:100];//we just added a tag to the nib, no property necessary
    
    //set each button's (e.g. collection view cell) text from the array values we pass in
    NSString *cellData = [self.segmentTitles objectAtIndex:indexPath.row];
    [titleLabel setText:cellData];
    
    return cell;
}

//- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
//    
//    return [[UICollectionReusableView alloc] init];
//}

#pragma mark - UICollectionViewDelegate
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    //only allow selection of an item if it's not already selected
    if (selectedIndex != indexPath.row) {
        return YES;
    } else {
        return NO;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    //set the selectedIndex to the newly selected item
    selectedIndex = indexPath.row;
    
    //pass it to KKAccountViewController (the delegate) for further processing
    [self.delegate didTouchToolbarItemAtIndex:selectedIndex];
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
    
    return CGSizeMake(TOOLBAR_COLLECTION_ITEM_WIDTH, 37);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

@end
