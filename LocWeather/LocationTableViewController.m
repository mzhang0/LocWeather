//
//  LocationTableViewController.m
//  LocWeather
//
//  Copyright (c) 2015 APAX Software. All rights reserved.
//

#import "LocationTableViewController.h"
#import "WeatherInformationViewController.h"
#import "AFNetworking.h"

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
    
    if ([PFUser currentUser] == nil) {
        
        PFLogInViewController *logInController = [[PFLogInViewController alloc] init];
        logInController.delegate = self;
        
        PFSignUpViewController *signUpController = [[PFSignUpViewController alloc] init];
        signUpController.delegate = self;
        
        logInController.signUpController = signUpController;
        
        [self presentViewController:logInController animated:YES completion:nil];
    }
    else {
        [self fetchAllObjectsFromLocalDataStore];
        [self fetchAllObjects];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)fetchAllObjectsFromLocalDataStore {
    
    PFQuery *query = [PFQuery queryWithClassName:@"Location"];
    [query fromLocalDatastore];
    [query findObjectsInBackgroundWithBlock:^(NSArray *locationObjects, NSError *error) {
        
        if (error == nil) {
            
            self.locations = [locationObjects mutableCopy];
            
            [self.tableView reloadData];
            
            NSLog(@"Fetched from local datastore!");
            
            //
            //
            
            NSMutableString *formattedUrlWithZipCodes = [[NSMutableString alloc] init];
            
            [formattedUrlWithZipCodes appendString:@"https://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20weather.forecast%20where%20location%20IN%20("];
            
            for (NSUInteger i = 0; i < locationObjects.count; i++) {
                
                NSDictionary *location = [locationObjects objectAtIndex:i];
                [formattedUrlWithZipCodes appendString:[location objectForKey:@"zip"]];
                
                if (i < locationObjects.count - 1)
                    [formattedUrlWithZipCodes appendString:@"%2C"];
                
            }
            
            [formattedUrlWithZipCodes appendString:@")&format=json&callback="];
            NSURL *url = [NSURL URLWithString:formattedUrlWithZipCodes];
            
            [self loadWeatherInformationWithUrl:url];
            
        }
        else
            NSLog(@"Error when fetching from local datastore!");
        
    }];
}

- (void)fetchAllObjects {
    
    [PFObject unpinAllObjectsInBackgroundWithBlock:nil];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Location"];
    [query whereKey:@"username" equalTo:[PFUser currentUser].username];
    [query findObjectsInBackgroundWithBlock:^(NSArray *locationObjects, NSError *error) {
        
        if (error == nil) {
            
            [PFObject pinAllInBackground:locationObjects block:nil];
            
            [self fetchAllObjectsFromLocalDataStore];
            
            NSLog(@"%@", locationObjects);
            
            NSLog(@"Fetched from Parse datastore!");
        }
        else
            NSLog(@"Error when fetching from Parse datastore!");
    }];
    
}

- (void)loadWeatherInformationWithUrl:(NSURL*)url {
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *weather = (NSDictionary *)responseObject;
        NSLog(@"%@", weather);
        //self.title = @"JSON Retrieved";
        /*NSDictionary *query = [(NSDictionary *)responseObject objectForKey:@"query"];
        
        NSArray *channels = [[query objectForKey:@"results"] objectForKey:@"channel"];
        
        for (NSDictionary *channel in channels)
            
            if (![[channel objectForKey:@"title"] isEqualToString:@"Yahoo! Weather - Error"])
                
                [self.dataArray addObject:channel];
        
        NSLog(@"%@", self.dataArray);
        
        [self.tableView reloadData];*/
        
    }
    failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        /*UIAlertController *alert = [UIAlertController alertControllerWithTitle:[error localizedDescription] message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {}];
        
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];*/
        
        NSLog(@"Failed!");
    }];
    
    [operation start];
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
    return self.locations.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
     UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
 
    // Configure the cell...
 
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
         
         WeatherInformationViewController *viewController = segue.destinationViewController;
         viewController.weatherInformation = [[WeatherInformation alloc] init];
         
     }
 }

@end
