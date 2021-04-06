import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:storyboard/logger/logger.dart';

typedef VoidCallback = void Function();

class _MenuItemNotifierListener
    extends LinkedListEntry<_MenuItemNotifierListener> {
  VoidCallback listener;
  _MenuItemNotifierListener({this.listener});
}

class _MenuItemNotifier extends Listenable implements ChangeNotifier {
  String _logTag = (_MenuItemNotifier).toString();
  Logger _logger;

  LinkedList<_MenuItemNotifierListener> _listeners;

  _MenuItemNotifier({@required logger}) : this._logger = logger {
    _listeners = LinkedList();
  }

  void dispose() {
    _listeners = null;
  }

  @protected
  bool get hasListeners {
    if (_listeners == null) return false;
    return _listeners.isNotEmpty;
  }

  void addListener(VoidCallback listener) {
    if (_listeners == null) return;
    _listeners.add(_MenuItemNotifierListener(listener: listener));
  }

  void removeListener(VoidCallback listener) {
    if (_listeners == null) return;
    for (final _MenuItemNotifierListener entry in _listeners) {
      if (entry.listener == listener) {
        entry.unlink();
        return;
      }
    }
  }

  void notifyListeners() {
    if (_listeners.isEmpty) return;

    final List<_MenuItemNotifierListener> localListeners =
        List<_MenuItemNotifierListener>.from(_listeners);

    for (final _MenuItemNotifierListener entry in localListeners) {
      try {
        if (entry.list != null) entry.listener();
      } catch (e) {
        _logger.error(_logTag, "notify listener failed: $e");
      }
    }
  }
}

class MenuNotifier {
  Logger _logger;

  LinkedHashMap<String, _MenuItemNotifier> _map;

  MenuNotifier({@required logger}) : this._logger = logger {
    _map = LinkedHashMap();
  }

  void dispose() {
    _map = null;
  }

  bool hasListeners(String menu) {
    if (_map == null) return false;
    if (_map[menu] == null) return false;
    return _map[menu].hasListeners;
  }

  void addListener(String menu, VoidCallback listener) {
    if (_map == null) return;
    if (_map[menu] == null) {
      _map[menu] = _MenuItemNotifier(logger: this._logger);
    }
    _map[menu].addListener(listener);
  }

  void removeListener(String menu, VoidCallback listener) {
    if (_map == null) return;
    if (_map[menu] != null) {
      _map[menu].removeListener(listener);
    }
  }

  void notifyListeners(String menu) {
    if (_map == null) return;
    if (_map[menu] != null) {
      _map[menu].notifyListeners();
    }
  }
}
