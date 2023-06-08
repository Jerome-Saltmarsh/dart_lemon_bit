import 'package:gamestream_flutter/gamestream/games/isometric/game_isometric_renderer.dart';

import '../../library.dart';

/// @percentage is a double between 0 and 1
/// determines how full it is
void renderBarGreen(double x, double y, double z, double percentage) {
  engine.renderSprite(
    image: GameImages.atlas_gameobjects,
    dstX: GameIsometricRenderer.getRenderX(x, y, z) - 26,
    dstY: GameIsometricRenderer.getRenderY(x, y, z) - 45,
    srcX: 171,
    srcY: 16,
    srcWidth: 51.0 * percentage,
    srcHeight: 8,
    anchorX: 0.0,
    color: 1,
  );
}

void renderBarBlue(double x, double y, double z, double percentage) {
  engine.renderSprite(
    image: GameImages.atlas_gameobjects,
    dstX: GameIsometricRenderer.getRenderX(x, y, z) - 26,
    dstY: GameIsometricRenderer.getRenderY(x, y, z) - 55,
    srcX: 171,
    srcY: 48,
    srcWidth: 51.0 * percentage,
    srcHeight: 8,
    anchorX: 0.0,
    color: 1,
  );
}


void renderCharacterHealthBar(IsometricCharacter character){
  renderBarGreen(character.x, character.y, character.z, character.health);

  // engine.renderSprite(
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

  // engine.renderBuffer(
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

  engine.renderSprite(
    image: GameImages.atlas_gameobjects,
    dstX: x - srcWidthHalf,
    dstY: y - marginY,
    srcX: srcX,
    srcY: 32,
    srcWidth: srcWidth,
    srcHeight: srcHeight,
    anchorX: 0,
  );

  engine.renderSprite(
    image: GameImages.atlas_gameobjects,
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
