//
//  ModalViewController.h
//  LocWeather
//
//  Copyright (c) 2015 APAX Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface ModalViewController : UIViewController <UITextFieldDelegate>

- (IBAction)SubmitAction:(id)sender;

- (IBAction)CancelAction:(id)sender;

@property (weak, nonatomic) IBOutlet UITextField *zipCodeTextField;

@property (strong, nonatomic) PFObject *locationObject;

//@property (nonatomic) id delegate;

@end
