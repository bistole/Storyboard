import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../actions/actions.dart';
import '../../net/tasks.dart';
import '../../models/app.dart';
import '../../models/task.dart';
import '../../models/status.dart';

class ReduxActions {
  final void Function() delete;
  final void Function() update;
  ReduxActions({this.delete, this.update});
}

class TaskWidget extends StatelessWidget {
  final Task task;

  TaskWidget({this.task});

  @override
  Widget build(BuildContext context) {
    var fmt = new DateFormat('HH:mm a');
    var date = DateTime.fromMicrosecondsSinceEpoch(task.updatedAt * 1000);
    return StoreConnector<AppState, ReduxActions>(
      converter: (store) {
        return ReduxActions(
          delete: () {
            store.dispatch(ChangeStatusAction(status: StatusKey.ListTask));
            deleteTask(store, task);
          },
          update: () {
            // start to update
            store.dispatch(ChangeStatusWithUUIDAction(
                status: StatusKey.EditingTask, uuid: task.uuid));
          },
        );
      },
      builder: (context, ReduxActions redux) {
        return ListTile(
          title: Text(task.title),
          subtitle: Text(fmt.format(date)),
          trailing: PopupMenuButton(
            onSelected: (value) {
              if (value == 'delete') {
                redux.delete();
              } else {
                redux.update();
              }
            },
            icon: Icon(Icons.more_horiz),
            itemBuilder: (_) => <PopupMenuItem<String>>[
              new PopupMenuItem<String>(
                child: Text('Delete'),
                value: 'delete',
              ),
              new PopupMenuItem<String>(
                child: Text('Change'),
                value: 'change',
              ),
            ],
          ),
        );
      },
    );
  }
}
