
import 'package:bleed_server/gamestream.dart';
import 'package:lemon_byte/byte_writer.dart';

abstract class Player extends ByteWriter {
  Game get game;
  late Function sendBufferToClient;

  void writeError(String error){
    writeByte(ServerResponse.Error);
    writeString(error);
  }
}