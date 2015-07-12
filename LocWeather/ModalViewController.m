//
//  ModalViewController.m
//  LocWeather
//
//  Copyright (c) 2015 APAX Software. All rights reserved.
//

#import "ModalViewController.h"
#import "AFNetworking.h"

@interface ModalViewController ()

@end

@implementation ModalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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

- (IBAction)SubmitAction:(id)sender {
    
    NSString *zipCode = self.zipCodeTextField.text;

    if (zipCode.length == 5) {
        
        //Use YQL to validate the user's 5 digit ZIP code.
        NSArray *stringArray = [[NSArray alloc] initWithObjects:@"https://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20weather.forecast%20where%20location%20IN%20(", zipCode, @")&format=json", nil];
        NSString *url = [stringArray componentsJoinedByString:@""];
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSDictionary *query = [(NSDictionary *)responseObject objectForKey:@"query"];
            NSDictionary *channel = [[query objectForKey:@"results"] objectForKey:@"channel"];
            
            //Save ZIP code to Parse Core should the ZIP code be valid.
            if (![[channel objectForKey:@"title"] isEqualToString:@"Yahoo! Weather - Error"]) {
            
                self.locationObject = [PFObject objectWithClassName:@"Location"];
                
                [self.locationObject setObject:[PFUser currentUser].username forKey:@"username"];
                [self.locationObject setObject:zipCode forKey:@"zip"];
                
                [self.zipCodeTextField resignFirstResponder];
                
                [self.locationObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    
                    if (succeeded) {
                        NSLog(@"Location object saved!");
                        [self dismissViewControllerAnimated:YES completion:nil];
                    }
                    else {
                        NSLog(@"Location object failed to save!");
                        [self dismissViewControllerAnimated:YES completion:nil];
                    }
                }];
            }
            else {
                NSLog(@"ZIP Code does NOT exist!");
                
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Invalid ZIP Code" message:@"ZIP Code does not exist." preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {}];
                
                [alert addAction:okAction];
                [self presentViewController:alert animated:YES completion:nil];
            }
        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            NSLog(@"Failed get request with error: %@", error);
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:[error localizedDescription] message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {}];
            
            [alert addAction:okAction];
            [self presentViewController:alert animated:YES completion:nil];
        }];
    }
    else {
        
        NSLog(@"Invalid ZIP code entered!");
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Invalid ZIP Code" message:@"ZIP Codes must consist of 5 digits." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {}];
        
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (IBAction)CancelAction:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
