import 'dart:io';

import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:storyboard/net/command.dart';
import 'package:storyboard/net/photos.dart';

import '../../actions/actions.dart';
import '../../models/app.dart';
import '../../models/status.dart';
import '../../net/tasks.dart';

class ReduxActions {
  final void Function() startTask;
  final void Function(String) createTask;
  final void Function(String) createPhoto;
  final void Function() cancel;
  final Status status;
  ReduxActions({
    this.startTask,
    this.createTask,
    this.createPhoto,
    this.cancel,
    this.status,
  });
}

class CreateTaskWidget extends StatelessWidget {
  Widget buildAddButton(ReduxActions redux) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
          child: TextButton(
            onPressed: () {
              redux.startTask();
            },
            child: Text('ADD TASK'),
          ),
        ),
        Expanded(
          child: TextButton(
            onPressed: () {
              importPhoto();
            },
            child: Text('ADD PHOTO'),
          ),
        ),
      ],
    );
  }

  Widget buildWhenAddingTask(ReduxActions redux) {
    return ListTile(
      title: RawKeyboardListener(
        child: TextField(
          onSubmitted: redux.createTask,
          autofocus: true,
          decoration: InputDecoration(hintText: 'Put task name here'),
        ),
        focusNode: FocusNode(),
        onKey: (RawKeyEvent event) {
          if (event.isKeyPressed(LogicalKeyboardKey.escape)) {
            redux.cancel();
          }
        },
      ),
    );
  }

  Widget buildWhenAddingPhoto(ReduxActions redux) {
    return Column(
      children: [
        Image.file(File(redux.status.param1)),
        Row(children: [
          TextButton(
            onPressed: () {
              redux.createPhoto(redux.status.param1);
            },
            child: Text("ADD"),
          ),
          TextButton(
            onPressed: () {
              redux.cancel();
            },
            child: Text("CANCEL"),
          )
        ]),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, ReduxActions>(
      converter: (store) {
        return ReduxActions(
          startTask: () {
            store.dispatch(ChangeStatusAction(status: StatusKey.AddingTask));
          },
          createTask: (String title) {
            store.dispatch(ChangeStatusAction(status: StatusKey.ListTask));
            createTask(store, title);
          },
          createPhoto: (String path) {
            store.dispatch(ChangeStatusAction(status: StatusKey.ListTask));
            uploadPhoto(store, path);
          },
          cancel: () {
            store.dispatch(ChangeStatusAction(status: StatusKey.ListTask));
          },
          status: store.state.status,
        );
      },
      builder: (context, ReduxActions redux) {
        if (redux.status.status == StatusKey.AddingTask) {
          return buildWhenAddingTask(redux);
        } else if (redux.status.status == StatusKey.AddingPhoto) {
          return buildWhenAddingPhoto(redux);
        }
        return buildAddButton(redux);
      },
    );
  }
}
