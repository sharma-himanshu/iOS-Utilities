//
//  GFPlainTableViewController.h
//  GameFly
//
//  Created by Himanshu Sharma on 12/22/15.
//  Copyright © 2015 GameFly. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FilterSelectionDelegate <NSObject>

- (void)didSelectFilterWithObject:(id)object;

@end

@interface GFPlainTableViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *dataSource;
@property (weak, nonatomic) id<FilterSelectionDelegate> delegate;

@end
