//  Project name: UberClone
//  File name   : LocationSuggestionManager.h
//
//  Author      : Dung Le
//  Created date: 6/18/16
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2016 Dung Le. All rights reserved.
//  --------------------------------------------------------------

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface LocationSuggestionManager : NSObject<NSCoding> {
}

+ (instancetype)sharedManager;
- (void)suggestLocationWithSearchString:(NSString *)string region:(MKCoordinateRegion)region completion:(void (^)(MKLocalSearchResponse *response, NSError *error))completionBlock;

@end


@interface LocationSuggestionManager (LocationSuggestionManagerCreation)

// Class's static constructors

// Class's constructors

@end
