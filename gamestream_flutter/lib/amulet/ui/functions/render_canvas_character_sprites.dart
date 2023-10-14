
import 'package:flutter/rendering.dart';
import 'package:gamestream_flutter/amulet/ui/functions/render_canvas_sprite.dart';
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
  final torsoTop = sprites.torsoTop[gender]?.fromCharacterState(characterState);
  final torsoBottom = sprites.torsoBottom[gender]?.fromCharacterState(characterState);
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

  renderCanvasSprite(
      sprite: torsoTop,
      canvas: canvas,
      row: row,
      column: column,
      color: skinColor,
  );

  renderCanvasSprite(
    sprite: legs,
    canvas: canvas,
    row: row,
    column: column,
  );

  renderCanvasSprite(
    sprite: armsLeft,
    canvas: canvas,
    row: row,
    column: column,
    color: skinColor,
  );

  renderCanvasSprite(
    sprite: armsRight,
    canvas: canvas,
    row: row,
    column: column,
    color: skinColor,
  );

  renderCanvasSprite(
      sprite:
      shoesLeft,
      canvas: canvas,
      row: row,
      column: column,
  );

  renderCanvasSprite(
      sprite: shoesRight,
      canvas: canvas,
      row: row,
      column: column,
  );

  renderCanvasSprite(
      sprite: body,
      canvas: canvas,
      row: row,
      column: column,
  );

  renderCanvasSprite(
      sprite: head,
      canvas: canvas,
      row: row,
      column: column,
      color: skinColor,
  );

  renderCanvasSprite(
      sprite: hair,
      canvas: canvas,
      row: row,
      column: column,
      color: hairColor,
  );

  renderCanvasSprite(
      sprite: helm,
      canvas: canvas,
      row: row,
      column: column,
  );

  renderCanvasSprite(
      sprite: weapon,
      canvas: canvas,
      row: row,
      column: column,
  );
}
