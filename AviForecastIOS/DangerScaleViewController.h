//
// danger scale view
//


@class DangerScaleViewController;

@protocol DangerScaleViewControllerDelegate
- (void) dangerScaleViewControllerDidFinish: (DangerScaleViewController *) controller;
@end

@interface DangerScaleViewController : UIViewController <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet id <DangerScaleViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIScrollView * scrollView;

- (IBAction)donePressed:(id)sender;

@end
