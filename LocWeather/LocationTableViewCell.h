//
//  LocationTableViewCell.h
//  LocWeather
//
//  Copyright (c) 2015 APAX Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LocationTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *LocationLabel;

@property (weak, nonatomic) IBOutlet UILabel *TemperatureLabel;

@end
