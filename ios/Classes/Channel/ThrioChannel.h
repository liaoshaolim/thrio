//
//  ThrioChannel.h
//  Pods-Runner
//
//  Created by foxsofter on 2019/12/9.
//

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>

#import "ThrioTypes.h"

NS_ASSUME_NONNULL_BEGIN

/// A wrapper class for FlutterMethodChannel and FlutterEventChannel.
///
@interface ThrioChannel : NSObject<FlutterStreamHandler>

/// Construct the instance with a default channel name.
///
+ (instancetype)channel;

/// Construct the instance with a `channelName`.
///
+ (instancetype)channelWithName:(NSString *)channelName;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

/// Invokes the specified Flutter method with the specified arguments, expecting
/// no results.
- (void)invokeMethod:(NSString*)method arguments:(id _Nullable)arguments;

/// Invokes the specified Flutter method with the specified arguments, expecting
/// an asynchronous result.
///
- (void)invokeMethod:(NSString*)method
           arguments:(id _Nullable)arguments
              result:(FlutterResult _Nullable)callback;

/// Register a handler for the specified Flutter method with the specified
/// method.
///
- (ThrioVoidCallback)registryMethodCall:(NSString *)method
                                handler:(ThrioMethodHandler)handler;

/// Must be called before `invokeMethod` to setup the method channel.
///
- (void)setupMethodChannel:(NSObject<FlutterBinaryMessenger> *)messenger;

/// Sends the specified Flutter event with the specified name and arguments.
///
- (void)sendEvent:(NSString *)name arguments:(id _Nullable)arguments;

/// Register a handler for the specified Flutter event with the specified
/// name.
///
- (ThrioVoidCallback)registryEventHandling:(NSString *)name
                                   handler:(ThrioEventHandler)handler;

/// Must be called before `sendEvent` to setup the event channel.
///
- (void)setupEventChannel:(NSObject<FlutterBinaryMessenger> *)messenger;

@end

NS_ASSUME_NONNULL_END
