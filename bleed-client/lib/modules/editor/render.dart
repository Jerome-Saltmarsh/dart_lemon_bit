import 'package:bleed_client/classes/Character.dart';
import 'package:bleed_client/common/Tile.dart';
import 'package:bleed_client/common/enums/Shade.dart';
import 'package:bleed_client/constants/colours.dart';
import 'package:bleed_client/mappers/mapTileToSrcRect.dart';
import 'package:bleed_client/modules/editor/enums.dart';
import 'package:bleed_client/modules/editor/scope.dart';
import 'package:bleed_client/modules/isometric/atlas.dart';
import 'package:bleed_client/modules/isometric/utilities.dart';
import 'package:bleed_client/modules/modules.dart';
import 'package:bleed_client/render/draw/drawCanvas.dart';
import 'package:bleed_client/render/draw/drawCharacter.dart';
import 'package:flutter/material.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_math/Vector2.dart';

class EditorRender with EditorScope {

  void render(Canvas canvas, Size size) {
    isometric.render.tiles();

    renderTilePreview();

    isometric.render.sprites();
    _drawSelectedObject();
    _drawCharacters();

    state.items.forEach(drawItem);

    for (final playerSpawnPosition in state.teamSpawnPoints){
      engine.draw.drawCircleOutline(
           radius: 25,
           x: playerSpawnPosition.x,
           y: playerSpawnPosition.y,
           color: colours.blue
       );
    }
  }

  void renderTilePreview() {
    if (state.tab.value != ToolTab.Tiles) return;
    if (isometric.queries.mouseOutOfBounds()) return;

    srcTile(state.tile.value);
    dstTile(state.tile.value, mouseWorldX, mouseWorldY);
    engine.actions.renderAtlas();
  }

  void srcTile(Tile tile, {int shade = Shade_Bright}){
    engine.actions.mapSrc(
        x: atlas.tiles.x + mapTileToSrcLeft(tile),
        y: atlas.tiles.y + (isometric.constants.tileSize * shade)
    );
  }

  void dstTile(Tile tile, double x, double y){
    int row = getRow(x, y);
    int column = getColumn(x, y);
    double x2 = getTileWorldX(row, column);
    double y2 = getTileWorldY(row, column);
    engine.actions.mapDst(x: x2, y: y2);
  }

  void _drawCharacters() {
    for (Character character in editor.state.characters){
      drawCharacter(character);
    }
  }

  void _drawSelectedObject() {
    final Vector2? selectedObject = editor.state.selected.value;
    if (selectedObject == null) return;

    engine.draw.drawCircleOutline(x: selectedObject.x, y: selectedObject.y, radius: 50, color: Colors.white, sides: 10);
    engine.draw.circle(selectedObject.x, selectedObject.y,
        15, Colors.white70);

  }
}

