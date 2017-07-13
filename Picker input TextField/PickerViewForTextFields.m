//
//  PickerViewForTextFields.m
//  gamecenter
//
//  Created by Himanshu Sharma on 7/22/14.
//  Copyright (c) 2014 GameFly. All rights reserved.
//

#import "PickerViewForTextFields.h"

@implementation PickerViewForTextFields

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

+ (PickerViewForTextFields *)pickerKeyboardWithDataSource:(NSArray *)dataSource
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"PickerViewForTextFields" owner:nil options:nil];
    for(id currentObject in topLevelObjects){
        if([currentObject isKindOfClass:[PickerViewForTextFields class]]){
            PickerViewForTextFields *view = (PickerViewForTextFields *)currentObject;
            view.pickerDataSource = dataSource;
            view.datePicker.hidden = YES;
            view.autoresizingMask = UIViewAutoresizingNone;
            [view.picker reloadAllComponents];
            view.picker.backgroundColor = THEMED_COLOR;
            return view;
        }
    }
    return nil;
}

+ (PickerViewForTextFields *)datePickerKeyboard
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"PickerViewForTextFields" owner:nil options:nil];
    for(id currentObject in topLevelObjects){
        if([currentObject isKindOfClass:[PickerViewForTextFields class]]){
            PickerViewForTextFields *view = (PickerViewForTextFields *)currentObject;
            view.picker.hidden = YES;
            view.datePicker.hidden = NO;
            view.datePicker.maximumDate = [NSDate date];
            return view;
        }
    }
    return nil;
}

- (IBAction)donePressed:(id)sender {
    
    if ([self.delegate respondsToSelector:@selector(donePressedWithValue:)]) {
        [self.delegate donePressedWithValue:(!self.pickerDataSource) ? self.datePicker.date : [self.pickerDataSource objectAtIndex:[self.picker selectedRowInComponent:0]]];
    }
}

- (IBAction)cancelPressed:(id)sender {
    if ([self.delegate respondsToSelector:@selector(cancelPressed)]) {
        [self.delegate cancelPressed];
    }
}

#pragma mark
#pragma mark UIPickerView Delegate Methods
#pragma mark

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [self.pickerDataSource count];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSAttributedString *attString;
    
    if ([[self.pickerDataSource objectAtIndex:row] isKindOfClass:[RetailGetHowDidYouHearAboutAnswersItem class]]) {
        RetailGetHowDidYouHearAboutAnswersItem *item = (RetailGetHowDidYouHearAboutAnswersItem *)[self.pickerDataSource objectAtIndex:row];
        attString = [[NSAttributedString alloc] initWithString:item.value attributes:@{NSForegroundColorAttributeName:THEMED_TEXT_COLOR}];
    }
    else if ([[self.pickerDataSource objectAtIndex:row] isKindOfClass:[RetailPlatform class]]) {
        RetailPlatform *item = (RetailPlatform *)[self.pickerDataSource objectAtIndex:row];
        attString = [[NSAttributedString alloc] initWithString:item.name attributes:@{NSForegroundColorAttributeName:THEMED_TEXT_COLOR}];
    }
    else if ([[self.pickerDataSource objectAtIndex:row] isKindOfClass:[RetailLocationCountry class]]) {
        RetailLocationCountry *item = (RetailLocationCountry *)[self.pickerDataSource objectAtIndex:row];
        attString = [[NSAttributedString alloc] initWithString:item.fullName attributes:@{NSForegroundColorAttributeName:THEMED_TEXT_COLOR}];
    }
    else if ([[self.pickerDataSource objectAtIndex:row] isKindOfClass:[RetailLocationState class]]) {
        RetailLocationState *item = (RetailLocationState *)[self.pickerDataSource objectAtIndex:row];
        attString = [[NSAttributedString alloc] initWithString:item.fullName attributes:@{NSForegroundColorAttributeName:THEMED_TEXT_COLOR}];
    }
    else {
        attString = [[NSAttributedString alloc] initWithString:[self.pickerDataSource objectAtIndex:row] attributes:@{NSForegroundColorAttributeName:THEMED_TEXT_COLOR}];
    }
    
    return attString;
}

- (IBAction)datePickerTapped:(UITapGestureRecognizer *)sender {
    
}


@end
