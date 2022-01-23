import 'package:bleed_client/classes/EnvironmentObject.dart';
import 'package:bleed_client/common/Tile.dart';
import 'package:bleed_client/common/enums/ObjectType.dart';
import 'package:bleed_client/constants/colours.dart';
import 'package:bleed_client/draw.dart';
import 'package:bleed_client/editor/events/onEditorKeyDownEvent.dart';
import 'package:bleed_client/editor/functions/resetTiles.dart';
import 'package:bleed_client/editor/state/keys.dart';
import 'package:bleed_client/editor/state/mouseDragClickProcess.dart';
import 'package:bleed_client/editor/state/mouseWorldStart.dart';
import 'package:bleed_client/editor/state/panning.dart';
import 'package:bleed_client/editor/state/selectedCollectable.dart';
import 'package:bleed_client/flutterkit.dart';
import 'package:bleed_client/functions/saveScene.dart';
import 'package:bleed_client/render/functions/mapTilesToSrcAndDst.dart';
import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/styles.dart';
import 'package:bleed_client/toString.dart';
import 'package:bleed_client/ui/compose/hudUI.dart';
import 'package:bleed_client/ui/views.dart';
import 'package:bleed_client/update.dart';
import 'package:bleed_client/user-service-client/firestoreService.dart';
import 'package:bleed_client/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lemon_engine/game.dart';
import 'package:lemon_engine/properties/mouse_world.dart';
import 'package:lemon_engine/state/camera.dart';
import 'package:lemon_engine/state/mouseDragging.dart';
import 'package:lemon_engine/state/screen.dart';
import 'package:lemon_engine/state/zoom.dart';
import 'package:lemon_math/Vector2.dart';
import 'package:lemon_math/distance_between.dart';
import 'package:lemon_watch/watch.dart';
import 'package:lemon_watch/watch_builder.dart';

import '../actions.dart';

enum _ToolTab { Tiles, Objects, All, Misc }

final _Editor editor = _Editor();

final _Style _style = _Style();

class _Style {
  final double buttonWidth = 230;
  final Color highlight = colours.purple;
}

class _Editor {
  final Watch<EnvironmentObject?> selectedObject = Watch(null);
  final Watch<_ToolTab> tab = Watch(_ToolTab.Tiles);
  final Watch<Tile> tile = Watch(Tile.Grass);
  final Watch<ObjectType> objectType = Watch(objectTypes.first);
  final Watch<EditorDialog> dialog = Watch(EditorDialog.None);

  init() {
    print("editor.init()");
    keyboardEvents.listen(onKeyboardEvent);
    mouseEvents.onLeftClicked.value = _onMouseLeftClicked;
    selectedObject.onChanged(_onSelectedObjectChanged);
  }

  _onSelectedObjectChanged(EnvironmentObject? environmentObject) {
    print("editor._onSelectedObjectChanged($environmentObject)");
    redrawCanvas();
  }

  _onMouseLeftClicked() {
    final double selectRadius = 25;
    if (game.environmentObjects.isNotEmpty) {
      EnvironmentObject closest =
          findClosest(game.environmentObjects, mouseWorldX, mouseWorldY);
      double closestDistance = distanceFromMouse(closest.x, closest.y);
      if (closestDistance <= selectRadius) {
        editor.selectedObject.value = closest;
        return;
      } else if (editor.selectedObject.value != null) {
        editor.selectedObject.value = null;
        return;
      }
    }

    switch (tab.value) {
      case _ToolTab.Tiles:
        setTileAtMouse(editor.tile.value);
        break;
      case _ToolTab.Objects:
        game.environmentObjects.add(EnvironmentObject(
          x: mouseWorldX,
          y: mouseWorldY,
          type: editor.objectType.value,
          radius: 0,
        ));
        redrawCanvas();
        break;
      case _ToolTab.All:
        break;
      case _ToolTab.Misc:
        break;
    }

    redrawCanvas();
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
        editor.tile.value = tileAtMouse;
      }
    }
  }

  void deleteSelected() {
    if (editor.selectedObject.value == null) return;
    game.environmentObjects.remove(editor.selectedObject.value);
    editor.selectedObject.value = null;
    redrawCanvas();
  }
}

