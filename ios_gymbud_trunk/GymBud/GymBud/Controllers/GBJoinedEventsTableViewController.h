//
//  GBJoinedEventsTableViewController.h
//  GymBud
//
//  Created by Hashim Shafique on 12/12/14.
//  Copyright (c) 2014 GymBud. All rights reserved.
//

#import <ParseUI/ParseUI.h>
#import <Parse/Parse.h>

@interface GBJoinedEventsTableViewController : PFQueryTableViewController
{
    NSArray *originalData;
    NSMutableArray *searchData;
    
    UISearchBar *searchBar;
    UISearchDisplayController *searchDisplayController;
}

@end
