import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../net/tasks.dart';
import '../../data/tasks.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

const STATUS_NONE = 0;
const STATUS_ADDING = 1;
const STATUS_EDITING = 2;

class _HomePageState extends State<HomePage> {
  var _status = STATUS_NONE;
  var _statusUUID = null;
  var _list = [];

  @override
  void initState() {
    super.initState();
    this._syncList();
  }

  void _syncList() {
    fetchTasks().then((tasks) {
      setState(() {
        _list = tasks;
      });
    }).catchError((err) {
      print(err);
    });
  }

  // adding
  void _pressAdd() {
    setState(() {
      _status = STATUS_ADDING;
    });
  }

  void _addTask(String value) {
    _status = STATUS_NONE;
    createTask(value).then((task) {
      setState(() {
        _list.add(task);
      });
    });
  }

  // editing
  void _pressEdit(uuid) {
    setState(() {
      _status = STATUS_EDITING;
      _statusUUID = uuid;
    });
  }

  void _updateTask(String value) {
    String updateUUID = this._statusUUID;
    setState(() {
      this._status = STATUS_NONE;
      this._statusUUID = null;
    });
    for (int i = 0; i < _list.length; i++) {
      Task task = _list[i];
      if (task.uuid == updateUUID) {
        task.title = value;
        updateTask(task).then((updatedTask) {
          setState(() {
            _list[i] = updatedTask;
          });
        });
      }
    }
  }

  // deleting
  void _pressDelete(task) {
    setState(() {
      _status = STATUS_NONE;
    });
    deleteTask(task).then((value) {
      setState(() {
        _list.remove(task);
      });
    });
  }

  // cancel adding or editing
  void _cancelTask() {
    setState(() {
      _status = STATUS_NONE;
      _statusUUID = null;
    });
  }

  // render
  ListTile _buildAddButton() {
    return ListTile(
        title: TextButton(onPressed: _pressAdd, child: Text('ADD')));
  }

  ListTile _buildAddInputBox() {
    return ListTile(
      title: RawKeyboardListener(
        child: TextField(
          onSubmitted: _addTask,
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
  }

  ListTile _buildEditInputBox(Task task) {
    return ListTile(
      title: RawKeyboardListener(
        child: TextField(
          onSubmitted: (String value) {
            this._updateTask(value);
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
  }

  ListTile _buildTile(Task task) {
    if (_status == STATUS_EDITING && _statusUUID == task.uuid) {
      return _buildEditInputBox(task);
    } else {
      var fmt = new DateFormat('HH:mm a');
      var date = DateTime.fromMicrosecondsSinceEpoch(task.updatedAt * 1000);
      return ListTile(
        title: Text(task.title),
        subtitle: Text(fmt.format(date)),
        trailing: PopupMenuButton(
          onSelected: (value) {
            if (value == 'delete') {
              this._pressDelete(task);
            } else {
              this._pressEdit(task.uuid);
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
    }
  }

  Widget _buildList() {
    var children = <Widget>[];
    children.add(
        _status == STATUS_ADDING ? _buildAddInputBox() : _buildAddButton());
    _list.forEach((element) {
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
      body: _buildList(),
    );
  }
}
