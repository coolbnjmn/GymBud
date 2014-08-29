
#import <Parse/Parse.h>

@interface UserDetailsViewController : UITableViewController <NSURLConnectionDelegate>

// UITableView header view properties
@property (nonatomic, strong) IBOutlet UIView *headerView;
@property (nonatomic, strong) IBOutlet UILabel *headerNameLabel;
@property (nonatomic, strong) IBOutlet UIImageView *headerImageView;
@property (nonatomic, strong) IBOutlet UIImageView *headerPictureLogo;
@property (weak, nonatomic) IBOutlet UITextView *headerCheckinMessage;
@property (weak, nonatomic) IBOutlet UIButton *headerJoinButton;

// UITableView row data properties
@property (nonatomic, strong) NSArray *rowTitleArray;
@property (nonatomic, strong) NSMutableArray *rowDataArray;
@property (nonatomic, strong) NSMutableData *imageData;

@property (nonatomic, strong) id annotation;
// UINavigationBar button touch handler
- (void)logoutButtonTouchHandler:(id)sender;

@end
