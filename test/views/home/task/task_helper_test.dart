import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:storyboard/views/config/styles.dart';
import 'package:storyboard/views/home/task/task_helper.dart';

void main() {
  group('TaskHelper', () {
    test('no url', () {
      var text = 'just normal test';
      var helper = getTaskHelper();
      var result = helper.buildTextSpanRegex(TextStyle(), text);

      expect(result.length, 1);
      TextSpan textSpan = result[0];
      expect(textSpan.toPlainText(), text);
    });

    test('url with interactive', () {
      var text = 'have https://www.google.com/ how are you';
      var helper = getTaskHelper();
      var result = helper.buildTextSpanRegex(
        TextStyle(),
        text,
        interactive: true,
        cursor: false,
      );

      expect(result.length, 3);
      expect((result[0] as TextSpan).toPlainText(), 'have ');
      expect((result[1] as TextSpan).toPlainText(), 'https://www.google.com/');
      expect((result[2] as TextSpan).toPlainText(), ' how are you');

      expect(
          (result[1] as TextSpan).style, TextStyle().merge(Styles.urlBodyText));

      TapGestureRecognizer recog = (result[1] as TextSpan).recognizer;
      expect(recog.onTap, isNotNull);
    });

    test('url with cursor', () {
      var text = 'have https://www.google.com/ how are you';
      var helper = getTaskHelper();
      var result = helper.buildTextSpanRegex(
        TextStyle(),
        text,
        interactive: true,
        cursor: true,
      );

      expect(result.length, 3);
      expect((result[0] as TextSpan).toPlainText(), 'have ');

      var textRich =
          ((result[1] as WidgetSpan).child as MouseRegion).child as Text;
      expect(textRich.textSpan.toPlainText(), 'https://www.google.com/');
      expect(textRich.textSpan.style, Styles.urlBodyText);
      expect((result[2] as TextSpan).toPlainText(), ' how are you');
    });
  });
}
