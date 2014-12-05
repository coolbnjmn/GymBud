//
//  BubbleChatTVC.m
//  GymBud
//
//  Created by Benjamin Hendricks on 12/3/14.
//  Copyright (c) 2014 GymBud. All rights reserved.
//

#import "BubbleChatTVC.h"
#import <JSQMessagesViewController/JSQMessage.h>
#import <JSQMessagesViewController/JSQMessagesBubbleImageFactory.h>
#import <JSQMessagesViewController/JSQMessagesAvatarImageFactory.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import "GymBudConstants.h"


@interface BubbleChatTVC ()

@property (nonatomic, strong) MBProgressHUD *HUD;
@property (nonatomic, strong) NSArray *objects;
@property (nonatomic, strong) UIImage *fromUserAvatar;
@property (nonatomic, strong) UIImage *toUserAvatar;
@end

@implementation BubbleChatTVC

- (void)objectsDidLoad:(id)result {
    self.objects = [NSArray arrayWithArray:result];
    // set fromuser avatar and touseravatar
    PFFile *theImage = [[self.objects objectAtIndex:0] objectForKey:@"fromUser"][@"gymbudProfile"][@"profilePicture"];
    if(theImage != nil) {
        [theImage getDataInBackgroundWithBlock:^(NSData *data, NSError *error){
            self.fromUserAvatar = [UIImage imageWithData:data];
            PFFile *theImage2 = [[self.objects objectAtIndex:0] objectForKey:@"toUser"][@"gymbudProfile"][@"profilePicture"];
            if(theImage2 != nil) {
                [theImage2 getDataInBackgroundWithBlock:^(NSData *data, NSError *error){
                    self.toUserAvatar = [UIImage imageWithData:data];
                    [self.collectionView reloadData];
                    [self.HUD hide:YES];
                }];
            } else {
                self.toUserAvatar = [UIImage imageNamed:@"yogaIcon.png"];
            }
            
        }];
    } else {
        self.fromUserAvatar = [UIImage imageNamed:@"yogaIcon.png"];
        PFFile *theImage2 = [[self.objects objectAtIndex:0] objectForKey:@"toUser"][@"gymbudProfile"][@"profilePicture"];
        if(theImage2 != nil) {
            [theImage2 getDataInBackgroundWithBlock:^(NSData *data, NSError *error){
                self.toUserAvatar = [UIImage imageWithData:data];
                [self.collectionView reloadData];
                [self.HUD hide:YES];
            }];
        } else {
            self.toUserAvatar = [UIImage imageNamed:@"yogaIcon.png"];
        }
    }
    
    
//
//    [self.HUD hide:YES];
//    [self.collectionView reloadData];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [super viewDidLoad];
    
    self.title = @"JSQMessages";
    
    /**
     *  You MUST set your senderId and display name
     */
//    self.senderId = [self.fromUser objectId];
//    self.senderDisplayName = self.fromUser[@"gymbudProfile"][@"name"];
    self.senderId = [[PFUser currentUser] objectId];
    self.senderDisplayName = [[PFUser currentUser] objectForKey:@"gymbudProfile"][@"name"];
    
    self.showLoadEarlierMessagesHeader = YES;
    
    PFQuery *toUserQuery = [PFQuery queryWithClassName:@"Activity"];
    [toUserQuery whereKey:@"toUser" equalTo:self.toUser];
    [toUserQuery whereKey:@"fromUser" equalTo:self.fromUser];
    [toUserQuery whereKey:@"type" equalTo:@"message"];
    
    PFQuery *fromUserQuery = [PFQuery queryWithClassName:@"Activity"];
    [fromUserQuery whereKey:@"fromUser" equalTo:self.toUser];
    [fromUserQuery whereKey:@"toUser" equalTo:self.fromUser];
    [fromUserQuery whereKey:@"type" equalTo:@"message"];
    
    PFQuery *query = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:toUserQuery,fromUserQuery,nil]];
    [query orderByAscending:@"createdAt"];
    [query includeKey:@"fromUser"];
    [query includeKey:@"toUser"];
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
    [query findObjectsInBackgroundWithTarget:self selector:@selector(objectsDidLoad:)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - JSQMessages CollectionView DataSource

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PFObject *activity = [self.objects objectAtIndex:indexPath.row];
    NSString *name = activity[@"fromUser"][@"gymbudProfile"] ? activity[@"fromUser"][@"gymbudProfile"][@"name"] : activity[@"fromUser"][@"profile"][@"name"];
    return [[JSQMessage alloc] initWithSenderId:[activity[@"fromUser"] objectId] senderDisplayName:name date:[activity createdAt] text:activity[@"content"]];
}

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  You may return nil here if you do not want bubbles.
     *  In this case, you should set the background color of your collection view cell's textView.
     *
     *  Otherwise, return your previously created bubble image data objects.
     */
    JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
    
    PFObject *activity = [self.objects objectAtIndex:indexPath.row];
    
    if ([[[PFUser currentUser] objectId] isEqualToString:[activity[@"fromUser"] objectId]]) { // blue
        return [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor colorWithHue:210.0f / 360.0f
                                                                              saturation:0.8f
                                                                              brightness:1.0f
                                                                                   alpha:1.0f]];
    }
    // light gray
    return [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor colorWithHue:240.0f / 360.0f
                                                                          saturation:0.02f
                                                                          brightness:0.92f
                                                                               alpha:1.0f]];
}

- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Return `nil` here if you do not want avatars.
     *  If you do return `nil`, be sure to do the following in `viewDidLoad`:
     *
     *  self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
     *  self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
     *
     *  It is possible to have only outgoing avatars or only incoming avatars, too.
     */
    
    /**
     *  Return your previously created avatar image data objects.
     *
     *  Note: these the avatars will be sized according to these values:
     *
     *  self.collectionView.collectionViewLayout.incomingAvatarViewSize
     *  self.collectionView.collectionViewLayout.outgoingAvatarViewSize
     *
     *  Override the defaults in `viewDidLoad`
     */
    
    if(indexPath.row % 2 == 0) {
        return [JSQMessagesAvatarImageFactory avatarImageWithPlaceholder:self.fromUserAvatar diameter:kJSQMessagesCollectionViewAvatarSizeDefault];
    } else {
        return [JSQMessagesAvatarImageFactory avatarImageWithPlaceholder:self.toUserAvatar diameter:kJSQMessagesCollectionViewAvatarSizeDefault];
    }
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  This logic should be consistent with what you return from `heightForCellTopLabelAtIndexPath:`
     *  The other label text delegate methods should follow a similar pattern.
     *
     *  Show a timestamp for every 3rd message
     */
    return nil;
//    if (indexPath.item % 3 == 0) {
//        JSQMessage *message = [self.demoData.messages objectAtIndex:indexPath.item];
//        return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
//    }
//    
//    return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    PFObject *activity = [self.objects objectAtIndex:indexPath.row];
    NSString *name = activity[@"fromUser"][@"gymbudProfile"] ? activity[@"fromUser"][@"gymbudProfile"][@"name"] : activity[@"fromUser"][@"profile"][@"name"];
    JSQMessage *message =[[JSQMessage alloc] initWithSenderId:[activity[@"fromUser"] objectId] senderDisplayName:name date:[activity createdAt] text:activity[@"content"]];
    /**
     *  iOS7-style sender name labels
     */
    if ([message.senderId isEqualToString:self.senderId]) {
        return nil;
    }
    
    if (indexPath.item - 1 > 0) {
        PFObject *activity2 = [self.objects objectAtIndex:indexPath.row-1];
        NSString *name2 = activity2[@"fromUser"][@"gymbudProfile"] ? activity[@"fromUser"][@"gymbudProfile"][@"name"] : activity[@"fromUser"][@"profile"][@"name"];
        JSQMessage *message2 =[[JSQMessage alloc] initWithSenderId:[activity2[@"fromUser"] objectId] senderDisplayName:name2 date:[activity2 createdAt] text:activity2[@"content"]];

        if ([[message2 senderId] isEqualToString:message2.senderId]) {
            return nil;
        }
    }
    
    return nil;
    /**
     *  Don't specify attributes to use the defaults.
     */
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

