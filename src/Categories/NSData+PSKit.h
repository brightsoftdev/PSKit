//
//  NSData+PSKit.h
//  SevenMinuteLibrary
//
//  Created by Peter Shih on 6/21/11.
//  Copyright 2011 Seven Minute Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>

@interface NSData (PSKit)

- (NSString *)base64md5String;
- (NSString *)base64EncodedString;
- (NSString *)signedHMACStringWithKey:(NSString *)key usingAlgorithm:(CCHmacAlgorithm)algorithm;

@end
