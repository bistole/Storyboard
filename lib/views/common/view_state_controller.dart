import 'dart:async';

import 'package:flutter/widgets.dart';

class ViewStateController<T> {
  ValueNotifier<T> _valueNotifier;
  StreamController<T> _outputCtrl;
  Stream<T> get outputStream => _outputCtrl.stream;

  ViewStateController(T initial) {
    _valueNotifier = ValueNotifier(initial);

    _valueNotifier.addListener(_valueChanged);
    _outputCtrl = StreamController<T>.broadcast();
    _outputCtrl.sink.add(initial);
  }

  void dispose() {
    _valueNotifier.dispose();
    _outputCtrl.close();
  }

  void _valueChanged() {
    _outputCtrl.sink.add(value);
  }

  addListener(VoidCallback callback) {
    _valueNotifier.addListener(callback);
  }

  removeListener(VoidCallback callback) {
    _valueNotifier.removeListener(callback);
  }

  // set
  set value(T value) {
    if (_valueNotifier.value != value) {
      _valueNotifier.value = value;
    }
  }

  // get
  T get value => _valueNotifier.value;
}
