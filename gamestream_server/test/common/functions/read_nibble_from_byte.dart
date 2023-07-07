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

  test("readCharacterAnimationAndDirection", () {
    final animationFrameIn = 16 + 8 + 4 + 2 + 1;
    final directionIn = 1;
    var byte = animationFrameIn | (directionIn << 5);
    printByte(byte);
    final directionOut = (byte & Hex11100000) >> 5;
    final animationFrameOut = (byte & Hex00011111);
    // expect(directionOut, directionIn);
    // expect(animationFrameOut, animationFrameIn);
  });



  test("other", () {

    for (var i = 0; i < 8; i++){
      print(readBitFromByteLR(Hex11100000, i));
    }

  });
}

void printByte(int byte){
  print(byteToBinaryString(byte));
}

