//
//  PSFacebookCenter.h
//  MealTime
//
//  Created by Peter Shih on 8/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Facebook.h"

// Facebook
#define FB_APP_ID @"APP_ID_HERE"
#define FB_PERMISSIONS_PUBLISH @"publish_stream"
#define FB_BASIC_PERMISISONS [NSArray arrayWithObjects:@"offline_access", nil]

#define kPSFacebookCenterDialogDidSucceed @"PSFacebookCenterDialogDidSucceed"
#define kPSFacebookCenterDialogDidFail @"PSFacebookCenterDialogDidFail"

@interface PSFacebookCenter : PSObject <FBDialogDelegate, FBSessionDelegate, UIAlertViewDelegate> {
  Facebook *_facebook;
  NSArray *_newPermissions;
}

+ (id)defaultCenter;

- (BOOL)handleOpenURL:(NSURL *)url;

// Login
- (BOOL)isLoggedIn;

// Permissions
- (void)authorizeBasicPermissions;
- (BOOL)hasPublishStreamPermission;
- (void)requestPublishStream;
- (NSArray *)availableExtendedPermissions;
- (void)addExtendedPermission:(NSString *)permission;

// Dialog
- (void)showDialog:(NSString *)dialog andParams:(NSMutableDictionary *)params;

@end
