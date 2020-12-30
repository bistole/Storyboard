import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:storyboard/net/tasks.dart';
import 'package:storyboard/redux/actions/actions.dart';
import 'package:storyboard/redux/models/app.dart';
import 'package:storyboard/redux/models/status.dart';
import 'package:storyboard/redux/models/task.dart';

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

  Widget buildTask(context) {
    var fmt = new DateFormat('HH:mm a');
    var date = DateTime.fromMicrosecondsSinceEpoch(task.updatedAt * 1000);

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
                  style: Theme.of(context).textTheme.headline3),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(fmt.format(date),
                  style: Theme.of(context).textTheme.headline3),
            ),
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
