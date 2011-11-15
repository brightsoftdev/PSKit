//
//  PSImageView.h
//  SevenMinuteLibrary
//
//  Created by Peter Shih on 3/10/11.
//  Copyright 2011 Seven Minute Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "PSConstants.h"
#import "NSString+SML.h"
#import "PSImageViewDelegate.h"

@interface PSImageView : UIImageView {
  UIActivityIndicatorView *_loadingIndicator;
  UIImage *_placeholderImage;
  
  BOOL _shouldScale;
  BOOL _shouldAnimate;
  id <PSImageViewDelegate> _delegate;
}

- (void)animateImageFade:(UIImage *)image;

@property (nonatomic, retain) UIImage *placeholderImage;
@property (nonatomic, assign) BOOL shouldScale;
@property (nonatomic, assign) BOOL shouldAnimate;
@property (nonatomic, assign) id <PSImageViewDelegate> delegate;

@end
