import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:storyboard/logger/logger.dart';

typedef VoidCallback = void Function();

class _ItemNotifierListener extends LinkedListEntry<_ItemNotifierListener> {
  VoidCallback listener;
  _ItemNotifierListener({this.listener});
}

class _ItemNotifier<T> extends ValueListenable implements ChangeNotifier {
  String _logTag = (_ItemNotifier).toString();
  Logger _logger;

  LinkedList<_ItemNotifierListener> _listeners;

  _ItemNotifier({@required logger}) : this._logger = logger {
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
    _listeners.add(_ItemNotifierListener(listener: listener));
  }

  void removeListener(VoidCallback listener) {
    if (_listeners == null) return;
    for (final _ItemNotifierListener entry in _listeners) {
      if (entry.listener == listener) {
        entry.unlink();
        return;
      }
    }
  }

  void notifyListeners({T param}) {
    if (_listeners.isEmpty) return;

    this.value = param;

    final List<_ItemNotifierListener> localListeners =
        List<_ItemNotifierListener>.from(_listeners);

    for (final _ItemNotifierListener entry in localListeners) {
      try {
        if (entry.list != null) entry.listener();
      } catch (e) {
        _logger.error(_logTag, "notify listener failed: $e");
      }
    }
  }

  T getValue() {
    return value;
  }

  @override
  T value;
}

class Notifier {
  Logger _logger;
  void setLogger(Logger logger) {
    _logger = logger;
  }

  LinkedHashMap<String, _ItemNotifier> _map;

  Notifier() {
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

  void registerNotifier<T>(String menu) {
    if (_map == null) return;
    if (_map[menu] == null) {
      _map[menu] = _ItemNotifier<T>(logger: this._logger);
    }
  }

  void addListener<T>(
    String menu,
    VoidCallback listener,
  ) {
    if (_map == null) return;
    if (_map[menu] != null) {
      _map[menu].addListener(listener);
    }
  }

  void removeListener(String menu, VoidCallback listener) {
    if (_map == null) return;
    if (_map[menu] != null) {
      _map[menu].removeListener(listener);
    }
  }

  void notifyListeners<T>(String menu, {T param}) {
    if (_map == null) return;
    if (_map[menu] != null) {
      _map[menu].notifyListeners(param: param);
    }
  }

  T getValue<T>(String menu) {
    return _map[menu].getValue();
  }
}
