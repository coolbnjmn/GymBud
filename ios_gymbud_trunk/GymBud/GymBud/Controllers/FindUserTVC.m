//
//  FindUserTVC.m
//  GymBud
//
//  Created by Benjamin Hendricks on 7/21/14.
//  Copyright (c) 2014 GymBud. All rights reserved.
//

#import "FindUserTVC.h"
#import "MessageUserVC.h"
#import "MBProgressHUD.h"
#import "GymBudConstants.h"
#import "Mixpanel.h"

@interface FindUserTVC () <UISearchDisplayDelegate, UISearchBarDelegate>

@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UISearchDisplayController *searchController;
@property (nonatomic, strong) NSMutableArray *searchResults;
@property (nonatomic, strong) MBProgressHUD *HUD;

@end

@implementation FindUserTVC

- (void)viewDidLoad {
    
    self.tableView.tableHeaderView = nil;
    self.tableView.scrollEnabled = YES;
    
    self.searchBar = [[UISearchBar alloc] init];
    
    
    self.searchController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    
    self.searchController.searchResultsDataSource = self;
    self.searchController.searchResultsDelegate = self;
    self.searchController.delegate = self;
    self.tableView.tableHeaderView = self.searchBar;
    
    self.searchBar.tintColor = [UIColor colorWithRed:44/255.0f green:62/255.0f blue:80/255.0f alpha:1.0f];
    
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Bold" size:10.0f],
                                                        NSForegroundColorAttributeName : [UIColor colorWithRed:44/255.0f green:62/255.0f blue:80/255.0f alpha:1.0f]
                                                        } forState:UIControlStateNormal];
    self.searchBar.barTintColor = [UIColor colorWithRed:60/255.0f green:151/255.0f blue:211/255.0f alpha:1.0f];

    self.searchResults = [NSMutableArray array];
    [super viewDidLoad];
}

- (void)filterResults:(NSString *)searchTerm {
    NSLog(@"filterResults being called");
    [self.searchResults removeAllObjects];
    
    PFQuery *query = [PFUser query];
    
    NSArray *results  = [query findObjects];
    NSMutableArray *actualResults = [[NSMutableArray alloc] initWithCapacity:10];
    
    for (PFUser *user in results) {
        NSString *name;
        if([[user objectForKey:@"gymbudProfile"] objectForKey:@"name"]) {
            name = [[user objectForKey:@"gymbudProfile"] objectForKey:@"name"];
        } else {
            name = [[user objectForKey:@"profile"] objectForKey:@"name"];
        }
        if ([name rangeOfString:searchTerm].location == NSNotFound) {
        } else {
            [actualResults addObject:user];
        }
    }
    
    NSLog(@"%@", actualResults);
    NSLog(@"%u", actualResults.count);
    
    [self.searchResults addObjectsFromArray:actualResults];
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
        NSLog(@"self.objects.count = %d", self.objects.count);
        return self.objects.count;
    } else {
        NSLog(@"self.searchResults.count = %d", self.searchResults.count);
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
    
    self.HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:self.HUD];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kLoadingAnimationWidth, kLoadingAnimationHeight)];
    imageView.image = [UIImage imageNamed:kLoadingImageFirst];
    //Add more images which will be used for the animation
    imageView.animationImages = kLoadingImagesArray;
    
    //Set the duration of the animation (play with it
    //until it looks nice for you)
    imageView.animationDuration = kLoadingAnimationDuration;
    [imageView startAnimating];
    imageView.contentMode = UIViewContentModeScaleToFill;
    self.HUD.customView = imageView;
    self.HUD.mode = MBProgressHUDModeCustomView;
    self.HUD.color = [UIColor clearColor];
    [self.HUD show:YES];
    for (UIView *subview in self.view.subviews)
    {
        if ([subview class] == NSClassFromString(@"PFLoadingView"))
        {
            [subview removeFromSuperview];
        }
    }
    [self setLoadingViewEnabled:NO];
    return query;
}

- (void)objectsDidLoad:(NSError *)error {
    
    NSLog(@"objectsDidLoad Find User TVC");
    [super objectsDidLoad:error];
    [self.HUD hide:YES];

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
    
    if (cell == nil) {
        cell = [[PFTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:uniqueIdentifier];

    }

    if (tableView != self.searchDisplayController.searchResultsTableView) {
        if([[object objectForKey:@"gymbudProfile"] objectForKey:@"name"]) {
            cell.textLabel.text = [[object objectForKey:@"gymbudProfile"] objectForKey:@"name"];
        } else {
            cell.textLabel.text = [[object objectForKey:@"profile"] objectForKey:@"name"];
        }
    }
    if ([tableView isEqual:self.searchDisplayController.searchResultsTableView]) {
        PFUser *obj2 = [self.searchResults objectAtIndex:indexPath.row];
        if([[obj2 objectForKey:@"gymbudProfile"] objectForKey:@"name"]) {
            cell.textLabel.text = [[obj2 objectForKey:@"gymbudProfile"] objectForKey:@"name"];
        } else {
            cell.textLabel.text = [[obj2 objectForKey:@"profile"] objectForKey:@"name"];
        }
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
//    detailViewController.user = [[super objects] objectAtIndex:indexPath.row];
    if (tableView != self.searchDisplayController.searchResultsTableView) {
        detailViewController.user = [[super objects] objectAtIndex:indexPath.row];
        
    }
    if ([tableView isEqual:self.searchDisplayController.searchResultsTableView]) {
        detailViewController.user = [self.searchResults objectAtIndex:indexPath.row];
    }
    // Push the view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"FindUserTVC SelectedRow" properties:@{
                                                           }];
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
