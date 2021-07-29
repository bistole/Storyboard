import 'package:flutter/material.dart';

enum QueueItemType {
  Note,
  Photo,
}

QueueItemType decodeType(String typeAsString) {
  for (QueueItemType type in QueueItemType.values) {
    if (type.toString() == typeAsString) {
      return type;
    }
  }
  return null;
}

enum QueueItemAction {
  List,
  Create,
  Update,
  Delete,
  Upload,
  DownloadPhoto,
  DownloadThumbnail,
}

QueueItemAction decodeAction(String actionAsString) {
  for (QueueItemAction action in QueueItemAction.values) {
    if (action.toString() == actionAsString) {
      return action;
    }
  }
  return null;
}

@immutable
class QueueItem {
  final QueueItemType type;
  final QueueItemAction action;
  final String uuid;

  QueueItem({this.type, this.action, this.uuid});

  QueueItem copyWith({
    QueueItemType type,
    QueueItemAction action,
    String uuid,
  }) {
    return QueueItem(
      type: type ?? this.type,
      action: action ?? this.action,
      uuid: uuid ?? this.uuid,
    );
  }

  @override
  int get hashCode => type.hashCode ^ action.hashCode ^ uuid.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QueueItem &&
          type == other.type &&
          action == other.action &&
          uuid == other.uuid);

  @override
  String toString() {
    return "QueueItem{type: $type, action: $action, uuid: $uuid}";
  }

  factory QueueItem.fromJson(Map<String, dynamic> json) {
    return QueueItem(
      type: decodeType(json['type']),
      action: decodeAction(json['action']),
      uuid: json['uuid'],
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = new Map();
    map['type'] = this.type.toString();
    map['action'] = this.action.toString();
    map['uuid'] = this.uuid;
    return map;
  }
}
