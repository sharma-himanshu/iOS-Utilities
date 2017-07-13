//
//  ImagePickerAPI.h
//  Pintact
//
//  Created by Himanshu Sharma on 6/23/14.
//  Copyright (c) 2014 Himanshu Sharma. All rights reserved.
//

#import <Foundation/Foundation.h>
// Create a delegate so that the View Controller can receive an image.
@protocol imagePickerAPIDelegate <NSObject>

- (void) finishedSelectingImage:(UIImage *) image;

@end

@interface ImagePickerAPI : NSObject <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) id <imagePickerAPIDelegate> delegate;
@property (strong, nonatomic) UIViewController *vc;
@property (nonatomic, strong) UIPopoverController *popOver;
@property (nonatomic, strong) UIImageView *popOverSource;
@property (nonatomic, strong) UIActionSheet *actionSheet;

- (void)orientationChanged;
- (void)addImage;

@end
