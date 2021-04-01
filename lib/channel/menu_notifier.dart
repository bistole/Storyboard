import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

typedef VoidCallback = void Function();

class _MenuItemNotifierListener
    extends LinkedListEntry<_MenuItemNotifierListener> {
  VoidCallback listener;
  _MenuItemNotifierListener({this.listener});
}

class _MenuItemNotifier extends Listenable implements ChangeNotifier {
  LinkedList<_MenuItemNotifierListener> _listeners;

  bool _debugAssertNotDisposed() {
    assert(() {
      if (_listeners == null) {
        throw FlutterError('A $runtimeType was used after being disposed.\n'
            'Once you have called dispose() on a $runtimeType, it can no longer be used.');
      }
      return true;
    }());
    return true;
  }

  _MenuItemNotifier() {
    _listeners = LinkedList();
  }

  void dispose() {
    assert(_debugAssertNotDisposed());
    _listeners = null;
  }

  @protected
  bool get hasListeners {
    assert(_debugAssertNotDisposed());
    return _listeners.isNotEmpty;
  }

  void addListener(VoidCallback listener) {
    assert(_debugAssertNotDisposed());
    _listeners.add(_MenuItemNotifierListener(listener: listener));
  }

  void removeListener(VoidCallback listener) {
    assert(_debugAssertNotDisposed());
    for (final _MenuItemNotifierListener entry in _listeners) {
      if (entry.listener == listener) {
        entry.unlink();
        return;
      }
    }
  }

  void notifyListeners() {
    assert(_debugAssertNotDisposed());
    if (_listeners.isEmpty) return;

    final List<_MenuItemNotifierListener> localListeners =
        List<_MenuItemNotifierListener>.from(_listeners);

    for (final _MenuItemNotifierListener entry in localListeners) {
      try {
        if (entry.list != null) entry.listener();
      } catch (exception, stack) {
        FlutterError.reportError(FlutterErrorDetails(
          exception: exception,
          stack: stack,
          library: 'foundation library',
          context: ErrorDescription(
              'while dispatching notifications for $runtimeType'),
          informationCollector: () sync* {
            yield DiagnosticsProperty<ChangeNotifier>(
              'The $runtimeType sending notification was',
              this,
              style: DiagnosticsTreeStyle.errorProperty,
            );
          },
        ));
      }
    }
  }
}

class MenuNotifier {
  LinkedHashMap<String, _MenuItemNotifier> _map;

  bool _debugAssertNotDisposed() {
    assert(() {
      if (_map == null) {
        throw FlutterError('A $runtimeType was used after being disposed.\n'
            'Once you have called dispose() on a $runtimeType, it can no longer be used.');
      }
      return true;
    }());
    return true;
  }

  MenuNotifier() {
    _map = LinkedHashMap();
  }

  void dispose() {
    assert(_debugAssertNotDisposed());
    _map = null;
  }

  void addListener(String menu, VoidCallback listener) {
    assert(_debugAssertNotDisposed());
    if (_map[menu] == null) {
      _map[menu] = _MenuItemNotifier();
    }
    _map[menu].addListener(listener);
  }

  void removeListener(String menu, VoidCallback listener) {
    assert(_debugAssertNotDisposed());
    if (_map[menu] != null) {
      _map[menu].removeListener(listener);
    }
  }

  void notifyListeners(String menu) {
    assert(_debugAssertNotDisposed());
    if (_map[menu] != null) {
      _map[menu].notifyListeners();
    }
  }
}
