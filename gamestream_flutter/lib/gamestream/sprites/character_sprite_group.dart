
import 'package:gamestream_flutter/packages/common/src/isometric/character_state.dart';
import 'package:lemon_sprite/lib.dart';


class CharacterSpriteGroup {
  final Sprite idle;
  final Sprite running;
  final Sprite change;
  final Sprite dead;
  final Sprite fire;
  final Sprite strike;
  final Sprite hurt;
  final Sprite casting;

  CharacterSpriteGroup({
    required this.idle,
    required this.running,
    required this.change,
    required this.dead,
    required this.fire,
    required this.strike,
    required this.hurt,
    required this.casting,
  });

  Sprite fromCharacterState(int characterState) =>
      switch (characterState) {
        CharacterState.Idle => idle,
        CharacterState.Running => running,
        CharacterState.Strike_1 => strike,
        CharacterState.Strike_2 => strike,
        CharacterState.Hurt => hurt,
        CharacterState.Dead => dead,
        CharacterState.Fire => fire,
        CharacterState.Changing => change,
        CharacterState.Casting => casting,
        _ => throw Exception(),
      };
}