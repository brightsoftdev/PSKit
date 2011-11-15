//
//  UIBarButtonItem+SML.h
//  PhotoTime
//
//  Created by Peter Shih on 8/7/11.
//  Copyright 2011 Seven Minute Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

enum {
  BarButtonTypeNormal = 0,
  BarButtonTypeBlue = 1,
  BarButtonTypeRed = 2,
  BarButtonTypeGreen = 3,
  BarButtonTypeSilver = 4,
  BarButtonTypeGray = 5
};
typedef uint32_t BarButtonType;

@interface UIBarButtonItem (SML)

+ (UIBarButtonItem *)barButtonWithTitle:(NSString *)title withTarget:(id)target action:(SEL)action width:(CGFloat)width height:(CGFloat)height buttonType:(BarButtonType)buttonType style:(NSString *)style;
+ (UIBarButtonItem *)barButtonWithTitle:(NSString *)title withTarget:(id)target action:(SEL)action width:(CGFloat)width height:(CGFloat)height buttonType:(BarButtonType)buttonType;
+ (UIBarButtonItem *)barButtonWithImage:(UIImage *)image withTarget:(id)target action:(SEL)action width:(CGFloat)width height:(CGFloat)height buttonType:(BarButtonType)buttonType;
+ (UIBarButtonItem *)navBackButtonWithTarget:(id)target action:(SEL)action;

@end
