//
//  PickerViewForTextFields.h
//  gamecenter
//
//  Created by Himanshu Sharma on 7/22/14.
//  Copyright (c) 2014 GameFly. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PickerKeyboardDelegate <NSObject>

- (void)donePressedWithValue:(id)selectedValue;
- (void)cancelPressed;

@end

/**
Creating a Generic Picker Which Uses Delegation to pass values back to the implementing View Controller.
 This created a Done and Cancel button in the Picker View which is used to replace the keyboard.
*/
@interface PickerViewForTextFields : UIView <UIPickerViewDataSource, UIPickerViewDelegate>

@property (strong, nonatomic) NSArray *pickerDataSource;
@property (weak, nonatomic) id <PickerKeyboardDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIPickerView *picker;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;

+ (PickerViewForTextFields *)pickerKeyboardWithDataSource:(NSArray *)dataSource;
+ (PickerViewForTextFields *)datePickerKeyboard;

@end
