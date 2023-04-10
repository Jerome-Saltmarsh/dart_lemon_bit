
import 'package:bleed_server/gamestream.dart';
import 'package:lemon_byte/byte_writer.dart';

class Player<T extends Game> extends ByteWriter {
  late T game;
  late Function sendBufferToClient;

  void writeError(String error){
    writeByte(ServerResponse.Error);
    writeString(error);
  }
}