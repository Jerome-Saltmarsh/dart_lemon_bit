import 'package:bleed_common/library.dart';

var characterAction = CharacterAction.Idle;
var characterAbility = AbilityType.None;
var characterDirection = 0;

void playerPerform() {
  setCharacterAction(CharacterAction.Perform);
}

void playerRun() {
  setCharacterAction(CharacterAction.Run);
}

void setCharacterActionRun(){
  setCharacterAction(CharacterAction.Run);
}

void setCharacterActionPerform(){
  setCharacterAction(CharacterAction.Perform);
}

void setCharacterAction(int value){
  if (value < characterAction) return;
  characterAction = value;
}