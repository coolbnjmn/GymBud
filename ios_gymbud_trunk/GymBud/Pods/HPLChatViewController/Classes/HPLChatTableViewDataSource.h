//
//  HPLChatTableViewDataSource.h
//
//  Created by Alex Barinov
//
//  This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Unported License.
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/
//

#import <Foundation/Foundation.h>

@class HPLChatData;
@class HPLChatTableView;
@protocol HPLChatTableViewDataSource <NSObject>

@optional

@required

- (NSInteger)numberOfRowsForChatTable:(HPLChatTableView *)tableView;
- (HPLChatData *)chatTableView:(HPLChatTableView *)tableView dataForRow:(NSInteger)row;

@end
