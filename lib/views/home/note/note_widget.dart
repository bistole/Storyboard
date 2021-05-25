import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:storyboard/redux/actions/actions.dart';
import 'package:storyboard/redux/models/app.dart';
import 'package:storyboard/redux/models/status.dart';
import 'package:storyboard/redux/models/note.dart';
import 'package:storyboard/views/config/config.dart';
import 'package:storyboard/views/config/styles.dart';
import 'package:storyboard/views/home/note/note_helper.dart';

class ReduxActions {
  StatusKey status;
  final void Function() delete;
  final void Function() update;
  ReduxActions({this.status, this.delete, this.update});
}

class NoteWidget extends StatefulWidget {
  final Note note;

  NoteWidget({this.note});

  @override
  NoteWidgetState createState() => NoteWidgetState();
}

class NoteWidgetState extends State<NoteWidget> {
  ReduxActions redux;
  bool isMenuShown = false;

  @override
  void initState() {
    isMenuShown = false;
    super.initState();
  }

  void showMenu() {
    if (isMenuShown) return;
    setState(() {
      isMenuShown = true;
    });
  }

  void hideMenu() {
    if (!isMenuShown) return;
    setState(() {
      isMenuShown = false;
    });
  }

  void editNote(ReduxActions redux) {
    redux.update();
  }

  Widget buildTimeAndSync() {
    var fmt = new DateFormat('yyyy/MM/dd hh:mm a');
    var date =
        DateTime.fromMillisecondsSinceEpoch(widget.note.updatedAt * 1000);

    if (widget.note.ts == 0) {
      // wait for sync
      return Container(
        margin: EdgeInsets.only(top: 4),
        child: Row(
          children: [
            Expanded(
              child: Text(fmt.format(date), style: Styles.lessBodyText),
            ),
            Align(
              child: Icon(Icons.cloud_upload,
                  size: 16, color: Styles.unsyncedColor),
            ),
          ],
        ),
      );
    } else {
      return Container(
        margin: EdgeInsets.only(top: 4),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(fmt.format(date), style: Styles.lessBodyText),
        ),
      );
    }
  }

  Widget buildRichText() {
    return Align(
      alignment: Alignment.centerLeft,
      child: RichText(
        key: getViewResource()
            .getGlobalKeyByName("NOTE-LIST-TEXT:" + widget.note.uuid),
        text: TextSpan(
          style: Styles.normalBodyText,
          children: getNoteHelper().buildTextSpanRegex(
            Styles.normalBodyText,
            widget.note.title,
            interactive: true,
            cursor: true,
          ),
        ),
      ),
    );
  }

  Widget buildDeleteWidget(ReduxActions redux) {
    return AnimatedPositioned(
      width: 48,
      right: isMenuShown ? 0 : -48,
      top: 0,
      bottom: 0,
      curve: Curves.ease,
      duration: Duration(milliseconds: 300),
      child: GestureDetector(
        onTap: () => redux.delete(),
        child: Container(
          color: Styles.swiftPanelBackColor,
          child: Align(
            alignment: Alignment.center,
            child: Icon(
              Icons.delete,
              color: Styles.buttonTextColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget wrapWidgetWithGestureDetector(ReduxActions redux, Widget child) {
    if (getViewResource().deviceManager.isDesktop()) {
      return MouseRegion(
        onEnter: (event) => showMenu(),
        onExit: (event) => hideMenu(),
        onHover: (event) => showMenu(),
        child: GestureDetector(
          key: getViewResource()
              .getGlobalKeyByName("NOTE-LIST:" + widget.note.uuid),
          onTap: () {
            editNote(redux);
          },
          child: child,
        ),
      );
    } else {
      return GestureDetector(
        key: getViewResource()
            .getGlobalKeyByName("NOTE-LIST:" + widget.note.uuid),
        onTap: () {
          if (isMenuShown) {
            hideMenu();
          } else {
            editNote(redux);
          }
        },
        onPanUpdate: (details) {
          if (details.delta.dx < 0) {
            showMenu();
          } else {
            hideMenu();
          }
        },
        onLongPress: () {
          showMenu();
        },
        child: child,
      );
    }
  }

  Widget buildNote(BuildContext context, ReduxActions redux) {
    var container = Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Styles.noteBackColor,
            borderRadius: BorderRadius.all(Radius.circular(4)),
            border: Border.all(color: Styles.noteBackColor, width: 8),
          ),
          child: Column(
            children: [
              buildRichText(),
              buildTimeAndSync(),
            ],
          ),
        ),
        buildDeleteWidget(redux),
      ],
    );
    if (redux.status == StatusKey.ListNote) {
      return wrapWidgetWithGestureDetector(redux, container);
    }
    return container;
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, ReduxActions>(
      converter: (store) {
        return redux = ReduxActions(
          status: store.state.status.status,
          delete: () {
            store.dispatch(ChangeStatusAction(status: StatusKey.ListNote));
            getViewResource().actNotes.actDeleteNote(store, widget.note.uuid);
          },
          update: () {
            // start to update
            store.dispatch(ChangeStatusWithUUIDAction(
                status: StatusKey.EditingNote, uuid: widget.note.uuid));
          },
        );
      },
      builder: (context, ReduxActions redux) {
        return Row(
          children: [
            Expanded(
              child: this.buildNote(context, redux),
            )
          ],
        );
      },
    );
  }
}
