//
//  FindUserTVC.m
//  GymBud
//
//  Created by Benjamin Hendricks on 7/21/14.
//  Copyright (c) 2014 GymBud. All rights reserved.
//

#import "FindUserTVC.h"
#import "MessageUserVC.h"

@interface FindUserTVC () <UISearchDisplayDelegate, UISearchBarDelegate>

@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UISearchDisplayController *searchController;
@property (nonatomic, strong) NSMutableArray *searchResults;

@end

@implementation FindUserTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    
    self.tableView.tableHeaderView = self.searchBar;
    
    self.searchController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    
    self.searchController.searchResultsDataSource = self;
    self.searchController.searchResultsDelegate = self;
    self.searchController.delegate = self;
        
    CGPoint offset = CGPointMake(0, self.searchBar.frame.size.height);
    
    self.tableView.contentOffset = offset;

    self.searchResults = [NSMutableArray array];
}

- (void)filterResults:(NSString *)searchTerm {
    
    [self.searchResults removeAllObjects];
    
    PFQuery *query = [PFUser query];
    [query whereKey:@"profile" containsString:searchTerm];
    
    NSArray *results  = [query findObjects];
    
    NSLog(@"%@", results);
    NSLog(@"%u", results.count);
    
    [self.searchResults addObjectsFromArray:results];
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    [self filterResults:searchString];
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (tableView == self.tableView) {
        return self.objects.count;
    } else {
        return self.searchResults.count;
    }
    
}
#pragma mark - PFQueryTableViewController

- (PFQuery *)queryForTable {
    
    //    if (![PFUser currentUser]) {
    //        PFQuery *query = [PFQuery queryWithClassName:@"Activity"];
    //        [query setLimit:0];
    //        return query;
    //    }
    
    PFQuery *query = [PFUser query];
    [query setCachePolicy:kPFCachePolicyNetworkOnly];
    return query;
}

- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    
    NSLog(@"objectsDidLoad Find User TVC");
    self.tableView.tableHeaderView = nil;
    self.tableView.scrollEnabled = YES;
    
    //    NSUInteger unreadCount = 0;
    //    for (PFObject *activity in self.objects) {
    //        if ([lastRefresh compare:[activity createdAt]] == NSOrderedAscending && ![[activity objectForKey:kPAPActivityTypeKey] isEqualToString:kPAPActivityTypeJoined]) {
    //            unreadCount++;
    //        }
    //    }
    //
    //    if (unreadCount > 0) {
    //        self.navigationController.tabBarItem.badgeValue = [NSString stringWithFormat:@"%d",unreadCount];
    //    } else {
    //        self.navigationController.tabBarItem.badgeValue = nil;
    //    }
}



- (PFTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object
{
//    PFTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserCell"];
//    
//    if(cell == nil) {
//        cell = [[PFTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"UserCell"];
//    }
//    
//    cell.textLabel.text = [[object objectForKey:@"profile"] objectForKey:@"name"];
//    return cell;
    
    NSString *uniqueIdentifier = @"UserCell";
    
    PFTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:uniqueIdentifier];
    
    if (!cell) {
        cell = [[PFTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:uniqueIdentifier];

    }
    
    
    if (tableView != self.searchDisplayController.searchResultsTableView) {
        cell.textLabel.text = [[object objectForKey:@"profile"] objectForKey:@"name"];

    }
    if ([tableView isEqual:self.searchDisplayController.searchResultsTableView]) {
        PFUser *obj2 = [self.searchResults objectAtIndex:indexPath.row];
        cell.textLabel.text = [[obj2 objectForKey:@"profile"] objectForKey:@"name"];
    }
    return cell;

}

#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here, for example:
    // Create the next view controller.
    MessageUserVC *detailViewController = [[MessageUserVC alloc] init];
    
    // Pass the selected object to the new view controller.
    detailViewController.user = [[super objects] objectAtIndex:indexPath.row];
    // Push the view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
