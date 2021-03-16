import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:storyboard/redux/models/app.dart';
import 'package:storyboard/redux/models/status.dart';
import 'package:storyboard/views/home/task_list_widget.dart';

class ReduxActions {
  Status status;

  ReduxActions({this.status});
}

class DetailPageWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, ReduxActions>(
      converter: (store) {
        return ReduxActions(
          status: store.state.status,
        );
      },
      builder: (context, ReduxActions redux) {
        if (redux.status.status == StatusKey.ListTask) {
          return TaskListWidget();
        } else {
          return Container();
        }
      },
    );
  }
}
