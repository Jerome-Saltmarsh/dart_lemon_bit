
import 'package:bleed_server/gamestream.dart';
import 'package:lemon_byte/byte_writer.dart';
import 'package:lemon_math/library.dart';

abstract class Player with ByteWriter {
  Game get game;
  late Function sendBufferToClient;
  var framesSinceClientRequest = 0;
  final mouse = Vector2(0, 0);
  var screenLeft = 0.0;
  var screenTop = 0.0;
  var screenRight = 0.0;
  var screenBottom = 0.0;
  var inputMode = InputMode.Keyboard;

  void writeError(String error){
    writeByte(ServerResponse.Error);
    writeString(error);
  }

  // void writePlayerGame();
}