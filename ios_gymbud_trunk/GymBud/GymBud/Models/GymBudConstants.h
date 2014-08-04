//
//  GymBudConstants.h
//  GymBud
//
//  Created by Benjamin Hendricks on 8/3/14.
//  Copyright (c) 2014 GymBud. All rights reserved.
//

#define kGymBudActivities [NSArray arrayWithObjects: @"Aerobics", @"Basketball", @"Crossfit", @"Running", @"Swimming", @"Weightlifting", @"Yoga", nil]
#define kGymBudActivityMapIcons [NSArray arrayWithObjects: @"aerobicsMap.png", @"basketballMap.png", @"crossfitMap.png", @"runningMap.png", @"swimmingMap.png", @"weightliftingMap.png", @"yogaMap.png", nil]
#define kGymBudActivityIcons [NSArray arrayWithObjects: @"aerobicsIcon.png", @"basketballIcon.png", @"crossfitIcon.png", @"runningIcon.png", @"swimmingIcon.png", @"weightliftingIcon.png", @"yogaIcon.png", nil]


#define kGymBudActivityIconMapping [NSDictionary dictionaryWithObjects:kGymBudActivityIcons forKeys:kGymBudActivities]
#define kGymBudActivityMapIconMapping [NSDictionary dictionaryWithObjects:kGymBudActivityMapIcons forKeys:kGymBudActivities]
