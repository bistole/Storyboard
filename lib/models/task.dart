class Task {
  final String uuid;
  String title;
  int deleted;
  int updatedAt;
  final int createdAt;
  final int ts;

  Task({
    this.uuid,
    this.title,
    this.deleted,
    this.updatedAt,
    this.createdAt,
    this.ts,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      uuid: json['uuid'],
      title: json['title'],
      deleted: json['deleted'],
      updatedAt: json['updatedAt'],
      createdAt: json['createdAt'],
      ts: json['_ts'],
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = new Map();
    map['uuid'] = this.uuid;
    map['title'] = this.title;
    map['deleted'] = this.deleted;
    map['updatedAt'] = this.updatedAt;
    map['createdAt'] = this.createdAt;
    map['_ts'] = this.ts;
    return map;
  }
}

List<Task> buildTaskList(List<dynamic> json) {
  var list = new List<Task>();
  json.forEach((element) {
    list.add(Task(
      uuid: element['uuid'],
      title: element['title'],
      deleted: element['deleted'],
      updatedAt: element['updatedAt'],
      createdAt: element['createdAt'],
      ts: element['_ts'],
    ));
  });
  return list;
}
