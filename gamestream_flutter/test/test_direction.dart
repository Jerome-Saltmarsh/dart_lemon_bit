

import 'package:bleed_common/src.dart';
import 'package:gamestream_flutter/gamestream/gamestream.dart';
import 'package:gamestream_flutter/gamestream/server_response_reader.dart';
import 'package:lemon_byte/byte_writer.dart';
import 'package:test/test.dart';

void main() {
  test('responseReader', () {
    
    final gamestream = Gamestream();
    
    final bytes = ByteWriter();
    bytes.writeByte(ServerResponse.Characters);
    bytes.writeByte(CharacterType.Template);
    bytes.writeByte(CharacterType.Template);
    gamestream.readServerResponse(bytes.compile());
  });
}
