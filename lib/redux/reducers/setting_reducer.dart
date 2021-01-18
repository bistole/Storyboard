import 'package:redux/redux.dart';

import '../actions/actions.dart';
import '../models/setting.dart';

final settingReducer = combineReducers<Setting>([
  TypedReducer<Setting, SettingServerKeyAction>(_changeServerKey),
]);

Setting _changeServerKey(Setting setting, SettingServerKeyAction action) {
  return setting.copyWith(serverKey: action.serverKey);
}
