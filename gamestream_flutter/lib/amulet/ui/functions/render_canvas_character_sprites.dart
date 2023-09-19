
import 'package:flutter/rendering.dart';
import 'package:gamestream_flutter/amulet/ui/functions/render_sprite.dart';
import 'package:gamestream_flutter/gamestream/sprites/kid_character_sprites.dart';
import 'package:gamestream_flutter/packages/common/src/isometric/arm_type.dart';
import 'package:gamestream_flutter/packages/common/src/isometric/gender.dart';

void renderCanvasCharacterSprites({
  required Canvas canvas,
  required KidCharacterSprites sprites,
  required int row,
  required int column,
  required int characterState,
  required int gender,
  required int helmType,
  required int headType,
  required int bodyType,
  required int shoeType,
  required int legsType,
  required int hairType,
  required int weaponType,
  required int skinColor,
  required int hairColor,
}) {
  final isMale = gender == Gender.male;
  final helm = sprites.helm[helmType]
      ?.fromCharacterState(characterState);
  final head = sprites.head[headType]?.fromCharacterState(characterState);
  final bodySprite = isMale ? sprites.bodyMale : sprites.bodyFemale;
  final body = bodySprite[bodyType]
      ?.fromCharacterState(characterState);
  final torso = sprites.torso[gender]?.fromCharacterState(characterState);
  final armsLeft = sprites.armLeft[ArmType.regular]
      ?.fromCharacterState(characterState);
  final armsRight = sprites.armRight[ArmType.regular]
      ?.fromCharacterState(characterState);
  final shoesLeft = sprites.shoesLeft[shoeType]
      ?.fromCharacterState(characterState);
  final shoesRight = sprites.shoesRight[shoeType]
      ?.fromCharacterState(characterState);
  final legs = sprites.legs[legsType]
      ?.fromCharacterState(characterState);
  final hair = sprites.hairFront[hairType]
      ?.fromCharacterState(characterState);
  final weapon = sprites.weapons[weaponType]
      ?.fromCharacterState(characterState);

  // final hairColor = player.colors.palette[player.hairColor.value].value;

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
