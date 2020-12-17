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
      hasOrigin: false,
      hasThumb: false,
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

List<Photo> buildPhotoList(List<dynamic> json) {
  var list = new List<Photo>();
  json.forEach((element) {
    list.add(Photo(
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
    ));
  });
  return list;
}
