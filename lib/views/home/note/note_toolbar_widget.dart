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

const String NOTE_TOOLBAR = "NOTE_TOOLBAR";

class NoteToolbarWidget extends StatelessWidget {
  @override
  Widget build(Object context) {
    return StoreConnector<AppState, ReduxActions>(
      converter: (store) {
        return ReduxActions(
          create: () {
            store.dispatch(ChangeStatusAction(status: StatusKey.AddingNote));
          },
          status: store.state.status,
        );
      },
      builder: (context, ReduxActions redux) {
        return SBToolbar(
          redux.status.status != StatusKey.AddingNote
              ? [
                  SBToolbarButton(
                    redux.create,
                    text: "ADD NOTE",
                    icon: Icon(AppIcons.tasks),
                  ),
                ]
              : [],
        );
      },
    );
  }
}
