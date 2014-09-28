//
// the application delegate
//


void uncaughtExceptionHandler(NSException * exception);

@class MainViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow * window;
@property (strong, nonatomic) MainViewController * mainViewController;

@end
