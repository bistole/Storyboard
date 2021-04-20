import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:storyboard/redux/actions/actions.dart';
import 'package:storyboard/redux/models/app.dart';
import 'package:storyboard/redux/models/status.dart';
import 'package:storyboard/views/home/category_panel_item.dart';

class ReduxActions {
  Status status;
  Function(StatusKey statusKey) changeStatus;

  ReduxActions({this.status, this.changeStatus});
}

const double CATEGORY_PANEL_DEFAULT_WIDTH = 150;

class CategoryPanel extends StatelessWidget {
  final EdgeInsets padding;
  final Size size;

  CategoryPanel({@required this.size, this.padding = EdgeInsets.zero});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, ReduxActions>(
      converter: (store) {
        return ReduxActions(
          status: store.state.status,
          changeStatus: (StatusKey statusKey) {
            store.dispatch(ChangeStatusAction(status: statusKey));
          },
        );
      },
      builder: (context, ReduxActions redux) {
        return Container(
          constraints: BoxConstraints(
            maxWidth: this.size.width + this.padding.left,
            maxHeight: this.size.height,
          ),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(width: 1, color: Colors.grey[300]),
              right: BorderSide(width: 2, color: Colors.grey[300]),
            ),
            color: Colors.white,
          ),
          // child: Expanded(
          child: Column(
            children: [
              CategoryPanelItem(
                () => redux.changeStatus(StatusKey.ListTask),
                text: "Tasks",
                selected: redux.status.inTask,
                padding: EdgeInsets.only(left: this.padding.left),
              ),
              CategoryPanelItem(
                () => redux.changeStatus(StatusKey.ListPhoto),
                text: "Photos",
                selected: redux.status.inPhoto,
                padding: EdgeInsets.only(left: this.padding.left),
              ),
            ],
          ),
          // ),
        );
      },
    );
  }
}
