//
//  LocationTableViewController.m
//  LocWeather
//
//  Copyright (c) 2015 APAX Software. All rights reserved.
//

#import "AFNetworking.h"
#import "LocationTableViewController.h"
#import "LocationTableViewCell.h"
#import "WeatherInformationViewController.h"

@interface LocationTableViewController ()

@end

@implementation LocationTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (![PFUser currentUser])
        
        [self showLogInSignUpView];
    else {
        
        [self.LocationTableActivityIndicator startAnimating];
        [self fetchAllObjects];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showLogInSignUpView {
    
    PFLogInViewController *logInController = [[PFLogInViewController alloc] init];
    logInController.delegate = self;
    
    PFSignUpViewController *signUpController = [[PFSignUpViewController alloc] init];
    signUpController.delegate = self;
    
    UILabel *logInLogo = [[UILabel alloc] init];
    logInLogo.text = @"LocWeather";
    logInController.logInView.logo = logInLogo;
    
    logInController.logInView.dismissButton.hidden = YES;
    
    UILabel *signUpLogo = [[UILabel alloc] init];
    signUpLogo.text = @"LocWeather";
    signUpController.signUpView.logo = signUpLogo;
    
    logInController.signUpController = signUpController;
    
    [self presentViewController:logInController animated:YES completion:nil];
}

- (void)fetchAllObjects {
    
    PFQuery *query = [PFQuery queryWithClassName:@"Location"];
    [query whereKey:@"username" equalTo:[PFUser currentUser].username];
    [query findObjectsInBackgroundWithBlock:^(NSArray *locationObjects, NSError *error) {
        
        if (!error) {
            
            NSLog(@"Fetched from Parse datastore!:\n%@", locationObjects);
            
            NSMutableString *formattedUrlWithZipCodes = [@"https://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20weather.forecast%20where%20location%20IN%20(" mutableCopy];
            
            NSLog(@"THERE ARE %d OBJECTS!!!", locationObjects.count);
            
            for (NSUInteger i = 0; i < locationObjects.count; i++) {
                
                NSDictionary *location = [locationObjects objectAtIndex:i];
                [formattedUrlWithZipCodes appendString:[location objectForKey:@"zip"]];
                
                if (i < locationObjects.count - 1)
                    [formattedUrlWithZipCodes appendString:@"%2C"];
            }
            
            [formattedUrlWithZipCodes appendString:@")&format=json"];
            
            [self loadWeatherInformationWithUrl:(NSString *)formattedUrlWithZipCodes];
        }
        else
            NSLog(@"Error when fetching from Parse datastore!");
        
        [self.LocationTableActivityIndicator stopAnimating];
    }];
}

- (void)loadWeatherInformationWithUrl:(NSString*)url {
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSMutableArray *dataArray = [[NSMutableArray alloc] init];
        
        NSDictionary *query = [(NSDictionary *)responseObject objectForKey:@"query"];
        
        NSArray *channels = [[query objectForKey:@"results"] objectForKey:@"channel"];
        
        for (NSDictionary *channel in channels)
            
            if (![[channel objectForKey:@"title"] isEqualToString:@"Yahoo! Weather - Error"])
                
                [dataArray addObject:channel];
        
        NSLog(@"DATA ARRAY:\n%@", dataArray);
        
        NSMutableArray *filteredDataArray = [[NSMutableArray alloc] init];
        
        for (NSDictionary *localData in dataArray) {
            
            NSMutableDictionary *filteredLocalData = [[NSMutableDictionary alloc] init];
            
            NSDictionary *locationInformation = [localData objectForKey:@"location"];
            [filteredLocalData setObject:[locationInformation objectForKey:@"city"] forKey:@"city"];
            [filteredLocalData setObject:[locationInformation objectForKey:@"region"] forKey:@"state"];
            
            NSDictionary *conditionInformation = [[localData objectForKey:@"item"] objectForKey:@"condition"];
            
            [filteredLocalData setObject:[conditionInformation objectForKey:@"temp"] forKey:@"temperature"];
            [filteredLocalData setObject:[conditionInformation objectForKey:@"text"] forKey:@"text"];
            
            [filteredDataArray addObject:filteredLocalData];
        }
        
        NSLog(@"FILTERED DATA ARRAY:\n%@", filteredDataArray);
        
        self.weatherInformationArray = [[NSMutableArray alloc] init];
        
        for (NSDictionary* localWeatherData in filteredDataArray) {
            
            WeatherInformation *localWeatherInformation = [[WeatherInformation alloc] initWithDictionary:localWeatherData];
            [self.weatherInformationArray addObject:localWeatherInformation];
        }
        
        [self.tableView reloadData];
    }
    failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Failed get request with error: %@", error);
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:[error localizedDescription] message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {}];
        
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
    }];
}

#pragma mark - Log in delegate methods

- (BOOL)logInViewController:(PFLogInViewController * __nonnull)logInController shouldBeginLogInWithUsername:(NSString * __nonnull)username password:(NSString * __nonnull)password {
    
    /*if (![username isEqualToString:@""] || ![password isEqualToString:@""])
     return YES;
     
     return NO;*/
    
    return (![username isEqualToString:@""] && ![password isEqualToString:@""]);
}

- (void)logInViewController:(PFLogInViewController * __nonnull)logInController didLogInUser:(PFUser * __nonnull)user {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)logInViewController:(PFLogInViewController * __nonnull)logInController didFailToLogInWithError:(nullable NSError *)error {
    NSLog(@"Log in failed!");
}

#pragma mark - Sign up delegate methods

- (void)signUpViewController:(PFSignUpViewController * __nonnull)signUpController didSignUpUser:(PFUser * __nonnull)user {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)signUpViewController:(PFSignUpViewController *)signUpController didFailToSignUpWithError:(PFUI_NULLABLE NSError *)error {
    NSLog(@"Sign up failed!");
}

- (void)signUpViewControllerDidCancelSignUp:(PFSignUpViewController * __nonnull)signUpController {
    NSLog(@"Sign up cancelled!");
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.weatherInformationArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    LocationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
 
    WeatherInformation *weatherInformation = self.weatherInformationArray[indexPath.row];
    
    cell.LocationLabel.text = [NSString stringWithFormat:@"%@, %@", weatherInformation.city, weatherInformation.state];
    cell.TemperatureLabel.text = [NSString stringWithFormat:@"%@°F", weatherInformation.temperature];
    
    return cell;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

 #pragma mark - Navigation

/*-(IBAction)prepareForUnwind:(UIStoryboardSegue *)segue {
    
}*/

 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
     
     if ([segue.identifier isEqualToString:@"ShowWeatherInformation"]) {
         
         NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
         
         WeatherInformationViewController *viewController = segue.destinationViewController;
         viewController.weatherInformation = self.weatherInformationArray[indexPath.row];
     }
 }

- (IBAction)SignOut:(UIBarButtonItem *)sender {
    
    [PFUser logOut];
    [self showLogInSignUpView];
    NSLog(@"User logged out!");
}

@end
