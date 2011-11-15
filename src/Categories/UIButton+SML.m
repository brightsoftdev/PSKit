//
//  UIButton+SML.m
//  SevenMinuteLibrary
//
//  Created by Peter Shih on 6/21/11.
//  Copyright 2011 Seven Minute Labs. All rights reserved.
//

#import "UIButton+SML.h"
#import "PSStyleSheet.h"

@implementation UIButton (SML)

+ (UIButton *)buttonWithFrame:(CGRect)frame andStyle:(NSString *)style target:(id)target action:(SEL)action {
  UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
  btn.frame = frame;
  
  if (style) {
    [btn.titleLabel setFont:[PSStyleSheet fontForStyle:style]];
    [btn setTitleColor:[PSStyleSheet textColorForStyle:style] forState:UIControlStateNormal];
    [btn.titleLabel setShadowColor:[PSStyleSheet shadowColorForStyle:style]];
    [btn.titleLabel setShadowOffset:[PSStyleSheet shadowOffsetForStyle:style]];
  }
  
  if (target && action) {
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
  }
  
	return btn;
}

+ (UIButton *)buttonWithStyle:(NSString *)style {
  return [UIButton buttonWithFrame:CGRectZero andStyle:style target:nil action:nil];
}

@end
