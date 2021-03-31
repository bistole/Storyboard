import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:redux/redux.dart';
import 'package:storyboard/configs/device_manager.dart';
import 'package:storyboard/configs/factory.dart';
import 'package:storyboard/redux/models/app.dart';
import 'package:storyboard/views/config/config.dart';

import '../../common.dart';

class MockDeviceManager extends Mock implements DeviceManager {}

class MockForGetContext extends StatelessWidget {
  final Function(BuildContext context) callback;

  MockForGetContext({this.callback});
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        callback(context);
      },
      child: Text("PUSH ME"),
    );
  }
}

void main() {
  Store<AppState> store;
  setUp(() {
    setFactoryLogger(MockLogger());
    getFactory().store = store = getMockStore();
  });

  testWidgets('.getGlobalKeyByName', (WidgetTester tester) async {
    Key key1 = getViewResource().getGlobalKeyByName("abc");
    Key key2 = getViewResource().getGlobalKeyByName("abc");
    expect(key1, key2);
  });

  testWidgets('.getRectFromWidget', (WidgetTester tester) async {
    Key key = GlobalKey();
    Text t = Text('Text', key: key);
    Widget w = buildDefaultTestableWidget(t, store);
    await tester.pumpWidget(w);

    Rect rect = getViewResource().getRectFromWidget(key);
    expect(rect.left, 0);
    expect(rect.top, 0);
    expect(rect.width, greaterThan(0));
    expect(rect.height, greaterThan(0));
  });

  testWidgets('.getSizeFromWidget', (WidgetTester tester) async {
    Key key = GlobalKey();
    Text t = Text('Text', key: key);
    Widget w = buildDefaultTestableWidget(t, store);
    await tester.pumpWidget(w);

    Size size = getViewResource().getSizeFromWidget(key);
    expect(size.width, greaterThan(0));
    expect(size.height, greaterThan(0));
  });

  group('.isWiderLayout', () {
    testWidgets('is Desktop', (WidgetTester tester) async {
      getViewResource().deviceManager = MockDeviceManager();
      when(getViewResource().deviceManager.isDesktop()).thenReturn(true);

      bool triggered = false;
      bool ans = false;
      var callback = (BuildContext context) {
        triggered = true;
        ans = getViewResource().isWiderLayout(context);
      };
      Widget w = buildDefaultTestableWidget(
          MockForGetContext(callback: callback), store);
      await tester.pumpWidget(w);
      await tester.tap(find.byType(TextButton));

      expect(triggered, true);
      expect(ans, true);
    });

    testWidgets('is Mobile', (WidgetTester tester) async {
      getViewResource().deviceManager = MockDeviceManager();
      when(getViewResource().deviceManager.isDesktop()).thenReturn(false);

      bool triggered = false;
      bool ans = false;
      var callback = (BuildContext context) {
        triggered = true;
        ans = getViewResource().isWiderLayout(context);
      };
      Widget w = buildDefaultTestableWidget(
          MockForGetContext(callback: callback), store);
      await tester.pumpWidget(w);
      await tester.tap(find.byType(TextButton));

      expect(triggered, true);
      expect(ans, true);
    });
  });
}
