import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../actions/actions.dart';
import '../../models/app.dart';
import '../../models/status.dart';
import '../../net/tasks.dart';

class ReduxActions {
  final void Function() start;
  final void Function(String) create;
  final void Function() cancel;
  final Status status;
  ReduxActions({this.start, this.create, this.cancel, this.status});
}

class CreateTaskWidget extends StatelessWidget {
  ListTile buildAddButton(ReduxActions redux) {
    return ListTile(
      title: TextButton(
        onPressed: () {
          redux.start();
        },
        child: Text('ADD'),
      ),
    );
  }

  Widget buildWhenAdding(ReduxActions redux) {
    return new ListTile(
      title: RawKeyboardListener(
        child: TextField(
          onSubmitted: redux.create,
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
        return new ReduxActions(
          start: () {
            store
                .dispatch(new ChangeStatusAction(status: StatusKey.AddingTask));
          },
          create: (String title) {
            store.dispatch(new ChangeStatusAction(status: StatusKey.ListTask));
            createTask(store, title);
          },
          cancel: () {
            store.dispatch(new ChangeStatusAction(status: StatusKey.ListTask));
          },
          status: store.state.status,
        );
      },
      builder: (context, ReduxActions redux) {
        if (redux.status.status == StatusKey.AddingTask) {
          return buildWhenAdding(redux);
        }
        return buildAddButton(redux);
      },
    );
  }
}
