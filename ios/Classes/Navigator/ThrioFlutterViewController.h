//
//  ThrioFlutterViewController.h
//  thrio
//
//  Created by foxsofter on 2019/12/11.
//

#import <Flutter/Flutter.h>
#import "NavigatorNotifyProtocol.h"
#import "ThrioTypes.h"

NS_ASSUME_NONNULL_BEGIN

@interface ThrioFlutterViewController : FlutterViewController<UINavigationControllerDelegate>

- (instancetype)initWithEntrypoint:(NSString *)entrypoint NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (instancetype)initWithNibName:(NSString * _Nullable)nibNameOrNil
                         bundle:(NSBundle * _Nullable)nibBundleOrNil NS_UNAVAILABLE;
- (instancetype)initWithEngine:(FlutterEngine*)engine
                       nibName:(NSString* _Nullable)nibName
                        bundle:(NSBundle* _Nullable)nibBundle NS_UNAVAILABLE;
- (instancetype)initWithProject:(FlutterDartProject* _Nullable)project
                        nibName:(NSString* _Nullable)nibName
                         bundle:(NSBundle* _Nullable)nibBundle NS_UNAVAILABLE;

- (void)surfaceUpdated:(BOOL)appeared;

@property (nonatomic, copy, readonly) NSString *entrypoint;

@end

NS_ASSUME_NONNULL_END
