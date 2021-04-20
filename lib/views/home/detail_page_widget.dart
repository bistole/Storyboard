import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:storyboard/redux/models/app.dart';
import 'package:storyboard/redux/models/status.dart';
import 'package:storyboard/views/config/config.dart';
import 'package:storyboard/views/home/photo/photo_list_widget.dart';
import 'package:storyboard/views/home/task/task_list_widget.dart';

class ReduxActions {
  Status status;
  ReduxActions({this.status});
}

class DetailPageWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    EdgeInsets srn = MediaQuery.of(context).padding;
    EdgeInsets padding = getViewResource().isWiderLayout(context)
        ? EdgeInsets.fromLTRB(0, 0, srn.right, srn.bottom)
        : EdgeInsets.fromLTRB(srn.left, 0, srn.right, srn.bottom);

    return StoreConnector<AppState, ReduxActions>(
      converter: (store) {
        return ReduxActions(
          status: store.state.status,
        );
      },
      builder: (context, ReduxActions redux) {
        if (redux.status.inTask) {
          return TaskListWidget(padding: padding);
        } else if (redux.status.inPhoto) {
          return PhotoListWidget(padding: padding);
        } else {
          return Container();
        }
      },
    );
  }
}
