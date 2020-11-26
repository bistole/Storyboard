class Task {
  final String uuid;
  String title;
  int updatedAt;
  final int createdAt;

  Task({this.uuid, this.title, this.updatedAt, this.createdAt});

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
        uuid: json['uuid'],
        title: json['title'],
        updatedAt: json['updatedAt'],
        createdAt: json['createdAt']);
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = new Map();
    map['uuid'] = this.uuid;
    map['title'] = this.title;
    map['updatedAt'] = this.updatedAt;
    map['createdAt'] = this.createdAt;
    return map;
  }
}

List<Task> buildTaskList(List<dynamic> json) {
  var list = new List<Task>();
  json.forEach((element) {
    list.add(Task(
      uuid: element['uuid'],
      title: element['title'],
      updatedAt: element['updatedAt'],
      createdAt: element['createdAt'],
    ));
  });
  return list;
}
