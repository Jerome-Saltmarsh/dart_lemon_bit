import 'package:gamestream_flutter/atlases.dart';
import 'package:gamestream_flutter/isometric/classes/character.dart';
import 'package:gamestream_flutter/isometric/nodes/render/atlas_src_gameobjects.dart';
import 'package:gamestream_flutter/game_render.dart';
import 'package:lemon_engine/engine.dart';

/// @percentage is a double between 0 and 1
/// determines how full it is
void renderBarGreen(double x, double y, double z, double percentage, {
  bool transparent = false, int color = 1,
}) {
  Engine.renderSprite(
    image: Images.gameobjects,
    dstX: GameRender.getRenderX(x, y, z) - AtlasSrcGameObjects.Bar_Green_Width_Half,
    dstY: GameRender.getRenderY(x, y, z) - 45,
    srcX: transparent ? AtlasSrcGameObjects.Bar_Green_Transparent_X :AtlasSrcGameObjects.Bar_Green_X,
    srcY: transparent ? AtlasSrcGameObjects.Bar_Green_Transparent_Y :AtlasSrcGameObjects.Bar_Green_Y,
    srcWidth: (transparent ? AtlasSrcGameObjects.Bar_Green_Transparent_Width :AtlasSrcGameObjects.Bar_Green_Width) * percentage,
    srcHeight: transparent ? AtlasSrcGameObjects.Bar_Green_Transparent_Height :AtlasSrcGameObjects.Bar_Green_Height,
    anchorX: 0.0,
    color: color,
  );
}

void renderCharacterHealthBar(Character character){
  renderBarGreen(character.x, character.y, character.z, character.health);

  // Engine.renderSprite(
  //     image: Images.gameobjects,
  //     dstX: character.renderX - srcWidthHalf,
  //     dstY: character.renderY - marginY,
  //     srcX: srcX,
  //     srcY: character.allie ? 24 : 8,
  //     srcWidth: AtlasSrcGameObjects.Bar_Width,
  //     srcHeight: AtlasSrcGameObjects.Bar_Height,
  //     anchorX: 0,
  //     color: color,
  // );

  // Engine.renderBuffer(
  //     dstX: character.renderX - srcWidthHalf,
  //     dstY: character.renderY - marginY,
  //     srcX: srcX,
  //     srcY: character.allie ? 16 : 0,
  //     srcWidth: srcWidth * character.health,
  //     srcHeight: srcHeight,
  //     anchorX: 0,
  //     color: color,
  // );
}



void renderCharacterBarWeaponRounds({
  required double x,
  required double y,
  required double percentage,
}){
  const srcX = 2400.0;
  const srcWidth = 40.0;
  const srcHeight = 8.0;
  const marginY = 45;
  const srcWidthHalf = srcWidth * 0.5;

  Engine.renderBuffer(
    dstX: x - srcWidthHalf,
    dstY: y - marginY,
    srcX: srcX,
    srcY: 32,
    srcWidth: srcWidth,
    srcHeight: srcHeight,
    anchorX: 0,
  );

  Engine.renderBuffer(
    dstX: x - srcWidthHalf,
    dstY: y - marginY,
    srcX: srcX,
    srcY: 40,
    srcWidth: srcWidth * percentage,
    srcHeight: srcHeight,
    anchorX: 0,
    // color: color,
  );
}
