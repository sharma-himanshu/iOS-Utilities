//
//  SocialPostAccessoryView.m
//  gamecenter
//
//  Created by Himanshu Sharma on 8/13/14.
//  Copyright (c) 2014 GameFly. All rights reserved.
//

#import "SocialPostAccessoryView.h"
#import "GameFlyUI.h"

#define SOCIAL_CHARACTER_COUNT_LIMIT 256

@interface SocialPostAccessoryView ()

@property (nonatomic, assign) NSInteger charactersRemaining;

@end

@implementation SocialPostAccessoryView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code

    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self enablePostButton:NO];
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:self.placeholderText]) {
        textView.text = @"";
    }
    [self enablePostButton:([textView.text isEqualToString:@""] || [textView.text isEqualToString:self.placeholderText]) ? NO : YES];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""]) {
        textView.text = self.placeholderText;
        [self enablePostButton:NO];
    }
}

- (void)textViewDidChange:(UITextView *)textView
{
    NSString *postContent = [self.textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [self enablePostButton:([postContent isEqualToString:@""] || [postContent isEqualToString:self.placeholderText]) ? NO : YES];
    self.charactersRemaining = SOCIAL_CHARACTER_COUNT_LIMIT - postContent.length;
    self.charactersRemainingLabel.text = [NSString stringWithFormat:@"%ld", (long)self.charactersRemaining];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    return textView.text.length + (text.length - range.length) <= SOCIAL_CHARACTER_COUNT_LIMIT;
}

+ (SocialPostAccessoryView *)viewForSocialPostWithDelegate:(id) delegate andPlaceHolder:(NSString *)placeholder
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"SocialPostAccessoryView" owner:nil options:nil];
    for(id currentObject in topLevelObjects) {
        if ([currentObject isKindOfClass:[SocialPostAccessoryView class]]) {
            SocialPostAccessoryView *view = (SocialPostAccessoryView *)currentObject;
            view.delegate = delegate;
            view.textView.backgroundColor = THEMED_TEXT_COLOR;
            view.textView.textColor = THEMED_COLOR;
            view.textView.layer.cornerRadius = 5.0f;
            view.textView.layer.masksToBounds = YES;
            view.placeholderText = placeholder;
            view.textView.text = placeholder;
            return view;
        }
    }
    return nil;
}

- (void)enablePostButton:(BOOL)shouldEnablePostButton
{
    self.postButton.enabled = shouldEnablePostButton;
    self.postButton.backgroundColor = (shouldEnablePostButton) ? GAMEFLY_LIGHT_BLUE : DISABLED_COLOR;
    if ([self.delegate respondsToSelector:@selector(enablePostButton:)]) {
        [self.delegate enablePostButton:shouldEnablePostButton];
    }
}

- (IBAction)postButtonPressed:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(postButtonPressed:)]) {
        [self.delegate postButtonPressed:self.textView.text];
    }
}

@end
