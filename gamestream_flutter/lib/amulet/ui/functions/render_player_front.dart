
import 'package:flutter/rendering.dart';
import 'package:gamestream_flutter/amulet/ui/functions/render_sprite.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/isometric_player.dart';
import 'package:gamestream_flutter/gamestream/sprites/kid_character_sprites.dart';
import 'package:gamestream_flutter/packages/common/src/isometric/arm_type.dart';
import 'package:gamestream_flutter/packages/common/src/isometric/character_state.dart';
import 'package:gamestream_flutter/packages/common/src/isometric/gender.dart';

void renderPlayerFront(
    IsometricPlayer player,
    KidCharacterSprites sprites,
    Canvas canvas,
    int row,
    int column,
    ) {
  final gender = player.gender.value;
  final isMale = gender == Gender.male;
  final characterState = CharacterState.Idle;
  final helm = sprites.helm[player.helmType.value]
      ?.fromCharacterState(characterState);
  final head = sprites.head[player.headType.value]?.fromCharacterState(characterState);
  final bodySprite = isMale ? sprites.bodyMale : sprites.bodyFemale;
  final body = bodySprite[player.bodyType.value]
      ?.fromCharacterState(characterState);
  final torso = sprites.torso[gender]?.fromCharacterState(characterState);
  final armsLeft = sprites.armLeft[ArmType.regular]
      ?.fromCharacterState(characterState);
  final armsRight = sprites.armRight[ArmType.regular]
      ?.fromCharacterState(characterState);
  final shoesLeft = sprites.shoesLeft[player.shoeType.value]
      ?.fromCharacterState(characterState);
  final shoesRight = sprites.shoesRight[player.shoeType.value]
      ?.fromCharacterState(characterState);
  final legs = sprites.legs[player.legsType.value]
      ?.fromCharacterState(characterState);
  final hair = sprites.hairFront[player.hairType.value]
      ?.fromCharacterState(characterState);
  final weapon = sprites.weapons[player.weaponType.value]
      ?.fromCharacterState(characterState);

  final skinColor = player.skinColor.value;
  final hairColor = player.colors.palette[player.hairColor.value].value;

  renderSprite(
      sprite: torso,
      canvas: canvas,
      row: row,
      column: column,
      color: skinColor);

  renderSprite(
    sprite: legs,
    canvas: canvas,
    row: row,
    column: column,
  );

  renderSprite(
    sprite: armsLeft,
    canvas: canvas,
    row: row,
    column: column,
    color: skinColor,
  );

  renderSprite(
    sprite: armsRight,
    canvas: canvas,
    row: row,
    column: column,
    color: skinColor,
  );

  renderSprite(
      sprite: shoesLeft, canvas: canvas, row: row, column: column);
  renderSprite(
      sprite: shoesRight, canvas: canvas, row: row, column: column);
  renderSprite(sprite: body, canvas: canvas, row: row, column: column);
  renderSprite(
      sprite: head,
      canvas: canvas,
      row: row,
      column: column,
      color: skinColor);
  renderSprite(
      sprite: hair,
      canvas: canvas,
      row: row,
      column: column,
      color: hairColor);
  renderSprite(sprite: helm, canvas: canvas, row: row, column: column);
  renderSprite(sprite: weapon, canvas: canvas, row: row, column: column);
}
