
import 'package:gamestream_ws/isometric/character.dart';
import 'package:gamestream_ws/packages/common/src/isometric/character_state.dart';

void setCharacterState({
  required Character character,
  required int value,
  required int duration,
}) {
  assert (duration >= 0);
  assert (value != CharacterState.Dead); // use game.setCharacterStateDead
  assert (value != CharacterState.Hurt); // use character.setCharacterStateHurt

  if (character.characterState == value || character.deadOrBusy) {
    return;
  }

  character.characterState = value;
  character.frame = 0;
  character.actionDuration = duration;
}
