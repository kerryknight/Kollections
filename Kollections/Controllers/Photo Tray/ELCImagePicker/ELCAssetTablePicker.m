//
//  AssetTablePicker.m
//
//  Created by Matt Tuzzolo on 2/15/11.
//  Copyright 2011 ELC Technologies. All rights reserved.
//

#import "ELCAssetTablePicker.h"
#import "ELCAssetCell.h"
#import "ELCAsset.h"
#import "ELCAlbumPickerController.h"
#import "KKToolbarButton.h"


@implementation ELCAssetTablePicker

@synthesize parent;
@synthesize selectedAssetsLabel;
@synthesize assetGroup, elcAssets;

-(void)viewDidLoad {
//    NSLog(@"%s", __FUNCTION__);
	[self.tableView setSeparatorColor:[UIColor clearColor]];
	[self.tableView setAllowsSelection:NO];

    self.tableView.backgroundColor = [UIColor clearColor];
    
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    self.elcAssets = tempArray;
	
	[self performSelectorInBackground:@selector(preparePhotos) withObject:nil];
    
    // Show partial while full list loads
	[self.tableView performSelector:@selector(reloadData) withObject:nil afterDelay:.5];
}

-(void)preparePhotos {
//    NSLog(@"%s", __FUNCTION__);
//    NSLog(@"enumerating photos");
    [self.assetGroup enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop)
     {         
         if(result == nil) 
         {
             return;
         }
         
         ELCAsset *elcAsset = [[ELCAsset alloc] initWithAsset:result];
         [elcAsset setParent:self];
         [self.elcAssets addObject:elcAsset];
     }];    
//    NSLog(@"done enumerating photos");
	
	[self.tableView reloadData];
	[self.navigationItem setTitle:@"Photos"];
    

}

- (void) doneAction:(id)sender {
	
	NSMutableArray *selectedAssetsImages = [[NSMutableArray alloc] init];
	    
	for(ELCAsset *elcAsset in self.elcAssets) {		
		if([elcAsset selected]) {
			
			[selectedAssetsImages addObject:[elcAsset asset]];
		}
	}
        
    [(ELCAlbumPickerController*)self.parent selectedAssets:selectedAssetsImages];
}

#pragma mark UITableViewDataSource Delegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (ceil([self.assetGroup numberOfAssets] / 4.0) + 1);
}

- (NSArray*)assetsForIndexPath:(NSIndexPath*)_indexPath {
    
	int index = ((_indexPath.row - 1)*4);//knightka subtract 1 since we aren't starting our table rows until after navigation header row at indexpath 0
	int maxIndex = ((_indexPath.row - 1)*4+3);
    
//	NSLog(@"Getting assets for %d to %d with array count %d", index, maxIndex, [self.elcAssets count]);
    
	if(maxIndex < [self.elcAssets count]) {
        
		return [NSArray arrayWithObjects:[self.elcAssets objectAtIndex:index],
				[self.elcAssets objectAtIndex:index+1],
				[self.elcAssets objectAtIndex:index+2],
				[self.elcAssets objectAtIndex:index+3],
				nil];
	}
    
	else if(maxIndex-1 < [self.elcAssets count]) {
        
		return [NSArray arrayWithObjects:[self.elcAssets objectAtIndex:index],
				[self.elcAssets objectAtIndex:index+1],
				[self.elcAssets objectAtIndex:index+2],
				nil];
	}
    
	else if(maxIndex-2 < [self.elcAssets count]) {
        
		return [NSArray arrayWithObjects:[self.elcAssets objectAtIndex:index],
				[self.elcAssets objectAtIndex:index+1],
				nil];
	}
    
	else if(maxIndex-3 < [self.elcAssets count]) {
        
		return [NSArray arrayWithObject:[self.elcAssets objectAtIndex:index]];
	}
    
	return nil;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        //put in our pseudo navigation bar
        static NSString *CellIdentifier = @"CellA";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        cell.contentView.backgroundColor = [UIColor clearColor];
        cell.backgroundColor = [UIColor clearColor];
        
        //add a custom back button
        KKToolbarButton *backButton = [[KKToolbarButton alloc] initWithFrame:kKKBarButtonItemLeftFrame isBackButton:YES andTitle:@"Back"];
        [backButton addTarget:self action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:backButton];
        
        //add a header label to tell us what album we're looking at
        UILabel *headerLabel = [[UILabel alloc] init];
        headerLabel.textAlignment = UITextAlignmentCenter;
        [headerLabel setTextColor:kCreme];
        [headerLabel setShadowColor:kGray6];
        [headerLabel setShadowOffset:CGSizeMake( 0.0f, 1.0f)];
        headerLabel.frame = CGRectMake(75.0f, 2.0f, cell.contentView.frame.size.width - 150.0f, self.tableView.rowHeight);
        [headerLabel setFont:[UIFont fontWithName:@"OriyaSangamMN-Bold" size:20]];
        [headerLabel setBackgroundColor:[UIColor clearColor]];
        headerLabel.text = self.albumTitle;
        [cell.contentView addSubview:headerLabel];
        
        //blank out generic stuff
        cell.textLabel.text = @"";
        cell.detailTextLabel.text = @"";
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;//disable selection
        return cell;
        
    } else {
        static NSString *CellIdentifier = @"Cell";
        
        ELCAssetCell *cell = (ELCAssetCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            cell = [[ELCAssetCell alloc] initWithAssets:[self assetsForIndexPath:indexPath] reuseIdentifier:CellIdentifier];
        }
        else {
            [cell setAssets:[self assetsForIndexPath:indexPath]];
        }
        
        //set our delegate for each of the items in each cell row
        for(ELCAsset *elcAsset in cell.rowAssets) {
            elcAsset.delegate = self;
            
            //add our drop targets here 
        }
        
        return cell;
    }
}

#pragma mark - ELCAssetDelegate
-(void)photoTouchDown:(ELCAsset*)photo{
//    NSLog(@"%s", __FUNCTION__);
    
    self.tableView.scrollEnabled = NO;
    
    NSDictionary *userInfo = @{@"photo": photo};
    
    //post a notification with our photo object included to be passed to KKKollectionViewController
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PhotosTrayPhotoTouchDown" object:nil userInfo:userInfo];
}

-(void)photoTouchUp:(ELCAsset*)photo {
//    NSLog(@"%s", __FUNCTION__);
    
    self.tableView.scrollEnabled = YES;
}

-(BOOL) isInsideKollectionView:(ELCAsset *)photo touching:(BOOL)finished {
    NSLog(@"%s", __FUNCTION__);
//    CGPoint newLoc = [self convertPoint:self.recycleBin.frame.origin toView:self.mainView];
//    CGRect binFrame = self.recycleBin.frame;
//    binFrame.origin = newLoc;
//    
//    if (CGRectIntersectsRect(binFrame, button.frame) == TRUE){
//        if (finished){
//            [self removeAttachment:button];
//        }
//        return YES;
//    }
//    else {
//        return NO;
//    }
    return NO;
}

- (void)backButtonAction:(id)sender {
    //    NSLog(@"%s", __FUNCTION__);
    
    //tell KKKollectionViewController to dismiss any potentially visible enlarged selected photo
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PhotosTrayDismissAnySelectedPhoto" object:nil];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        return 44;
    }
    
	return 79;
}

- (int)totalSelectedAssets {
    
    int count = 0;
    
    for(ELCAsset *asset in self.elcAssets) 
    {
		if([asset selected]) 
        {            
            count++;	
		}
	}
    
    return count;
}

- (void)dealloc 
{
    
}

@end
