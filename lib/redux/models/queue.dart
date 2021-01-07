import 'package:flutter/material.dart';
import 'package:storyboard/redux/models/queue_item.dart';

@immutable
class Queue {
  final int tick;
  final QueueItem now;
  final List<QueueItem> list;

  Queue({this.tick = 0, this.now, this.list = const <QueueItem>[]});

  Queue copyWith({
    int tick,
    QueueItem now,
    List<QueueItem> list,
  }) {
    return Queue(
      tick: tick ?? this.tick,
      now: now ?? this.now,
      list: list ?? this.list,
    );
  }

  Queue push(QueueItem item) {
    return Queue(
      tick: tick + 1,
      list: List.unmodifiable([...list, item]),
    );
  }

  Queue unshift(QueueItem item) {
    return Queue(
      tick: tick + 1,
      list: List.unmodifiable([item, ...list]),
    );
  }

  Queue process() {
    return Queue(
      tick: tick + 1,
      now: list[0],
      list: List.unmodifiable(list.skip(1)),
    );
  }

  Queue done() {
    return Queue(
      tick: tick + 1,
      now: null,
    );
  }

  @override
  int get hashCode => tick.hashCode ^ now.hashCode ^ list.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Queue &&
          tick == other.tick &&
          now == other.now &&
          list == other.list);

  @override
  String toString() {
    return "Queue{list: $list, tick: $tick, now: $now}";
  }

  factory Queue.fromJson(Map<String, dynamic> json) {
    var list = <QueueItem>[];
    if (json['list'] is List<dynamic>) {
      json['list'].forEach((jsonItem) {
        list.add(QueueItem.fromJson(jsonItem));
      });
    }
    QueueItem now;
    if (json['now'] != null) {
      now = QueueItem.fromJson(json['now']);
    }
    var q = Queue(
      tick: json['tick'],
      now: now,
      list: list,
    );
    return q;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = Map();

    List<dynamic> list = List();
    for (var item in this.list) {
      list.add(item.toJson());
    }
    map['tick'] = this.tick;
    if (this.now != null) {
      map['now'] = this.now.toJson();
    }
    map['list'] = list;
    return map;
  }
}
