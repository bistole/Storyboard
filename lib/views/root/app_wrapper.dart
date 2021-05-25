import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:storyboard/views/root/app.dart';
import 'package:storyboard/configs/factory.dart';
import 'package:storyboard/redux/models/app.dart';
import 'package:storyboard/views/root/not_available_widget.dart';

class StoryBoardAppWrapper extends StatelessWidget {
  Future<Store<AppState>> getFutureStore() async {
    await getFactory().initCrashlytics();
    try {
      await getFactory().initMethodChannels();
      await getFactory().initStoreAndStorage();
      await getFactory().checkServerStatus();
    } catch (e, s) {
      await FirebaseCrashlytics.instance
          .recordError(e, s, reason: 'when create store');
    }
    return Future.value(getFactory().store);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Store<AppState>>(
      future: getFutureStore(),
      builder: (
        BuildContext context,
        AsyncSnapshot<Store<AppState>> snapshot,
      ) {
        if (!snapshot.hasData) {
          return NotAvailableWidget();
        }

        return StoreProvider(
          store: snapshot.data,
          child: StoryBoardApp(),
        );
      },
    );
  }
}
