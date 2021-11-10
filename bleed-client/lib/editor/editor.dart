import 'dart:ui';

import 'package:bleed_client/classes/EnvironmentObject.dart';
import 'package:bleed_client/common/Tile.dart';
import 'package:bleed_client/common/enums/EnvironmentObjectType.dart';
import 'package:bleed_client/common/functions/diffOver.dart';
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
import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/state/environmentObjects.dart';
import 'package:bleed_client/maths.dart';
import 'package:bleed_client/ui/compose/widgets.dart';
import 'package:bleed_client/ui/state/flutter_constants.dart';
import 'package:flutter/material.dart';
import 'package:lemon_engine/game.dart';
import 'package:lemon_engine/properties/mouse_world.dart';
import 'package:lemon_engine/state/camera.dart';
import 'package:lemon_engine/state/mouseDragging.dart';
import 'package:lemon_engine/state/size.dart';
import 'package:lemon_engine/state/zoom.dart';

import 'state/editState.dart';

_ToolTab _tab = _ToolTab.Tiles;
StateSetter _toolsStateSetter;

enum _ToolTab { Tiles, Objects, Misc }

Widget _buildTabs() {
  return Row(
    children: [
      button("Tiles", (){
        _setTab(_ToolTab.Tiles);
      }),
      button("Objects", (){
        _setTab(_ToolTab.Objects);
      }),
      button("Misc", (){
        _setTab(_ToolTab.Misc);
      }),
    ],
    mainAxisAlignment: main.even,
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
    case _ToolTab.Misc:
      return _buildTabMisc();
  }
  throw Exception();
}

List<Widget> _buildTabEnvironmentObjects(){
  return EnvironmentObjectType.values.map(buildEnvironmentType).toList();
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
    button("Save Scene", saveScene),
    button("Reset Tiles", resetTiles),
    button("Increase Tiles X", () {
      for (List<Tile> row in game.tiles) {
        row.add(Tile.Grass);
      }
      renderTiles(game.tiles);
    }),
    button("Increase Tiles Y", () {
      List<Tile> row = [];
      for (int i = 0; i < game.tiles[0].length; i++) {
        row.add(Tile.Grass);
      }
      game.tiles.add(row);
      renderTiles(game.tiles);
    }),
  ];
}

void _rebuildTools(){
  _toolsStateSetter((){});
}

Widget _buildTools() {
  return StatefulBuilder(builder: (BuildContext context, StateSetter setState){
    print("_buildTools()");
    _toolsStateSetter = setState;
    return Positioned(
      left: 0,
      top: 0,
      child: Column(
        crossAxisAlignment: cross.start,
        children: [
          _buildTabs(),
          height8,
          Container(
            height: screenHeight - 100,
            child: SingleChildScrollView(
              child: Column(
                children: _getTabChildren(),
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
    width: globalSize.width,
    height: globalSize.height,
    alignment: Alignment.center,
    child: Stack(
      children: [
        _buildTools(),
        // _buildObjectList(),
      ],
    ),
  );
}

void updateEditMode() {
  _onMouseLeftClick();
  _handleMouseDrag();
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
  for (EnvironmentObject environmentObject in environmentObjects) {
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
      renderTiles(game.tiles);
      break;
    case EditTool.EnvironmentObject:
      environmentObjects.add(EnvironmentObject(
          x: mouseWorldX,
          y: mouseWorldY,
          type: editState.environmentObjectType));
      print("added house");
      redrawCanvas();
      break;
  }
}
