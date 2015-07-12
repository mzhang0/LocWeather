//
//  WeatherInformationViewController.h
//  LocWeather
//
//  Copyright (c) 2015 APAX Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WeatherInformation.h"

@interface WeatherInformationViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *temperatureLabel;

@property (weak, nonatomic) IBOutlet UILabel *textConditionLabel;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *weatherInformationActivity;

@property (strong, nonatomic) WeatherInformation *weatherInformation;

@end