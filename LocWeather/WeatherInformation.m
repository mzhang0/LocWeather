//
//  WeatherInformation.m
//  LocWeather
//
//  Copyright (c) 2015 APAX Software. All rights reserved.
//

#import "WeatherInformation.h"

@implementation WeatherInformation

+ (NSString *)getFormattedUrlStringWithZipCodes:(NSArray *)zipCodeArray {
    
    NSMutableString *formattedUrlWithZipCodes = [@"https://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20weather.forecast%20where%20location%20IN%20(" mutableCopy];
    
    for (NSUInteger i = 0; i < zipCodeArray.count; i++) {

        [formattedUrlWithZipCodes appendString:[zipCodeArray objectAtIndex:i]];
        
        if (i < zipCodeArray.count - 1)
            [formattedUrlWithZipCodes appendString:@"%2C"];
    }
    
    [formattedUrlWithZipCodes appendString:@")&format=json"];
    
    return (NSString *)formattedUrlWithZipCodes;
}

- (WeatherInformation *)initWithDictionary:(NSDictionary *)dictionary {
    
    if (self = [super init]) {
        
        self.zip = [dictionary objectForKey:@"zip"];
        self.city = [dictionary objectForKey:@"city"];
        self.state = [dictionary objectForKey:@"state"];
        self.temperature = [dictionary objectForKey:@"temperature"];
        self.text = [dictionary objectForKey:@"text"];
    }
    return self;
}

@end
