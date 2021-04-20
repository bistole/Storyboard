import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:storyboard/redux/actions/actions.dart';
import 'package:storyboard/redux/models/app.dart';
import 'package:storyboard/redux/models/status.dart';
import 'package:storyboard/views/common/app_icons.dart';
import 'package:storyboard/views/common/toolbar.dart';
import 'package:storyboard/views/common/toolbar_button.dart';

class ReduxActions {
  final void Function() create;
  final Status status;
  ReduxActions({
    this.create,
    this.status,
  });
}

const String TASK_TOOLBAR = "TASK_TOOLBAR";

class TaskToolbarWidget extends StatelessWidget {
  @override
  Widget build(Object context) {
    return StoreConnector<AppState, ReduxActions>(
      converter: (store) {
        return ReduxActions(
          create: () {
            store.dispatch(ChangeStatusAction(status: StatusKey.AddingTask));
          },
          status: store.state.status,
        );
      },
      builder: (context, ReduxActions redux) {
        return SBToolbar(
          redux.status.status != StatusKey.AddingTask
              ? [
                  SBToolbarButton(
                    redux.create,
                    text: "ADD TASK",
                    icon: Icon(AppIcons.tasks),
                  ),
                ]
              : [],
        );
      },
    );
  }
}
