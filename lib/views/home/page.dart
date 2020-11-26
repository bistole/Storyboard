import 'package:flutter_redux/flutter_redux.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/app.dart';
import '../../models/task.dart';
import '../../net/tasks.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

enum Status { None, Adding, Editing }

class _HomePageState extends State<HomePage> {
  var _status;
  var _statusUUID;

  @override
  void initState() {
    super.initState();
    _status = Status.None;
    _statusUUID = null;
  }

  void _cancelTask() {
    setState(() {
      _status = Status.None;
      _statusUUID = null;
    });
  }

  // render
  ListTile _buildAddButton() {
    return ListTile(title: TextButton(onPressed: () {}, child: Text('ADD')));
  }

  Widget _buildAddInputBox() {
    return StoreConnector<AppState, void Function(String)>(converter: (store) {
      return (String title) => createTask(store, title);
    }, builder: (context, callback) {
      return new ListTile(
        title: RawKeyboardListener(
          child: TextField(
            onSubmitted: callback,
            autofocus: true,
            decoration: InputDecoration(hintText: 'Put task name here'),
          ),
          focusNode: FocusNode(),
          onKey: (RawKeyEvent event) {
            if (event.isKeyPressed(LogicalKeyboardKey.escape)) {
              _cancelTask();
            }
          },
        ),
      );
    });
  }

  Widget _buildAdd() {
    if (_status == Status.Adding) {
      return _buildAddInputBox();
    }
    return _buildAddButton();
  }

  Widget _buildEditInputBox(Task task) {
    return StoreConnector<AppState, void Function(String)>(
      converter: (store) {
        return (String value) {
          task.title = value;
          updateTask(store, task);
        };
      },
      builder: (context, callback) {
        return new ListTile(
          title: RawKeyboardListener(
            child: TextField(
              onSubmitted: (String value) {
                callback(value);
              },
              controller: new TextEditingController(text: task.title),
              autofocus: true,
              decoration: InputDecoration(hintText: 'Put task name here'),
            ),
            focusNode: FocusNode(),
            onKey: (RawKeyEvent event) {
              if (event.isKeyPressed(LogicalKeyboardKey.escape)) {
                _cancelTask();
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildNormalTile(Task task) {
    var fmt = new DateFormat('HH:mm a');
    var date = DateTime.fromMicrosecondsSinceEpoch(task.updatedAt * 1000);
    return StoreConnector<AppState, VoidCallback>(
      converter: (store) {
        return () {
          this._status = Status.None;
          this._statusUUID = null;
          deleteTask(store, task);
        };
      },
      builder: (context, deleteFunc) {
        return ListTile(
          title: Text(task.title),
          subtitle: Text(fmt.format(date)),
          trailing: PopupMenuButton(
            onSelected: (value) {
              if (value == 'delete') {
                // delete
                deleteFunc();
              } else {
                // ready to update
                this._status = Status.Editing;
                this._statusUUID = task.uuid;
              }
            },
            icon: Icon(Icons.more_horiz),
            itemBuilder: (_) => <PopupMenuItem<String>>[
              new PopupMenuItem<String>(
                child: Text('Delete'),
                value: 'delete',
              ),
              new PopupMenuItem<String>(
                child: Text('Change'),
                value: 'change',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTile(Task task) {
    if (_status == Status.Editing && _statusUUID == task.uuid) {
      return _buildEditInputBox(task);
    } else {
      return _buildNormalTile(task);
    }
  }

  Widget _buildList(List<Task> tasks) {
    var children = <Widget>[];
    children.add(_buildAdd());
    tasks.forEach((element) {
      children.insert(1, _buildTile(element));
    });

    return ListView(
      children: children,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: StoreConnector<AppState, List<Task>>(
          converter: (store) {
            return store.state.tasks;
          },
          builder: (context, tasks) {
            return _buildList(tasks);
          },
        ));
  }
}
