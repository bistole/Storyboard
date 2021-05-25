import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:storyboard/views/home/note/note_editor_controller.dart';

void main() {
  group('NoteEditorController', () {
    group('#buildTextSpan', () {
      test('no composing, no url', () {
        NoteEditorController nec = NoteEditorController();

        nec.value = TextEditingValue(
          text: 'simple text',
          selection: TextSelection.collapsed(offset: -1),
          composing: TextRange.empty,
        );

        TextSpan ts = nec.buildTextSpan(context: null, withComposing: false);

        expect(ts.children.length, 1);
        expect(ts.children[0].toPlainText(), 'simple text');
      });

      test('composing, no url', () {
        NoteEditorController nec = NoteEditorController();

        nec.value = TextEditingValue(
          text: 'simple text',
          selection: TextSelection.collapsed(offset: -1),
          composing: TextRange(start: 5, end: 8),
        );

        TextSpan ts = nec.buildTextSpan(context: null, withComposing: true);

        expect(ts.children.length, 3);
        expect(ts.children[0].toPlainText(), 'simpl');
        expect(ts.children[1].toPlainText(), 'e t');
        expect(ts.children[2].toPlainText(), 'ext');
      });

      test('composing, special style', () {
        NoteEditorController nec = NoteEditorController();

        nec.value = TextEditingValue(
          text: 'simple text',
          selection: TextSelection.collapsed(offset: -1),
          composing: TextRange(start: 5, end: 8),
        );

        TextSpan ts = nec.buildTextSpan(
          context: null,
          withComposing: true,
          style: TextStyle(decoration: TextDecoration.underline),
        );

        expect(ts.children.length, 3);
        expect(ts.children[0].toPlainText(), 'simpl');
        expect(
            ts.children[0].style.decoration.contains(TextDecoration.underline),
            true);
        expect(ts.children[1].toPlainText(), 'e t');
        expect(
            ts.children[1].style.decoration
                .contains(TextDecoration.lineThrough),
            true);
        expect(ts.children[2].toPlainText(), 'ext');
      });

      test('no composing, has url', () {
        NoteEditorController nec = NoteEditorController();

        nec.value = TextEditingValue(
          text: 'simple http://www.google.com/ url',
          selection: TextSelection.collapsed(offset: -1),
          composing: TextRange.empty,
        );

        TextSpan ts = nec.buildTextSpan(context: null, withComposing: false);

        expect(ts.children.length, 3);
        expect(ts.children[0].toPlainText(), 'simple ');
        expect(ts.children[1].toPlainText(), 'http://www.google.com/');
        expect(ts.children[2].toPlainText(), ' url');
      });
    });
  });
}
