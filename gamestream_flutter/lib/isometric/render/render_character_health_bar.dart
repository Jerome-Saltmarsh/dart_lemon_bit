import 'package:gamestream_flutter/isometric/classes/character.dart';
import 'package:lemon_engine/engine.dart';

void renderCharacterHealthBar(Character character){
  const _healthX = 2400.0;
  const _healthY = 0.0;
  const _healthWidth = 40.0;
  const _healthWidthHalf = _healthWidth * 0.5;
  const _healthHeight = 8.0;
  const _healthAnchorY = 50.0;
  const _healthBackgroundY = _healthY + _healthHeight;

  engine.mapSrc(x: _healthX, y: _healthBackgroundY, width: _healthWidth, height: 6);
  engine.mapDst(x: character.renderX, y: character.renderY, anchorX: _healthWidthHalf, anchorY: _healthAnchorY);
  engine.renderAtlas();
  engine.mapSrc(x: _healthX, y: _healthY, width: _healthWidth * character.health, height: 6);
  engine.mapDst(x: character.renderX, y: character.renderY, anchorX: _healthWidthHalf, anchorY: _healthAnchorY);
  engine.renderAtlas();
}
