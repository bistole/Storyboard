import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:redux/redux.dart';
import 'package:storyboard/configs/factory.dart';
import 'package:storyboard/redux/models/app.dart';
import 'package:storyboard/redux/models/photo.dart';
import 'package:storyboard/redux/models/photo_repo.dart';
import 'package:storyboard/redux/models/setting.dart';
import 'package:storyboard/redux/models/status.dart';
import 'package:storyboard/redux/models/task_repo.dart';
import 'package:storyboard/redux/reducers/app_reducer.dart';
import 'package:storyboard/views/common/app_icons.dart';
import 'package:storyboard/views/common/button.dart';

void main() {
  Store<AppState> store;

  Widget buildTestableWidget(Widget widget) {
    return StoreProvider(
      store: store,
      child: MaterialApp(
        home: widget,
      ),
    );
  }

  setUp(() {
    getFactory().store = store = Store<AppState>(
      appReducer,
      initialState: AppState(
        status: Status.noParam(StatusKey.ListPhoto),
        photoRepo: PhotoRepo(photos: <String, Photo>{}, lastTS: 0),
        taskRepo: TaskRepo(tasks: {}, lastTS: 0),
        setting: Setting(
          clientID: 'client-id',
          serverKey: 'server-key',
          serverReachable: Reachable.Unknown,
        ),
      ),
    );
  });

  testWidgets('button with icon', (WidgetTester tester) async {
    var pressed = false;
    var onPress = () {
      pressed = true;
    };
    Widget w = buildTestableWidget(SBButton(
      onPress,
      icon: Icon(AppIcons.android),
      text: 'HELLO TEXT',
    ));
    await tester.pumpWidget(w);

    // find
    expect(find.byIcon(AppIcons.android), findsOneWidget);
    expect(find.text('HELLO TEXT'), findsOneWidget);

    // tap
    var btn = find.ancestor(
      of: find.byIcon(AppIcons.android),
      matching: find.byWidgetPredicate((widget) => widget is ElevatedButton),
    );
    await tester.tap(btn);
    await tester.pumpAndSettle();

    // done
    expect(pressed, true);
  });
}
