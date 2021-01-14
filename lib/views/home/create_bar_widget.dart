import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:storyboard/views/common/toolbar.dart';
import 'package:storyboard/views/common/toolbar_button.dart';
import 'package:storyboard/redux/actions/actions.dart';
import 'package:storyboard/redux/models/app.dart';
import 'package:storyboard/redux/models/status.dart';
import 'package:storyboard/views/config/config.dart';

class ReduxActions {
  final void Function() startTask;
  final void Function(String) createTask;
  final void Function() cancel;
  final Status status;
  ReduxActions({
    this.startTask,
    this.createTask,
    this.cancel,
    this.status,
  });
}

class CreateBarWidget extends StatelessWidget {
  Widget buildAddButton(ReduxActions redux) {
    SBToolbarButton photoActionButton;
    if (getViewResource().deviceManager.isMobile()) {
      photoActionButton = SBToolbarButton(
        "TAKE PHOTO",
        getViewResource().command.takePhoto,
      );
    } else {
      photoActionButton = SBToolbarButton(
        "ADD PHOTO",
        getViewResource().command.importPhoto,
      );
    }
    return SBToolbar([
      SBToolbarButton("ADD TASK", redux.startTask),
      photoActionButton,
    ]);
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
            getViewResource().actTasks.actCreateTask(store, title);
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
        }
        return buildAddButton(redux);
      },
    );
  }
}
