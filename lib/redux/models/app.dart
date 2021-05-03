import 'package:flutter/material.dart';
import 'package:storyboard/redux/models/setting.dart';

import 'package:storyboard/redux/models/note_repo.dart';
import 'package:storyboard/redux/models/photo_repo.dart';
import 'package:storyboard/redux/models/queue.dart';
import 'package:storyboard/redux/models/status.dart';
import 'package:uuid/uuid.dart';

@immutable
class AppState {
  final Status status;
  final NoteRepo noteRepo;
  final PhotoRepo photoRepo;
  final Queue queue;
  final Setting setting;

  AppState({
    this.status,
    this.noteRepo,
    this.photoRepo,
    this.queue,
    this.setting,
  });

  factory AppState.initState() {
    return AppState(
      status: Status.noParam(StatusKey.ListNote),
      noteRepo: NoteRepo(notes: {}, lastTS: 0),
      photoRepo: PhotoRepo(photos: {}, lastTS: 0),
      queue: Queue(),
      setting: Setting(
        clientID: Uuid().v4(),
        serverKey: null,
        serverReachable: Reachable.Unknown,
      ),
    );
  }

  AppState copyWith({
    Status status,
    NoteRepo noteRepo,
    PhotoRepo photoRepo,
    Queue queue,
    Setting setting,
  }) {
    return AppState(
      status: status ?? this.status,
      noteRepo: noteRepo ?? this.noteRepo,
      photoRepo: photoRepo ?? this.photoRepo,
      queue: queue ?? this.queue,
      setting: setting ?? this.setting,
    );
  }

  @override
  int get hashCode =>
      status.hashCode ^
      noteRepo.hashCode ^
      photoRepo.hashCode ^
      queue.hashCode ^
      setting.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppState &&
          status == other.status &&
          noteRepo == other.noteRepo &&
          photoRepo == other.photoRepo &&
          queue == other.queue &&
          setting == other.setting);

  @override
  String toString() {
    return 'AppState{status: $status, noteRepo: $noteRepo, photoRepo: $photoRepo, queue: $queue, setting: $setting}';
  }

  static AppState fromJson(dynamic json) {
    NoteRepo noteRepo;
    if (json is Map && json['notes'] is Map) {
      noteRepo = NoteRepo.fromJson(json['notes']);
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
      status: Status.noParam(StatusKey.ListNote),
      noteRepo: noteRepo ?? NoteRepo(notes: {}, lastTS: 0),
      photoRepo: photoRepo ?? PhotoRepo(photos: {}, lastTS: 0),
      queue: queue,
      setting: setting,
    );
  }

  dynamic toJson() {
    return {
      "notes": noteRepo.toJson(),
      "photos": photoRepo.toJson(),
      'queue': queue.toJson(),
      'setting': setting.toJson(),
    };
  }
}
