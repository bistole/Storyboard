import 'package:flutter/material.dart';

import 'package:storyboard/redux/models/photo.dart';
import 'package:storyboard/redux/models/status.dart';

import 'task.dart';

@immutable
class AppState {
  final Status status;
  final Map<String, Task> tasks;
  final Map<String, Photo> photos;

  AppState({
    this.status,
    this.tasks = const <String, Task>{},
    this.photos = const <String, Photo>{},
  });

  AppState copyWith({
    Status status,
    Map<String, Task> tasks,
    Map<String, Photo> photos,
  }) {
    return AppState(
      status: status ?? this.status,
      tasks: tasks ?? this.tasks,
      photos: photos ?? this.photos,
    );
  }

  @override
  int get hashCode => status.hashCode ^ tasks.hashCode ^ photos.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppState &&
          status == other.status &&
          tasks == other.tasks &&
          photos == other.photos);

  @override
  String toString() {
    return 'AppState{status: $status, tasks: $tasks, photos: $photos}';
  }

  static AppState fromJson(dynamic json) {
    var tasks = <String, Task>{};
    if (json is Map && json['tasks'] is Map) {
      json['tasks'].forEach((uuid, jsonTask) {
        var task = Task.fromJson(jsonTask);
        tasks[task.uuid] = task;
      });
    }
    var photos = <String, Photo>{};
    if (json is Map && json['photos'] is Map) {
      json['photos'].forEach((uuid, jsonPhoto) {
        var photo = Photo.fromJson(jsonPhoto);
        photos[photo.uuid] = photo;
      });
    }

    return AppState(
      status: Status.noParam(StatusKey.ListTask),
      tasks: tasks,
      photos: photos,
    );
  }

  dynamic toJson() {
    return {"tasks": tasks, "photos": photos};
  }
}
