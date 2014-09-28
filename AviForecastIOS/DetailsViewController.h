//
// modal detailed forecast view
//


@class DetailsViewController;

@protocol DetailsViewControllerDelegate
- (void) detailsViewControllerDidFinish: (DetailsViewController *) controller;
@end

@interface DetailsViewController : UIViewController <UIWebViewDelegate>

@property (strong, nonatomic) NSURL * URL; 
@property (strong, nonatomic) NSString * customTitle;
@property (weak, nonatomic) IBOutlet id <DetailsViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIWebView * webView;
@property (weak, nonatomic) IBOutlet UINavigationItem *uiNavigationItem;

- (IBAction)donePressed:(id)sender;

@end
