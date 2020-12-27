import 'package:flutter/material.dart';
import 'package:storyboard/widgets/toolbar_button.dart';

class SBToolbar extends StatelessWidget {
  final List<SBToolbarButton> children;
  SBToolbar(this.children);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
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
