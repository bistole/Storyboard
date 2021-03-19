import 'package:flutter/material.dart';
import 'package:storyboard/views/common/app_icons.dart';
import 'package:storyboard/views/common/panel_popup_route.dart';
import 'package:storyboard/views/common/server_status.dart';
import 'package:storyboard/views/config/config.dart';
import 'package:storyboard/views/home/category_panel.dart';
import 'package:storyboard/views/home/detail_page_widget.dart';

class HomePage extends StatelessWidget {
  HomePage({Key key, this.title}) : super(key: key);

  final String title;

  Widget buildDesktopLayout(BuildContext context) {
    EdgeInsets padding = MediaQuery.of(context).padding;
    double height = MediaQuery.of(context).size.height;
    return Container(
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                CategoryPanel(
                  padding: EdgeInsets.only(left: padding.left),
                  size: Size(CATEGORY_PANEL_DEFAULT_WIDTH, height),
                ),
                Expanded(child: DetailPageWidget())
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMobileLayout(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Expanded(
            child: DetailPageWidget(),
          ),
        ],
      ),
    );
  }

  Widget buildMenuButton(context, Function onTap) {
    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(AppIcons.menu, color: Colors.white),
      label: Text(""),
    );
  }

  Widget buildTitle() {
    return Expanded(
      child: Text(
        this.title,
        textAlign: TextAlign.center,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    AppBar appBar;

    Function onTap = () {
      double height = MediaQuery.of(context).size.height;
      double top = MediaQuery.of(context).padding.top;
      double barHeight = appBar.preferredSize.height;

      Navigator.push(
        context,
        PanelPopupRoute(
          widget: PanelPopupWidget(
            child:
                CategoryPanel(size: Size(CATEGORY_PANEL_DEFAULT_WIDTH, height)),
            rect: Rect.fromLTWH(0, top + barHeight,
                CATEGORY_PANEL_DEFAULT_WIDTH, height - top - barHeight),
          ),
        ),
      );
    };

    appBar = AppBar(
      elevation: 0,
      titleSpacing: 0.0,
      title: Row(
        children: [
          getViewResource().isWiderLayout(context)
              ? Container()
              : buildMenuButton(context, onTap),
          buildTitle(),
          ServerStatus(),
        ],
      ),
    );
    return Scaffold(
      appBar: appBar,
      body: getViewResource().isWiderLayout(context)
          ? buildDesktopLayout(context)
          : buildMobileLayout(context),
    );
  }
}
