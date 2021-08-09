import '../classes.dart';
import '../enums.dart';
import '../settings.dart';
import 'characterFireWeapon.dart';

void setCharacterState(Character character, CharacterState value) {
  if (character.dead) return;
  if (character.state == value) return;
  if (value != CharacterState.Dead && character.shotCoolDown > 0) return;

  switch (value) {
    case CharacterState.Running:
      if (character is Player && character.stamina <= minStamina){
        character.state = CharacterState.Walking;
        return;
      }
      break;
    case CharacterState.Dead:
      character.collidable = false;
      break;
    case CharacterState.ChangingWeapon:
      character.shotCoolDown = 10;
      break;
    case CharacterState.Aiming:
      character.accuracy = 0;
      break;
    case CharacterState.Firing:
    // TODO Fix hack
      characterFireWeapon(character as Player);
      break;
    case CharacterState.Striking:
      character.shotCoolDown = 10;
      break;
    case CharacterState.Reloading:
      character.shotCoolDown = 20;
      break;
  }
  character.state = value;
}
