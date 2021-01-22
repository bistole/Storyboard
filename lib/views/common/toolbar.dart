import 'package:flutter/material.dart';
import 'package:storyboard/views/common/toolbar_button.dart';

class SBToolbar extends StatelessWidget {
  final List<SBToolbarButton> children;
  SBToolbar(this.children);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
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
