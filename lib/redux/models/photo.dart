import 'package:flutter/material.dart';

@immutable
class Photo {
  final String uuid;
  final String filename;
  final String mime;
  final String size;
  final bool hasOrigin;
  final bool hasThumb;
  final int deleted;
  final int updatedAt;
  final int createdAt;
  final int ts;

  Photo({
    this.uuid,
    this.filename,
    this.mime,
    this.size,
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
    bool hasOrigin,
    bool hasThumb,
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
        "size: $size, hasOrigin: $hasOrigin, hasThumb: $hasThumb, " +
        "deleted: $deleted, updatedAt: $updatedAt, createdAt: $createdAt}";
  }

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      uuid: json['uuid'],
      filename: json['filename'],
      mime: json['mime'],
      size: json['size'],
      hasOrigin: json['hasOrigin'] ?? false,
      hasThumb: json['hasThumb'] ?? false,
      deleted: json['deleted'],
      updatedAt: json['updatedAt'],
      createdAt: json['createdAt'],
      ts: json['_ts'],
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = new Map();
    map['uuid'] = this.uuid;
    map['filename'] = this.filename;
    map['mime'] = this.mime;
    map['size'] = this.size;
    map['hasOrigin'] = this.hasOrigin;
    map['hasThumb'] = this.hasThumb;
    map['deleted'] = this.deleted;
    map['updatedAt'] = this.updatedAt;
    map['createdAt'] = this.createdAt;
    map['_ts'] = this.ts;
    return map;
  }
}

Map<String, Photo> buildPhotoMap(Map<String, dynamic> json) {
  Map<String, Photo> map = json.map(
    (uuid, element) => MapEntry(
      uuid,
      Photo(
        uuid: element['uuid'],
        filename: element['filename'],
        mime: element['mime'],
        size: element['size'],
        hasOrigin: element['hasOrigin'] ?? false,
        hasThumb: element['hasThumb'] ?? false,
        deleted: element['deleted'],
        updatedAt: element['updatedAt'],
        createdAt: element['createdAt'],
        ts: element['_ts'],
      ),
    ),
  );
  return map;
}
