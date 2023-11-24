import 'package:test/test.dart';
import 'package:gamestream_ws/packages.dart';

void main() {


  test("All False", () {
    expect(writeBits(false, false, false, false, false, false, false, false), 0);
  });

  test("All True", () {
    expect(writeBits(true, true, true, true, true, true, true, true), 255);
  });

  test("Cases", () {
    final byte = writeBits(false, true, true, true, true, true, true, true);
    readBitFromByte(byte, 0);
    expect(readBitFromByte(byte, 0), false);
    expect(readBitFromByte(byte, 1), true);
    expect(readBitFromByte(byte, 2), true);
    expect(readBitFromByte(byte, 3), true);
    expect(readBitFromByte(byte, 4), true);
    expect(readBitFromByte(byte, 5), true);
    expect(readBitFromByte(byte, 6), true);
    expect(readBitFromByte(byte, 7), true);
  });


}
