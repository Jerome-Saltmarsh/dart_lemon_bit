import 'package:gamestream_ws/isometric.dart';
import 'package:gamestream_ws/packages/common/src/isometric/character_state.dart';

import 'set_character_state.dart';

void setCharacterStateFire({
  required Character character,
  required int duration,
  required int actionFrame,
}){
  assert (character.active);
  assert (character.alive);
  assert (duration > 0);
  assert (actionFrame < duration);

  character.actionFrame = actionFrame;
  character.setDestinationToCurrentPosition();
  setCharacterState(
    character: character,
    value: CharacterState.Fire,
    duration: duration,
  );
}
