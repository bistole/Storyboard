import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var _adding = false;
  var _list = [];

  void _pressAdd() {
    setState(() {
      _adding = true;  
    });
  }

  void _addTask(String value) {
    setState(() {
      _list.add(value);
      _adding = false;  
    });    
  }

  void _cancelTask() {
    setState(() {
      _adding = false;
    });
  }

  ListTile _buildAddButton() {
    return ListTile(
      title: TextButton(
        onPressed: _pressAdd,
        child: Text('ADD')
      )
    );
  }

  ListTile _buildInputBox() {
    return ListTile(
      title: RawKeyboardListener(
        child: TextField(
          onSubmitted: _addTask,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Put task name here'
          ),
        ),
        focusNode: FocusNode(),
        onKey: (RawKeyEvent event) {
          if (event.isKeyPressed(LogicalKeyboardKey.escape)) {
            _cancelTask();            
          }
        },
      )
    );
  }

  ListTile _buildTile(String title) {
    return ListTile(title: Text(title));
  }

  Widget _buildList() {
    var children = <Widget>[];
    children.add(_adding ? _buildInputBox() : _buildAddButton());
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
      body: _buildList()
    );
  }
}
