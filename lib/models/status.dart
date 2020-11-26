import 'package:flutter/material.dart';

enum StatusKey { AddingTask, EditingTask, ListTask }

@immutable
class Status {
  final StatusKey status;
  final dynamic param1;
  final dynamic param2;

  Status(this.status, this.param1, this.param2);

  Status.noParam(StatusKey key)
      : status = key,
        param1 = null,
        param2 = null;

  Status.oneParam(StatusKey key, dynamic param1)
      : status = key,
        param1 = param1,
        param2 = null;

  @override
  int get hashCode => status.hashCode ^ param1.hashCode ^ param2.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Status &&
          status == other.status &&
          param1 == other.param1 &&
          param2 == other.param2);

  @override
  String toString() {
    return 'AppState{status: $status, param1: $param1, param2: $param2}';
  }
}
