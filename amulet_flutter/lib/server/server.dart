
import 'package:amulet_engine/common.dart';

abstract class Server {

  bool get connected;

  Future createNewCharacter({
    required String name,
    required int complexion,
    required int hairType,
    required int hairColor,
    required int gender,
    required int headType,
    required Difficulty difficulty,
  });

  void playCharacter(String characterUuid);

  Future deleteCharacter(String characterId);

  void disconnect();

  void send(dynamic data);
}