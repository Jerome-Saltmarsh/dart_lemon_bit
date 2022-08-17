

import 'dart:typed_data';

import 'package:bleed_common/compile_util.dart';
import 'package:test/test.dart';

void main() {
  test('approximate', () {
    const numberIn = 1123643;
    final bytes = Uint8List(16);
    writeBigNumberToArray(number: numberIn, list: bytes, index: 0);
    final numberOut = readBigNumberFromArray(bytes, index: 0);
    assert(numberIn == numberOut);
  });
}
