//
//  AssetTablePicker.h
//
//  Created by Matt Tuzzolo on 2/15/11.
//  Copyright 2011 ELC Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "ELCAsset.h"

@interface ELCAssetTablePicker : UITableViewController <ELCAssetDelegate>{
	int selectedAssets;
	NSOperationQueue *queue;
}

@property (nonatomic, strong) id parent;
@property (nonatomic, strong) ALAssetsGroup *assetGroup;
@property (nonatomic, strong) NSMutableArray *elcAssets;
@property (nonatomic, strong) IBOutlet UILabel *selectedAssetsLabel;
@property (nonatomic, strong) NSString *albumTitle;
@property (nonatomic, strong) UIView *mainView;
@property (nonatomic, strong) UIView *mainTableView;
@property (nonatomic, strong) NSArray *dropTargets;

-(int)totalSelectedAssets;
-(void)preparePhotos;
-(void)doneAction:(id)sender;

@end