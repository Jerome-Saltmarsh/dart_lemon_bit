import 'package:gamestream_ws/isometric/character.dart';
import 'package:gamestream_ws/isometric/functions/set_character_state.dart';
import 'package:gamestream_ws/packages/common/src/isometric/character_state.dart';

void setCharacterStateRunning(Character character) {
  setCharacterState(
    character: character,
    value: CharacterState.Running,
    duration: 0,
  );
}