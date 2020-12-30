import 'package:redux/redux.dart';

import '../actions/actions.dart';
import '../models/photo.dart';

final photoReducer = combineReducers<Map<String, Photo>>([
  TypedReducer<Map<String, Photo>, FetchPhotosAction>(_fetchPhotos),
  TypedReducer<Map<String, Photo>, CreatePhotoAction>(_createPhoto),
  TypedReducer<Map<String, Photo>, DownloadPhotoAction>(_downloadPhoto),
  TypedReducer<Map<String, Photo>, ThumbnailPhotoAction>(_thumbnailPhoto),
  TypedReducer<Map<String, Photo>, DeletePhotoAction>(_deletePhoto),
]);

Map<String, Photo> _fetchPhotos(
    Map<String, Photo> photos, FetchPhotosAction action) {
  // new photos
  var newPhotos = Map<String, Photo>.fromIterable(
    action.photoList.where((photo) => photos[photo.uuid] == null),
    key: (v) => v.uuid,
    value: (v) => v,
  );
  // existed photos
  var existedPhotos = Map<String, Photo>.fromIterable(
    action.photoList.where((photo) => photos[photo.uuid] != null),
    key: (v) => v.uuid,
    value: (v) => v,
  );

  // update photos from existed photos
  var updatedPhotos = photos.map((uuid, photo) => MapEntry(
      uuid,
      existedPhotos[uuid] == null
          ? photo
          : existedPhotos[uuid].copyWith(
              hasOrigin: photo.hasOrigin,
              hasThumb: photo.hasThumb,
            )));

  // merge
  print(updatedPhotos);
  print(newPhotos);
  return Map.from(updatedPhotos)..addAll(newPhotos);
}

Map<String, Photo> _createPhoto(
    Map<String, Photo> photos, CreatePhotoAction action) {
  return Map.from(photos)
    ..addAll({action.photo.uuid: action.photo.copyWith(hasOrigin: true)});
}

Map<String, Photo> _downloadPhoto(
    Map<String, Photo> photos, DownloadPhotoAction action) {
  return photos.map((uuid, photo) => MapEntry(
      uuid, uuid == action.uuid ? photo.copyWith(hasOrigin: true) : photos));
}

Map<String, Photo> _thumbnailPhoto(
    Map<String, Photo> photos, ThumbnailPhotoAction action) {
  return photos.map((uuid, photo) => MapEntry(
      uuid, uuid == action.uuid ? photo.copyWith(hasThumb: true) : photo));
}

Map<String, Photo> _deletePhoto(
    Map<String, Photo> photos, DeletePhotoAction action) {
  return photos.map((uuid, photo) => MapEntry(
      uuid,
      uuid == action.photo.uuid
          ? action.photo.copyWith(
              hasOrigin: photo.hasOrigin,
              hasThumb: photo.hasThumb,
            )
          : photo));
}
