//
//  PSImageCache.m
//  SevenMinuteLibrary
//
//  Created by Peter Shih on 3/10/11.
//  Copyright 2011 Seven Minute Labs. All rights reserved.
//

#import "PSImageCache.h"
#import "NSString+SML.h"
#import "ASIHTTPRequest.h"
#import "PSNetworkQueue.h"

@implementation PSImageCache

@synthesize cachePath = _cachePath;

+ (id)sharedCache {
  static id sharedCache;
  if (!sharedCache) {
    sharedCache = [[self alloc] init];
  }
  return sharedCache;
}

- (id)init {
  self = [super init];
  if (self) {
    _buffer = [[NSCache alloc] init];
    [_buffer setName:@"PSImageCache"];
    [_buffer setDelegate:self];
//    [_buffer setTotalCostLimit:100];
    
    _requestQueue = [[PSNetworkQueue alloc] init];
    _requestQueue.maxConcurrentOperationCount = 10;
    
    // Set to NSDocumentDirectory by default
    [self setupCachePathWithCacheDirectory:NSCachesDirectory];
  }
  return self;
}

- (void)setupCachePathWithCacheDirectory:(NSSearchPathDirectory)cacheDirectory {
  self.cachePath = [[NSSearchPathForDirectoriesInDomains(cacheDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"psimagecache"];
  
  BOOL isDir = NO;
  NSError *error;
  if (![[NSFileManager defaultManager] fileExistsAtPath:_cachePath isDirectory:&isDir] && isDir == NO) {
    [[NSFileManager defaultManager] createDirectoryAtPath:_cachePath withIntermediateDirectories:NO attributes:nil error:&error];
  }
}

#pragma mark Setter/Getter for cacheDirectory
- (void)setCacheDirectory:(NSSearchPathDirectory)cacheDirectory {
  _cacheDirectory = cacheDirectory;
  
  // Change the cachePath to use the new directory
  [self setupCachePathWithCacheDirectory:cacheDirectory];
}

- (NSSearchPathDirectory)cacheDirectory {
  return _cacheDirectory;
}

- (void)dealloc {
  RELEASE_SAFELY(_buffer);
  RELEASE_SAFELY(_cachePath);
  RELEASE_SAFELY(_requestQueue);
  [super dealloc];
}

// Cache Image Data
- (void)cacheImage:(NSData *)imageData forURLPath:(NSString *)urlPath {
  NSString *md5Path = [urlPath stringFromMD5Hash];
  if (imageData) {
    [imageData retain];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
      UIImage *image = [[UIImage alloc] initWithData:imageData];
      if (image) {
        // First put it in the NSCache buffer
        [_buffer setObject:image forKey:md5Path cost:1];
        
        // Also write it to file
        [imageData writeToFile:[_cachePath stringByAppendingPathComponent:md5Path] atomically:YES];
      }
      [imageData release];
      
      dispatch_async(dispatch_get_main_queue(), ^{
        VLog(@"PSImageCache CACHE: %@", urlPath);
        
        // fire notification
        [[NSNotificationCenter defaultCenter] postNotificationName:kPSImageCacheDidCacheImage object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[image autorelease], @"image", urlPath, @"urlPath", nil]];
        
        // Notify delegate
        //    if (delegate && [delegate respondsToSelector:@selector(imageCacheDidLoad:forURLPath:)]) {
        //      [delegate performSelector:@selector(imageCacheDidLoad:forURLPath:) withObject:[image autorelease] withObject:urlPath];
        //    }
      });
    });
  }
}

