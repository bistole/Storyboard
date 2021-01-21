import 'package:flutter/material.dart';

enum Reachable { Yes, No, Unknown }

@immutable
class Setting {
  final String serverKey;
  final Reachable serverReachable;

  Setting({this.serverKey, this.serverReachable});

  Setting copyWith({String serverKey, Reachable serverReachable}) {
    return Setting(
      serverKey: serverKey ?? this.serverKey,
      serverReachable: serverReachable ?? this.serverReachable,
    );
  }

  @override
  int get hashCode => serverKey.hashCode ^ serverReachable.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Setting &&
          serverKey == other.serverKey &&
          serverReachable == other.serverReachable);

  @override
  String toString() {
    return 'Setting{serverKey: $serverKey, serverReachable: $serverReachable}';
  }

  factory Setting.fromJson(Map<String, dynamic> json) {
    return Setting(
      serverKey: json['serverKey'] ?? null,
      serverReachable: Reachable.Unknown,
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {};
    if (this.serverKey != null) {
      map['serverKey'] = this.serverKey;
    }
    return map;
  }
}
