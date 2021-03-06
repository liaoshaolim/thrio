//
//  UINavigationController+FlutterEngine.h
//  thrio
//
//  Created by foxsofter on 2020/2/22.
//

#import <UIKit/UIKit.h>
#import <Flutter/Flutter.h>
#import "ThrioFlutterViewController.h"
#import "ThrioChannel.h"

NS_ASSUME_NONNULL_BEGIN

@interface UINavigationController (FlutterEngine)

- (void)thrio_startupWithEntrypoint:(NSString *)entrypoint readyBlock:(ThrioVoidCallback)block;

- (FlutterEngine *)thrio_getEngineForEntrypoint:(NSString *)entrypoint;

- (ThrioChannel *)thrio_getChannelForEntrypoint:(NSString *)entrypoint;

- (void)thrio_attachFlutterViewController:(ThrioFlutterViewController *)viewController;

- (void)thrio_detachFlutterViewController:(ThrioFlutterViewController *)viewController;

- (void)thrio_removeAllEngineIfNeeded;

- (void)thrio_registerUrls:(NSArray *)urls;

- (void)thrio_unregisterUrls:(NSArray *)urls;

@end

NS_ASSUME_NONNULL_END
