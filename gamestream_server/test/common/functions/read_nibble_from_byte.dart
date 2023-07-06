import 'package:gamestream_server/common/src/functions/read_nibble_from_byte_1.dart';
import 'package:gamestream_server/common/src/functions/src.dart';
import 'package:gamestream_server/utils/byte_utils.dart';
import 'package:test/test.dart';

void main() {

  test("writeNibblesToByte(2, 5)", () {
    final byte = writeNibblesToByte(2, 5);
    expect(readNibbleFromByte1(byte), 2);
    expect(readNibbleFromByte2(byte), 5);
  });

}
