import 'dart:ui';

import 'package:bleed_client/classes/EnvironmentObject.dart';
import 'package:bleed_client/common/Tile.dart';
import 'package:bleed_client/common/enums/ObjectType.dart';
import 'package:bleed_client/draw.dart';
import 'package:bleed_client/editor/enums/EditTool.dart';
import 'package:bleed_client/editor/functions/resetTiles.dart';
import 'package:bleed_client/editor/render/buildEnvironmentType.dart';
import 'package:bleed_client/editor/state/editTool.dart';
import 'package:bleed_client/editor/state/mouseDragClickProcess.dart';
import 'package:bleed_client/editor/state/mouseWorldStart.dart';
import 'package:bleed_client/editor/state/panning.dart';
import 'package:bleed_client/editor/state/selectedCollectable.dart';
import 'package:bleed_client/functions/saveScene.dart';
import 'package:bleed_client/render/functions/mapTilesToSrcAndDst.dart';
import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/ui/compose/widgets.dart';
import 'package:bleed_client/ui/state/flutter_constants.dart';
import 'package:bleed_client/update.dart';
import 'package:flutter/material.dart';
import 'package:lemon_engine/game.dart';
import 'package:lemon_engine/properties/mouse_world.dart';
import 'package:lemon_engine/state/camera.dart';
import 'package:lemon_engine/state/mouseDragging.dart';
import 'package:lemon_engine/state/screen.dart';
import 'package:lemon_engine/state/zoom.dart';
import 'package:lemon_math/diff.dart';
import 'package:lemon_math/diff_over.dart';

import 'state/editState.dart';

_ToolTab _tab = _ToolTab.Tiles;

enum _ToolTab { Tiles, Objects, All, Misc }

Widget _buildTabs() {
  return Row(
    children: [
      button("Tiles", (){
        _setTab(_ToolTab.Tiles);
      }),
      button("Objects", (){
        _setTab(_ToolTab.Objects);
      }),
      button("All", (){
        _setTab(_ToolTab.All);
      }),
      button("Misc", (){
        _setTab(_ToolTab.Misc);
      }),
    ],
    mainAxisAlignment: axis.main.even,
  );
}

void _setTab(_ToolTab value){
  if(_tab == value) return;
  _tab = value;
  _rebuildTools();
}

List<Widget> _getTabChildren() {
  switch (_tab) {
    case _ToolTab.Tiles:
      return _buildTabTiles();
    case _ToolTab.Objects:
      return _buildTabEnvironmentObjects();
    case _ToolTab.All:
      return _buildObjectList();
    case _ToolTab.Misc:
      return _buildTabMisc();
  }
}

List<Widget> _buildObjectList(){
  return game.environmentObjects.map((e){
    return text(parseEnvironmentObjectTypeToString(e.type));
  }).toList();
}

List<Widget> _buildTabEnvironmentObjects(){
  return ObjectType.values.map(buildEnvironmentType).toList();
}

List<Widget> _buildTabTiles(){
  return Tile.values.map((tile) {
    return button(parseTileToString(tile), () {
      tool = EditTool.Tile;
      editState.tile = tile;
    });
  }).toList();
}

List<Widget> _buildTabMisc() {
  return [
    button("Save", saveScene),
    button("New", newScene),
    button("Tiles.X++", () {
      for (List<Tile> row in game.tiles) {
        row.add(Tile.Grass);
      }
      mapTilesToSrcAndDst(game.tiles);
    }),
    button("Tiles.Y++", () {
      List<Tile> row = [];
      for (int i = 0; i < game.tiles[0].length; i++) {
        row.add(Tile.Grass);
      }
      game.tiles.add(row);
      mapTilesToSrcAndDst(game.tiles);
    }),
    if(game.tiles.length > 2)
    button("Tiles.X--", () {
      game.tiles.removeLast();
      mapTilesToSrcAndDst(game.tiles);
    }),
    if(game.tiles[0].length > 2)
      button("Tiles.Y--", () {
        for (int i = 0; i < game.tiles.length; i++) {
           game.tiles[i].removeLast();
        }
        mapTilesToSrcAndDst(game.tiles);
      }),
  ];
}

void _rebuildTools(){
  // _toolsStateSetter((){});
}

Widget _buildTools() {
  return StatefulBuilder(builder: (BuildContext context, StateSetter setState){
    print("_buildTools()");
    // _toolsStateSetter = setState;
    return Positioned(
      left: 0,
      top: 0,
      child: Column(
        crossAxisAlignment: axis.cross.start,
        children: [
          _buildTabs(),
          height8,
          Container(
            height: screen.height - 100,
            child: SingleChildScrollView(
              child: Column(
                // crossAxisAlignment: cross.stretch,
                children: _getTabChildren().toList(),
              ),
            ),
          )
        ],
      ),
    );
  });
}

Widget buildEditorUI() {
  return Container(
    width: screen.width,
    height: screen.height,
    alignment: Alignment.center,
    child: Stack(
      children: [
        _buildTools(),
      ],
    ),
  );
}

void updateEditMode() {
  _onMouseLeftClick();
  _handleMouseDrag();
  updateZoom();
  redrawCanvas();

  if (panning) {
    Offset mouseWorldDiff = mouseWorldStart - mouseWorld;
    camera.y += mouseWorldDiff.dy * zoom;
    camera.x += mouseWorldDiff.dx * zoom;
  }
}

void _handleMouseDrag() {
  if (!mouseDragging) {
    mouseDragClickProcess = false;
    return;
  }

  if (!mouseDragClickProcess) {
    mouseDragClickProcess = true;
    _onMouseLeftClick(true);
    return;
  }

  if (selectedCollectable > -1) {
    game.collectables[selectedCollectable + 1] = mouseWorldX.toInt();
    game.collectables[selectedCollectable + 2] = mouseWorldY.toInt();
    return;
  }

  setTileAtMouse(editState.tile);
}

void _onMouseLeftClick([bool drag = false]) {
  if (!drag && !mouseClicked) return;
  selectedCollectable = -1;

  double r = 50;

  for (int i = 0; i < game.collectables.length; i += 3) {
    double x = game.collectables[i + 1].toDouble();
    double y = game.collectables[i + 2].toDouble();
    if (diff(x, mouseWorldX) < r && diff(y, mouseWorldY) < r) {
      selectedCollectable = i;
      return;
    }
  }

  double selectRadius = 25;
  for (EnvironmentObject environmentObject in game.environmentObjects) {
    if (diffOver(environmentObject.x, mouseWorldX, selectRadius)) continue;
    if (diffOver(environmentObject.y, mouseWorldY, selectRadius)) continue;
    editState.selectedObject = environmentObject;
    redrawCanvas();
    return;
  }

  setTileAtMouse(editState.tile);
}

Tile get tileAtMouse {
  try {
    return game.tiles[mouseTileY][mouseTileX];
  } catch (e) {
    return Tile.Boundary;
  }
}

void setTileAtMouse(Tile tile) {
  int row = mouseTileY;
  int column = mouseTileX;
  if (row < 0) return;
  if (column < 0) return;

  switch (tool) {
    case EditTool.Tile:
      game.tiles[row][column] = tile;
      mapTilesToSrcAndDst(game.tiles);
      break;
    case EditTool.EnvironmentObject:
      // TODO
      // game.environmentObjects.add(EnvironmentObject(
      //     x: mouseWorldX,
      //     y: mouseWorldY,
      //     type: editState.environmentObjectType));
      // print("added house");
      // redrawCanvas();
      break;
  }
}
