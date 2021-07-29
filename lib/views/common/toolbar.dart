import 'package:flutter/material.dart';
import 'package:storyboard/views/common/toolbar_button.dart';
import 'package:storyboard/views/config/styles.dart';

class SBToolbar extends StatelessWidget {
  final List<SBToolbarButton> children;
  SBToolbar(this.children, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Styles.toolbarBackColor,
        border: Border(
          bottom: BorderSide(color: Styles.toolbarBorderColor, width: 2),
        ),
      ),
      padding: EdgeInsets.only(
        left: MediaQuery.of(context).padding.left,
        right: MediaQuery.of(context).padding.right,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: children,
      ),
    );
  }
}
