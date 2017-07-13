//
//  ImagePickerAPI.m
//  Pintact
//
//  Created by Himanshu Sharma on 6/23/14.
//  Copyright (c) 2014 Himanshu Sharma. All rights reserved.
//

#import "ImagePickerAPI.h"
#import <AVFoundation/AVFoundation.h>
#import "AlertHelper.h"

@implementation ImagePickerAPI

- (void) addImage
{
    self.actionSheet = [[UIActionSheet alloc] init];
    self.actionSheet.title = @"Select Picture Source";
    self.actionSheet.delegate = self;
    
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    // photos
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        [self.actionSheet addButtonWithTitle:@"Photo Library"];
    }
    
    // camera
    if (authStatus == AVAuthorizationStatusAuthorized) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            [self.actionSheet addButtonWithTitle:@"Camera"];
        }
        [self.actionSheet setCancelButtonIndex:[self.actionSheet addButtonWithTitle:@"Cancel"]];
        [self showActionSheet];
    }
    else if (authStatus == AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (granted) {
                    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                        [self.actionSheet addButtonWithTitle:@"Camera"];
                    }
                    [self.actionSheet setCancelButtonIndex:[self.actionSheet addButtonWithTitle:@"Cancel"]];
                    [self showActionSheet];
                }
                else {
                    [AlertHelper showErrorAlert:@"Unable to access photo library or camera."  withTitle:@"Error"];                    
                }
            });
        }];
    }
    else if (authStatus == AVAuthorizationStatusDenied || authStatus == AVAuthorizationStatusRestricted) {
        // re-test if we can get to photos, if so display action sheet
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
            [self.actionSheet setCancelButtonIndex:[self.actionSheet addButtonWithTitle:@"Cancel"]];
            [self showActionSheet];
        }
        else {
            // can't get to photos or camera, display alert
            [AlertHelper showErrorAlert:@"Unable to access photo library or camera."  withTitle:@"Error"];
        }
    }
}

- (void)showActionSheet
{
    if (IS_IPAD) {
        [self.actionSheet showFromRect:self.popOverSource.frame inView:self.vc.view animated:YES];
    }
    else {
        [self.actionSheet showInView:self.vc.view];
    }
}

- (void)orientationChanged
{
    if (IS_IPAD) {
        if (self.actionSheet.isVisible) {
            [self.actionSheet dismissWithClickedButtonIndex:0 animated:NO];
            [self addImage];
        }
        else if (self.popOver.isPopoverVisible) {
            [self.popOver dismissPopoverAnimated:NO];
            [self.popOver presentPopoverFromRect:self.popOverSource.frame
                                          inView:self.vc.view
                        permittedArrowDirections:UIPopoverArrowDirectionAny
                                        animated:YES];
        }
        DLog(@"frame %@", NSStringFromCGRect(self.popOverSource.frame));
    }
}

#pragma mark
#pragma mark Actionsheet Delegate
#pragma mark

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    long i = buttonIndex;
    switch(i)
    {
        // photo library
        case 0:
        {
            UIImagePickerController * picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.allowsEditing = YES;
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            if (IS_IPAD) {
                self.popOver = [[UIPopoverController alloc] initWithContentViewController:picker];
                self.popOver.backgroundColor = GAMEFLY_NAVBAR_COLOR;
                [self.popOver setPopoverContentSize:CGSizeMake(300, 300)];
                [self.popOver presentPopoverFromRect:self.popOverSource.frame
                                              inView:self.vc.view
                            permittedArrowDirections:UIPopoverArrowDirectionAny
                                            animated:YES];
            }
            else {
                [self.vc presentViewController:picker animated:YES completion:^{}];
            }
        }
            break;
            
        // camera
        case 1:
        {
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.allowsEditing = YES;
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self.vc presentViewController:picker animated:YES completion:^{}];
            
        }
            break;
            
        default:
            break;
    }
}

#pragma mark
#pragma mark ImagePicker Delegate
#pragma mark

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad &&
        picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
        [self.popOver dismissPopoverAnimated:YES];
    } else {
            [picker dismissViewControllerAnimated:YES completion:^{}];
    }
    [picker dismissViewControllerAnimated:YES completion:^{}];
    UIImage *image = [self scaleAndRotateImage:[info objectForKey:@"UIImagePickerControllerEditedImage"]];
    
    // Adjusting Image Orientation
    NSData *data = UIImageJPEGRepresentation(image,1);
    UIImage *tmp = [UIImage imageWithData:data];
    UIImage *fixed = [UIImage imageWithCGImage:tmp.CGImage
                                         scale:image.scale
                                   orientation:image.imageOrientation];
    if ([self.delegate respondsToSelector:@selector(finishedSelectingImage:)]) {
        [self.delegate finishedSelectingImage:fixed];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^{}];
}

- (UIImage *)scaleAndRotateImage:(UIImage *)image {
    
    int kMaxResolution = 640; // Or whatever
    
    CGImageRef imgRef = image.CGImage;
    
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    if (width > kMaxResolution || height > kMaxResolution) {
        CGFloat ratio = width/height;
        if (ratio > 1) {
            bounds.size.width = kMaxResolution;
            bounds.size.height = roundf(bounds.size.width / ratio);
        }
        else {
            bounds.size.height = kMaxResolution;
            bounds.size.width = roundf(bounds.size.height * ratio);
        }
    }
    
    CGFloat scaleRatio = bounds.size.width / width;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    CGFloat boundHeight;
    UIImageOrientation orient = image.imageOrientation;
    switch(orient) {
            
        case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
            
        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
            
        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
            
        case UIImageOrientationLeftMirrored: //EXIF = 5
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationLeft: //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationRightMirrored: //EXIF = 7
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        case UIImageOrientationRight: //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
            
    }
    
    // force square image
    if (bounds.size.height > bounds.size.width) {
        bounds.size.height = bounds.size.width;
    }
    else {
        bounds.size.width = bounds.size.height;
    }
    
    UIGraphicsBeginImageContext(bounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -height, 0);
    }
    else {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);
    }
    
    CGContextConcatCTM(context, transform);
    
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageCopy;
}

@end
