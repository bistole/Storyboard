import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

enum Reachable { Yes, No, Unknown }

@immutable
class Setting {
  final String clientID;
  final String serverKey;
  final Reachable serverReachable;

  Setting({this.clientID, this.serverKey, this.serverReachable});

  Setting copyWith({
    String clientID,
    String serverKey,
    Reachable serverReachable,
  }) {
    return Setting(
      clientID: clientID ?? this.clientID,
      serverKey: serverKey ?? this.serverKey,
      serverReachable: serverReachable ?? this.serverReachable,
    );
  }

  @override
  int get hashCode =>
      clientID.hashCode ^ serverKey.hashCode ^ serverReachable.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Setting &&
          clientID == other.clientID &&
          serverKey == other.serverKey &&
          serverReachable == other.serverReachable);

  @override
  String toString() {
    return 'Setting{clientID: $clientID, serverKey: $serverKey, serverReachable: $serverReachable}';
  }

  factory Setting.fromJson(Map<String, dynamic> json) {
    return Setting(
      clientID: json['clientID'] ?? Uuid().v4(),
      serverKey: json['serverKey'] ?? null,
      serverReachable: Reachable.Unknown,
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {};
    if (this.serverKey != null) {
      map['clientID'] = this.clientID;
      map['serverKey'] = this.serverKey;
    }
    return map;
  }
}
