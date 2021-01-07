import 'package:redux/redux.dart';

import '../actions/actions.dart';
import '../models/photo.dart';

final photoReducer = combineReducers<Map<String, Photo>>([
  TypedReducer<Map<String, Photo>, FetchPhotosAction>(_fetchPhotos),
  TypedReducer<Map<String, Photo>, CreatePhotoAction>(_createPhoto),
  TypedReducer<Map<String, Photo>, UpdatePhotoAction>(_updatePhoto),
  TypedReducer<Map<String, Photo>, DownloadPhotoAction>(_downloadPhoto),
  TypedReducer<Map<String, Photo>, ThumbnailPhotoAction>(_thumbnailPhoto),
  TypedReducer<Map<String, Photo>, DeletePhotoAction>(_deletePhoto),
]);

Map<String, Photo> _fetchPhotos(
    Map<String, Photo> photos, FetchPhotosAction action) {
  // new photos
  Map<String, Photo> newPhotos = Map();
  Map<String, Photo> existedPhotos = Map();
  Set<String> removeUuids = Set();

  action.photoMap.forEach((uuid, photo) {
    if (photos[uuid] == null) {
      if (photo.deleted == 0) {
        newPhotos[uuid] = photo;
      }
    } else if (photo.deleted == 0) {
      existedPhotos[uuid] = photo.copyWith(
        hasOrigin: photos[uuid].hasOrigin,
        hasThumb: photos[uuid].hasThumb,
      );
    } else {
      removeUuids.add(photo.uuid);
    }
  });

  // merge
  return Map.from(photos)
    ..addAll(newPhotos)
    ..removeWhere((uuid, photo) => removeUuids.contains(uuid))
    ..map((uuid, photo) => MapEntry(
        uuid, existedPhotos[uuid] != null ? existedPhotos[uuid] : photo));
}

Map<String, Photo> _createPhoto(
  Map<String, Photo> photos,
  CreatePhotoAction action,
) {
  String uuid = action.photo.uuid;
  return Map.from(photos)..addAll({uuid: action.photo});
}

Map<String, Photo> _updatePhoto(
  Map<String, Photo> photos,
  UpdatePhotoAction action,
) {
  String updatedUuid = action.photo.uuid;
  return Map.from(photos).map(
    (uuid, photo) => MapEntry(
      uuid,
      updatedUuid == uuid
          ? action.photo.copyWith(
              hasOrigin: photo.hasOrigin,
              hasThumb: photo.hasThumb,
            )
          : photo,
    ),
  );
}

Map<String, Photo> _downloadPhoto(
  Map<String, Photo> photos,
  DownloadPhotoAction action,
) {
  String updatedUuid = action.uuid;
  return Map.from(photos).map(
    (uuid, photo) => MapEntry(
      uuid,
      updatedUuid == uuid ? photo.copyWith(hasOrigin: true) : photo,
    ),
  );
}

Map<String, Photo> _thumbnailPhoto(
  Map<String, Photo> photos,
  ThumbnailPhotoAction action,
) {
  String updatedUuid = action.uuid;
  return Map.from(photos).map(
    (uuid, photo) => MapEntry(
      uuid,
      updatedUuid == uuid ? photo.copyWith(hasThumb: true) : photo,
    ),
  );
}

Map<String, Photo> _deletePhoto(
  Map<String, Photo> photos,
  DeletePhotoAction action,
) {
  return Map.from(photos)..remove(action.uuid);
}
