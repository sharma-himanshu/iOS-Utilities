//
//  SocialPostAccessoryView.h
//  gamecenter
//
//  Created by Himanshu Sharma on 8/13/14.
//  Copyright (c) 2014 GameFly. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SocialPostAccessoryViewDelegate <NSObject>

- (void)postButtonPressed:(NSString *)postContent;
- (void)enablePostButton:(BOOL)shouldEnablePostButton;
// HS Using a Fixed height after discussing it with Peter, so this is not needed. 
//- (void)updateAccessoryViewHeight:(CGRect)rect;

@end

@interface SocialPostAccessoryView : UIView <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) id <SocialPostAccessoryViewDelegate> delegate;
@property (strong, nonatomic) NSString *placeholderText;
@property (weak, nonatomic) IBOutlet UIButton *postButton;
@property (weak, nonatomic) IBOutlet UILabel *charactersRemainingLabel;

+ (SocialPostAccessoryView *)viewForSocialPostWithDelegate:(id)delegate andPlaceHolder:(NSString *)placeholder;

@end
