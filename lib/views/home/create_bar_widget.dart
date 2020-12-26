import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:storyboard/net/command.dart';
import 'package:storyboard/net/photos.dart';
import 'package:storyboard/widgets/toolbar.dart';
import 'package:storyboard/widgets/toolbar_button.dart';

import '../../actions/actions.dart';
import '../../models/app.dart';
import '../../models/status.dart';
import '../../net/tasks.dart';

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
    return SBToolbar([
      SBToolbarButton("ADD TASK", redux.startTask),
      SBToolbarButton("ADD PHOTO", importPhoto),
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
            createTask(store, title);
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
