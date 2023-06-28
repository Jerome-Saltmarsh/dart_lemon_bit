import 'package:gamestream_server/data_types/boolean32_list.dart';
import 'package:test/test.dart';

void main() {
  group('Boolean32List', () {
    // Test case 1: Creating a BitArray and setting boolean values
    test('Setting boolean values', () {
      final arrayLength = 10;
      final bitArray = Boolean32List(arrayLength);

      bitArray[2] = true;
      bitArray[5] = true;

      for (var i = 0; i < arrayLength; i++) {
        if (i == 2 || i == 5) {
          expect(bitArray[i], isTrue);
        } else {
          expect(bitArray[i], isFalse);
        }
      }
    });

    // Test case 2: Accessing boolean values in an initialized BitArray
    test('Accessing initialized values', () {
      final initializedArrayLength = 8;
      final initializedBitArray = Boolean32List(initializedArrayLength);
      initializedBitArray[1] = true;
      initializedBitArray[3] = true;
      initializedBitArray[5] = true;

      expect(initializedBitArray[1], isTrue);
      expect(initializedBitArray[3], isTrue);
      expect(initializedBitArray[5], isTrue);

      for (var i = 0; i < initializedArrayLength; i++) {
        if (i == 1 || i == 3 || i == 5) {
          expect(initializedBitArray[i], isTrue);
        } else {
          expect(initializedBitArray[i], isFalse);
        }
      }
    });

    // Test case 3: Accessing out-of-range index in BitArray
    test('Accessing out-of-range index', () {
      final outOfRangeArrayLength = 5;
      final outOfRangeBitArray = Boolean32List(outOfRangeArrayLength);

      expect(() => outOfRangeBitArray[10], throwsA(isRangeError));
    });

    // Test case 4: Setting and accessing boolean values in a large BitArray
    test('Setting and accessing in a large BitArray', () {
      final largeArrayLength = 1000000;
      final largeBitArray = Boolean32List(largeArrayLength);

      largeBitArray[500000] = true;
      largeBitArray[750000] = true;

      expect(largeBitArray[500000], isTrue);
      expect(largeBitArray[750000], isTrue);

      for (var i = 0; i < largeArrayLength; i++) {
        if (i == 500000 || i == 750000) {
          expect(largeBitArray[i], isTrue);
        } else {
          expect(largeBitArray[i], isFalse);
        }
      }
    });
  });
}
