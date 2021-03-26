import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:storyboard/channel/backend.dart';
import 'package:storyboard/logger/logger.dart';

class MockLogger extends Mock implements Logger {}

class MockMethodChannel extends Mock implements MethodChannel {}

void main() {
  test('getDataHome', () async {
    MethodChannel mc = MockMethodChannel();
    String path = '/homedata';
    when(mc.invokeMethod(any)).thenAnswer((_) async => path);

    var bc = BackendChannel(mc);
    bc.setLogger(MockLogger());

    var datahome = await bc.getDataHome();
    expect(datahome, path);

    var capture = verify(mc.invokeMethod(captureAny)).captured;
    expect(capture[0], 'BK:GET_DATA_HOME');
  });

  test('getCurrentIp', () async {
    MethodChannel mc = MockMethodChannel();
    String ip = '192.168.3.199';
    when(mc.invokeMethod(any)).thenAnswer((_) async => ip);

    var bc = BackendChannel(mc);
    bc.setLogger(MockLogger());

    var getip = await bc.getCurrentIp();
    expect(getip, ip);

    var capture = verify(mc.invokeMethod(captureAny)).captured;
    expect(capture[0], 'BK:GET_CURRENT_IP');
  });

  test('setCurrentIp', () async {
    MethodChannel mc = MockMethodChannel();

    var bc = BackendChannel(mc);
    bc.setLogger(MockLogger());

    String ip = '192.168.3.199';
    await bc.setCurrentIp(ip);

    var capture = verify(mc.invokeMethod(captureAny, captureAny)).captured;
    expect(capture[0], 'BK:SET_CURRENT_IP');
    expect(capture[1], ip);
  });

  test('getAvailableIps', () async {
    MethodChannel mc = MockMethodChannel();
    var ips = {"eth0": "192.168.7.88"};
    when(mc.invokeMapMethod(any)).thenAnswer((_) async => ips);

    var bc = BackendChannel(mc);
    bc.setLogger(MockLogger());

    var getips = await bc.getAvailableIps();
    expect(getips, ips);

    var capture = verify(mc.invokeMapMethod(captureAny)).captured;
    expect(capture[0], 'BK:GET_SERVER_IPS');
  });
}
