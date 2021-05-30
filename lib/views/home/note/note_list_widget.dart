import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:storyboard/redux/models/app.dart';
import 'package:storyboard/redux/models/status.dart';
import 'package:storyboard/redux/models/note.dart';
import 'package:storyboard/views/common/server_status_warning_messager.dart';
import 'package:storyboard/views/config/styles.dart';
import 'package:storyboard/views/home/note/create_note_widget.dart';
import 'package:storyboard/views/home/note/note_toolbar_widget.dart';
import 'package:storyboard/views/home/note/note_widget.dart';
import 'package:storyboard/views/home/note/update_note_widget.dart';

class ReduxActions {
  final List<Note> noteList;
  final Status status;
  ReduxActions({this.status, this.noteList});
}

class NoteListWidget extends StatelessWidget {
  final EdgeInsets padding;
  NoteListWidget({this.padding = EdgeInsets.zero});

  List<Widget> buildList(ReduxActions redux) {
    var children = <Widget>[];

    if (redux.status.status == StatusKey.AddingNote) {
      Widget w = CreateNoteWidget();
      children.add(w);
    }

    var updatedNoteList = List<Note>.from(redux.noteList);
    updatedNoteList.sort((Note a, Note b) {
      return a.updatedAt == b.updatedAt
          ? 0
          : (a.updatedAt < b.updatedAt ? 1 : -1);
    });
    updatedNoteList.forEach((note) {
      Widget w = redux.status.status == StatusKey.EditingNote &&
              redux.status.uuid == note.uuid
          ? UpdateNoteWidget(note: note)
          : NoteWidget(note: note);
      children.add(w);
    });

    return children;
  }

  @override
  Widget build(Object context) {
    return StoreConnector<AppState, ReduxActions>(
      converter: (store) {
        List<Note> noteList = [];
        store.state.noteRepo.notes.forEach((uuid, note) {
          if (note.deleted == 0) {
            noteList.add(note);
          }
        });

        return ReduxActions(
          status: store.state.status,
          noteList: noteList,
        );
      },
      builder: (context, ReduxActions redux) {
        return Container(
          decoration: BoxDecoration(
            color: Styles.noteBoardBackColor,
          ),
          child: Column(children: [
            NoteToolbarWidget(),
            ServerStatusWarningMessage(),
            Expanded(
              child: Container(
                margin: padding,
                child: ListView(
                  children: buildList(redux),
                ),
              ),
            ),
          ]),
        );
      },
    );
  }
}