// Read Cached Image
- (UIImage *)imageForURLPath:(NSString *)urlPath shouldDownload:(BOOL)shouldDownload withDelegate:(id)delegate {
  if (!urlPath) return nil;
  
  // First check NSCache buffer
  //  NSData *imageData = [_buffer objectForKey:[urlPath stringByURLEncoding]];
  UIImage *image = [_buffer objectForKey:[urlPath stringFromMD5Hash]];
  if (image) {
    // Image exists in buffer
    VLog(@"PSImageCache CACHE HIT: %@", urlPath);
    return image;
  } else {
    // Image not in buffer, read from disk instead
    VLog(@"PSImageCache CACHE MISS: %@", urlPath);
    image = [UIImage imageWithContentsOfFile:[_cachePath stringByAppendingPathComponent:[urlPath stringFromMD5Hash]]];
    
    // If Image is in disk, read it
    if (image) {
      VLog(@"PSImageCache DISK HIT: %@", urlPath);
      // Put this image into the buffer also
      [_buffer setObject:image forKey:[urlPath stringFromMD5Hash] cost:1];
      return image;
    } else {
      VLog(@"PSImageCache DISK MISS: %@", urlPath);
      if (shouldDownload) {
        // Download the image data from the source URL
        [self downloadImageForURLPath:urlPath withDelegate:delegate];
      }
      return nil;
    }
  }
}

- (BOOL)hasImageForURLPath:(NSString *)urlPath {
  NSString *md5Path = [urlPath stringFromMD5Hash];
  if ([_buffer objectForKey:md5Path]) {
    // Image exists in memcache
    return YES;
  } else {
    // Check disk for image
    return [[NSFileManager defaultManager] fileExistsAtPath:[_cachePath stringByAppendingPathComponent:md5Path]];
  }
}

- (void)cacheImageForURLPath:(NSString *)urlPath withDelegate:(id)delegate {
  if (![self hasImageForURLPath:urlPath]) {
    [self downloadImageForURLPath:urlPath withDelegate:delegate];
  }
}

#pragma mark Remote Image Load Request
- (BOOL)downloadImageForURLPath:(NSString *)urlPath withDelegate:(id)delegate {
  // Check to make sure urlPath is not already pending
  for (ASIHTTPRequest *request in [_requestQueue operations]) {
    if ([[request.originalURL absoluteString] isEqualToString:urlPath]) {
      VLog(@"urlpath: %@ already enqueued to download", urlPath);
      return NO;
    }
  }
  
  VLog(@"Downloading image at url: %@", urlPath)
  
  ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:urlPath]];
  request.numberOfTimesToRetryOnTimeout = 3;
  request.requestMethod = @"GET";
  request.allowCompressedResponse = YES;
  request.userInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:0] forKey:@"retryCount"];
  
  // Request Completion Block
  [request setDelegate:self];
  [request setDidFinishSelector:@selector(downloadImageRequestFinished:)];
  [request setDidFailSelector:@selector(downloadImageRequestFailed:)];
  
  // Start the Request
  [_requestQueue addOperation:request];
  
  return YES;
}

- (void)downloadImageRequestFinished:(ASIHTTPRequest *)request {
  NSString *urlPath = [[request originalURL] absoluteString];
//  id delegate = [request.userInfo objectForKey:@"delegate"];
  
  if ([request responseData]) {
    [self cacheImage:[request responseData] forURLPath:urlPath];
  } else {
    // something bad happened
  }
}

- (void)downloadImageRequestFailed:(ASIHTTPRequest *)request {
  
//  NSInteger retryCount = [[request.userInfo objectForKey:@"retryCount"] integerValue];
//  
//  // something bad happened, retry if < 3 attempts
//  if (retryCount < 3) {
//    ASIHTTPRequest *retryRequest = [[request copy] autorelease];
//    retryRequest.userInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:retryCount + 1] forKey:@"retryCount"];
//    [_requestQueue addOperation:retryRequest];
//    DLog(@"Retrying request: %d", retryCount + 1);
//  }
}

- (void)cancelDownloadForURLPath:(NSString *)urlPath {
  for (ASIHTTPRequest *request in [_requestQueue operations]) {
    if ([[request.originalURL absoluteString] isEqualToString:urlPath]) {
      [request clearDelegatesAndCancel];
    }
  }
}

#pragma mark NSCacheDelegate
- (void)cache:(NSCache *)cache willEvictObject:(id)obj {
  VLog(@"NSCache evicting object");
}
   
#pragma mark Helpers
+ (NSString *)documentDirectory {
  return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

+ (NSString *)cachesDirectory {
  return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
}

@end
