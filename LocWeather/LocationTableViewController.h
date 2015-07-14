//
//  LocationTableViewController.h
//  LocWeather
//
//  Copyright (c) 2015 APAX Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import "WeatherInformation.h"

@interface LocationTableViewController : UITableViewController <PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *LocationTableActivityIndicator;

@property (nonatomic, strong) NSMutableArray *zipCodes;
@property (nonatomic, strong) NSMutableArray *weatherInformationArray;

- (IBAction)SignOut:(UIBarButtonItem *)sender;

@end

