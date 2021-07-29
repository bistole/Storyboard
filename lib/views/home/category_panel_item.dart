import 'package:flutter/material.dart';
import 'package:storyboard/views/config/styles.dart';

class CategoryPanelItem extends StatelessWidget {
  final bool selected;
  final EdgeInsets padding;
  final String text;
  final Function onTap;

  CategoryPanelItem(this.onTap,
      {this.text, this.padding = EdgeInsets.zero, this.selected = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (this.onTap != null) {
          this.onTap();
        }
      },
      child: Container(
        height: 32,
        width: double.infinity,
        decoration: BoxDecoration(
          color: this.selected
              ? Styles.menuPanelSelectedBackColor
              : Styles.menuPanelBackColor,
          border: Border(
            bottom: BorderSide(width: 1, color: Styles.toolbarBorderColor),
          ),
        ),
        padding: EdgeInsets.fromLTRB(padding.left + 8, 4, 8, 4),
        child: Text(
          this.text,
          style: Styles.titleTextStyle.copyWith(
            color: this.selected
                ? Styles.menuPanelSelectedColor
                : Styles.menuPanelColor,
          ),
        ),
      ),
    );
  }
}
