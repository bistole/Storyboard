import 'package:flutter/material.dart';

import 'package:storyboard/redux/models/photo.dart';
import 'package:storyboard/redux/models/queue.dart';
import 'package:storyboard/redux/models/status.dart';

import 'task.dart';

@immutable
class AppState {
  final Status status;
  final Map<String, Task> tasks;
  final Map<String, Photo> photos;
  final Queue queue;

  AppState({
    this.status,
    this.tasks = const <String, Task>{},
    this.photos = const <String, Photo>{},
    this.queue,
  });

  AppState copyWith({
    Status status,
    Map<String, Task> tasks,
    Map<String, Photo> photos,
    Queue queue,
  }) {
    return AppState(
      status: status ?? this.status,
      tasks: tasks ?? this.tasks,
      photos: photos ?? this.photos,
      queue: queue ?? this.queue,
    );
  }

  @override
  int get hashCode =>
      status.hashCode ^ tasks.hashCode ^ photos.hashCode ^ queue.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppState &&
          status == other.status &&
          tasks == other.tasks &&
          photos == other.photos &&
          queue == other.queue);

  @override
  String toString() {
    return 'AppState{status: $status, tasks: $tasks, photos: $photos, queue: $queue}';
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
    var queue = Queue();
    if (json is Map && json['queue'] is Map) {
      queue = Queue.fromJson(json['queue']);
    }

    return AppState(
      status: Status.noParam(StatusKey.ListTask),
      tasks: tasks,
      photos: photos,
      queue: queue,
    );
  }

  dynamic toJson() {
    var jsonTasks = {};
    tasks.forEach((uuid, task) {
      jsonTasks[uuid] = task.toJson();
    });

    var jsonPhotos = {};
    photos.forEach((uuid, photo) {
      jsonPhotos[uuid] = photo.toJson();
    });

    return {
      "tasks": jsonTasks,
      "photos": jsonPhotos,
      'queue': queue.toJson(),
    };
  }
}
