import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dinar_echange/utils/textfield_format.dart';

TextEditingValue _apply(String oldText, String newText) {
  return InputFormatter().formatEditUpdate(
    TextEditingValue(text: oldText),
    TextEditingValue(text: newText),
  );
}

void main() {
  group('InputFormatter', () {
    test('empty input passes through', () {
      final r = _apply('123', '');
      expect(r.text, '');
    });

    test('valid integer is accepted', () {
      final r = _apply('', '12345');
      expect(r.text, '12345');
    });

    test('valid decimal with 2 places is accepted', () {
      final r = _apply('', '12.34');
      expect(r.text, '12.34');
    });

    test('letters and symbols are rejected (old value kept)', () {
      final r = _apply('42', 'abc');
      expect(r.text, '42');
    });

    test('multiple decimal points are rejected', () {
      final r = _apply('1.2', '1.2.3');
      expect(r.text, '1.2');
    });

    test('more than 2 decimal places are rejected', () {
      final r = _apply('1.23', '1.234');
      expect(r.text, '1.23');
    });

    test('values above 1 trillion are rejected', () {
      final r = _apply('1000000000000', '1000000000001');
      expect(r.text, '1000000000000');
    });
  });
}
