//
//  WeatherInformationViewController.m
//  LocWeather
//
//  Copyright (c) 2015 APAX Software. All rights reserved.
//

#import "WeatherInformationViewController.h"
#import "AFNetworking.h"

@interface WeatherInformationViewController ()

@end

@implementation WeatherInformationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = [NSString stringWithFormat:@"%@, %@", self.weatherInformation.city, self.weatherInformation.state];
    
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(SelectedRefreshButton)];
    self.navigationItem.rightBarButtonItem = refreshButton;
    
    self.temperatureLabel.text = [NSString stringWithFormat:@"%@°F", self.weatherInformation.temperature];
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

- (void)SelectedRefreshButton {
    
    [self.refreshActivityIndicator startAnimating];
    
    NSString *url = [WeatherInformation getFormattedUrlStringWithZipCodes:[[NSArray alloc] initWithObjects:self.weatherInformation.zip, nil]];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
            NSDictionary *query = [(NSDictionary *)responseObject objectForKey:@"query"];
            NSDictionary *channel = [[query objectForKey:@"results"] objectForKey:@"channel"];
        
            NSLog(@"%@", query);
        
            if (![[channel objectForKey:@"title"] isEqualToString:@"Yahoo! Weather - Error"]) {
                
                NSDictionary *conditionDictionary = [[channel objectForKey:@"item"] objectForKey:@"condition"];
                
                NSLog(@"%@", conditionDictionary);
                
                self.weatherInformation.temperature = [conditionDictionary objectForKey:@"temp"];
                self.weatherInformation.text = [conditionDictionary objectForKey:@"text"];
                
                self.temperatureLabel.text = [NSString stringWithFormat:@"%@°F", self.weatherInformation.temperature];
                self.textConditionLabel.text = self.weatherInformation.text;
            }
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             
             NSLog(@"Failed get request with error: %@", error);
             
             UIAlertController *alert = [UIAlertController alertControllerWithTitle:[error localizedDescription] message:nil preferredStyle:UIAlertControllerStyleAlert];
             UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {}];
             
             [alert addAction:okAction];
             [self presentViewController:alert animated:YES completion:nil];
    }];
    
    [self.refreshActivityIndicator stopAnimating];
}

@end
