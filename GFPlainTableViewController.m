//
//  GFPlainTableViewController.m
//  GameFly
//
//  Created by Himanshu Sharma on 12/22/15.
//  Copyright © 2015 GameFly. All rights reserved.
//

#import "GFPlainTableViewController.h"

@interface GFPlainTableViewController ()

@end

@implementation GFPlainTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!self.dataSource) {
        self.dataSource = @[ @"Popularity", @"Release Date", @"User Rating", @"A-Z"];
    }
    [self.tableView reloadData];

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataSource count];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [UIView new];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"basicCell" forIndexPath:indexPath];
    if ([[self.dataSource objectAtIndex:indexPath.row] isKindOfClass:[RetailPlatform class]]) {
        RetailPlatform *platform = (RetailPlatform *)[self.dataSource objectAtIndex:indexPath.row];
        cell.textLabel.text = platform.name;
    }
    else {
        cell.textLabel.text = [self.dataSource objectAtIndex:indexPath.row];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectFilterWithObject:)]) {
        [self.delegate didSelectFilterWithObject:[self.dataSource objectAtIndex:indexPath.row]];
    }
    [self dismissViewControllerAnimated:YES completion:^{}];
}

@end
