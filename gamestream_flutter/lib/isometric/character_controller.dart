import 'package:bleed_common/library.dart';

var characterAction = CharacterAction.Idle;
var characterAbility = AbilityType.None;
var characterDirection = 0;

void playerRun() =>
  setCharacterAction(CharacterAction.Run);

void setCharacterActionRun() =>
  setCharacterAction(CharacterAction.Run);

void setCharacterActionPerform1() =>
  setCharacterAction(CharacterAction.Perform1);

void setCharacterActionPerform2() =>
  setCharacterAction(CharacterAction.Perform2);

void setCharacterAction(int value){
  if (value < characterAction) return;
  characterAction = value;
}