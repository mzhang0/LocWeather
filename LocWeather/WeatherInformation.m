//
//  WeatherInformation.m
//  LocWeather
//
//  Copyright (c) 2015 APAX Software. All rights reserved.
//

#import "WeatherInformation.h"

@implementation WeatherInformation

- (WeatherInformation *)initWithDictionary:(NSDictionary *)dictionary {
    
    if (self = [super init]) {
        self.city = [dictionary objectForKey:@"city"];
        self.state = [dictionary objectForKey:@"state"];
        self.temperature = [dictionary objectForKey:@"temperature"];
        self.text = [dictionary objectForKey:@"text"];
    }
    return self;
}

@end
