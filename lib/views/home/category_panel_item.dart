import 'package:flutter/material.dart';

class CategoryPanelItem extends StatelessWidget {
  final bool selected;
  final EdgeInsets padding;
  final String text;
  final Function onTap;

  CategoryPanelItem(this.onTap,
      {this.text, this.padding = EdgeInsets.zero, this.selected = false});

  @override
  Widget build(BuildContext context) {
    Color bkColor =
        this.selected ? Theme.of(context).primaryColor : Colors.white;
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
            color: bkColor,
            border: Border(bottom: BorderSide(width: 1, color: Colors.grey))),
        padding: EdgeInsets.fromLTRB(padding.left + 8, 4, 8, 4),
        child: Text(
          this.text,
          style: Theme.of(context).textTheme.headline2,
        ),
      ),
    );
  }
}
