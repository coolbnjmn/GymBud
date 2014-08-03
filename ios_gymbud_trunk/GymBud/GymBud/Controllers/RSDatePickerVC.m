//
//  RSDatePickerVC.m
//  GymBud
//
//  Created by Benjamin Hendricks on 8/3/14.
//  Copyright (c) 2014 GymBud. All rights reserved.
//

#import "RSDatePickerVC.h"

@interface RSDatePickerVC() <RSDFDatePickerViewDelegate, RSDFDatePickerViewDataSource>

@end

@interface RSDatePickerVC ()

@end

@implementation RSDatePickerVC
@synthesize datePickerView = _datePickerView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addSubview:self.datePickerView];
}

- (RSDFDatePickerView *)datePickerView
{
    if (!_datePickerView) {
        _datePickerView = [RSDFDatePickerView new];
        _datePickerView.delegate = self;
        _datePickerView.dataSource = self;
        _datePickerView.frame = self.view.bounds;
        _datePickerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return _datePickerView;
}

#pragma mark - RSDFDatePickerViewDelegate

- (void)datePickerView:(RSDFDatePickerView *)view didSelectDate:(NSDate *)date
{
    [[[UIAlertView alloc] initWithTitle:@"Picked Date" message:[date description] delegate:nil cancelButtonTitle:@":D" otherButtonTitles:nil] show];
}

#pragma mark - RSDFDatePickerViewDataSource

- (NSDictionary *)datePickerViewMarkedDates:(RSDFDatePickerView *)view
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *todayComponents = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:[NSDate date]];
    NSDate *today = [calendar dateFromComponents:todayComponents];
    
    NSArray *numberOfDaysFromToday = @[@(-8), @(-2), @(-1), @(0), @(2), @(4), @(8), @(13), @(22)];
    
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    NSMutableDictionary *markedDates = [[NSMutableDictionary alloc] initWithCapacity:[numberOfDaysFromToday count]];
    [numberOfDaysFromToday enumerateObjectsUsingBlock:^(NSNumber *numberOfDays, NSUInteger idx, BOOL *stop) {
        dateComponents.day = [numberOfDays integerValue];
        NSDate *date = [calendar dateByAddingComponents:dateComponents toDate:today options:0];
        if ([date compare:today] == NSOrderedAscending) {
            markedDates[date] = @YES;
        } else {
            markedDates[date] = @NO;
        }
    }];
    
    return [markedDates copy];
}

@end
