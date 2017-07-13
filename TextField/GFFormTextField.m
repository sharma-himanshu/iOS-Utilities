//
//  GFFormTextField.m
//  gamecenter
//
//  Created by Himanshu Sharma on 10/2/14.
//  Copyright (c) 2014 GameFly. All rights reserved.
//

#import "GFFormTextField.h"
#import "RetailConfig.h"

@interface GFFormTextField()
{
    CGColorRef originalBorderColor;
    CGColorRef errorBorderColor;
    CGFloat originalBorderWidth;
    GFThemedGrayLabel *counterLabel;
}

@end

@implementation GFFormTextField

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    
    if (self) {
        self.supportsCounter = NO;
        [self beginObservingNotifications];
        errorBorderColor = [UIColor redColor].CGColor;
    }
    
    return self;
}

- (void)beginObservingNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textFieldDidEndEditing:)
                                                 name:UITextFieldTextDidEndEditingNotification object:self];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textFieldDidChange:)
                                                 name:UITextFieldTextDidChangeNotification object:self];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textFieldDidBeginEditing:)
                                                 name:UITextFieldTextDidBeginEditingNotification object:self];
}

- (void)stopObservingNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setRightViewForTextFieldWhenEditing:(BOOL) isEditing;
{
    if (self.validationType != noValidation) {
        UIImageView *validationImage = [[UIImageView alloc] initWithFrame:([self isValid]) ? CGRectMake(0, 0, 17, 12) : CGRectMake(0, 0, 13, 13)];
        validationImage.image = [UIImage imageNamed:([self isValid]) ? @"icon_reg_checked.png" : (isEditing) ? @"" : @"icon_reg_error.png"];
        self.rightViewMode = UITextFieldViewModeAlways;
        self.rightView = validationImage;
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        
        // Set the initial and the final values
        [animation setFromValue:[NSNumber numberWithFloat:0.3f]];
        [animation setToValue:[NSNumber numberWithFloat:1.0f]];
        
        // Set duration
        [animation setDuration:0.3f];
        
        // Set animation to be consistent on completion
        [animation setRemovedOnCompletion:NO];
        [animation setFillMode:kCAFillModeForwards];
        
        // Add animation to the view's layer
        [[self.rightView layer] addAnimation:animation forKey:@"scale"];
    }
    else if (self.supportsCounter)
    {
        counterLabel = [[GFThemedGrayLabel alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        counterLabel.font = [UIFont systemFontOfSize:12];
        self.rightViewMode = UITextFieldViewModeAlways;
        counterLabel.text = [NSString stringWithFormat:@"%lu", (long)self.supportedCount - [self.text length]];
        self.rightView = counterLabel;
    }
}

- (void)textFieldDidChange:(NSNotification *)aNotification
{
    if (self.supportsCounter) {
        if([self.text length] < self.supportedCount)
        {
        }
        else {
            self.text = [self.text substringToIndex:self.supportedCount];
        }
        [self setRightViewForTextFieldWhenEditing:YES];
    }
    else {
        self.rightView.hidden = YES;
    }
}


- (void)deleteBackward
{
    [super deleteBackward];
}

- (void)textFieldDidBeginEditing:(NSNotification *)aNotification
{
    if (aNotification.object == self) {
        if (self.layer.borderColor != errorBorderColor) {
            originalBorderColor = self.layer.borderColor;
            originalBorderWidth = self.layer.borderWidth;
        }
        if (self.borderStyle == UITextBorderStyleRoundedRect) {
            self.layer.cornerRadius = 5.0f;
        }
        self.layer.borderWidth= (IS_IPAD) ? 3.0f : 2.0f;
        self.layer.borderColor = GAMEFLY_LIGHT_BLUE.CGColor;
    }
}

- (void)textFieldDidEndEditing:(NSNotification *)aNotification
{
    if (aNotification.object == self) {
        self.rightView.hidden = NO;
        [self setRightViewForTextFieldWhenEditing:NO];
        // remove any trailing spaces from the textField so that Retail's RegEx's don't barf
        self.text = [self.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if (![self isValid]) {
            self.layer.borderColor = errorBorderColor;
            self.layer.borderWidth = 1.0f;
        }
        else if ((self.validationType == noValidation) || (self.borderStyle == UITextBorderStyleRoundedRect)) {
            self.layer.borderColor = originalBorderColor;
            self.layer.borderWidth = originalBorderWidth;
        }
        else {
            self.layer.borderColor = THEMED_TEXT_COLOR.CGColor;
            self.layer.borderWidth = 1.0f;
        }
    }
}

- (BOOL) isValid
{
    NSString *trimmedText = [self.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (self.validationType == username) {
        return [[RetailConfig sharedConfig] isUsernameValid:trimmedText];
    }
    else if (self.validationType == emailAddress) {
        return [[RetailConfig sharedConfig] isEmailValid:trimmedText];
    }
    else if (self.validationType == password) {
        return [[RetailConfig sharedConfig] isPasswordValid:trimmedText];
    }
    else if (self.validationType == firstname || self.validationType == lastname) {
        return [[RetailConfig sharedConfig] isNameValid:trimmedText];
    }
    else if (self.validationType == streetAddress) {
        return [[RetailConfig sharedConfig] isAddressValid:trimmedText];
    }
    else if (self.validationType == city) {
        return [[RetailConfig sharedConfig] isCityValid:trimmedText];
    }
    else if (self.validationType == zipCode) {
        return [[RetailConfig sharedConfig] isZipCodeValid:trimmedText];
    }
    else if (self.validationType == zipCode) {
        return [[RetailConfig sharedConfig] isZipCodeValid:trimmedText];
    }
    else if (self.validationType == postalCodeCAN) {
        return [[RetailConfig sharedConfig] isCanadianPostalCodeValid:trimmedText];
    }
    else if (self.validationType == postalCodeUK) {
        return [[RetailConfig sharedConfig] isUkPostalCodeValid:trimmedText];
    }
    else if (self.validationType == phoneNumber) {
        return [[RetailConfig sharedConfig] isPhoneNumberValid:trimmedText];
    }
    else if (self.validationType == state) {
        return (trimmedText.length == 2);
    }
    else if (self.validationType == country) {
        NSArray *filtered = [[AccountManager sharedManager].countries filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(countryCode == %@)", trimmedText]];
        return ([filtered count]) ? YES : NO;
    }
    else if (self.validationType == socialBirthday) {
        if (trimmedText.length > 0) {
            NSDateFormatter *date = [NSDateFormatter new];
            [date setTimeStyle:NSDateFormatterNoStyle];
            [date setDateStyle:NSDateFormatterMediumStyle];
            NSDate *birthDate = [date dateFromString:trimmedText];
            NSDateComponents *ageComponents = [[NSCalendar currentCalendar]
                                               components:NSCalendarUnitYear
                                               fromDate:birthDate
                                               toDate:[NSDate date]
                                               options:0];
            return (ageComponents.year >= 13);
        }
        return NO;
    }
    else if (self.validationType == birthday) {
        return (trimmedText.length > 0);
    }
    else if (self.validationType == fourDigitPin) {
        NSCharacterSet *notDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
        return ([trimmedText rangeOfCharacterFromSet:notDigits].location == NSNotFound && [trimmedText length] == 4);
    }
    else if (self.validationType == regexPattern) {
        return [[RetailConfig sharedConfig] regex:self.regexPattern matchesString:trimmedText];
    }
    else if (self.validationType == noValidation) {
        return YES;
    }
    
    return NO;
}

- (CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectMake(bounds.origin.x + 10, bounds.origin.y + 8,
                      bounds.size.width - 50, bounds.size.height - 16);
}
- (CGRect)editingRectForBounds:(CGRect)bounds {
    return [self textRectForBounds:bounds];
}

- (CGRect) leftViewRectForBounds:(CGRect)bounds {
    CGRect textRect = [super leftViewRectForBounds:bounds];
    textRect.origin.x += 10;
    return textRect;
}

- (CGRect) rightViewRectForBounds:(CGRect)bounds {
    CGRect textRect = [super rightViewRectForBounds:bounds];
    textRect.origin.x -= 10;
    return textRect;
}

- (void)dealloc
{
    [self stopObservingNotifications];
}

@end
