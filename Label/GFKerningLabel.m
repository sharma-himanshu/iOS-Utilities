//
//  GFKerningLabel.m
//  GameFly
//
//  Created by Himanshu Sharma on 9/5/16.
//  Copyright © 2016 GameFly. All rights reserved.
//

#import "GFKerningLabel.h"
#import "UILabel+Kerning.h"

@implementation GFKerningLabel

- (void)awakeFromNib
{
    [super awakeFromNib];
    if (_kerning > 1) {
        [self setText:[self.text uppercaseString] withKerning:_kerning];
    }
}

@end
