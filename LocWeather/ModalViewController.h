//
//  ModalViewController.h
//  LocWeather
//
//  Copyright (c) 2015 APAX Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ModalViewController : UIViewController <UITextFieldDelegate>

- (IBAction)SubmitAction:(id)sender;

- (IBAction)CancelAction:(id)sender;

@property (weak, nonatomic) IBOutlet UITextField *zipCodeTextField;

@property (strong, nonatomic) NSString *zipCode;

@end
