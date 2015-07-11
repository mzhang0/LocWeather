//
//  WeatherInformationViewController.m
//  LocWeather
//
//  Copyright (c) 2015 APAX Software. All rights reserved.
//

#import "WeatherInformationViewController.h"

@interface WeatherInformationViewController ()

@end

@implementation WeatherInformationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = [NSString stringWithFormat:@"%@, %@", self.weatherInformation.city, self.weatherInformation.state];
    
    self.temperatureLabel.text = self.weatherInformation.temperature;
    self.textConditionLabel.text = self.weatherInformation.text;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
