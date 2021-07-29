import 'package:flutter/material.dart';

enum PhotoStatus {
  None,
  Loading,
  Ready,
}

PhotoStatus decodeStatus(dynamic statusAsString) {
  if (statusAsString == true) {
    return PhotoStatus.Ready;
  }

  for (PhotoStatus status in PhotoStatus.values) {
    if (status.toString() == statusAsString) {
      return status;
    }
  }
  return PhotoStatus.None;
}

@immutable
class Photo {
  final String uuid;
  final String filename;
  final String mime;
  final String size;
  final int direction;
  final PhotoStatus hasOrigin;
  final PhotoStatus hasThumb;
  final int deleted;
  final int updatedAt;
  final int createdAt;
  final int ts;

  Photo({
    this.uuid,
    this.filename,
    this.mime,
    this.size,
    this.direction,
    this.hasOrigin,
    this.hasThumb,
    this.deleted,
    this.updatedAt,
    this.createdAt,
    this.ts,
  });

  Photo copyWith({
    String uuid,
    String filename,
    String mime,
    String size,
    int direction,
    PhotoStatus hasOrigin,
    PhotoStatus hasThumb,
    int deleted,
    int updatedAt,
    int createdAt,
    int ts,
  }) {
    return Photo(
      uuid: uuid ?? this.uuid,
      filename: filename ?? this.filename,
      mime: mime ?? this.mime,
      size: size ?? this.size,
      direction: direction ?? this.direction,
      hasOrigin: hasOrigin ?? this.hasOrigin,
      hasThumb: hasThumb ?? this.hasThumb,
      deleted: deleted ?? this.deleted,
      updatedAt: updatedAt ?? this.updatedAt,
      createdAt: createdAt ?? this.createdAt,
      ts: ts ?? this.ts,
    );
  }

  @override
  int get hashCode =>
      uuid.hashCode ^
      filename.hashCode ^
      mime.hashCode ^
      size.hashCode ^
      direction.hashCode ^
      hasOrigin.hashCode ^
      hasThumb.hashCode ^
      deleted.hashCode ^
      updatedAt.hashCode ^
      createdAt.hashCode ^
      ts.hashCode;

  @override
  bool operator ==(Object other) {
    var same = identical(this, other) ||
        (other is Photo &&
            uuid == other.uuid &&
            filename == other.filename &&
            mime == other.mime &&
            size == other.size &&
            direction == other.direction &&
            hasOrigin == other.hasOrigin &&
            hasThumb == other.hasThumb &&
            deleted == other.deleted &&
            updatedAt == other.updatedAt &&
            createdAt == other.createdAt &&
            ts == other.ts);
    return same;
  }

  @override
  String toString() {
    return "Photo{uuid: $uuid, filename: $filename, mime: $mime, " +
        "size: $size, direction: $direction, hasOrigin: $hasOrigin, hasThumb: $hasThumb, " +
        "deleted: $deleted, updatedAt: $updatedAt, createdAt: $createdAt}";
  }

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      uuid: json['uuid'],
      filename: json['filename'],
      mime: json['mime'],
      size: json['size'],
      direction: json['direction'] ?? 0,
      hasOrigin: decodeStatus(json['hasOrigin']),
      hasThumb: decodeStatus(json['hasThumb']),
      deleted: json['deleted'],
      updatedAt: json['updatedAt'],
      createdAt: json['createdAt'],
      ts: json['_ts'],
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {};
    map['uuid'] = this.uuid;
    map['filename'] = this.filename;
    map['mime'] = this.mime;
    map['size'] = this.size;
    map['direction'] = this.direction;
    map['hasOrigin'] = this.hasOrigin.toString();
    map['hasThumb'] = this.hasThumb.toString();
    map['deleted'] = this.deleted;
    map['updatedAt'] = this.updatedAt;
    map['createdAt'] = this.createdAt;
    map['_ts'] = this.ts;
    return map;
  }
}

Map<String, Photo> buildPhotoMap(List<dynamic> json) {
  Map<String, Photo> map = <String, Photo>{};
  json.forEach((element) {
    var uuid = element['uuid'];
    if (!(uuid is String)) return;
    map[uuid] = Photo(
      uuid: element['uuid'],
      filename: element['filename'],
      mime: element['mime'],
      size: element['size'],
      direction: element['direction'] ?? 0,
      hasOrigin: decodeStatus(element['hasOrigin']),
      hasThumb: decodeStatus(element['hasThumb']),
      deleted: element['deleted'],
      updatedAt: element['updatedAt'],
      createdAt: element['createdAt'],
      ts: element['_ts'],
    );
  });
  return map;
}
