import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:storyboard/redux/actions/actions.dart';
import 'package:storyboard/redux/models/app.dart';
import 'package:storyboard/redux/models/status.dart';
import 'package:storyboard/views/config/config.dart';
import 'package:storyboard/views/config/styles.dart';
import 'package:storyboard/views/home/task/task_editor_controller.dart';

class ReduxActions {
  final void Function(String) create;
  final void Function() cancel;

  ReduxActions({this.create, this.cancel});
}

class CreateTaskWidget extends StatefulWidget {
  @override
  _CreateTaskWidgetState createState() => _CreateTaskWidgetState();
}

class _CreateTaskWidgetState extends State<CreateTaskWidget> {
  bool executed;
  ReduxActions redux;
  TaskEditorController controller;
  FocusNode focusNode;

  focusChanged() {
    if (!focusNode.hasFocus) {
      redux.cancel();
    }
  }

  @override
  void initState() {
    executed = false;
    controller = TaskEditorController(text: "");
    focusNode = FocusNode(
      onKey: (node, event) {
        if (event.isKeyPressed(LogicalKeyboardKey.escape)) {
          setState(() {
            executed = true;
            redux.cancel();
          });
        }
        return false;
      },
    );
    focusNode.addListener(focusChanged);
    super.initState();
  }

  @override
  void dispose() {
    if (!executed) {
      redux.create(controller.text);
    }
    controller.dispose();
    focusNode.removeListener(focusChanged);
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, ReduxActions>(
      converter: (store) {
        return redux = ReduxActions(
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
                margin: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                child: TextField(
                  style: Styles.normalBodyText,
                  focusNode: focusNode,
                  controller: controller,
                  maxLines: null,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Put task name here',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Styles.borderColor,
                        width: 1,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
