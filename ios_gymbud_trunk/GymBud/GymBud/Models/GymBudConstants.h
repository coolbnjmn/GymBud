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
#define kLoadingAnimationHeight 58
#define kLoadingAnimationWidth 59
#define kLoadingAnimationDuration 1.08
#define kLoadingImageFirst @"1.png"
#define kLoadingImagesArray [NSArray arrayWithObjects:[UIImage imageNamed:@"1.png"],[UIImage imageNamed:@"2.png"],[UIImage imageNamed:@"3.png"],[UIImage imageNamed:@"4.png"],[UIImage imageNamed:@"5.png"],[UIImage imageNamed:@"6.png"],[UIImage imageNamed:@"7.png"],[UIImage imageNamed:@"8.png"],[UIImage imageNamed:@"9.png"], [UIImage imageNamed:@"10.png"], [UIImage imageNamed:@"11.png"], [UIImage imageNamed:@"12.png"],[UIImage imageNamed:@"13.png"],[UIImage imageNamed:@"14.png"],[UIImage imageNamed:@"15.png"],[UIImage imageNamed:@"16.png"],[UIImage imageNamed:@"17.png"],[UIImage imageNamed:@"18.png"],[UIImage imageNamed:@"19.png"], [UIImage imageNamed:@"20.png"], [UIImage imageNamed:@"21.png"], [UIImage imageNamed:@"22.png"],[UIImage imageNamed:@"23.png"],[UIImage imageNamed:@"24.png"],[UIImage imageNamed:@"25.png"],[UIImage imageNamed:@"26.png"],[UIImage imageNamed:@"27.png"],[UIImage imageNamed:@"28.png"],[UIImage imageNamed:@"29.png"], [UIImage imageNamed:@"30.png"], [UIImage imageNamed:@"31.png"], [UIImage imageNamed:@"32.png"],[UIImage imageNamed:@"33.png"],[UIImage imageNamed:@"34.png"],[UIImage imageNamed:@"35.png"],[UIImage imageNamed:@"36.png"],[UIImage imageNamed:@"37.png"],[UIImage imageNamed:@"38.png"],[UIImage imageNamed:@"39.png"], [UIImage imageNamed:@"40.png"], [UIImage imageNamed:@"41.png"], [UIImage imageNamed:@"42.png"],[UIImage imageNamed:@"43.png"],[UIImage imageNamed:@"44.png"],[UIImage imageNamed:@"45.png"],[UIImage imageNamed:@"46.png"],[UIImage imageNamed:@"47.png"],[UIImage imageNamed:@"48.png"],[UIImage imageNamed:@"49.png"], [UIImage imageNamed:@"50.png"], [UIImage imageNamed:@"51.png"], [UIImage imageNamed:@"52.png"],[UIImage imageNamed:@"53.png"],[UIImage imageNamed:@"54.png"],[UIImage imageNamed:@"55.png"],[UIImage imageNamed:@"56.png"],[UIImage imageNamed:@"57.png"],[UIImage imageNamed:@"58.png"],[UIImage imageNamed:@"59.png"], [UIImage imageNamed:@"60.png"], [UIImage imageNamed:@"61.png"], [UIImage imageNamed:@"62.png"],[UIImage imageNamed:@"63.png"],[UIImage imageNamed:@"64.png"],[UIImage imageNamed:@"65.png"],[UIImage imageNamed:@"66.png"],[UIImage imageNamed:@"67.png"],[UIImage imageNamed:@"68.png"],[UIImage imageNamed:@"69.png"], [UIImage imageNamed:@"70.png"], [UIImage imageNamed:@"71.png"], [UIImage imageNamed:@"72.png"], [UIImage imageNamed:@"73.png"], [UIImage imageNamed:@"74.png"], [UIImage imageNamed:@"75.png"], [UIImage imageNamed:@"76.png"], nil]
// Version 3 Constants
#define kGBV3Array [NSArray arrayWithObjects:@"Full Body", @"Tennis", @"Basketball", @"Soccer", @"Racketball", @"Volleyball", nil]
#define kGBV3ImagesArray [NSArray arrayWithObjects: @"body_sel.png", @"tennis.png", @"basketball.png", @"soccer.png", @"racketball.png", @"volleyball.png", nil]
#define kGBV3ImagesSelArray [NSArray arrayWithObjects: @"body.png", @"tennis_white.png", @"basketball_white.png", @"soccer_white.png", @"racketball_white.png", @"volleyball_white.png", nil]
#define kGBV3Mapping [NSDictionary dictionaryWithObjects:kGBV3ImagesArray forKeys:kGBV3Array]

// **** End Version 3 Constants

// Body Parrt Stuff
#define kGBBodyPartArray [NSArray arrayWithObjects:@"Full Body", @"Chest", @"Back", @"Legs", @"Shoulders", @"Arms", @"Abs", nil]
#define kGBBodyPartImagesArray [NSArray arrayWithObjects: @"body.png", @"chest.png", @"back.png", @"leg.png", @"shoulder.png", @"arms.png", @"abs.png", nil]
#define kGBBodyPartImagesSelArray [NSArray arrayWithObjects: @"body_sel.png", @"chest_sel.png", @"back_sel.png", @"leg_sel.png", @"shoulder_sel.png", @"arms_sel.png", @"abs_sel.png", nil]
#define kGBBodyPartMapping [NSDictionary dictionaryWithObjects:kGBBodyPartImagesArray forKeys:kGBBodyPartArray]

#define kPreferredTimes [NSArray arrayWithObjects: @"Morning (6AM-Noon)", @"Afternoon (Noon-5PM)", @"Evening (5PM-Midnight)", nil]
#define kPreferredTimesShort [NSArray arrayWithObjects: @"Morning", @"Afternoon", @"Evening", nil]

#define kGBSports [NSArray arrayWithObjects:@"Football", @"Baseball", @"Basketball", @"Hockey", @"Golf", @"Soccer", @"Tennis", @"Boxing", @"Olympic Sports", @"Lacrosse", @"Rugby", @"Cricket", @"Martial Arts", nil]

#define kGBOther [NSArray arrayWithObjects:@"Jump Rope", nil]

#define kGBMileTimes [NSArray arrayWithObjects:@"Under 5min", @"5 minute", @"6 minute", @"7 minute", @"8 minute", @"9 minute", @"10 minute", @"11 minute", @"Above 11 minute", nil]


#define kGymBudDarkBlue [UIColor colorWithRed:0/255.0f green:38/255.0f blue:242/255.0f alpha:1.0f]
#define kGymBudLightBlue  [UIColor colorWithRed:0/255.0f green:134/255.0f blue:215/255.0f alpha:1.0f]
#define kGymBudGold [UIColor colorWithRed:255/255.0f green:230/255.0f blue:13/255.0f alpha:1.0f]
#define kGymBudGrey [UIColor colorWithRed:228/255.0f green:229/255.0f blue:233/255.0f alpha:1.0f]
#define kGymBudOrange [UIColor colorWithRed:243/255.0f green:163/255.0f blue:32/255.0f alpha:1.0f]
