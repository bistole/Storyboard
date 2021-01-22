import 'package:storyboard/redux/models/photo.dart';

class PhotoRepo {
  final Map<String, Photo> photos;
  final int lastTS;

  PhotoRepo({this.photos, this.lastTS});

  PhotoRepo copyWith({Map<String, Photo> photos, int lastTS}) {
    return PhotoRepo(
      photos: photos ?? this.photos,
      lastTS: lastTS ?? this.lastTS,
    );
  }

  @override
  int get hashCode => photos.hashCode ^ lastTS.hashCode;

  @override
  bool operator ==(Object other) {
    var same = identical(this, other) ||
        (other is PhotoRepo &&
            photos == other.photos &&
            lastTS == other.lastTS);
    return same;
  }

  @override
  String toString() {
    return "PhotoRepo{photos: $photos, lastTS: $lastTS}";
  }

  factory PhotoRepo.fromJson(Map<String, dynamic> json) {
    var photos = <String, Photo>{};
    if (json is Map && json['photos'] is Map) {
      json['photos'].forEach((uuid, jsonPhoto) {
        var photo = Photo.fromJson(jsonPhoto);
        photos[photo.uuid] = photo;
      });
    }

    int lastTS = 0;
    if (json is Map && json['ts'] is int) {
      lastTS = json['ts'];
    }

    return PhotoRepo(
      photos: photos,
      lastTS: lastTS,
    );
  }

  Map<String, dynamic> toJson() {
    var jsonPhotos = {};
    photos.forEach((uuid, photo) {
      jsonPhotos[uuid] = photo.toJson();
    });

    Map<String, dynamic> json = {};
    json['ts'] = lastTS;
    json['photos'] = jsonPhotos;

    return json;
  }
}
