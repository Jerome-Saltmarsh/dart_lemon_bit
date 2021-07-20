import '../common.dart';
import '../state.dart';

spawnCharacter(double x, double y, {required bool npc, required int health, String? name}) {
  if (x == double.nan) {
    throw Exception("x is nan");
  }
  Map<String, dynamic> character = new Map();
  character[keyPositionX] = x;
  character[keyPositionY] = y;
  character[keyCharacterId] = id;
  character[keyDirection] = directionDown;
  character[keyState] = characterStateIdle;
  character[keyType] = npc ? typeNpc : typeHuman;
  character[keyHealth] = health;
  character[keyVelocityX] = 0;
  character[keyVelocityY] = 0;
  if (name != null) {
    character[keyPlayerName] = name;
  }
  if (!npc) {
    character[keyLastUpdateFrame] = frame;
  }
  characters.add(character);
  id++;
  return character;
}
