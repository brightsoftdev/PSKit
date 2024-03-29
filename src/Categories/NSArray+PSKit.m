//
//  NSArray+PSKit.m
//  SevenMinuteLibrary
//
//  Created by Peter Shih on 6/21/11.
//  Copyright 2011 Seven Minute Labs. All rights reserved.
//

#import "NSArray+PSKit.h"


@implementation NSArray (PSKit)

- (id)firstObject {
  if ([self count] > 0) {
    return [self objectAtIndex:0];
  } else {
    return nil;
  }
}

- (id)randomObject {
  if ([self count] > 0) {
    return [self objectAtIndex:arc4random() % [self count]];
  } else {
    return nil;
  }
}

@end
