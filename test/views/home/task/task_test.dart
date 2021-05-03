import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:redux/redux.dart';
import 'package:storyboard/configs/device_manager.dart';
import 'package:storyboard/configs/factory.dart';
import 'package:storyboard/redux/models/app.dart';
import 'package:storyboard/redux/models/status.dart';
import 'package:storyboard/redux/models/task.dart';
import 'package:storyboard/redux/models/task_repo.dart';
import 'package:storyboard/views/config/config.dart';
import 'package:storyboard/views/home/page.dart';
import 'package:storyboard/views/home/task/task_widget.dart';

import '../../../common.dart';

class MockDeviceManager extends Mock implements DeviceManager {}

void main() {
  Store<AppState> store;

  final uuid = '04deb797-7ca0-4cd3-b4ef-c1e01aeea130';
  final taskJson = {
    'uuid': uuid,
    'title': 'original Title',
    'deleted': 0,
    'updatedAt': 1606406017,
    'createdAt': 1606406017,
    '_ts': 1606406017000,
  };

  group('TaskWidget', () {
    setUp(() {
      setFactoryLogger(MockLogger());
      getFactory().store = store = getMockStore(
        status: Status.noParam(StatusKey.ListTask),
        tr: TaskRepo(
          tasks: <String, Task>{uuid: Task.fromJson(taskJson)},
          lastTS: 0,
        ),
      );

      getViewResource().deviceManager = MockDeviceManager();
    });

    group('Desktop', () {
      setUp(() {
        when(getViewResource().deviceManager.isDesktop()).thenReturn(true);
        when(getViewResource().deviceManager.isMobile()).thenReturn(false);
      });

      testWidgets('menu', (WidgetTester tester) async {
        // home page
        var widget = buildTestableWidget(HomePage(title: 'title'), store);
        await tester.pumpWidget(widget);

        // find one task
        var gKey =
            getViewResource().getGlobalKeyByName("TASK-LIST-TEXT:" + uuid);
        RichText rt = find.byKey(gKey).evaluate().first.widget as RichText;
        expect(rt.text.toPlainText(), 'original Title');

        var gestureRecog = find.ancestor(
            of: find.byKey(gKey), matching: find.byType(GestureDetector));
        expect(gestureRecog, findsWidgets);

        var mouse = find.ancestor(
            of: find.byKey(gKey), matching: find.byType(MouseRegion));
        expect(mouse, findsOneWidget);

        // hover in
        final gesture =
            await tester.createGesture(kind: PointerDeviceKind.mouse);
        await gesture.addPointer(location: Offset.zero);
        addTearDown(gesture.removePointer);
        await tester.pump();

        await gesture.moveTo(tester.getCenter(find.byType(TaskWidget)));
        await tester.pumpAndSettle();

        // hover out
        await gesture.moveTo(Offset.zero);
        await tester.pumpAndSettle();
      });
    });

    group('Mobile', () {
      setUp(() {
        when(getViewResource().deviceManager.isDesktop()).thenReturn(false);
        when(getViewResource().deviceManager.isMobile()).thenReturn(true);
      });

      testWidgets('menu', (WidgetTester tester) async {
        // home page
        var widget = buildTestableWidget(HomePage(title: 'title'), store);
        await tester.pumpWidget(widget);

        // find one task
        var gKey =
            getViewResource().getGlobalKeyByName("TASK-LIST-TEXT:" + uuid);
        RichText rt = find.byKey(gKey).evaluate().first.widget as RichText;
        expect(rt.text.toPlainText(), 'original Title');

        var gesture = find.ancestor(
            of: find.byKey(gKey), matching: find.byType(GestureDetector));
        expect(gesture, findsWidgets);

        var mouse = find.ancestor(
            of: find.byKey(gKey), matching: find.byType(MouseRegion));
        expect(mouse, findsNothing);

        // show menu by long press
        (gesture.evaluate().first.widget as GestureDetector).onLongPress();

        var state1 = tester.state<TaskWidgetState>(find.byType(TaskWidget));
        expect(state1.isMenuShown, true);

        // tap to hide menu
        (gesture.evaluate().first.widget as GestureDetector).onTap();
        var state2 = tester.state<TaskWidgetState>(find.byType(TaskWidget));
        expect(state2.isMenuShown, false);

        // swipe left to show
        (gesture.evaluate().first.widget as GestureDetector)
            .onPanUpdate(DragUpdateDetails(
          globalPosition: Offset.zero,
          delta: Offset(-20, 0),
        ));
        var state3 = tester.state<TaskWidgetState>(find.byType(TaskWidget));
        expect(state3.isMenuShown, true);

        // swipe right to hide
        (gesture.evaluate().first.widget as GestureDetector)
            .onPanUpdate(DragUpdateDetails(
          globalPosition: Offset.zero,
          delta: Offset(20, 0),
        ));
        var state4 = tester.state<TaskWidgetState>(find.byType(TaskWidget));
        expect(state4.isMenuShown, false);
      });
    });
  });
}
