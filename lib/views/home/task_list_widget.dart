import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:storyboard/redux/models/app.dart';
import 'package:storyboard/redux/models/photo.dart';
import 'package:storyboard/redux/models/status.dart';
import 'package:storyboard/redux/models/task.dart';
import 'package:storyboard/views/home/create_photo_widget.dart';
import 'package:storyboard/views/home/photo_widget.dart';
import 'package:storyboard/views/home/task_widget.dart';
import 'package:storyboard/views/home/update_task_widget.dart';

class ReduxActions {
  final List<Task> taskList;
  final List<Photo> photoList;
  final Status status;
  ReduxActions({this.status, this.taskList, this.photoList});
}

class TaskListWidget extends StatelessWidget {
  List<Widget> buildList(ReduxActions redux) {
    var children = <Widget>[];

    var updatedTaskList = List<Task>.from(redux.taskList);
    updatedTaskList.sort((Task a, Task b) {
      return a.updatedAt == b.updatedAt
          ? 0
          : (a.updatedAt > b.updatedAt ? 1 : -1);
    });
    updatedTaskList.forEach((task) {
      Widget w = redux.status.status == StatusKey.EditingTask &&
              redux.status.param1 == task.uuid
          ? UpdateTaskWidget(task: task)
          : TaskWidget(task: task);
      children.insert(0, w);
    });

    var updatedPhotoList = List<Photo>.from(redux.photoList);
    updatedPhotoList.sort((Photo a, Photo b) {
      return a.updatedAt == b.updatedAt
          ? 0
          : (a.updatedAt > b.updatedAt ? 1 : -1);
    });
    updatedPhotoList.forEach((photo) {
      Widget w = PhotoWidget(uuid: photo.uuid);
      children.insert(0, w);
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

        List<Photo> photoList = [];
        store.state.photoRepo.photos.forEach((uuid, photo) {
          if (photo.deleted == 0) {
            photoList.add(photo);
          }
        });

        return ReduxActions(
          status: store.state.status,
          taskList: taskList,
          photoList: photoList,
        );
      },
      builder: (context, ReduxActions redux) {
        if (redux.status.status == StatusKey.AddingPhoto) {
          return CreatePhotoWidget();
        }

        var padding = MediaQuery.of(context).padding;

        return Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
          ),
          child: Column(children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.fromLTRB(
                    padding.left, 0, padding.right, padding.bottom),
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