#pragma mark - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.objects count];
}

- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Override point for customizing cells
     */
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    /**
     *  Configure almost *anything* on the cell
     *
     *  Text colors, label text, label colors, etc.
     *
     *
     *  DO NOT set `cell.textView.font` !
     *  Instead, you need to set `self.collectionView.collectionViewLayout.messageBubbleFont` to the font you want in `viewDidLoad`
     *
     *
     *  DO NOT manipulate cell layout information!
     *  Instead, override the properties you want on `self.collectionView.collectionViewLayout` from `viewDidLoad`
     */
    
    PFObject *activity = [self.objects objectAtIndex:indexPath.row];
    NSString *name = activity[@"fromUser"][@"gymbudProfile"] ? activity[@"fromUser"][@"gymbudProfile"][@"name"] : activity[@"fromUser"][@"profile"][@"name"];
    JSQMessage *msg =[[JSQMessage alloc] initWithSenderId:[activity[@"fromUser"] objectId] senderDisplayName:name date:[activity createdAt] text:activity[@"content"]];
    
    if (!msg.isMediaMessage) {
        
        if ([msg.senderId isEqualToString:self.senderId]) {
            cell.textView.textColor = [UIColor blackColor];
        }
        else {
            cell.textView.textColor = [UIColor whiteColor];
        }
        
        cell.textView.linkTextAttributes = @{ NSForegroundColorAttributeName : cell.textView.textColor,
                                              NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid) };
    }
    
    return cell;
}



#pragma mark - JSQMessages collection view flow layout delegate

#pragma mark - Adjusting cell label heights

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Each label in a cell has a `height` delegate method that corresponds to its text dataSource method
     */
    
    /**
     *  This logic should be consistent with what you return from `attributedTextForCellTopLabelAtIndexPath:`
     *  The other label height delegate methods should follow similarly
     *
     *  Show a timestamp for every 3rd message
     */
//    if (indexPath.item % 3 == 0) {
//        return kJSQMessagesCollectionViewCellLabelHeightDefault;
//    }
//    
    return 0.0f;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  iOS7-style sender name labels
     */
    PFObject *activity = [self.objects objectAtIndex:indexPath.row];
    NSString *name = activity[@"fromUser"][@"gymbudProfile"] ? activity[@"fromUser"][@"gymbudProfile"][@"name"] : activity[@"fromUser"][@"profile"][@"name"];
    JSQMessage *currentMessage =[[JSQMessage alloc] initWithSenderId:[activity[@"fromUser"] objectId] senderDisplayName:name date:[activity createdAt] text:activity[@"content"]];

    if ([[currentMessage senderId] isEqualToString:self.senderId]) {
        return 0.0f;
    }
    
    if (indexPath.item - 1 > 0) {
        PFObject *prevActivity = [self.objects objectAtIndex:indexPath.row-1];
        NSString *name = activity[@"fromUser"][@"gymbudProfile"] ? activity[@"fromUser"][@"gymbudProfile"][@"name"] : activity[@"fromUser"][@"profile"][@"name"];
        JSQMessage *previousMessage =[[JSQMessage alloc] initWithSenderId:[prevActivity[@"fromUser"] objectId] senderDisplayName:name date:[prevActivity createdAt] text:prevActivity[@"content"]];
        

        if ([[previousMessage senderId] isEqualToString:[currentMessage senderId]]) {
            return 0.0f;
        }
    }
    
    return kJSQMessagesCollectionViewCellLabelHeightDefault;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return 0.0f;
}

- (void)didPressSendButton:(UIButton *)button
           withMessageText:(NSString *)text
                  senderId:(NSString *)senderId
         senderDisplayName:(NSString *)senderDisplayName
                      date:(NSDate *)date
{
    NSLog(@"trying to send message with text: %@", text);
}



@end
