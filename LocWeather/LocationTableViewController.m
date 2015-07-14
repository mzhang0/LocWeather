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

@interface LocationTableViewController () {
    UIRefreshControl *refreshControl;
}

@end

@implementation LocationTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(fetchAllObjects) forControlEvents:UIControlEventValueChanged];
    [self setRefreshControl:refreshControl];
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
            
            self.zipCodes = [[NSMutableArray alloc] init];
            
            for (NSDictionary *locationObject in locationObjects)
                [self.zipCodes addObject:[locationObject objectForKey:@"zip"]];
            
            NSString *formattedUrlString = [WeatherInformation getFormattedUrlStringWithZipCodes:(NSArray *)self.zipCodes];
            
            if (self.zipCodes.count > 0)
                [self loadWeatherInformationWithUrl:formattedUrlString];
        }
        else
            NSLog(@"Error when fetching from Parse datastore!");
        
        [refreshControl endRefreshing];
        [self.LocationTableActivityIndicator stopAnimating];
    }];
}

- (void)loadWeatherInformationWithUrl:(NSString*)stringUrl {
    
    NSURL *url = [NSURL URLWithString:stringUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions: NSJSONReadingMutableContainers];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSMutableArray *dataArray = [[NSMutableArray alloc] init];
        
        NSDictionary *query = [responseObject objectForKey:@"query"];
        
        if ((NSNumber *)[query objectForKey:@"count"] > [NSNumber numberWithInt:1]) {
            
            NSArray *channels = [[query objectForKey:@"results"] objectForKey:@"channel"];
            
            for (NSUInteger i = 0; i < channels.count; i++) {
                
                NSDictionary *channel = [channels objectAtIndex:i];
                
                //Filters out results with errors
                if (![[channel objectForKey:@"title"] isEqualToString:@"Yahoo! Weather - Error"]) {
                    
                    //Adds the ZIP code
                    NSMutableDictionary *location = [channel objectForKey:@"location"];
                    [location setObject:[self.zipCodes objectAtIndex:i] forKey:@"zip"];
                    
                    [dataArray addObject:channel];
                }
            }
        }
        else {
            
            NSDictionary *channelDictionary = [[query objectForKey:@"results"] objectForKey:@"channel"];
            
            if (![[channelDictionary objectForKey:@"title"] isEqualToString:@"Yahoo! Weather - Error"]) {
                
                //Adds the ZIP code
                NSMutableDictionary *location = [channelDictionary  objectForKey:@"location"];
                [location setObject:[self.zipCodes objectAtIndex:0] forKey:@"zip"];
                
                [dataArray addObject:channelDictionary];
            }
        }
        
        NSMutableArray *filteredDataArray = [[NSMutableArray alloc] init];
        
        for (NSDictionary *localData in dataArray) {
            
            NSMutableDictionary *filteredLocalData = [[NSMutableDictionary alloc] init];
            
            NSDictionary *locationInformation = [localData objectForKey:@"location"];
            [filteredLocalData setObject:[locationInformation objectForKey:@"city"] forKey:@"city"];
            [filteredLocalData setObject:[locationInformation objectForKey:@"region"] forKey:@"state"];
            [filteredLocalData setObject:[locationInformation objectForKey:@"zip"] forKey:@"zip"];
            
            NSDictionary *conditionInformation = [[localData objectForKey:@"item"] objectForKey:@"condition"];
            
            [filteredLocalData setObject:[conditionInformation objectForKey:@"temp"] forKey:@"temperature"];
            [filteredLocalData setObject:[conditionInformation objectForKey:@"text"] forKey:@"text"];
            
            [filteredDataArray addObject:filteredLocalData];
        }
        
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
    
    [operation start];
}

#pragma mark - Log in delegate methods

- (BOOL)logInViewController:(PFLogInViewController * __nonnull)logInController shouldBeginLogInWithUsername:(NSString * __nonnull)username password:(NSString * __nonnull)password {
    return (![username isEqualToString:@""] && ![password isEqualToString:@""]);
}

- (void)logInViewController:(PFLogInViewController * __nonnull)logInController didLogInUser:(PFUser * __nonnull)user {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)logInViewController:(PFLogInViewController * __nonnull)logInController didFailToLogInWithError:(nullable NSError *)error {
    
    NSLog(@"Log in failed!");
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Login failed!" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {}];
    
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
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
