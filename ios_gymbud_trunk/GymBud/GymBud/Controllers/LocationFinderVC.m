//
//  LocationFinderVC.m
//  GymBud
//
//  Created by Benjamin Hendricks on 12/11/14.
//  Copyright (c) 2014 GymBud. All rights reserved.
//

#import "LocationFinderVC.h"
#import "AppDelegate.h"
#import <AFNetworking/AFNetworking.h>
#import "GymBudConstants.h"

@interface LocationFinderVC () <UITextFieldDelegate, MLPAutoCompleteTextFieldDataSource, MLPAutoCompleteTextFieldDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property NSMutableArray *places;
@end

@implementation LocationFinderVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.places = [[NSMutableArray alloc] init];
    self.locationFinder.autoCompleteDataSource = self;
    self.locationFinder.autoCompleteDelegate = self;
    self.locationFinder.delegate = self;
    self.locationFinder.autoCompleteTableAppearsAsKeyboardAccessory = NO;
    self.locationFinder.autoCompleteTableOriginOffset = CGSizeMake(0, -self.view.bounds.size.height + 45);
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    if(![self.input isEqualToString:@""]) {
        self.locationFinder.text = self.input;
        NSURL *url = [NSURL URLWithString:@"https://maps.googleapis.com/maps/api/place/autocomplete/"];
        
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        CLLocation *currentLocation = appDelegate.currentLocation;
        
        NSDictionary *params = @{@"input" : [self.input stringByReplacingOccurrencesOfString:@" " withString:@"+"],
                                 @"location" : [NSString stringWithFormat:@"%f,%f", currentLocation.coordinate.latitude, currentLocation.coordinate.longitude],
                                 @"sensor" : @"true",
                                 @"key" : kGoogleApiKey};
        
        AFHTTPSessionManager *httpSessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:url];
        [httpSessionManager GET:@"json" parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
            //        NSLog(@"\n============= Entity Saved Success ===\n%@",responseObject);
            [self.places removeAllObjects];
            for(id description in responseObject[@"predictions"]) {
                [self.places addObject:description[@"description"]];
                [self.tableView reloadData];
            }
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            NSLog(@"\n============== ERROR ====\n%@",error.userInfo);
        }];

    }
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Auto Complete Data Source / Delegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if([textField isEqual:self.locationFinder]) {
        if(textField.text.length < 2) {
            return YES;
        }
        NSURL *url = [NSURL URLWithString:@"https://maps.googleapis.com/maps/api/place/autocomplete/"];

        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        CLLocation *currentLocation = appDelegate.currentLocation;

        NSDictionary *params = @{@"input" : [textField.text stringByReplacingOccurrencesOfString:@" " withString:@"+"],
                                 @"location" : [NSString stringWithFormat:@"%f,%f", currentLocation.coordinate.latitude, currentLocation.coordinate.longitude],
                                 @"sensor" : @"true",
                                 @"key" : kGoogleApiKey};

        AFHTTPSessionManager *httpSessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:url];
        [httpSessionManager GET:@"json" parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
            //        NSLog(@"\n============= Entity Saved Success ===\n%@",responseObject);
            [self.places removeAllObjects];
            for(id description in responseObject[@"predictions"]) {
                [self.places addObject:description[@"description"]];
                [self.tableView reloadData];
            }
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            NSLog(@"\n============== ERROR ====\n%@",error.userInfo);
        }];

        return YES;
    } else return YES;

}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.places count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"placeCell"];
    cell.textLabel.text = [self.places objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.delegate performSelector:@selector(didSetLocation:) withObject:[self.places objectAtIndex:indexPath.row]];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSArray *)autoCompleteTextField:(MLPAutoCompleteTextField *)textField
      possibleCompletionsForString:(NSString *)string {
    if([textField isEqual:self.locationFinder]) {
        return self.places;
    } else return [NSArray new];
}
@end
