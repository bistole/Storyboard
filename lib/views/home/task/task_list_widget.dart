import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:storyboard/redux/models/app.dart';
import 'package:storyboard/redux/models/status.dart';
import 'package:storyboard/redux/models/task.dart';
import 'package:storyboard/views/config/styles.dart';
import 'package:storyboard/views/home/task/create_task_widget.dart';
import 'package:storyboard/views/home/task/task_toolbar_widget.dart';
import 'package:storyboard/views/home/task/task_widget.dart';
import 'package:storyboard/views/home/task/update_task_widget.dart';

class ReduxActions {
  final List<Task> taskList;
  final Status status;
  ReduxActions({this.status, this.taskList});
}

class TaskListWidget extends StatelessWidget {
  final EdgeInsets padding;
  TaskListWidget({this.padding = EdgeInsets.zero});

  List<Widget> buildList(ReduxActions redux) {
    var children = <Widget>[];

    if (redux.status.status == StatusKey.AddingTask) {
      Widget w = CreateTaskWidget();
      children.add(w);
    }

    var updatedTaskList = List<Task>.from(redux.taskList);
    updatedTaskList.sort((Task a, Task b) {
      return a.updatedAt == b.updatedAt
          ? 0
          : (a.updatedAt < b.updatedAt ? 1 : -1);
    });
    updatedTaskList.forEach((task) {
      Widget w = redux.status.status == StatusKey.EditingTask &&
              redux.status.param1 == task.uuid
          ? UpdateTaskWidget(task: task)
          : TaskWidget(task: task);
      children.add(w);
    });

    return children;
  }

  @override
  Widget build(Object context) {
    return StoreConnector<AppState, ReduxActions>(
      converter: (store) {
        List<Task> taskList = [];
        store.state.taskRepo.tasks.forEach((uuid, task) {
          if (task.deleted == 0) {
            taskList.add(task);
          }
        });

        return ReduxActions(
          status: store.state.status,
          taskList: taskList,
        );
      },
      builder: (context, ReduxActions redux) {
        return Container(
          decoration: BoxDecoration(
            color: Styles.taskBackColor,
          ),
          child: Column(children: [
            TaskToolbarWidget(),
            Expanded(
              child: Container(
                padding: padding,
                child: ListView(
                  children: buildList(redux),
                ),
              ),
            ),
          ]),
        );
      },
    );
  }
}
