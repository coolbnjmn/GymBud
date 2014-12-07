//
//  HPLChatTableView.m
//
//  Created by Alex Barinov
//
//  This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Unported License.
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/
//

#import "HPLChatTableView.h"
#import "HPLChatData.h"
#import "HPLChatHeaderTableViewCell.h"
#import "HPLChatTypingTableViewCell.h"

@interface HPLChatTableView ()

@property (nonatomic, retain) NSMutableArray *chatSection;

@end

@implementation HPLChatTableView

@synthesize chatDataSource = _chatDataSource;
@synthesize snapInterval = _snapInterval;
@synthesize groupInterval = _groupInterval;
@synthesize chatSection = _chatSection;
@synthesize typingChat = _typingChat;
@synthesize showAvatars = _showAvatars;

#pragma mark - Initializators

- (void)initializator
{
    // UITableView properties
    
    self.backgroundColor = [UIColor clearColor];
    self.separatorStyle = UITableViewCellSeparatorStyleNone;
    assert(self.style == UITableViewStylePlain);
    
    self.delegate = self;
    self.dataSource = self;
    
    // HPLChatTableView default properties
    
    self.snapInterval = 120;
    self.groupInterval = 2.0;
    self.typingChat = HPLChatTypingTypeNobody;
}

- (id)init
{
    self = [super init];
    if (self) {
        [self initializator];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self initializator];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self initializator];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:UITableViewStylePlain];
    if (self)
    {
        [self initializator];
    }
    return self;
}

#pragma mark - Override

- (void)reloadData
{
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;
    
    // Cleaning up
	self.chatSection = nil;
    
    // Loading new data
    int count = 0;
    self.chatSection = [[NSMutableArray alloc] init];
    
    if (self.chatDataSource && (count = [self.chatDataSource numberOfRowsForChatTable:self]) > 0)
    {
        NSMutableArray *chatData = [[NSMutableArray alloc] initWithCapacity:count];
        
        for (int i = 0; i < count; i++)
        {
            NSObject *object = [self.chatDataSource chatTableView:self dataForRow:i];
            assert([object isKindOfClass:[HPLChatData class]]);
            [chatData addObject:object];
        }
        
        [chatData sortUsingComparator:^NSComparisonResult(id obj1, id obj2)
         {
             HPLChatData *chatData1 = (HPLChatData *)obj1;
             HPLChatData *chatData2 = (HPLChatData *)obj2;
             
             return [chatData1.date compare:chatData2.date];            
         }];
        
        NSDate *last = [NSDate dateWithTimeIntervalSince1970:0];
        NSMutableArray *currentSection = nil;
        HPLChatData *lastData = nil;
        
        for (int i = 0; i < count; i++)
        {
            HPLChatData *data = (HPLChatData *)[chatData objectAtIndex:i];
            
            if ([data.date timeIntervalSinceDate:last] > self.snapInterval)
            {
                currentSection = [[NSMutableArray alloc] init];
                [self.chatSection addObject:currentSection];
            }

            if([data.date timeIntervalSinceDate:last] > self.groupInterval || !lastData || data.messageStatus != lastData.messageStatus || data.type != lastData.type) {
                [currentSection addObject:data];
                lastData = data;
            } else {
                NSString *newText = [NSString stringWithFormat:@"%@\n\n%@", lastData.text, data.text];
                lastData.text = newText;
            }

            last = data.date;
        }
    }
    
    [super reloadData];
    [self setNeedsDisplay];

    if(self.scrollOnActivity) {
        [self scrollToBottomAnimated:YES];
    }
}

-(void)scrollToBottomAnimated:(BOOL)animated {
    NSInteger sectionCount = [self numberOfSections];

    if(sectionCount == 0) {
        return;
    }

    NSInteger rowCount = [self numberOfRowsInSection:sectionCount - 1];

    NSIndexPath* scrollTo = [NSIndexPath indexPathForRow:rowCount-1 inSection:sectionCount - 1];
    [self scrollToRowAtIndexPath:scrollTo atScrollPosition:UITableViewScrollPositionTop animated:animated];
}

#pragma mark - UITableViewDelegate implementation

#pragma mark - UITableViewDataSource implementation

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    int result = [self.chatSection count];
    if (self.typingChat != HPLChatTypingTypeNobody) result++;
    return result;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // This is for now typing chat
	if (section >= [self.chatSection count]) return 1;
    
    return [[self.chatSection objectAtIndex:section] count] + 1;
}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Now typing
	if (indexPath.section >= [self.chatSection count])
    {
        return MAX([HPLChatTypingTableViewCell height], self.showAvatars ? 52 : 0);
    }
    
    // Header
    if (indexPath.row == 0)
    {
        return [HPLChatHeaderTableViewCell height];
    }
    
    HPLChatData *data = [[self.chatSection objectAtIndex:indexPath.section] objectAtIndex:indexPath.row - 1];
    return MAX(data.insets.top + data.view.frame.size.height + data.insets.bottom + 10, self.showAvatars ? 52 : 0);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Now typing
	if (indexPath.section >= [self.chatSection count])
    {
        static NSString *cellId = @"tblChatTypingCell";
        HPLChatTypingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        
        if (cell == nil) cell = [[HPLChatTypingTableViewCell alloc] init];

        cell.type = self.typingChat;
        cell.showAvatar = self.showAvatars;
        
        return cell;
    }

    // Header with date and time
    if (indexPath.row == 0)
    {
        static NSString *cellId = @"tblChatHeaderCell";
        HPLChatHeaderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        HPLChatData *data = [[self.chatSection objectAtIndex:indexPath.section] objectAtIndex:0];
        
        if (cell == nil) cell = [[HPLChatHeaderTableViewCell alloc] init];

        cell.date = data.date;
       
        return cell;
    }
    
    // Standard chat    
    static NSString *cellId = @"tblChatCell";
    HPLChatTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    HPLChatData *data = [[self.chatSection objectAtIndex:indexPath.section] objectAtIndex:indexPath.row - 1];
    
    if (cell == nil) cell = [[HPLChatTableViewCell alloc] init];
    
    cell.data = data;
    cell.showAvatar = self.showAvatars;

    return cell;
}

@end
