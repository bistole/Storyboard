import 'package:flutter/material.dart';
import 'package:storyboard/redux/models/setting.dart';

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
  final Setting setting;

  AppState({
    this.status,
    this.taskRepo,
    this.photoRepo,
    this.queue,
    this.setting,
  });

  AppState copyWith({
    Status status,
    TaskRepo taskRepo,
    PhotoRepo photoRepo,
    Queue queue,
    Setting setting,
  }) {
    return AppState(
      status: status ?? this.status,
      taskRepo: taskRepo ?? this.taskRepo,
      photoRepo: photoRepo ?? this.photoRepo,
      queue: queue ?? this.queue,
      setting: setting ?? this.setting,
    );
  }

  @override
  int get hashCode =>
      status.hashCode ^
      taskRepo.hashCode ^
      photoRepo.hashCode ^
      queue.hashCode ^
      setting.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppState &&
          status == other.status &&
          taskRepo == other.taskRepo &&
          photoRepo == other.photoRepo &&
          queue == other.queue &&
          setting == other.setting);

  @override
  String toString() {
    return 'AppState{status: $status, taskRepo: $taskRepo, photoRepo: $photoRepo, queue: $queue, setting: $setting}';
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

    var setting = Setting();
    if (json is Map && json['setting'] is Map) {
      setting = Setting.fromJson(json['setting']);
    }

    return AppState(
      status: Status.noParam(StatusKey.ListTask),
      taskRepo: taskRepo ?? TaskRepo(tasks: {}, lastTS: 0),
      photoRepo: photoRepo ?? PhotoRepo(photos: {}, lastTS: 0),
      queue: queue,
      setting: setting,
    );
  }

  dynamic toJson() {
    return {
      "tasks": taskRepo.toJson(),
      "photos": photoRepo.toJson(),
      'queue': queue.toJson(),
      'setting': setting.toJson(),
    };
  }
}
