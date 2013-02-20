//
//  AlbumPickerController.h
//
//  Created by Matt Tuzzolo on 2/15/11.
//  Copyright 2011 ELC Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface ELCAlbumPickerController : UITableViewController {
	
	NSOperationQueue *queue;
    ALAssetsLibrary *library;
}

@property (nonatomic, strong) id parent;
@property (nonatomic, strong) NSMutableArray *assetGroups;
@property (nonatomic, strong) UIView *mainView;
@property (nonatomic, strong) UIView *mainTableView;
//@property (nonatomic, strong) NSArray *dropTargets;

-(void)selectedAssets:(NSArray*)_assets;

@end

