import 'package:flutter/material.dart';

@immutable
class Task {
  final String uuid;
  final String title;
  final int deleted;
  final int updatedAt;
  final int createdAt;
  final int ts;

  Task({
    this.uuid,
    this.title,
    this.deleted,
    this.updatedAt,
    this.createdAt,
    this.ts,
  });

  Task copyWith({
    String uuid,
    String title,
    int deleted,
    int updatedAt,
    int createdAt,
    int ts,
  }) {
    return Task(
      uuid: uuid ?? this.uuid,
      title: title ?? this.title,
      deleted: deleted ?? this.deleted,
      updatedAt: updatedAt ?? this.updatedAt,
      createdAt: createdAt ?? this.createdAt,
      ts: ts ?? this.ts,
    );
  }

  @override
  int get hashCode =>
      uuid.hashCode ^
      title.hashCode ^
      deleted.hashCode ^
      updatedAt.hashCode ^
      createdAt.hashCode ^
      ts.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Task &&
          uuid == other.uuid &&
          title == other.title &&
          deleted == other.deleted &&
          updatedAt == other.updatedAt &&
          createdAt == other.createdAt &&
          ts == other.ts);

  @override
  String toString() {
    return "Task{uuid: $uuid, title: $title, deleted: $deleted, updatedAt: $updatedAt, createdAt: $createdAt}";
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      uuid: json['uuid'],
      title: json['title'],
      deleted: json['deleted'],
      updatedAt: json['updatedAt'],
      createdAt: json['createdAt'],
      ts: json['_ts'],
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = new Map();
    map['uuid'] = this.uuid;
    map['title'] = this.title;
    map['deleted'] = this.deleted;
    map['updatedAt'] = this.updatedAt;
    map['createdAt'] = this.createdAt;
    map['_ts'] = this.ts;
    return map;
  }
}

Map<String, Task> buildTaskMap(List<dynamic> json) {
  var map = <String, Task>{};
  json.forEach((element) {
    var uuid = element['uuid'];
    if (!(uuid is String)) return;

    map[uuid] = Task(
      uuid: element['uuid'],
      title: element['title'],
      deleted: element['deleted'],
      updatedAt: element['updatedAt'],
      createdAt: element['createdAt'],
      ts: element['_ts'],
    );
  });
  return map;
}
