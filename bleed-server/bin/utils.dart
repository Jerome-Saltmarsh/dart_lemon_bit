import 'common.dart';
import 'maths.dart';
import 'settings.dart';
import 'state.dart';

double bulletDistanceTravelled(dynamic bullet) {
  return distance(bullet[keyPositionX], bullet[keyPositionY], bullet[keyStartX],
      bullet[keyStartY]);
}

List<dynamic> getHumans() {
  return characters.where(isHuman).toList();
}

List<dynamic> getNpcs() {
  return characters.where(isNpc).toList();
}

bool isHuman(dynamic character) {
  return character[keyType] == typeHuman;
}

bool isNpc(dynamic character) {
  return character[keyType] == typeNpc;
}

bool isAlive(dynamic character) {
  return character[keyState] != characterStateDead;
}

void setCharacterState(dynamic character, int value) {
  character[keyState] = value;
}

void setDirection(dynamic character, int value) {
  character[keyDirection] = value;
}

dynamic npcTarget(dynamic character) {
  return findCharacterById(character[keyNpcTarget]);
}

dynamic findCharacterById(int id) {
  return characters.firstWhere((element) => element[keyCharacterId] == id,
      orElse: () {
    return null;
  });
}

bool npcTargetSet(dynamic character) {
  return character[keyNpcTarget] != null;
}

void setPosition(dynamic character, {double? x, double? y}) {
  if (x != null) {
    character[keyPositionX] = x;
  }
  if (y != null) {
    character[keyPositionY] = y;
  }
}

int getId(dynamic character) {
  return character[keyCharacterId];
}

int lastUpdateFrame(dynamic character) {
  return character[keyLastUpdateFrame];
}

bool connectionExpired(dynamic character) {
  return frame - lastUpdateFrame(character) > expiration;
}

bool isDead(dynamic character) {
  return character[keyState] == characterStateDead;
}

bool isAiming(dynamic character) {
  return character[keyState] == characterStateAiming;
}
