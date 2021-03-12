import 'package:redux/redux.dart';
import 'package:storyboard/logger/logger.dart';
import 'package:storyboard/net/sse.dart';
import 'package:storyboard/redux/actions/actions.dart';
import 'package:storyboard/redux/models/app.dart';

class ActServer {
  String _LOG_TAG = (ActServer).toString();
  Logger _logger;
  void setLogger(Logger logger) {
    _logger = logger;
  }

  NetSSE _netSSE;
  void setNetSSE(NetSSE netSSE) {
    _netSSE = netSSE;
  }

  void actChangeServerKey(Store<AppState> store, String serverKey) {
    // only update serverKey when it is different
    if (serverKey != store.state.setting.serverKey) {
      _logger.info(_LOG_TAG, "actChangeServerKey");
      store.onChange
          .any((state) => state.setting.serverKey == serverKey)
          .then((_) => {_netSSE.reconnect(store)});
      store.dispatch(
        SettingServerKeyAction(serverKey: serverKey),
      );
    }
  }
}
