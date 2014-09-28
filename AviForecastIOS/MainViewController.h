//
// the main view
//


#import "DetailsViewController.h"
#import "DangerScaleViewController.h"

@class DataManager;
@class NetworkEngine;

@interface MainViewController : UIViewController <MKMapViewDelegate, UIGestureRecognizerDelegate, DetailsViewControllerDelegate, DangerScaleViewControllerDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView * map;
@property (weak, nonatomic) IBOutlet UISegmentedControl * dayControl;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView * spinner;
@property (strong, nonatomic) NSMutableDictionary * settings;
@property (strong, nonatomic) DataManager * dataManager;
@property (strong, nonatomic) NSMutableDictionary * overlayViewDict;
@property (nonatomic) BOOL haveUpdatedUserLocation;
@property (nonatomic) int mode; 

- (IBAction)dayPressed;
- (IBAction)legendPressed;
- (IBAction)infoPressed;

@end
