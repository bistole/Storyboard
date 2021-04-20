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
            store.dispatch(new ChangeStatusAction(status: StatusKey.ListTask));
            if (value.length > 0 && value != task.title) {
              getViewResource().actTasks.actUpdateTask(store, task.uuid, value);
            }
          },
          cancel: () {
            store.dispatch(new ChangeStatusAction(status: StatusKey.ListTask));
          },
        );
      },
      builder: (context, ReduxActions redux) {
        return Row(
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  style: Theme.of(context).textTheme.headline2,
                  onSubmitted: redux.update,
                  focusNode: FocusNode(onKey: (node, event) {
                    if (event.isKeyPressed(LogicalKeyboardKey.escape)) {
                      redux.cancel();
                    }
                    return false;
                  }),
                  autofocus: true,
                  controller: TextEditingController(text: task.title),
                  decoration: InputDecoration(hintText: 'Put task name here'),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
