import 'dart:ui';

import 'package:bleed_client/classes/EnvironmentObject.dart';
import 'package:bleed_client/common/Tile.dart';
import 'package:bleed_client/common/enums/ObjectType.dart';
import 'package:bleed_client/constants/colours.dart';
import 'package:bleed_client/draw.dart';
import 'package:bleed_client/editor/enums/EditTool.dart';
import 'package:bleed_client/editor/events/onEditorKeyDownEvent.dart';
import 'package:bleed_client/editor/functions/resetTiles.dart';
import 'package:bleed_client/editor/render/buildEnvironmentType.dart';
import 'package:bleed_client/editor/state/editTool.dart';
import 'package:bleed_client/editor/state/keys.dart';
import 'package:bleed_client/editor/state/mouseDragClickProcess.dart';
import 'package:bleed_client/editor/state/mouseWorldStart.dart';
import 'package:bleed_client/editor/state/panning.dart';
import 'package:bleed_client/editor/state/selectedCollectable.dart';
import 'package:bleed_client/functions/saveScene.dart';
import 'package:bleed_client/render/functions/mapTilesToSrcAndDst.dart';
import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/toString.dart';
import 'package:bleed_client/ui/compose/hudUI.dart';
import 'package:bleed_client/ui/compose/widgets.dart';
import 'package:bleed_client/ui/state/flutter_constants.dart';
import 'package:bleed_client/update.dart';
import 'package:bleed_client/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lemon_engine/game.dart';
import 'package:lemon_engine/properties/mouse_world.dart';
import 'package:lemon_engine/state/camera.dart';
import 'package:lemon_engine/state/mouseDragging.dart';
import 'package:lemon_engine/state/screen.dart';
import 'package:lemon_engine/state/zoom.dart';
import 'package:lemon_math/diff.dart';
import 'package:lemon_math/diff_over.dart';
import 'package:lemon_watch/watch.dart';
import 'package:lemon_watch/watch_builder.dart';

import '../logic.dart';
import 'state/editState.dart';

final Watch<_ToolTab> _tab = Watch(_ToolTab.Tiles);
enum _ToolTab { Tiles, Objects, All, Misc }

final _Editor editor = _Editor();

class _Editor {

  init(){
    print("editor.init()");
    keyboardEvents.listen(onKeyboardEvent);
    mouseEvents.onLeftClicked.value = _onMouseLeftClicked;
  }

  _onMouseLeftClicked(){
    print("editor.onMouseLeftClicked()");
  }

  onKeyboardEvent(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      onEditorKeyDownEvent(event);
      return;
    }
    if (event is RawKeyUpEvent) {
      if (event.logicalKey == keys.pan) {
        panning = false;
      }
      if (event.logicalKey == keys.selectTileType) {
        editState.tile = tileAtMouse;
      }
    }
  }
}

Widget _buildTabs(_ToolTab activeTab) {
  return Row(
    children: _ToolTab.values.map((tab) {
      bool active = tab == activeTab;

      return button(enumString(tab), () {
        _tab.value = tab;
      },
        fillColor: active ? colours.aqua : Colors.transparent,
      );
    }).toList(),
    mainAxisAlignment: axis.main.even,
  );
}

List<Widget> _getTabChildren(_ToolTab tab) {
  switch (tab) {
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

List<Widget> _buildObjectList() {
  return game.environmentObjects.map((env) {
    return text(parseEnvironmentObjectTypeToString(env.type), onPressed: (){
      editState.selectedObject = env;
      cameraCenter(env.x, env.y);
      redrawCanvas();
    });
  }).toList();
}

List<Widget> _buildTabEnvironmentObjects() {
  return ObjectType.values.map(buildEnvironmentType).toList();
}

List<Widget> _buildTabTiles() {
  return Tile.values.map((tile) {
    return button(parseTileToString(tile), () {
      tool = EditTool.Tile;
      editState.tile = tile;
    }, width: 200, alignment: Alignment.centerLeft);
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
    if (game.tiles.length > 2)
      button("Tiles.X--", () {
        game.tiles.removeLast();
        mapTilesToSrcAndDst(game.tiles);
      }),
    if (game.tiles[0].length > 2)
      button("Tiles.Y--", () {
        for (int i = 0; i < game.tiles.length; i++) {
          game.tiles[i].removeLast();
        }
        mapTilesToSrcAndDst(game.tiles);
      }),
  ];
}

Widget buildEditorUI() {
  print('buildEditorUI()');
  return layout(
    topLeft: _toolTabs,
    topRight: _exitEditor,
  );
}

final Widget _exitEditor = button("Exit", logic.toggleEditMode);

final Widget _toolTabs = Builder(builder: (BuildContext context) {
  return WatchBuilder(_tab, (_ToolTab tab) {
    return Column(
      crossAxisAlignment: axis.cross.start,
      children: [
        _buildTabs(tab),
        height8,
        Container(
          height: screen.height - 100,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: axis.cross.start,
              children: _getTabChildren(tab),
            ),
          ),
        )
      ],
    );
  });
});

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
