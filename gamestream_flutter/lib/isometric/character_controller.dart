import 'package:bleed_common/library.dart';
import 'package:lemon_watch/watch.dart';

final characterController = CharacterController();

class CharacterController {
  final action = Watch(CharacterAction.Idle);
  var ability = AbilityType.None;
  var angle = 0;
}

void playerPerform() {
  setCharacterAction(CharacterAction.Perform);
}

void playerRun() {
  setCharacterAction(CharacterAction.Run);
}

void setCharacterAction(int value){
  if (value < characterController.action.value) return;
  characterController.action.value = value;
}


