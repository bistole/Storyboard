import 'package:flutter/material.dart';
import 'package:storyboard/views/home/note/note_helper.dart';

class NoteEditorController extends TextEditingController {
  NoteEditorController({String text}) : super(text: text);

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
        children: getNoteHelper().buildTextSpanRegex(style, value.text),
      );
    }

    final TextStyle composingStyle = style != null
        ? style.merge(const TextStyle(decoration: TextDecoration.lineThrough))
        : TextStyle(decoration: TextDecoration.lineThrough);

    return TextSpan(style: style, children: <TextSpan>[
      ...getNoteHelper().buildTextSpanRegex(
        style,
        value.composing.textBefore(value.text),
      ),
      TextSpan(
        style: composingStyle,
        text: value.composing.textInside(value.text),
      ),
      ...getNoteHelper().buildTextSpanRegex(
        style,
        value.composing.textAfter(value.text),
      ),
    ]);
  }
}
