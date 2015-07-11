//
//  WeatherInformation.h
//  LocWeather
//
//  Copyright (c) 2015 APAX Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WeatherInformation : NSObject

@property (nonatomic, strong) NSDictionary *location;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong) NSString *temperature;
@property (nonatomic, strong) NSString *text;

@end
