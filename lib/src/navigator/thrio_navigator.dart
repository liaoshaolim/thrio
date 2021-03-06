// Copyright (c) 2019/12/02, 11:28:58 PM The Hellobike. All rights reserved.
// Created by foxsofter, foxsofter@gmail.com.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../channel/thrio_channel.dart';
import '../registry/registry_map.dart';
import 'navigator_receive_channel.dart';
import 'navigator_route_observer.dart';
import 'navigator_send_channel.dart';
import 'navigator_types.dart';
import 'navigator_widget.dart';

class ThrioNavigator {
  ThrioNavigator._();

  static final _default = ThrioNavigator._();

  static TransitionBuilder builder({String entrypoint = ''}) {
    _entrypoint = entrypoint;
    _default._channel = ThrioChannel(channel: '__thrio_app__$entrypoint');
    _default._sendChannel = NavigatorSendChannel(_default._channel);
    _default._receiveChannel = NavigatorReceiveChannel(_default._channel);

    _default._sendChannel.registerUrls(_default._pageBuilders.keys.toList());

    return (context, child) => NavigatorWidget(
          key: _default._stateKey = GlobalKey<NavigatorWidgetState>(),
          observer: NavigatorRouteObserver(_default._channel),
          child: child is Navigator ? child : null,
        );
  }

  static String _entrypoint;

  static String get entrypoint => _entrypoint;

  GlobalKey<NavigatorWidgetState> _stateKey;

  static NavigatorWidgetState get navigatorState =>
      _default._stateKey?.currentState;

  ThrioChannel _channel;

  NavigatorSendChannel _sendChannel;

  NavigatorReceiveChannel _receiveChannel;

  final _pageBuilders = RegistryMap<String, NavigatorPageBuilder>();

  /// Sent when the navigation stack can be pushed.
  ///
  /// Do not call this method.
  ///
  static void ready() => _default._channel.invokeMethod<bool>('ready');

  /// Push the page onto the navigation stack.
  ///
  /// If a native page builder exists for the `url`, open the native page,
  /// otherwise open the flutter page.
  ///
  static Future<bool> push({
    @required String url,
    bool animated = true,
    Map<String, dynamic> params = const {},
  }) =>
      _default._sendChannel.push(
        url: url,
        animated: animated,
        params: params,
      );

  /// Send a notification to the page.
  ///
  /// Notifications will be triggered when the page enters the foreground.
  /// Notifications with the same `name` will be overwritten.
  ///
  static Future<bool> notify({
    @required String url,
    int index = 0,
    @required String name,
    Map<String, dynamic> params = const {},
  }) =>
      _default._sendChannel.notify(
        name: name,
        url: url,
        index: index,
        params: params,
      );

  /// Pop a page from the navigation stack.
  ///
  static Future<bool> pop({bool animated = true}) =>
      _default._sendChannel.pop(animated: animated);

  /// Pop the page in the navigation stack until the page with `url`.
  ///
  static Future<bool> popTo({
    @required String url,
    int index = 0,
    bool animated = true,
  }) =>
      _default._sendChannel.popTo(
        url: url,
        index: index,
        animated: animated,
      );

  /// Remove the page with `url` in the navigation stack.
  ///
  static Future<bool> remove({
    String url = '',
    int index = 0,
    bool animated = true,
  }) =>
      _default._sendChannel.remove(
        url: url,
        index: index,
        animated: animated,
      );

  /// Returns the index of the page that was last pushed to the navigation
  /// stack.
  ///
  static Future<int> lastIndex({String url}) =>
      _default._sendChannel.lastIndex(url: url);

  /// Returns all index of the page with `url` in the navigation stack.
  ///
  static Future<List<int>> allIndex(String index) =>
      _default._sendChannel.allIndex(index);

  /// Setting the page with `url` and `index` cannot be poped..
  ///
  static Future<bool> setPopDisabled({
    @required String url,
    int index = 0,
    bool disabled = true,
  }) =>
      _default._sendChannel.setPopDisabled(
        url: url,
        index: index,
        disabled: disabled,
      );

  /// Sets up a broadcast stream for receiving page notify events.
  ///
  /// return value is `params`.
  ///
  static Stream<Map<String, dynamic>> onPageNotify({
    @required String url,
    @required int index,
    @required String name,
  }) =>
      _default._receiveChannel.onPageNotify(
        url: url,
        index: index,
        name: name,
      );

  /// Register default page builder for the router.
  ///
  /// Unregistry by calling the return value `VoidCallback`.
  ///
  static VoidCallback registerDefaultPageBuilder(
    NavigatorPageBuilder builder,
  ) =>
      _default._pageBuilders.registry(Navigator.defaultRouteName, builder);

  /// Register an page builder for the router.
  ///
  /// Unregistry by calling the return value `VoidCallback`.
  ///
  static VoidCallback registerPageBuilder(
    String url,
    NavigatorPageBuilder builder,
  ) {
    _default._sendChannel?.registerUrls([url]);
    final callback = _default._pageBuilders.registry(url, builder);
    return () {
      callback();
      _default._sendChannel.unregisterUrls([url]);
    };
  }

  /// Register page builders for the router.
  ///
  /// Unregistry by calling the return value `VoidCallback`.
  ///
  static VoidCallback registerPageBuilders(
    Map<String, NavigatorPageBuilder> builders,
  ) {
    _default._sendChannel?.registerUrls(builders.keys.toList());
    final callback = _default._pageBuilders.registryAll(builders);
    return () {
      callback();
      _default._sendChannel.unregisterUrls(builders.keys.toList());
    };
  }

  static NavigatorPageBuilder getPageBuilder(String url) =>
      _default._pageBuilders[url];

  /// Send on hot restart.
  ///
  static void hotRestart() =>
      _default._channel.invokeMethod<bool>('hotRestart');
}
