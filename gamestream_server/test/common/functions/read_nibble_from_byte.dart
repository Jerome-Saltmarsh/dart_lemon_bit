import 'package:gamestream_server/common/src/functions/src.dart';
import 'package:test/test.dart';

void main() {

  test("writeNibblesToByte(2, 5)", () {
    final byte = writeNibblesToByte(2, 5);
    expect(readNibbleFromByte1(byte), 2);
    expect(readNibbleFromByte2(byte), 5);
  });

  test("writeNibblesToByte(2, 5)", () {
    final byte = writeNibblesToByte(2, 5);
    expect(readNibbleFromByte1(byte), 2);
    expect(readNibbleFromByte2(byte), 5);
  });

  test("other", () {

    print(byteToBinaryString(4));
    print(byteToBinaryString(4 >> 1));
    print(byteToBinaryString(7 << 5));

  });

}



String convertByteToHex(int byteValue) {
  const hexChars = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'];
  // Extract the upper and lower nibbles from the byte
  int upperNibble = (byteValue >> 4) & 0x0F;
  int lowerNibble = byteValue & 0x0F;
  // Convert the nibbles to their corresponding hex characters
  String hex = hexChars[upperNibble] + hexChars[lowerNibble];
  return hex;
}
