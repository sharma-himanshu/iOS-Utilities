//
//  GFEndlessCollectionView.h
//  GameFly
//
//  Created by Himanshu Sharma on 12/20/15.
//  Copyright © 2015 GameFly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GFSimplePagedCollection.h"
#import "GFEndlessViews.h"

@protocol GFEndlessCollectionViewDelegate <NSObject>

- (NSString *)collectionCellReuseIdentifier;

@optional

- (NSString *)emptyCollectionNibName;
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section;
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView;
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath;
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath;
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath;
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section;
-(void)didSelectObjectInCollection:(id)object;
- (void)collectionLoadFinished;

@end

@interface GFEndlessCollectionView : UICollectionView<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) GFSimplePagedCollection *pagedCollection;
@property (nonatomic, weak) id<GFEndlessCollectionViewDelegate> endlessDelegate;

- (void)initializeData;
- (UICollectionViewCell *)returnStandardCollectionViewCellWithCollection:(UICollectionView *)collection withIndexPath:(NSIndexPath *)indexPath;

@end
