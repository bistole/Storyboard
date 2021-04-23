import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:storyboard/redux/actions/actions.dart';
import 'package:storyboard/redux/models/app.dart';
import 'package:storyboard/redux/models/status.dart';
import 'package:storyboard/views/config/config.dart';
import 'package:storyboard/views/config/styles.dart';

class ReduxActions {
  final void Function(String) create;
  final void Function() cancel;

  ReduxActions({this.create, this.cancel});
}

class CreateTaskWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, ReduxActions>(
      converter: (store) {
        return ReduxActions(
          create: (String title) {
            store.dispatch(ChangeStatusAction(status: StatusKey.ListTask));
            if (title.length > 0) {
              getViewResource().actTasks.actCreateTask(store, title);
            }
          },
          cancel: () {
            store.dispatch(ChangeStatusAction(status: StatusKey.ListTask));
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
                  style: Styles.colorTitleTextStyle,
                  onSubmitted: redux.create,
                  focusNode: FocusNode(onKey: (node, event) {
                    if (event.isKeyPressed(LogicalKeyboardKey.escape)) {
                      redux.cancel();
                    }
                    return false;
                  }),
                  autofocus: true,
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
