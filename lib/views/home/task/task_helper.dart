import 'package:flutter/rendering.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:storyboard/views/config/styles.dart';

class TaskHelper {
  final regex = new RegExp(
      r'(https?:\/\/(?:www\.|(?!www))[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]\.[^\s]{2,}|www\.[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]\.[^\s]{2,}|https?:\/\/(?:www\.|(?!www))[a-zA-Z0-9]+\.[^\s]{2,}|www\.[a-zA-Z0-9]+\.[^\s]{2,})',
      caseSensitive: false);

  List<InlineSpan> buildTextSpanRegex(TextStyle style, String s,
      {bool interactive = false, bool cursor = false}) {
    List<InlineSpan> result = [];
    int offset = 0;
    for (RegExpMatch iter in regex.allMatches(s)) {
      if (iter.start > offset) {
        result.add(TextSpan(
          text: s.substring(offset, iter.start),
        ));
      }
      var url = s.substring(iter.start, iter.end);
      var textSpan = interactive
          ? TextSpan(
              recognizer: TapGestureRecognizer()
                ..onTap = () async {
                  if (await canLaunch(url)) {
                    await launch(url);
                  }
                },
              style: Styles.urlBodyText,
              text: url,
            )
          : TextSpan(
              style: Styles.urlBodyText,
              text: url,
            );

      var widget = cursor
          ? WidgetSpan(
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Text.rich(textSpan),
              ),
            )
          : textSpan;

      result.add(widget);
      offset = iter.end;
    }
    result.add(TextSpan(text: s.substring(offset)));
    return result;
  }
}

TaskHelper _helper;

TaskHelper getTaskHelper() {
  if (_helper == null) {
    _helper = TaskHelper();
  }
  return _helper;
}

setTaskHelper(TaskHelper helper) {
  _helper = helper;
}
