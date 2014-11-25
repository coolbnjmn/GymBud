//
//  GymBudEventCompletionView.m
//  GymBud
//
//  Created by Benjamin Hendricks on 11/21/14.
//  Copyright (c) 2014 GymBud. All rights reserved.
//

#import "GymBudEventCompletionView.h"
#import <Mixpanel/Mixpanel.h>
#import <Parse/Parse.h>
#import "AppDelegate.h"

#define kFiveStarWidth 225
#define kTwoLineHeight 42
#define kFiveStarHeight 64
#define kButtonHeight 40
#define kLittleOffset 8

@implementation GymBudEventCompletionView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        UILabel *descriptionLabel = [[UILabel alloc] init];
        descriptionLabel.frame = CGRectMake(0, 0, frame.size.width, kTwoLineHeight);
        descriptionLabel.lineBreakMode = NSLineBreakByWordWrapping;
        descriptionLabel.textAlignment = NSTextAlignmentCenter;
        descriptionLabel.text = @"How was your GymBud?";
        descriptionLabel.textColor = [UIColor whiteColor];
        descriptionLabel.font = [UIFont systemFontOfSize:26];
        
        [self addSubview:descriptionLabel];
        self.axRView = [[AXRatingView alloc] init];
        self.axRView.frame = CGRectMake((frame.size.width - kFiveStarWidth)/2, kTwoLineHeight, frame.size.width/2 + kFiveStarWidth/2, kFiveStarHeight);

        [self.axRView setStepInterval:1.0];
        [self.axRView setMarkFont:[UIFont systemFontOfSize:44.0f]];
//        [ratingView addTarget:self action:@selector(changeRate:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:self.axRView];
        [self setBackgroundColor:[UIColor colorWithRed:34/255.0f green:49/255.0f blue:66/255.0f alpha:1.0f]];
        
        UIButton *cancelButton = [[UIButton alloc] init];
        cancelButton.frame = CGRectMake(kLittleOffset, kTwoLineHeight+kFiveStarHeight, frame.size.width/2-kLittleOffset*2, kButtonHeight);
        cancelButton.backgroundColor = [UIColor whiteColor];
        [cancelButton setTitle:@"Cancel Review" forState:UIControlStateNormal];
        [cancelButton setTitleColor:[UIColor colorWithRed:34/255.0f green:49/255.0f blue:66/255.0f alpha:1.0f] forState:UIControlStateNormal];
        [cancelButton addTarget:self action:@selector(cancelReview:) forControlEvents:UIControlEventTouchDown];
        [cancelButton.layer setCornerRadius:cancelButton.frame.size.width/8];
        [self addSubview:cancelButton];
        
        UIButton *submitButton = [[UIButton alloc] init];
        submitButton.frame = CGRectMake(kLittleOffset+frame.size.width/2, kTwoLineHeight+kFiveStarHeight, frame.size.width/2-kLittleOffset*2, kButtonHeight);
        submitButton.backgroundColor = [UIColor whiteColor];
        [submitButton setTitle:@"Submit Review" forState:UIControlStateNormal];
        [submitButton setTitleColor:[UIColor colorWithRed:34/255.0f green:49/255.0f blue:66/255.0f alpha:1.0f] forState:UIControlStateNormal];
        [submitButton addTarget:self action:@selector(submitReview:) forControlEvents:UIControlEventTouchDown];
        [submitButton.layer setCornerRadius:cancelButton.frame.size.width/8];
        [self addSubview:submitButton];
    }
    return self;
}

- (void) cancelReview:(id) sender {
    NSLog(@"cancel review");
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"EventCompletion CancelReview" properties:@{}];
    [self removeFromSuperview];
}

- (void) submitReview:(id) sender {
    NSLog(@"submit review with : %lu", (unsigned long)self.axRView.value);
    
    PFQuery *eventQuery = [PFQuery queryWithClassName:@"Event"];
    [eventQuery whereKey:@"objectId" equalTo:self.event];
    [eventQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        PFObject *reviewObject = [PFObject objectWithClassName:@"Review"];
        [reviewObject setObject:[objects objectAtIndex:0] forKey:@"event"];
        [reviewObject setObject:[NSNumber numberWithFloat:self.axRView.value] forKey:@"value"];
        
        [reviewObject saveInBackground];
        Mixpanel *mixpanel = [Mixpanel sharedInstance];
        [mixpanel track:@"EventCompletion SubmitReview" properties:@{}];
        
        [self removeFromSuperview];

    }];
//    [eventQuery getObjectInBackgroundWithId:self.event block:^(PFObject *object, NSError *error) {
//        PFObject *reviewObject = [PFObject objectWithClassName:@"Review"];
//        [reviewObject setObject:object forKey:@"event"];
//        [reviewObject setObject:[NSNumber numberWithFloat:self.axRView.value] forKey:@"value"];
//        
//        [reviewObject saveInBackground];
//        Mixpanel *mixpanel = [Mixpanel sharedInstance];
//        [mixpanel track:@"EventCompletion SubmitReview" properties:@{}];
//        
//        [self removeFromSuperview];
//    }];
    
}


- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [super initWithCoder:decoder]) {
    }
    return self;
}

- (void)sizeToFit
{
    [super sizeToFit];
    self.frame = (CGRect) {
        self.frame.origin, self.intrinsicContentSize
    };
}

@end
