//
//  AlbumPickerController.m
//
//  Created by Matt Tuzzolo on 2/15/11.
//  Copyright 2011 ELC Technologies. All rights reserved.
//

#import "ELCAlbumPickerController.h"
#import "ELCImagePickerController.h"
#import "ELCAssetTablePicker.h"

@implementation ELCAlbumPickerController

@synthesize parent, assetGroups;

#pragma mark -
#pragma mark View lifecycle

#define kROW_AND_CONTENT_HEIGHT 57.0f

- (void)viewDidLoad {
//    NSLog(@"%s", __FUNCTION__);
    [super viewDidLoad];
	
	[self.navigationItem setTitle:@"Loading..."];

    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"kkBackgroundNavBar.png"] forBarMetrics:UIBarMetricsDefault];
    
    self.tableView.backgroundColor = [UIColor clearColor];
    
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
	self.assetGroups = tempArray;
    
    library = [[ALAssetsLibrary alloc] init];      

    // Load Albums into assetGroups
    dispatch_async(dispatch_get_main_queue(), ^
    {
        // Group enumerator Block
        void (^assetGroupEnumerator)(ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *group, BOOL *stop) 
        {
            if (group == nil)  {
                return;
            }
            
            [self.assetGroups addObject:group];

            // Reload albums
            [self performSelectorOnMainThread:@selector(reloadTableView) withObject:nil waitUntilDone:YES];
        };
        
        // Group Enumerator Failure Block
        void (^assetGroupEnumberatorFailure)(NSError *) = ^(NSError *error) {
            //show custom alert
            BlockAlertView *alert = [BlockAlertView alertWithTitle:@"Error" message:[NSString stringWithFormat:@"Album Error: %@ - %@", [error localizedDescription], [error localizedRecoverySuggestion]]];
            [alert setCancelButtonWithTitle:@"OK" block:nil];
            [alert show];
        };	
                
        // Enumerate Albums
        [library enumerateGroupsWithTypes:ALAssetsGroupAlbum
                               usingBlock:assetGroupEnumerator 
                             failureBlock:assetGroupEnumberatorFailure];
        
    });    
}

-(void)reloadTableView {
	
	[self.tableView reloadData];
	[self.navigationItem setTitle:@"Albums"];
}

-(void)selectedAssets:(NSArray*)_assets {
//	NSLog(@"%s", __FUNCTION__);
	[(ELCImagePickerController*)parent selectedAssets:_assets];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.assetGroups count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    static NSUInteger const kAlbumTitleTag = 1;
    static NSUInteger const kAlbumPhotoTag = 2;
    
    UILabel *albumTitleLabel = nil;
    UIImageView *albumPhotoImageView = nil;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        //add our album title label
        albumTitleLabel = [[UILabel alloc] init];
        albumTitleLabel.tag = kAlbumTitleTag;
        albumTitleLabel.textAlignment = UITextAlignmentLeft;
        [albumTitleLabel setTextColor:kCreme];
        [albumTitleLabel setShadowColor:kGray6];
        [albumTitleLabel setShadowOffset:CGSizeMake(0.0f, 1.0f)];
        albumTitleLabel.frame = CGRectMake(70, 8, 250, tableView.rowHeight);
        [albumTitleLabel setFont:[UIFont fontWithName:@"OriyaSangamMN" size:16]];
        [albumTitleLabel setBackgroundColor:[UIColor clearColor]];
        [cell.contentView addSubview:albumTitleLabel];
        
        //add our custom accessory disclosure 
        UILabel *accessoryLabel = [[UILabel alloc] initWithFrame:CGRectMake(295, 8, 20, kROW_AND_CONTENT_HEIGHT - 10)];
        accessoryLabel.text = @">";
        [accessoryLabel setFont:[UIFont fontWithName:@"OriyaSangamMN-Bold" size:24]];
        [accessoryLabel setTextColor:kGray2];
        [accessoryLabel setShadowColor:kGray6];
        accessoryLabel.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:accessoryLabel];
        
        //add our album photo image view
        albumPhotoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kROW_AND_CONTENT_HEIGHT, kROW_AND_CONTENT_HEIGHT)];
        albumPhotoImageView.tag = kAlbumPhotoTag;
        albumPhotoImageView.layer.borderColor = kGray3.CGColor;
        albumPhotoImageView.layer.borderWidth = 1.00f;
        [cell.contentView addSubview:albumPhotoImageView];
    } else {
        // A reusable cell was available, so we just need to get a reference to the subviews using their tags.
        albumTitleLabel = (UILabel *)[cell.contentView viewWithTag:kAlbumTitleTag];
        albumPhotoImageView = (UIImageView *)[cell.contentView viewWithTag:kAlbumPhotoTag];
    }
    
    // Get album count
    ALAssetsGroup *g = (ALAssetsGroup*)[self.assetGroups objectAtIndex:indexPath.row];
    [g setAssetsFilter:[ALAssetsFilter allPhotos]];
    NSInteger gCount = [g numberOfAssets];
    
    //set the title for the label
    albumTitleLabel.text = [NSString stringWithFormat:@"%@ (%d)",[g valueForProperty:ALAssetsGroupPropertyName], gCount];
    
    //set our album photo image
    [albumPhotoImageView setImage:[UIImage imageWithCGImage:[(ALAssetsGroup*)[self.assetGroups objectAtIndex:indexPath.row] posterImage]]];
    
	[cell setAccessoryType:UITableViewCellAccessoryNone];
	cell.selectionStyle = UITableViewCellSelectionStyleGray;
    
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	ELCAssetTablePicker *picker = [[ELCAssetTablePicker alloc] initWithNibName:@"ELCAssetTablePicker" bundle:[NSBundle mainBundle]];
	picker.parent = self;
    picker.mainView = self.mainView;
    picker.mainTableView = self.mainTableView;

    //tell the picker what the title should be by getting the title from the cell we just touched
    // Get count
    ALAssetsGroup *g = (ALAssetsGroup*)[self.assetGroups objectAtIndex:indexPath.row];
    picker.albumTitle = [NSString stringWithFormat:@"%@",[g valueForProperty:ALAssetsGroupPropertyName]];
    
    // Move me    
    picker.assetGroup = [self.assetGroups objectAtIndex:indexPath.row];
    [picker.assetGroup setAssetsFilter:[ALAssetsFilter allPhotos]];
    
	[self.navigationController pushViewController:picker animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	return kROW_AND_CONTENT_HEIGHT;
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc 
{	
}

@end

