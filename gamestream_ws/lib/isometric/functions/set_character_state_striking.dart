import 'package:gamestream_ws/isometric/character.dart';
import 'package:gamestream_ws/packages/common/src/isometric/character_state.dart';

void setCharacterStateStriking({
  required Character character,
  required int duration,
  required int actionFrame,
}){
  assert (character.active);
  assert (character.alive);
  character.actionFrame = actionFrame;
  character.setDestinationToCurrentPosition();
  character.setCharacterState(
      value: CharacterState.Strike,
      duration: duration,
  );
}
