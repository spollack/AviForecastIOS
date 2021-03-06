#import "AppDelegate.h"
#import "MainViewController.h"
#import "Flurry.h"
#import "RNCachingURLProtocol.h"
#import "Appirater.h"


@implementation AppDelegate

@synthesize window = _window;
@synthesize mainViewController = _mainViewController;

void uncaughtExceptionHandler(NSException * exception)
{
    DLog(@"uncaught exception: %@", exception);
#ifndef DEBUG
    [Flurry logError:@"Uncaught" message:@"Crash!" exception:exception];
#endif
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // set up uncaught exception handler
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);

    // set up persistent URL caching
    // NOTE this cache is not currently size limited in any way...
    [NSURLProtocol registerClass:[RNCachingURLProtocol class]];

    // begin statistics tracking
//    [Flurry setDebugLogEnabled:YES];
#ifndef DEBUG
    [Flurry startSession:@"N9YFD4HPQDDPHCSMXQ44"];
    [Flurry setCrashReportingEnabled:YES];
#endif
    
    // explain to the user why we need location services
    CLLocationManager * locationManager = [[CLLocationManager alloc] init];
    [locationManager setPurpose:@"In order to position the forecast map around your current location"];
    
    // initialize main view
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.mainViewController = [[MainViewController alloc] initWithNibName:@"MainViewController" bundle:nil];
    self.window.rootViewController = self.mainViewController;
    [self.window makeKeyAndVisible];
    
    // encourage users to rate the app in the app store
    [Appirater setAppId:@"501231389"];
    [Appirater setDaysUntilPrompt:0];
    [Appirater setUsesUntilPrompt:2];
    [Appirater setSignificantEventsUntilPrompt:-1];
    [Appirater setTimeBeforeReminding:1];
    //[Appirater setDebug:YES]; // NOTE for testing purposes
    [Appirater appLaunched:YES];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
    
    [Appirater appEnteredForeground:YES];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

@end
