import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:storyboard/views/home/task/task_editor_controller.dart';

void main() {
  group('TaskEditorController', () {
    group('#buildTextSpan', () {
      test('no composing, no url', () {
        TaskEditorController tec = TaskEditorController();

        tec.value = TextEditingValue(
          text: 'simple text',
          selection: TextSelection.collapsed(offset: -1),
          composing: TextRange.empty,
        );

        TextSpan ts = tec.buildTextSpan(context: null, withComposing: false);

        expect(ts.children.length, 1);
        expect(ts.children[0].toPlainText(), 'simple text');
      });

      test('composing, no url', () {
        TaskEditorController tec = TaskEditorController();

        tec.value = TextEditingValue(
          text: 'simple text',
          selection: TextSelection.collapsed(offset: -1),
          composing: TextRange(start: 5, end: 8),
        );

        TextSpan ts = tec.buildTextSpan(context: null, withComposing: true);

        expect(ts.children.length, 3);
        expect(ts.children[0].toPlainText(), 'simpl');
        expect(ts.children[1].toPlainText(), 'e t');
        expect(ts.children[2].toPlainText(), 'ext');
      });

      test('no composing, has url', () {
        TaskEditorController tec = TaskEditorController();

        tec.value = TextEditingValue(
          text: 'simple http://www.google.com/ url',
          selection: TextSelection.collapsed(offset: -1),
          composing: TextRange.empty,
        );

        TextSpan ts = tec.buildTextSpan(context: null, withComposing: false);

        expect(ts.children.length, 3);
        expect(ts.children[0].toPlainText(), 'simple ');
        expect(ts.children[1].toPlainText(), 'http://www.google.com/');
        expect(ts.children[2].toPlainText(), ' url');
      });
    });
  });
}
