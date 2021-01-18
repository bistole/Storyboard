import 'package:flutter/material.dart';

@immutable
class Setting {
  final String serverKey;

  Setting({this.serverKey});

  Setting copyWith({String serverKey}) {
    return Setting(serverKey: serverKey ?? this.serverKey);
  }

  @override
  int get hashCode => serverKey.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Setting && serverKey == other.serverKey);

  @override
  String toString() {
    return 'Setting{serverKey: $serverKey}';
  }

  factory Setting.fromJson(Map<String, dynamic> json) {
    return Setting(
      serverKey: json['serverKey'] ?? null,
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
