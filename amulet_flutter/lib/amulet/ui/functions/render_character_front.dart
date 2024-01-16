
import 'package:amulet_flutter/amulet/ui/functions/render_canvas_sprite.dart';
import 'package:amulet_flutter/gamestream/sprites/kid_character_sprites.dart';
import 'package:flutter/rendering.dart';

void renderCharacterFront({
  required Canvas canvas,
  required KidCharacterSprites sprites,
  required int row,
  required int column,
  required int characterState,
  required int gender,
  required int helmType,
  required int headType,
  required int armorType,
  required int shoeType,
  // required int legsType,
  required int hairType,
  // required int handsLeft,
  // required int handsRight,
  required int weaponType,
  required int skinColor,
  required int hairColor,
  required int color,
}) {
  final helm = sprites.helm[helmType]?.fromCharacterState(characterState);
  final head = sprites.head[headType]?.fromCharacterState(characterState) ?? (throw Exception());
  final armor = sprites.armor[armorType] ?.fromCharacterState(characterState);
  final torso = sprites.torso[gender]?.fromCharacterState(characterState) ?? (throw Exception());
  final shoes = sprites.shoes[shoeType]
      ?.fromCharacterState(characterState);
  // final legs = sprites.legs[legsType]
  //     ?.fromCharacterState(characterState);
  final hair = sprites.hair[hairType]
      ?.fromCharacterState(characterState);
  // final spriteHandsLeft = sprites.handLeft[handsLeft]
  //     ?.fromCharacterState(characterState);
  // final spriteHandsRight = sprites.handRight[handsRight]
  //     ?.fromCharacterState(characterState);
  final weapon = sprites.weapons[weaponType]
      ?.fromCharacterState(characterState);

  renderCanvasSprite(
    sprite: torso,
    canvas: canvas,
    row: row,
    column: column,
    color: skinColor,
    blendMode: BlendMode.modulate,
  );

  renderCanvasSprite(
    sprite: torso,
    canvas: canvas,
    row: row,
    column: column,
    color: color,
    blendMode: BlendMode.modulate,
  );

  // if (legs != null){
  //   renderCanvasSprite(
  //     sprite: legs,
  //     canvas: canvas,
  //     row: row,
  //     column: column,
  //     blendMode: BlendMode.dstATop,
  //     color: color,
  //   );
  // }

  if (shoes != null){
    renderCanvasSprite(
      sprite: shoes,
      canvas: canvas,
      row: row,
      column: column,
      blendMode: BlendMode.dstATop,
      color: color,
    );
  }

  if (armor != null) {
    renderCanvasSprite(
      sprite: armor,
      canvas: canvas,
      row: row,
      column: column,
      blendMode: BlendMode.dstATop,
      color: color,
    );
  }

  // if (spriteHandsLeft != null){
  //   renderCanvasSprite(
  //     sprite: spriteHandsLeft,
  //     canvas: canvas,
  //     row: row,
  //     column: column,
  //     blendMode: BlendMode.dstATop,
  //     color: color,
  //   );
  // }

  // if (spriteHandsRight != null){
  //   renderCanvasSprite(
  //     sprite: spriteHandsRight,
  //     canvas: canvas,
  //     row: row,
  //     column: column,
  //     blendMode: BlendMode.dstATop,
  //     color: color,
  //   );
  // }

  renderCanvasSprite(
    sprite: head,
    canvas: canvas,
    row: row,
    column: column,
    color: skinColor,
    blendMode: BlendMode.modulate,
  );

  renderCanvasSprite(
    sprite: head,
    canvas: canvas,
    row: row,
    column: column,
    color: color,
    blendMode: BlendMode.modulate,
  );

  if (hair != null){
    renderCanvasSprite(
      sprite: hair,
      canvas: canvas,
      row: row,
      column: column,
      color: hairColor,
      blendMode: BlendMode.modulate,
    );

    renderCanvasSprite(
      sprite: hair,
      canvas: canvas,
      row: row,
      column: column,
      color: color,
      blendMode: BlendMode.modulate,
    );
  }

  if (helm != null){
    renderCanvasSprite(
      sprite: helm,
      canvas: canvas,
      row: row,
      column: column,
      blendMode: BlendMode.dstATop,
      color: color,
    );
  }

  if (weapon != null){
    renderCanvasSprite(
      sprite: weapon,
      canvas: canvas,
      row: row,
      column: column,
      blendMode: BlendMode.dstATop,
      color: color,
    );
  }

}
