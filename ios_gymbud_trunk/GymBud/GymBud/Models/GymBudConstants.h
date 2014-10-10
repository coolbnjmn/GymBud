//
//  GymBudConstants.h
//  GymBud
//
//  Created by Benjamin Hendricks on 8/3/14.
//  Copyright (c) 2014 GymBud. All rights reserved.
//

// Activities
#define kGymBudActivities [NSArray arrayWithObjects: @"Aerobics", @"Crossfit", @"Running", @"Swimming", @"Sports", @"Strength Training", @"Other", nil]
#define kGymBudActivityMapIcons [NSArray arrayWithObjects: @"aerobicsMap.png", @"crossfitMap.png", @"runningMap.png", @"swimmingMap.png", @"sportsmap.png", @"weightliftingMap.png", @"othermap.png", nil]
#define kGymBudActivityIcons [NSArray arrayWithObjects: @"aerobicsIcon.png", @"crossfitIcon.png", @"runningIcon.png", @"swimmingIcon.png", @"sports.png", @"weightliftingIcon.png", @"other.png", nil]

// Count Stuff
#define kGymBudCountArray [NSArray arrayWithObjects: @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"11", @"12", @"13", @"14", nil]
#define kGymBudDurationMinuteArray [NSArray arrayWithObjects: @"0", @"15", @"30", @"45", nil]
#define kGymBudDurationHourArray [NSArray arrayWithObjects: @"0", @"1", @"2", @"3", @"4", @"5", nil]

// Icon Mappings
#define kGymBudActivityIconMapping [NSDictionary dictionaryWithObjects:kGymBudActivityIcons forKeys:kGymBudActivities]
#define kGymBudActivityMapIconMapping [NSDictionary dictionaryWithObjects:kGymBudActivityMapIcons forKeys:kGymBudActivities]


#define kGoogleApiKey @"AIzaSyBYOIc_oRgl8ridepQWCR3mG9IkfEODe8A"

#define kFacebookUsername @"user_fb_name"

// Loading Animation Stuff
#define kLoadingAnimationHeight 138
#define kLoadingAnimationWidth 200
#define kLoadingAnimationDuration 0.9
#define kLoadingLogoName @"loadingLogo"
#define kLoadingImageFirst @"load9.png"
#define kLoadingImagesArray [NSArray arrayWithObjects:[UIImage imageNamed:@"load9.png"],[UIImage imageNamed:@"load8.png"],[UIImage imageNamed:@"load7.png"],[UIImage imageNamed:@"load6.png"],[UIImage imageNamed:@"load5.png"],[UIImage imageNamed:@"load4.png"],[UIImage imageNamed:@"load3.png"],[UIImage imageNamed:@"load2.png"],[UIImage imageNamed:@"load1.png"],nil]

// Body Parrt Stuff
#define kGBBodyPartArray [NSArray arrayWithObjects:@"Full Body", @"Chest", @"Back", @"Legs", @"Shoulders", @"Arms", @"Abs", nil]
#define kGBBodyPartImagesArray [NSArray arrayWithObjects: @"body.png", @"chest.png", @"back.png", @"legs.png", @"shoulders.png", @"arms.png", @"abs.png", nil]
#define kGBBodyPartMapping [NSDictionary dictionaryWithObjects:kGBBodyPartImagesArray forKeys:kGBBodyPartArray]


#define kPreferredTimes [NSArray arrayWithObjects: @"Morning (6AM-Noon)", @"Afternoon (Noon-5PM)", @"Evening (5PM-Midnight)", nil]
#define kPreferredTimesShort [NSArray arrayWithObjects: @"Morning", @"Afternoon", @"Evening", nil]

#define kGBSports [NSArray arrayWithObjects:@"Football", @"Baseball", @"Basketball", @"Hockey", @"Golf", @"Soccer", @"Tennis", @"Boxing", @"Olympic Sports", @"Lacrosse", @"Rugby", @"Cricket", @"Martial Arts", nil]

#define kGBOther [NSArray arrayWithObjcts:@"
