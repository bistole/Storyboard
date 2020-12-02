import 'package:Storyboard/models/app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test("appState", () {
    var appState = AppState.fromJson({'tasks': {}});
    expect(appState.toString(),
        "AppState{status: Status{status: StatusKey.ListTask, param1: null, param2: null}, tasks: {}}");
  });
}
