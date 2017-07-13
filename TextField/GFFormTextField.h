//
//  GFFormTextField.h
//  gamecenter
//
//  Created by Himanshu Sharma on 10/2/14.
//  Copyright (c) 2014 GameFly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GFThemedTextField.h"

@interface GFFormTextField : GFThemedTextField

typedef NS_ENUM(NSInteger, ValidationType) {
    noValidation,
    username,
    emailAddress,
    password,
    firstname,
    lastname,
    streetAddress,
    city,
    state,
    country,
    zipCode,
    postalCodeCAN,
    postalCodeUK,
    phoneNumber,
    socialBirthday,
    birthday,
    fourDigitPin,
    regexPattern
};

@property (nonatomic, assign) ValidationType validationType;

@property (nonatomic, assign) BOOL supportsCounter;
@property (nonatomic, assign) NSInteger supportedCount;

@property (nonatomic, readwrite, assign) IBOutlet GFFormTextField *nextTextField;
@property (nonatomic, strong) NSString *regexPattern;

- (BOOL) isValid;

@end
