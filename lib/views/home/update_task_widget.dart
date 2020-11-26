import 'package:Storyboard/actions/actions.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../net/tasks.dart';
import '../../models/app.dart';
import '../../models/status.dart';
import '../../models/task.dart';

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
            task.title = value;
            updateTask(store, task);
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
