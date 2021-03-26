import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:redux/redux.dart';
import 'package:storyboard/logger/logger.dart';
import 'package:storyboard/net/config.dart';
import 'package:storyboard/net/sse.dart';
import 'package:storyboard/redux/models/app.dart';
import 'package:storyboard/redux/models/photo_repo.dart';
import 'package:storyboard/redux/models/queue.dart';
import 'package:storyboard/redux/models/setting.dart';
import 'package:storyboard/redux/models/status.dart';
import 'package:storyboard/redux/models/task_repo.dart';
import 'package:storyboard/redux/reducers/app_reducer.dart';

var mockHostname = "192.168.3.146";
var mockPort = 3000;
var mockServerKey = encodeServerKey(mockHostname, mockPort);
var mockURLPrefix = 'http://' + mockHostname + ":" + mockPort.toString();

class MockLogger extends Mock implements Logger {}

class MockHttpClient extends Mock implements http.Client {}

void main() {
  Store<AppState> store;

  setUp(() {
    store = Store<AppState>(
      appReducer,
      initialState: AppState(
        status: Status.noParam(StatusKey.ListTask),
        photoRepo: PhotoRepo(photos: {}, lastTS: 0),
        taskRepo: TaskRepo(tasks: {}, lastTS: 0),
        queue: Queue(),
        setting: Setting(serverKey: mockServerKey),
      ),
    );
  });

  test('connect - welcome - alive - close', () async {
    var netSSE = NetSSE();
    netSSE.setLogger(MockLogger());

    var httpClient = MockHttpClient();
    var welcomePack =
        jsonEncode({"action": 'welcome', "params": {}, "ts": 1234567});
    var alivePack =
        jsonEncode({"action": 'alive', "params": {}, "ts": 1234569});
    var closePack =
        jsonEncode({"action": 'close', "params": {}, "ts": 1234590});

    when(httpClient.send(any)).thenAnswer((_) async {
      var stream = Stream<List<int>>.periodic(
        Duration(milliseconds: 100),
        (idx) {
          String content;
          if (idx == 0) {
            content = welcomePack;
          } else if (idx == 1) {
            content = alivePack;
          } else {
            content = closePack;
          }

          // if message was send
          Future.delayed(Duration(milliseconds: 100), netSSE.disconnect);
          return Utf8Encoder().convert(content);
        },
      ).take(3);
      var response = http.StreamedResponse(stream, 200);
      return response;
    });

    netSSE.setGetHttpClient(() => httpClient);

    // connect
    netSSE.connect(store);

    // wait until disconnected
    await Future.delayed(Duration(milliseconds: 500));

    // is disconnected
    expect(netSSE.getStatus(), NetSSEStatus.Disconnected);
  });

  test('connect - wrong server', () async {
    var netSSE = NetSSE();
    netSSE.setLogger(MockLogger());

    var httpClient = MockHttpClient();

    when(httpClient.send(any)).thenAnswer((_) async {
      var content =
          jsonEncode({"action": 'welcome', "params": {}, "ts": 1234567});
      var packed = Utf8Encoder().convert(content);
      var stream = Stream<List<int>>.value(packed);
      var response = http.StreamedResponse(stream, 404);
      return response;
    });
    netSSE.setGetHttpClient(() => httpClient);

    // connect
    netSSE.connect(store);

    // wait until disconnected
    await Future.delayed(Duration(milliseconds: 500));

    // is wrong server
    expect(netSSE.getStatus(), NetSSEStatus.WrongServer);

    netSSE.disconnect();
  });

  test('connect - server closed', () async {
    var netSSE = NetSSE();
    netSSE.setLogger(MockLogger());

    var httpClient = MockHttpClient();

    when(httpClient.send(any)).thenAnswer((_) async {
      var content =
          jsonEncode({"action": 'welcome', "params": {}, "ts": 1234567});
      var packed = Utf8Encoder().convert(content);
      var stream =
          Stream<List<int>>.periodic(Duration(milliseconds: 100), (idx) {
        if (idx == 0) {
          return packed;
        }
        throw new Exception("Broken on server side");
      }).take(2);
      var response = http.StreamedResponse(stream, 200);
      return response;
    });
    netSSE.setGetHttpClient(() => httpClient);

    // connect
    netSSE.connect(store);

    // wait until disconnected
    await Future.delayed(Duration(milliseconds: 500));

    // is disconnect since server closed
    expect(netSSE.getStatus(), NetSSEStatus.Disconnected);

    netSSE.disconnect();
  });

  test('connect - notify', () async {
    var netSSE = NetSSE();
    netSSE.setLogger(MockLogger());

    var httpClient = MockHttpClient();

    when(httpClient.send(any)).thenAnswer((_) async {
      var content = jsonEncode({
        "action": 'notify',
        "params": {
          "type": "photo",
        },
        "ts": 1234567
      });
      var packed = Utf8Encoder().convert(content);
      var stream = Stream<List<int>>.value(packed);
      var response = http.StreamedResponse(stream, 200);
      return response;
    });
    netSSE.setGetHttpClient(() => httpClient);

    var updateFuncCalled = 0;
    var updateFunc = () {
      updateFuncCalled++;
    };

    // connect
    netSSE.connect(store);
    netSSE.registerUpdateFunc('photo', updateFunc);

    // wait until disconnected
    await Future.delayed(Duration(milliseconds: 500));

    // tiggered twice
    expect(updateFuncCalled, 2);

    netSSE.disconnect();
  });
}
