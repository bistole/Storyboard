import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter/material.dart';

import '../../models/app.dart';
import '../../models/task.dart';
import '../../models/status.dart';

import 'create_task_widget.dart';
import 'update_task_widget.dart';
import 'task_widget.dart';

class ReduxActions {
  final List<Task> tasks;
  final Status status;
  ReduxActions({this.status, this.tasks});
}

class HomePage extends StatelessWidget {
  HomePage({Key key, this.title}) : super(key: key);

  final String title;

  List<Widget> buildList(ReduxActions redux) {
    var children = List<Widget>();
    children.add(CreateTaskWidget());
    redux.tasks.forEach((task) {
      Widget w = redux.status.status == StatusKey.EditingTask
          ? UpdateTaskWidget(task: task)
          : TaskWidget(task: task);
      children.insert(1, w);
    });
    return children;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(this.title),
      ),
      body: StoreConnector<AppState, ReduxActions>(
        converter: (store) {
          return ReduxActions(
            status: store.state.status,
            tasks: store.state.tasks,
          );
        },
        builder: (context, ReduxActions redux) {
          return ListView(
            children: buildList(redux),
          );
        },
      ),
    );
  }
}
