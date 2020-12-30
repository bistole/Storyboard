import 'package:flutter_test/flutter_test.dart';
import 'package:storyboard/redux/models/app.dart';

void main() {
  test("appState", () {
    var appState = AppState.fromJson({'tasks': {}});
    expect(appState.toString(),
        "AppState{status: Status{status: StatusKey.ListTask, param1: null, param2: null}, tasks: {}}");
  });
}
