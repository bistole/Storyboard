import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:storyboard/redux/actions/actions.dart';
import 'package:storyboard/redux/models/app.dart';
import 'package:storyboard/redux/models/status.dart';
import 'package:storyboard/redux/models/task.dart';
import 'package:storyboard/views/config/config.dart';

class ReduxActions {
  final void Function(String) update;
  final void Function() cancel;

  ReduxActions({this.update, this.cancel});
}

class UpdateTaskWidget extends StatelessWidget {
  final Task task;

  UpdateTaskWidget({this.task});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, ReduxActions>(
      converter: (store) {
        return ReduxActions(
          update: (String value) {
            getViewResource().actTasks.actUpdateTask(store, task.uuid, value);
            store.dispatch(new ChangeStatusAction(status: StatusKey.ListTask));
          },
          cancel: () {
            store.dispatch(new ChangeStatusAction(status: StatusKey.ListTask));
          },
        );
      },
      builder: (context, ReduxActions redux) {
        return new ListTile(
          title: RawKeyboardListener(
            child: TextField(
              onSubmitted: (String value) {
                redux.update(value);
              },
              controller: new TextEditingController(text: task.title),
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
      },
    );
  }
}
