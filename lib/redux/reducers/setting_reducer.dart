import 'package:redux/redux.dart';

import '../actions/actions.dart';
import '../models/setting.dart';

final settingReducer = combineReducers<Setting>([
  TypedReducer<Setting, SettingServerKeyAction>(_changeServerKey),
  TypedReducer<Setting, SettingServerReachableAction>(_changeServerReachable),
]);

Setting _changeServerKey(Setting setting, SettingServerKeyAction action) {
  if (setting.serverKey != action.serverKey) {
    return setting.copyWith(
        serverKey: action.serverKey, serverReachable: Reachable.Unknown);
  } else {
    return setting;
  }
}

Setting _changeServerReachable(
    Setting setting, SettingServerReachableAction action) {
  return setting.copyWith(
      serverReachable: action.reachable ? Reachable.Yes : Reachable.No);
}
