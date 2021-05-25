import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:redux/redux.dart';
import 'package:storyboard/redux/models/app.dart';
import 'package:storyboard/redux/models/status.dart';
import 'package:storyboard/views/home/category_panel.dart';

import '../../common.dart';

void main() {
  testWidgets('click item', (WidgetTester tester) async {
    Store<AppState> store = getMockStore();
    Widget w = buildTestableWidgetInMaterial(
        CategoryPanel(size: Size(200, 500)), store);
    await tester.pumpWidget(w);

    var noteBtn = find.ancestor(
      of: find.text("Notes"),
      matching: find.byWidgetPredicate((widget) => widget is InkWell),
    );

    await tester.tap(noteBtn);
    await tester.pumpAndSettle();

    expect(store.state.status.status, StatusKey.ListNote);

    var photoBtn = find.ancestor(
      of: find.text("Photos"),
      matching: find.byWidgetPredicate((widget) => widget is InkWell),
    );

    await tester.tap(photoBtn);
    await tester.pumpAndSettle();

    expect(store.state.status.status, StatusKey.ListPhoto);
  });
}
