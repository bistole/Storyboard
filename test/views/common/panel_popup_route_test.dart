import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:redux/redux.dart';
import 'package:storyboard/configs/factory.dart';
import 'package:storyboard/redux/models/app.dart';
import 'package:storyboard/views/common/panel_popup_route.dart';
import 'package:storyboard/views/home/category_panel.dart';

import '../../common.dart';

class _TestPanelPopupRouteWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TextButton(
      child: Text('PUSH ME'),
      onPressed: () {
        Navigator.push(
          context,
          PanelPopupRoute(
            widget: PanelPopupWidget(
              child: CategoryPanel(
                size: Size(CATEGORY_PANEL_DEFAULT_WIDTH, 200),
              ),
              rect: Rect.fromLTWH(0, 0, CATEGORY_PANEL_DEFAULT_WIDTH, 200),
            ),
          ),
        );
      },
    );
  }
}

void main() {
  Store<AppState> store;

  group('init', () {
    setUp(() {
      setFactoryLogger(MockLogger());
      getFactory().store = store = getMockStore();
    });

    testWidgets('show popup and cancel', (WidgetTester tester) async {
      Widget w = buildTestableWidget(_TestPanelPopupRouteWidget(), store);
      await tester.pumpWidget(w);

      expect(find.text('PUSH ME'), findsOneWidget);

      await tester.tap(find.byType(TextButton));
      await tester.pumpAndSettle();

      expect(find.text('Notes'), findsOneWidget);
      expect(find.text('Photos'), findsOneWidget);

      var gds = find.ancestor(
          of: find.text("Notes"), matching: find.byType(GestureDetector));
      expect(gds, findsNWidgets(3));

      // cancel
      await tester.tap(gds.at(1));
      await tester.pumpAndSettle();

      expect(find.text('Notes'), findsNothing);
    });

    testWidgets('show popup and cancel', (WidgetTester tester) async {
      Widget w = buildTestableWidget(_TestPanelPopupRouteWidget(), store);
      await tester.pumpWidget(w);

      expect(find.text('PUSH ME'), findsOneWidget);

      await tester.tap(find.byType(TextButton));
      await tester.pumpAndSettle();

      expect(find.text('Notes'), findsOneWidget);

      var gds = find.ancestor(
          of: find.text("Notes"), matching: find.byType(GestureDetector));

      // cancel
      await tester.tap(gds.at(2));
      await tester.pumpAndSettle();

      expect(find.text('Notes'), findsNothing);
    });
  });
}
