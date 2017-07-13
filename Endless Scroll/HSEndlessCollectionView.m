//
//  HSEndlessCollectionView.m
//
//  Created by Himanshu Sharma on 7/12/17.
//

#import "GFEndlessCollectionView.h"
#import "GFSpinner.h"
#import "LoadingView.h"

@implementation GFEndlessCollectionView

- (void)initializeData
{
    self.dataSource = self;
    self.delegate = self;
    [self registerNib:[UINib nibWithNibName:@"FooterReusableView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"footerReusableView"];
    
    [self registerNib:[UINib nibWithNibName:@"HeaderReusableView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"headerReusableView"];
    
    [self registerNib:[UINib nibWithNibName:@"LoadingCollectionViewCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"LoadingCell"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkCallCompletedWithResponse:) name:@"pagedNetworkCallFinished" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)keyboardWillShow:(NSNotification*)notification {
    NSDictionary *info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    self.contentInset = UIEdgeInsetsMake(0, 0, kbSize.height, 0);
}

- (void)keyboardWillHide:(NSNotification*)notification {
    self.contentInset = UIEdgeInsetsZero;
}

- (NSString *)emptyCollectionNibName
{
    if (self.endlessDelegate && [self.endlessDelegate respondsToSelector:@selector(emptyCollectionNibName)]) {
        return [self.endlessDelegate emptyCollectionNibName];
    }
    return @"NoResultsView";
}

#pragma mark 
#pragma mark CollectionView Delegate & DataSource Methods
#pragma mark

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (self.endlessDelegate && [self.endlessDelegate respondsToSelector:@selector(collectionView:numberOfItemsInSection:)]) {
        return [self.endlessDelegate collectionView:collectionView numberOfItemsInSection:section];
    }
    return [self.pagedCollection.objects count];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    if (self.endlessDelegate && [self.endlessDelegate respondsToSelector:@selector(numberOfSectionsInCollectionView:)]) {
        return [self.endlessDelegate numberOfSectionsInCollectionView:collectionView];
    }
    return 1;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if (kind == UICollectionElementKindSectionHeader) {
        if (self.endlessDelegate && [self.endlessDelegate respondsToSelector:@selector(collectionView:viewForSupplementaryElementOfKind:atIndexPath:)]) {
            return [self.endlessDelegate collectionView:collectionView viewForSupplementaryElementOfKind:kind atIndexPath:indexPath];
        }
        else {
            UICollectionReusableView *reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"headerReusableView" forIndexPath:indexPath];
            return reusableView;
        }
    }
    else if (kind == UICollectionElementKindSectionFooter) {
        UICollectionReusableView *reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"footerReusableView" forIndexPath:indexPath];
        return reusableView;
    }
    

    return nil;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < [self.pagedCollection.objects count]) {
        if (self.endlessDelegate && [self.endlessDelegate respondsToSelector:@selector(collectionView:cellForItemAtIndexPath:)]) {
            return [self.endlessDelegate collectionView:collectionView cellForItemAtIndexPath:indexPath];
        }
        return [self returnStandardCollectionViewCellWithCollection:collectionView withIndexPath:indexPath];
    }
    else {
        return [self dequeueReusableCellWithReuseIdentifier:@"LoadingCell" forIndexPath:indexPath];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.endlessDelegate && [self.endlessDelegate respondsToSelector:@selector(collectionView:layout:sizeForItemAtIndexPath:)]) {
        return [self.endlessDelegate collectionView:collectionView layout:collectionViewLayout sizeForItemAtIndexPath:indexPath];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    if (self.endlessDelegate && [self.endlessDelegate respondsToSelector:@selector(collectionView:layout:referenceSizeForHeaderInSection:)]) {
        return [self.endlessDelegate collectionView:collectionView layout:collectionViewLayout referenceSizeForHeaderInSection:section];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    return CGSizeMake(self.bounds.size.width, [self.pagedCollection canLoadNextPage] ? 44 : 0);
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat contentOffset = scrollView.contentOffset.y;
    CGFloat maxOffset = scrollView.contentSize.height - scrollView.frame.size.height;
    if (maxOffset - contentOffset <= 400 && [self.pagedCollection canLoadNextPage]) {
        [self.pagedCollection fetchPageFromDataSource];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self deselectItemAtIndexPath:indexPath animated:YES];
    if (self.endlessDelegate && [self.endlessDelegate respondsToSelector:@selector(didSelectObjectInCollection:)]) {
        [self.endlessDelegate didSelectObjectInCollection:[self.pagedCollection.objects objectAtIndex:indexPath.row]];
    }
}

- (void)networkCallCompletedWithResponse:(NSNotification *)note
{
    if ([[note userInfo] objectForKey:@"isTableCollection"]) {
        if ([[[note userInfo] objectForKey:@"isTableCollection"] boolValue]) {
            return;
        }
    }
    [GFSpinner removeFromKeyWindowWithView:self];
    // Special Case only for Injecting Static Search Results into the search Results
    // HS TODO, move out of here and find a more suitable way to support this custom hack
    if ([[note userInfo] objectForKey:@"searchMatches"]) {
        for (id object in [[note userInfo] objectForKey:@"searchMatches"]) {
            if (![self.pagedCollection.objects containsObject:object]) {
                [self.pagedCollection.objects insertObject:object atIndex:0];
            }
        }
    }
    if ([self.pagedCollection.objects count] == 0 && ![self viewWithTag:101] && self.pagedCollection.objects) {
        NSArray *nibObjects = [[NSBundle mainBundle] loadNibNamed:[self emptyCollectionNibName] owner:self options:nil];
        UIView *emptyView = [nibObjects objectAtIndex:0];
        emptyView.tag = 101;
        emptyView.frame = CGRectMake(emptyView.frame.origin.x, [self collectionView:self layout:self.collectionViewLayout referenceSizeForHeaderInSection:0].height, self.frame.size.width, emptyView.frame.size.height);
        [self addSubview:emptyView];
    }
    else if ([self.pagedCollection.objects count] > 0)
    {
        [[self viewWithTag:101] removeFromSuperview];
    }
    RetailResponse *response = [[note userInfo] objectForKey:@"response"];
    if (!response.retailError) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self reloadData];
            
        });
    }
}

- (UICollectionViewCell *)returnStandardCollectionViewCellWithCollection:(UICollectionView *)collection withIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell <GFCollectionCellProtocol> *tmpCell;
    tmpCell = [collection dequeueReusableCellWithReuseIdentifier:[self.endlessDelegate collectionCellReuseIdentifier] forIndexPath:indexPath];
    
    if (tmpCell)
    {
        if ([tmpCell conformsToProtocol:@protocol(GFCollectionCellProtocol)])
        {
            [tmpCell configureCellWithObject:[self.pagedCollection.objects objectAtIndex:indexPath.row]];
        }
        else
        {
            DError(@"The collection cell doesn't conform to the <GFCollectionCellProtocol> protocol");
        }
    }
    else
    {
        // error failed to
        DError(@"failed to dequeue a cell");
    }
    return tmpCell;
}

@end
