//
//  KKHorizontalTableCell.m
//  Kollections
//
//  Created by Kerry Knight on 1/9/13.
//  Copyright (c) 2013 Kerry Knight. All rights reserved.
//

#import "KKHorizontalTableCell.h"
#import "KKKollectionTitleLabel.h"
#import "KKKollectionViewCell.h"
#import "KKSideScrollingTableViewConstants.h"

@implementation KKHorizontalTableCell

- (id)initWithFrame:(CGRect)frame {
//    NSLog(@"%s", __FUNCTION__);
    if ((self = [super initWithFrame:frame])) {
        self.horizontalTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kCellHeight, kHorizontalCellContentWidth)];
        self.horizontalTableView.showsVerticalScrollIndicator = NO;
        self.horizontalTableView.showsHorizontalScrollIndicator = NO;
        self.horizontalTableView.transform = CGAffineTransformMakeRotation(-M_PI * 0.5);
        [self.horizontalTableView setFrame:CGRectMake(0, 0, kHorizontalCellContentWidth, kCellHeight)];
        
        self.horizontalTableView.rowHeight = kCellWidth;
        self.horizontalTableView.backgroundColor = [UIColor clearColor];
        
        self.horizontalTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.horizontalTableView.separatorColor = [UIColor clearColor];
        
        self.horizontalTableView.dataSource = self;
        self.horizontalTableView.delegate = self;
        
        //add a container view to hold the table so we only show it within our table graphic and not from offscreen
        self.tableContainerView = [[UIView alloc] initWithFrame:CGRectMake(kHorizontalCellContentX, 0, kHorizontalCellContentWidth, 100)];
        self.tableContainerView.backgroundColor = [UIColor clearColor];
        [self.tableContainerView addSubview:self.horizontalTableView];
        
        [self addSubview:self.tableContainerView];
        
        self.contentView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"kkTableBodyBG.png"]];
        self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"kkTableBodyBG.png"]];
    }
    
    return self;
}

#pragma mark - Table View Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    NSLog(@"%s", __FUNCTION__);
    
    if ([self.kollections count] > 0) {
        return [self.kollections count];
    }
    
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"KKKollectionViewCell";
    
    __block KKKollectionViewCell *cell = (KKKollectionViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[KKKollectionViewCell alloc] initWithFrame:CGRectMake(0, 0, kCellWidth, kCellHeight)];
    }
    
    //check if we have any kollections to display
    
    if ([self.kollections count] > 0) {
        __block NSDictionary *currentKollection = [self.kollections objectAtIndex:indexPath.row];
        
        dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        
        dispatch_async(concurrentQueue, ^{
            UIImage *image = nil;
            image = [UIImage imageNamed:[currentKollection objectForKey:@"ImageName"]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [cell.thumbnail setImage:image];
            });
        });
        
        cell.titleLabel.text = [currentKollection objectForKey:@"Title"];
    } else {
        //just show the Add button
        dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        
        dispatch_async(concurrentQueue, ^{
            UIImage *image = [UIImage imageNamed:@"kkAddButtonUp.png"];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [cell.thumbnail setImage:image];
                cell.titleLabel.text = @"Add";
            });
        });
        
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"%s %@", __FUNCTION__, indexPath);
//    HorizontalTablesAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
//    
//    ArticleDetailViewController *articleDetailViewController = [[ArticleDetailViewController alloc] initWithNibName:@"ArticleDetailViewController" bundle:[NSBundle mainBundle]];
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    [appDelegate.navigationController pushViewController:articleDetailViewController animated:YES];
}

- (NSString *) reuseIdentifier {
    return @"KKHorizontalTableCell";
}

@end
