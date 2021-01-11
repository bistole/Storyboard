import 'package:flutter/material.dart';

import 'package:storyboard/redux/models/task_repo.dart';
import 'package:storyboard/redux/models/photo_repo.dart';
import 'package:storyboard/redux/models/queue.dart';
import 'package:storyboard/redux/models/status.dart';

@immutable
class AppState {
  final Status status;
  final TaskRepo taskRepo;
  final PhotoRepo photoRepo;
  final Queue queue;

  AppState({
    this.status,
    this.taskRepo,
    this.photoRepo,
    this.queue,
  });

  AppState copyWith({
    Status status,
    TaskRepo taskRepo,
    PhotoRepo photoRepo,
    Queue queue,
  }) {
    return AppState(
      status: status ?? this.status,
      taskRepo: taskRepo ?? this.taskRepo,
      photoRepo: photoRepo ?? this.photoRepo,
      queue: queue ?? this.queue,
    );
  }

  @override
  int get hashCode =>
      status.hashCode ^ taskRepo.hashCode ^ photoRepo.hashCode ^ queue.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppState &&
          status == other.status &&
          taskRepo == other.taskRepo &&
          photoRepo == other.photoRepo &&
          queue == other.queue);

  @override
  String toString() {
    return 'AppState{status: $status, taskRepo: $taskRepo, photoRepo: $photoRepo, queue: $queue}';
  }

  static AppState fromJson(dynamic json) {
    TaskRepo taskRepo;
    if (json is Map && json['tasks'] is Map) {
      taskRepo = TaskRepo.fromJson(json['tasks']);
    }

    PhotoRepo photoRepo;
    if (json is Map && json['photos'] is Map) {
      photoRepo = PhotoRepo.fromJson(json['photos']);
    }

    var queue = Queue();
    if (json is Map && json['queue'] is Map) {
      queue = Queue.fromJson(json['queue']);
    }

    return AppState(
      status: Status.noParam(StatusKey.ListTask),
      taskRepo: taskRepo ?? TaskRepo(tasks: {}, lastTS: 0),
      photoRepo: photoRepo ?? PhotoRepo(photos: {}, lastTS: 0),
      queue: queue,
    );
  }

  dynamic toJson() {
    return {
      "tasks": taskRepo.toJson(),
      "photos": photoRepo.toJson(),
      'queue': queue.toJson(),
    };
  }
}
