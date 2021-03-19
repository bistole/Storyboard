import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:storyboard/redux/actions/actions.dart';
import 'package:storyboard/redux/models/app.dart';
import 'package:storyboard/redux/models/status.dart';
import 'package:storyboard/redux/models/task.dart';
import 'package:storyboard/views/config/config.dart';

class ReduxActions {
  final void Function() delete;
  final void Function() update;
  ReduxActions({this.delete, this.update});
}

class TaskWidget extends StatelessWidget {
  final Task task;

  TaskWidget({this.task});

  Widget buildPopupMenu(ReduxActions redux) {
    return PopupMenuButton(
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
    );
  }

  Widget buildTimeAndSync(context) {
    var fmt = new DateFormat('HH:mm a');
    var date = DateTime.fromMicrosecondsSinceEpoch(task.updatedAt * 1000);

    if (task.ts == 0) {
      // wait for sync
      return Row(children: [
        Expanded(
          child: Text(fmt.format(date) + " (${task.ts})",
              style: Theme.of(context).textTheme.headline3),
        ),
        Align(
          child: Icon(
            Icons.cloud_upload,
            size: 16,
            color: Colors.orange[700],
          ),
        ),
      ]);
    } else {
      return Align(
        alignment: Alignment.centerLeft,
        child: Text(fmt.format(date) + " (${task.ts})",
            style: Theme.of(context).textTheme.headline3),
      );
    }
  }

  Widget buildTask(context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          border: Border.all(width: 8, color: Colors.grey[100]),
          borderRadius: BorderRadius.all(Radius.circular(4)),
        ),
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(task.title,
                  style: Theme.of(context).textTheme.headline2),
            ),
            buildTimeAndSync(context),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, ReduxActions>(
      converter: (store) {
        return ReduxActions(
          delete: () {
            store.dispatch(ChangeStatusAction(status: StatusKey.ListTask));
            getViewResource().actTasks.actDeleteTask(store, task.uuid);
          },
          update: () {
            // start to update
            store.dispatch(ChangeStatusWithUUIDAction(
                status: StatusKey.EditingTask, uuid: task.uuid));
          },
        );
      },
      builder: (context, ReduxActions redux) {
        return Row(
          children: [
            this.buildTask(context),
            this.buildPopupMenu(redux),
          ],
        );
      },
    );
  }
}
