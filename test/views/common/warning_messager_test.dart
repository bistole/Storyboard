import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:redux/redux.dart';
import 'package:storyboard/configs/factory.dart';
import 'package:storyboard/redux/models/app.dart';
import 'package:storyboard/views/common/app_icons.dart';
import 'package:storyboard/views/common/warning_messager.dart';

import '../../common.dart';

void main() {
  Store<AppState> store;

  group('WarningMessager', () {
    setUp(() {
      getFactory().store = store = getMockStore();
    });

    testWidgets('dismiss and next', (WidgetTester tester) async {
      bool forwarded = false;
      bool dismissed = false;

      WarningMessager wm = WarningMessager(
        RichText(text: TextSpan(text: 'warning text')),
        dismiss: () => {dismissed = true},
        forward: () => {forwarded = true},
      );

      Widget widget = buildTestableWidgetInMaterial(wm, store);
      await tester.pumpWidget(widget);

      RichText rt = find.byType(RichText).evaluate().first.widget as RichText;
      expect(rt.text.toPlainText(), 'warning text');

      expect(find.byIcon(AppIcons.right_open), findsOneWidget);
      expect(find.byIcon(AppIcons.cancel), findsOneWidget);

      await tester.tap(find.byIcon(AppIcons.right_open));
      expect(forwarded, true);

      await tester.tap(find.byIcon(AppIcons.cancel));
      expect(dismissed, true);
    });
  });
}
