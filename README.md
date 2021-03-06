# thrio

thrio 是一个支持 flutter 嵌入原生应用的路由库，目前只有 iOS 版本可看，Android 版本在开发中。

[引擎管理](./doc/FlutterEngine.md)

## 为什么写 thrio

thrio 的诞生主要是为了解决我们自身的业务问题。

我们目前积累了将近 10 万行 Dart 业务代码，早期的时候采用 flutter_boost 提供的解决方案来实现将 Flutter 嵌入原生应用，使用过程中也积累了很多对 flutter_boost 改造的需求，但因为 flutter_boost 的路线图短期或者长期都看不到能满足我们这些需求的可能，所以我们只好自己造了一个轮子。

## 需求是什么

1. 三端统一的打开页面的接口，至少支持 push，支持多开页面实例，flutter_boost 支持
2. 三端统一的关闭页面的接口，至少支持关闭顶层页面，关闭特定页面，关闭到特定页面，flutter_boost 支持前两点，第三点不支持
3. 三端统一的页面间通知的接口，一定要支持特定页面间的通知传递，flutter_boost 支持不好，无法满足特定页面间的通知传递
4. dart 页面导航栏自动隐藏，且不影响原生页面的导航栏，flutter_boost 不支持，需要自行扩展
5. iOS 的 FlutterViewController 要支持侧滑返回，flutter_boost 不支持
6. 原生页面和 dart 页面要支持页面禁止关闭，flutter_boost 支持了 dart 页面，但页面动画缺失
7. 支持 FlutterViewController 内嵌套 Dart 页面，flutter_boost 的支持非常弱

**以上对 flutter_boost 的一些判断可能不准确，仅做对比。**

## thrio 提供的功能

### 注册页面路由

1. dart 中注册页面路由

```dart
class Module with ThrioModule {
  @override
  void onPageRegister() {
    registerPageBuilder(
      'flutter3',
      (settings) => Page3(index: settings.index, params: settings.params),
    );
    registerPageBuilder(
      'flutter4',
      (settings) => Page4(index: settings.index, params: settings.params),
    );
  }
}
```

2. iOS 中注册页面路由

```objc
- (void)onPageRegister {
  [self registerNativeViewControllerBuilder:^UIViewController * _Nullable(NSDictionary<NSString *,id> * _Nonnull params) {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    return [sb instantiateViewControllerWithIdentifier:@"ThrioViewController"];
  } forUrl:@"native1"];
}
```

### 打开页面

1. Dart 端打开页面

```dart
ThrioNavigator.push(url: 'flutter1');
// 传入参数
ThrioNavigator.push(url: 'native1', params: { '1': {'2': '3'}});
// 是否动画，目前在内嵌的dart页面中动画无法取消，原生iOS页面有效果
ThrioNavigator.push(url: 'native1', animated:true);
```

2. iOS 端打开页面

```objc
[ThrioNavigator pushUrl:@"flutter1"];
```

### 关闭顶层页面

1. dart 端关闭顶层页面

```dart
// 默认动画开启
ThrioNavigator.pop();
// 不开启动画，原生和dart页面都生效
ThrioNavigator.pop(animated: false);
```

2. iOS 端关闭顶层页面

```objc
// 默认动画开启
[ThrioNavigator pop];
// 关闭动画
[ThrioNavigator popAnimated:NO];
```

### 关闭到页面

1. dart 端关闭到页面

```dart
// 默认动画开启
ThrioNavigator.popTo(url: 'flutter1');
// 不开启动画，原生和dart页面都生效
ThrioNavigator.popTo(url: 'flutter1', animated: false);
```

2. iOS 端关闭到页面

```objc
// 默认动画开启
[ThrioNavigator popToUrl:@"flutter1"];
// 关闭动画
[ThrioNavigator popToUrl:@"flutter1" animated:NO];
```

### 关闭特定页面

1. dart 端关闭特定页面

```dart
ThrioNavigator.remove(url: 'flutter1');
// 只有当页面是顶层页面时，animated参数才会生效
ThrioNavigator.remove(url: 'flutter1', animated: true);
```

2. iOS 端关闭特定页面

```objc
[ThrioNavigator removeUrl:@"flutter1"];
// 只有当页面是顶层页面时，animated参数才会生效
[ThrioNavigator removeUrl:@"flutter1" animated:NO];
```

### 给特定页面发通知

给一个页面发送通知，只有当页面呈现之后才会收到该通知。

1. dart 端给特定页面发通知

```dart
ThrioNavigator.notify(url: 'flutter1', name: 'reload');
```

2. iOS 端给特定页面发通知

```objc
[ThrioNavigator notifyUrl:@"flutter1" name:@"reload"];
```

### 页面接收通知

1. dart 端接收页面通知

使用`NavigatorPageNotify`这个Widget来实现在任何地方接收当前页面收到的通知。

```dart
NavigatorPageNotify(
      name: 'page1Notify',
      onPageNotify: (params) =>
          ThrioLogger().v('flutter1 receive notify: $params'),
      child: Xxxx());
```

2. iOS 端接收页面通知

`UIViewController`实现协议`NavigatorNotifyProtocol`，通过该协议定义的方法来接收页面通知

```objc
- (void)onNotify:(NSString *)name params:(NSDictionary *)params {
  ThrioLogV(@"native1 onNotify: %@, %@", name, params);
}
```

### Flutter 页面导航栏自动隐藏

实际上实现了 UIViewController 的分类扩展，FlutterViewController 强制设为 YES，原生页面设置导航栏隐藏，也很简单

```objc
viewController.thrio_hidesNavigationBar = NO;
```

### iOS 的 FlutterViewController 支持侧滑返回

FlutterViewController 默认是不支持侧滑返回的，因为 thrio 支持一个 FlutterViewController 可以打开任意多个 dart 页面，dart 页面本身也是要支持侧滑返回的，手势上存在一定的冲突，在这里 thrio 做了一些特殊处理，基本上支持无缝切换。有兴趣可以参看源码实现。

### 原生页面和 dart 页面支持页面禁止关闭

1. dart 端禁止特定页面关闭

```dart
ThrioNavigator.setPopDisabled(url: 'flutter1');
```

2. iOS 端禁止特定页面关闭

```objc
[ThrioNavigator setPopDisabledUrl:@"flutter1" disabled:NO];
```

在 dart 端依然支持通过 WillPopScope 来设置禁止页面返回。

### 支持内嵌套 Flutter 页面

这是谷歌推荐的实现方式，导航栈中不被原生页面分隔的所有Flutter页面共用一个原生的容器页面，有效减少内存消耗量。

1. iOS端

- 在 iOS 中，打开一个新的 FlutterViewController，内存消耗大概是12M+，打开一个内嵌的Flutter页面，内存消耗不会超过2M，目前在我们的商家App上，95%的页面都不会需要从Flutter页面跳转到原生页面，整个App的内存占用将会减少很多。


