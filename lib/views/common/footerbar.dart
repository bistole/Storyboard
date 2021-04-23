import 'package:flutter/material.dart';
import 'package:storyboard/views/common/toolbar_button.dart';
import 'package:storyboard/views/config/styles.dart';

class SBFooterbar extends StatelessWidget {
  final List<SBToolbarButton> children;
  SBFooterbar(this.children);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Styles.toolbarBackColor,
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom,
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
