import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:storyboard/redux/actions/actions.dart';
import 'package:storyboard/redux/models/app.dart';
import 'package:storyboard/redux/models/status.dart';
import 'package:storyboard/views/config/config.dart';
import 'package:storyboard/views/config/styles.dart';
import 'package:storyboard/views/home/note/note_editor_controller.dart';

class ReduxActions {
  final void Function(String) create;
  final void Function() cancel;

  ReduxActions({this.create, this.cancel});
}

class CreateNoteWidget extends StatefulWidget {
  @override
  _CreateNoteWidgetState createState() => _CreateNoteWidgetState();
}

class _CreateNoteWidgetState extends State<CreateNoteWidget> {
  bool executed;
  ReduxActions redux;
  NoteEditorController controller;
  FocusNode focusNode;

  focusChanged() {
    if (!focusNode.hasFocus) {
      redux.cancel();
    }
  }

  @override
  void initState() {
    executed = false;
    controller = NoteEditorController(text: "");
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
            store.dispatch(ChangeStatusAction(status: StatusKey.ListNote));
            if (title.length > 0) {
              getViewResource().actNotes.actCreateNote(store, title);
            }
          },
          cancel: () {
            store.dispatch(ChangeStatusAction(status: StatusKey.ListNote));
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
                    hintText: 'Put note name here',
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
