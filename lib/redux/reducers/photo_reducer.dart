import 'package:redux/redux.dart';
import 'package:storyboard/redux/models/photo_repo.dart';

import '../actions/actions.dart';
import '../models/photo.dart';

final photoReducer = combineReducers<PhotoRepo>([
  TypedReducer<PhotoRepo, FetchPhotosAction>(_fetchPhotos),
  TypedReducer<PhotoRepo, CreatePhotoAction>(_createPhoto),
  TypedReducer<PhotoRepo, UpdatePhotoAction>(_updatePhoto),
  TypedReducer<PhotoRepo, DownloadPhotoAction>(_downloadPhoto),
  TypedReducer<PhotoRepo, ThumbnailPhotoAction>(_thumbnailPhoto),
  TypedReducer<PhotoRepo, DeletePhotoAction>(_deletePhoto),
]);

PhotoRepo _fetchPhotos(
  PhotoRepo photoRepo,
  FetchPhotosAction action,
) {
  // new photos
  Map<String, Photo> newPhotos = Map();
  Map<String, Photo> existedPhotos = Map();
  Set<String> removeUuids = Set();

  int lastTS = photoRepo.lastTS;
  action.photoMap.forEach((uuid, element) {
    if (photoRepo.photos[uuid] == null) {
      if (element.deleted == 0) {
        newPhotos[uuid] = element;
      }
    } else if (element.deleted == 0) {
      existedPhotos[uuid] = element.copyWith(
        hasOrigin: photoRepo.photos[uuid].hasOrigin,
        hasThumb: photoRepo.photos[uuid].hasThumb,
      );
    } else {
      removeUuids.add(element.uuid);
    }
    if (element.ts > lastTS) {
      lastTS = element.ts;
    }
  });

  // merge
  return photoRepo.copyWith(
    photos: Map.from(photoRepo.photos).map((uuid, photo) => MapEntry(
        uuid, existedPhotos[uuid] != null ? existedPhotos[uuid] : photo))
      ..addAll(newPhotos)
      ..removeWhere((uuid, photo) => removeUuids.contains(uuid)),
    lastTS: lastTS,
  );
}

PhotoRepo _createPhoto(
  PhotoRepo photoRepo,
  CreatePhotoAction action,
) {
  String uuid = action.photo.uuid;
  return photoRepo.copyWith(
    photos: Map.from(photoRepo.photos)..addAll({uuid: action.photo}),
  );
}

PhotoRepo _updatePhoto(
  PhotoRepo photoRepo,
  UpdatePhotoAction action,
) {
  String updatedUuid = action.photo.uuid;
  return photoRepo.copyWith(
    photos: Map.from(photoRepo.photos).map(
      (uuid, photo) => MapEntry(
        uuid,
        updatedUuid == uuid
            ? action.photo.copyWith(
                hasOrigin: photo.hasOrigin,
                hasThumb: photo.hasThumb,
              )
            : photo,
      ),
    ),
  );
}

PhotoRepo _downloadPhoto(
  PhotoRepo photoRepo,
  DownloadPhotoAction action,
) {
  String updatedUuid = action.uuid;
  return photoRepo.copyWith(
    photos: Map.from(photoRepo.photos).map(
      (uuid, photo) => MapEntry(
        uuid,
        updatedUuid == uuid ? photo.copyWith(hasOrigin: true) : photo,
      ),
    ),
  );
}

PhotoRepo _thumbnailPhoto(
  PhotoRepo photoRepo,
  ThumbnailPhotoAction action,
) {
  String updatedUuid = action.uuid;
  return photoRepo.copyWith(
    photos: Map.from(photoRepo.photos).map(
      (uuid, photo) => MapEntry(
        uuid,
        updatedUuid == uuid ? photo.copyWith(hasThumb: true) : photo,
      ),
    ),
  );
}

PhotoRepo _deletePhoto(
  PhotoRepo photoRepo,
  DeletePhotoAction action,
) {
  return photoRepo.copyWith(
    photos: Map.from(photoRepo.photos)..remove(action.uuid),
  );
}
