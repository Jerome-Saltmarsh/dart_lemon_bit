import 'package:amulet_engine/packages/common.dart';
import 'package:lemon_sprite/lib.dart';


class CharacterSpriteGroup {
  final Sprite idle;
  final Sprite running;
  final Sprite change;
  final Sprite dead;
  final Sprite fire;
  final Sprite strike1;
  final Sprite strike2;
  final Sprite hurt;
  final Sprite casting;

  CharacterSpriteGroup({
    required this.idle,
    required this.running,
    required this.change,
    required this.dead,
    required this.fire,
    required this.strike1,
    required this.strike2,
    required this.hurt,
    required this.casting,
  });

  Sprite fromCharacterState(int characterState) =>
      switch (characterState) {
        CharacterState.Idle => idle,
        CharacterState.Running => running,
        CharacterState.Strike_1 => strike1,
        CharacterState.Strike_2 => strike2,
        CharacterState.Hurt => hurt,
        CharacterState.Dead => dead,
        CharacterState.Fire => fire,
        CharacterState.Changing => change,
        CharacterState.Casting => casting,
        _ => throw Exception(),
      };
}