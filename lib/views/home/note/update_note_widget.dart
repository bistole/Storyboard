import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:storyboard/redux/actions/actions.dart';
import 'package:storyboard/redux/models/app.dart';
import 'package:storyboard/redux/models/status.dart';
import 'package:storyboard/redux/models/note.dart';
import 'package:storyboard/views/config/config.dart';
import 'package:storyboard/views/config/styles.dart';
import 'package:storyboard/views/home/note/note_editor_controller.dart';

class ReduxActions {
  final void Function(String) update;
  final void Function() cancel;

  ReduxActions({this.update, this.cancel});
}

class UpdateNoteWidget extends StatefulWidget {
  final Note note;

  UpdateNoteWidget({this.note});

  @override
  _UpdateNoteWidgetState createState() => _UpdateNoteWidgetState();
}

class _UpdateNoteWidgetState extends State<UpdateNoteWidget> {
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
    controller = NoteEditorController(text: widget.note.title);
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
      redux.update(controller.text);
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
          update: (String value) {
            if (value.length > 0 && value != widget.note.title) {
              getViewResource()
                  .actNotes
                  .actUpdateNote(store, widget.note.uuid, value);
            }
          },
          cancel: () {
            store.dispatch(new ChangeStatusAction(status: StatusKey.ListNote));
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
                  autofocus: true,
                  maxLines: null,
                  controller: controller,
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
