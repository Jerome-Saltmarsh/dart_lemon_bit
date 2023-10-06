import 'package:gamestream_ws/isometric.dart';
import 'package:gamestream_ws/packages/common/src/isometric/character_state.dart';

import 'set_character_state.dart';

void setCharacterStateIdle(Character character,{
  int duration = 0}){
  if (
    character.deadOrBusy ||
    character.characterStateIdle
  ) return;

  character.setDestinationToCurrentPosition();
  // character.clearPath();
  // character.clearTarget();

  setCharacterState(
    character: character,
    value: CharacterState.Idle,
    duration: duration,
  );
}
