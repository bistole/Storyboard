import 'package:flutter/material.dart';

class PanelPopupRoute extends PopupRoute {
  final Duration _duration = Duration(milliseconds: 100);

  PanelPopupWidget widget;

  PanelPopupRoute({@required this.widget});

  @override
  Color get barrierColor => null;

  @override
  bool get barrierDismissible => false;

  @override
  String get barrierLabel => null;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return this.widget.buildWithAnimation(context, animation);
  }

  @override
  Duration get transitionDuration => _duration;
}

class PanelPopupWidget extends StatelessWidget {
  final Widget child;
  final Rect rect;
  final Function onTap;

  PanelPopupWidget({@required this.child, @required this.rect, this.onTap});

  @override
  Widget build(BuildContext context) {
    return child;
  }

  Widget buildWithAnimation(
    BuildContext context,
    Animation<double> animation,
  ) {
    double containerW = MediaQuery.of(context).size.width;
    Widget wrappedChild = PositionedTransition(
      rect: RelativeRectTween(
        begin: RelativeRect.fromLTRB(
            -this.rect.width, this.rect.top, containerW, 0),
        end: RelativeRect.fromLTRB(
            0, this.rect.top, containerW - this.rect.width, 0),
      ).animate(animation),
      child: GestureDetector(
        child: Container(
          decoration: BoxDecoration(color: Colors.green),
          child: child,
        ),
        onTap: () {
          if (this.onTap != null) {
            this.onTap();
          } else {
            Navigator.of(context).pop();
          }
        },
      ),
    );

    return Material(
      color: Colors.green.withOpacity(0),
      child: GestureDetector(
        child: Stack(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              color: Colors.white.withAlpha(0),
            ),
            wrappedChild,
          ],
        ),
        onTap: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }
}
