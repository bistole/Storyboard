import 'package:redux/redux.dart';

import '../actions/actions.dart';
import '../models/status.dart';

final statusReducer = combineReducers<Status>([
  TypedReducer<Status, ChangeStatusAction>(_changeStatus),
  TypedReducer<Status, ChangeStatusWithUUIDAction>(_changeStatusWithUUID),
]);

Status _changeStatus(Status status, ChangeStatusAction action) {
  return Status.noParam(action.status);
}

Status _changeStatusWithUUID(Status status, ChangeStatusWithUUIDAction action) {
  return Status.oneParam(action.status, action.uuid);
}
