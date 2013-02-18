//
//  Asset.h
//
//  Created by Matt Tuzzolo on 2/15/11.
//  Copyright 2011 ELC Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@protocol ELCAssetDelegate;

@interface ELCAsset : UIView {
	ALAsset *asset;
	UIImageView *overlayView;
	BOOL selected;
	id parent;
}

@property (nonatomic, strong) ALAsset *asset;
@property (nonatomic, strong) id parent;
@property (nonatomic, strong) UIView *mainView; //view we want to drop into
@property (nonatomic, strong) UITableView *tableParent;//container view for our object
@property (nonatomic, strong) id<ELCAssetDelegate> delegate;

-(id)initWithAsset:(ALAsset*)_asset;
-(BOOL)selected;

@end

@protocol ELCAssetDelegate
@optional
-(void)photoTouchDown:(ELCAsset*)photo;
-(void)photoTouchUp:(ELCAsset*)photo;
//-(BOOL) isInsideKollectionView:(ELCAsset *)photo touching:(BOOL)finished;
@end