Widget _buildTabs(_ToolTab activeTab) {
  return Row(
    children: _ToolTab.values.map((tab) {
      bool active = tab == activeTab;

      return button(
        enumString(tab),
        () {
          editor.tab.value = tab;
        },
        fillColor: active ? colours.purpleDarkest : Colors.transparent,
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
    return NullableWatchBuilder<EnvironmentObject?>(editor.selectedObject,
        (EnvironmentObject? selected) {
      return button(enumString(env.type), () {
        editor.selectedObject.value = env;
        cameraCenter(env.x, env.y);
        redrawCanvas();
      }, fillColor: env == selected ? _style.highlight : colours.transparent,
        width: _style.buttonWidth,
      );
    });
  }).toList();
}

List<Widget> _buildTabEnvironmentObjects() {
  return ObjectType.values.map(_buildEnvironmentType).toList();
}

List<Widget> _buildTabTiles() {
  return Tile.values.map((tile) {
    return WatchBuilder(editor.tile, (Tile selected) {
      return button(enumString(tile), () {
        editor.tile.value = tile;
      },
          width: _style.buttonWidth,
          alignment: Alignment.centerLeft,
          fillColor: selected == tile ? _style.highlight : colours.transparent);
    });
  }).toList();
}

List<Widget> _buildTabMisc() {
  return [
    button("Save", saveScene),
    button("New", resetTiles),
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

Widget buildLayoutEditor() {
  print('buildLayoutEditor()');
  return layout(
    topLeft: _toolTabs,
    topRight: Row(
      children: [
        text("Load", onPressed: actions.showDialogSelectMap),
        width8,
        text("Save", onPressed: (){
          print("(ui) save button pressed");
          firestoreService.createMap(title: 'hello', map: compileGameToJson());
        }),
        width8,
        _exitEditor,
      ],
    ),
    child: _buildEditorDialog()
  );
}

Widget _buildEditorDialog(){
    return WatchBuilder(editor.dialog, (dialog){
      print("buildEditorDialog($dialog)");
      switch(dialog){
        case EditorDialog.Load:
          return buildDialogLoadMap();
        default:
          return empty;
      }
    });
}

enum EditorDialog {
  None,
  Load
}

final Widget _exitEditor = button("Exit", actions.toggleEditMode);

final Widget _toolTabs = Builder(builder: (BuildContext context) {
  return WatchBuilder(editor.tab, (_ToolTab tab) {
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

  setTileAtMouse(editor.tile.value);
}

void _onMouseLeftClick([bool drag = false]) {
  if (!drag && !mouseClicked) return;
  // selectedCollectable = -1;
  // double r = 50;
  //
  // for (int i = 0; i < game.collectables.length; i += 3) {
  //   double x = game.collectables[i + 1].toDouble();
  //   double y = game.collectables[i + 2].toDouble();
  //   if (diff(x, mouseWorldX) < r && diff(y, mouseWorldY) < r) {
  //     selectedCollectable = i;
  //     return;
  //   }
  // }
  //
  // double selectRadius = 25;
  // for (EnvironmentObject environmentObject in game.environmentObjects) {
  //   if (diffOver(environmentObject.x, mouseWorldX, selectRadius)) continue;
  //   if (diffOver(environmentObject.y, mouseWorldY, selectRadius)) continue;
  //   editor.selectedObject.value = environmentObject;
  //   redrawCanvas();
  //   return;
  // }
  //
  // setTileAtMouse(editor.tile.value);
}

Tile get tileAtMouse {
  if (mouseRow < 0) return Tile.Boundary;
  if (mouseColumn < 0) return Tile.Boundary;
  if (mouseRow >= game.totalRows) return Tile.Boundary;
  if (mouseColumn >= game.totalColumns) return Tile.Boundary;
  return game.tiles[mouseRow][mouseColumn];
}

void setTileAtMouse(Tile tile) {
  setTile(row: mouseRow, column: mouseColumn, tile: tile);
}

void setTile({
  required int row,
  required int column,
  required Tile tile,
}) {
  if (row < 0) return;
  if (column < 0) return;
  if (row >= game.totalRows) return;
  if (column >= game.totalColumns) return;
  game.tiles[row][column] = tile;
  mapTilesToSrcAndDst(game.tiles);
}

Widget _buildEnvironmentType(ObjectType type) {
  return WatchBuilder(editor.objectType, (ObjectType selected) {
    return button(parseEnvironmentObjectTypeToString(type), () {
      editor.objectType.value = type;
    },
        fillColor: type == selected ? colours.purple : colours.transparent,
        width: 200,
        alignment: Alignment.centerLeft);
  });
}

double distanceFromMouse(double x, double y) {
  return distanceBetween(mouseWorldX, mouseWorldY, x, y);
}
