import 'package:flutter/material.dart';
import 'package:storyboard/views/home/task/task_helper.dart';

class TaskEditorController extends TextEditingController {
  TaskEditorController({String text}) : super(text: text);

  @override
  TextSpan buildTextSpan({
    @required BuildContext context,
    TextStyle style,
    @required bool withComposing,
  }) {
    assert(!value.composing.isValid ||
        !withComposing ||
        value.isComposingRangeValid);

    if (!value.isComposingRangeValid || !withComposing) {
      return TextSpan(
        style: style,
        children: getTaskHelper().buildTextSpanRegex(style, value.text),
      );
    }

    final TextStyle composingStyle = style != null
        ? style.merge(const TextStyle(decoration: TextDecoration.lineThrough))
        : TextStyle(decoration: TextDecoration.lineThrough);

    return TextSpan(style: style, children: <TextSpan>[
      ...getTaskHelper().buildTextSpanRegex(
        style,
        value.composing.textBefore(value.text),
      ),
      TextSpan(
        style: composingStyle,
        text: value.composing.textInside(value.text),
      ),
      ...getTaskHelper().buildTextSpanRegex(
        style,
        value.composing.textAfter(value.text),
      ),
    ]);
  }
}
