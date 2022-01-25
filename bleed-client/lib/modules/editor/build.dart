

import 'package:bleed_client/actions.dart';
import 'package:bleed_client/classes/EnvironmentObject.dart';
import 'package:bleed_client/common/Tile.dart';
import 'package:bleed_client/common/enums/ObjectType.dart';
import 'package:bleed_client/constants/colours.dart';
import 'package:bleed_client/flutterkit.dart';
import 'package:bleed_client/functions/saveScene.dart';
import 'package:bleed_client/modules.dart';
import 'package:bleed_client/render/functions/mapTilesToSrcAndDst.dart';
import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/styles.dart';
import 'package:bleed_client/toString.dart';
import 'package:bleed_client/ui/compose/hudUI.dart';
import 'package:bleed_client/ui/dialogs.dart';
import 'package:bleed_client/ui/style.dart';
import 'package:bleed_client/user-service-client/firestoreService.dart';
import 'package:bleed_client/utils.dart';
import 'package:flutter/material.dart';
import 'package:lemon_engine/game.dart';
import 'package:lemon_engine/state/screen.dart';
import 'package:lemon_watch/watch_builder.dart';

import 'enums.dart';
import 'state.dart';


class EditorBuild {

  final _buttonWidth = 230.0;
  final _highlight = colours.purple;

  EditorState get state => editor.state;

  Widget buildEditorUI() {
    print('editor.build.buildEditorUI()');

    return WatchBuilder(editor.state.process, (String process){
      if (process.isNotEmpty){
        return buildDialog(
            width: style.dialogWidthMedium,
            height: style.dialogHeightMedium,
            child: Center(child: text(process))
        );
      }

      return layout(
          topLeft: _toolTabs(),
          topRight: _mainMenu(),
          child: _buildEditorDialog()
      );
    });
  }

  Widget _mainMenu() {
    return Row(
          children: [
            buttonClear(),
            width16,
            buttonLoad(),
            width16,
            buttonSave(),
            width16,
            buttonExit(),
          ],
        );
  }


  List<Widget> buildTabEnvironmentObjects() {
    return ObjectType.values.map(buildEnvironmentType).toList();
  }

  List<Widget> buildTabTiles() {
    return Tile.values.map((tile) {
      return WatchBuilder(state.tile, (Tile selected) {
        return button(enumString(tile), () {
          state.tile.value = tile;
        },
            width: _buttonWidth,
            alignment: Alignment.centerLeft,
            fillColor: selected == tile ? _highlight : colours.transparent);
      });
    }).toList();
  }

  List<Widget> buildObjectList() {
    return game.environmentObjects.map((env) {
      return NullableWatchBuilder<EnvironmentObject?>(editor.state.selectedObject,
              (EnvironmentObject? selected) {
            return button(enumString(env.type), () {
              editor.state.selectedObject.value = env;
              cameraCenter(env.x, env.y);
              redrawCanvas();
            }, fillColor: env == selected ? _highlight : colours.transparent,
              width: style.buttonWidth,
            );
          });
    }).toList();
  }

  List<Widget> _buildTabMisc() {
    return [
      button("Copy to Clipboard", copyCompiledGameToClipboard),
      button("Tiles.X++", () {
        for (List<Tile> row in game.tiles) {
          row.add(Tile.Grass);
        }
        mapTilesToSrcAndDst();
      }),
      button("Tiles.Y++", () {
        List<Tile> row = [];
        for (int i = 0; i < game.tiles[0].length; i++) {
          row.add(Tile.Grass);
        }
        game.tiles.add(row);
        mapTilesToSrcAndDst();
      }),
      if (game.tiles.length > 2)
        button("Tiles.X--", () {
          game.tiles.removeLast();
          mapTilesToSrcAndDst();
        }),
      if (game.tiles[0].length > 2)
        button("Tiles.Y--", () {
          for (int i = 0; i < game.tiles.length; i++) {
            game.tiles[i].removeLast();
          }
          mapTilesToSrcAndDst();
        }),
    ];
  }

  Widget buttonClear() => text("Clear", onPressed: editor.actions.resetTiles);

  Widget buttonLoad() => text("Load", onPressed: actions.showEditorDialogLoadMap);

  Widget buttonSave() => text("Save", onPressed: actions.showEditorDialogSave);

  Widget _buildEditorDialog(){
    return WatchBuilder(editor.state.dialog, (EditorDialog dialog){
      print("buildEditorDialog($dialog)");
      switch(dialog){
        case EditorDialog.None:
          return empty;
        case EditorDialog.Load:
          return buildEditorDialogLoadMaps();
        case EditorDialog.Save:
          return buildEditorDialogSaveMap();
        case EditorDialog.Loading_Map:
          return buildDialogMessage("Loading Map");
      }
    });
  }

  Widget _buildTabs(ToolTab activeTab) {
    return Row(
      children: ToolTab.values.map((tab) {
        bool active = tab == activeTab;

        return button(
          enumString(tab),
              () {
            editor.state.tab.value = tab;
          },
          fillColor: active ? colours.purpleDarkest : Colors.transparent,
        );
      }).toList(),
      mainAxisAlignment: axis.main.even,
    );
  }

  List<Widget> _getTabChildren(ToolTab tab) {
    switch (tab) {
      case ToolTab.Tiles:
        return buildTabTiles();
      case ToolTab.Objects:
        return buildTabEnvironmentObjects();
      case ToolTab.All:
        return editor.build.buildObjectList();
      case ToolTab.Misc:
        return _buildTabMisc();
    }
  }

  Widget buttonExit(){
    return buildButton("Exit", actions.setModePlay);
  }

  Widget buildEnvironmentType(ObjectType type) {
    return WatchBuilder(editor.state.objectType, (ObjectType selected) {
      return button(parseEnvironmentObjectTypeToString(type), () {
        editor.state.objectType.value = type;
      },
          fillColor: type == selected ? colours.purple : colours.transparent,
          width: 200,
          alignment: Alignment.centerLeft);
    });
  }

  Widget buildEditorDialogSaveMap(){
    return buildDialog(
        width: style.dialogWidthMedium,
        height: style.dialogHeightMedium,
        child: Column(children: [
          TextField(controller: state.mapNameController),
        ],),
        bottomRight: buildButton('save', editor.actions.saveMapToFirestore)
    );
  }

  Widget _toolTabs(){
    return Builder(builder: (BuildContext context) {
      return WatchBuilder(state.tab, (ToolTab tab) {
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
  }

  FutureBuilder<List<String>> buildEditorDialogLoadMaps() {
    return FutureBuilder<List<String>>(
      future: firestoreService.getMapNames(),
      builder: (context, response){
        if (response.connectionState == ConnectionState.waiting){
          return buildDialogMessage("Loading Maps");
        }
        if (response.hasError){
          editor.actions.showErrorMessage(response.error.toString());
          editor.actions.closeDialog();
          return empty;
        }

        final mapNames = response.data;
        if (mapNames == null){
          return buildDialogMessage("no maps found");
        }
        return buildDialog(
          height: style.dialogHeightLarge,
          width: style.dialogWidthMedium,
          child: SingleChildScrollView(
            child: Column(
                crossAxisAlignment: axis.cross.start,
                children: mapNames.map((name){
                  return button(name, () async {
                    editor.actions.loadMapFromFirestore(name);
                  },
                    borderColor: none,
                    borderColorMouseOver: colours.white80,
                    fillColor: none,
                    fillColorMouseOver: none,
                  );
                }).toList()),
          ),
          bottomRight: buildButton("Close", editor.actions.closeDialog, underline: true),
        );
      },
    );
  }
}



