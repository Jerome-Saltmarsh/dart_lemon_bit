

import 'package:bleed_client/actions.dart';
import 'package:bleed_client/common/CharacterType.dart';
import 'package:bleed_client/common/Tile.dart';
import 'package:bleed_client/common/enums/ObjectType.dart';
import 'package:bleed_client/constants/colours.dart';
import 'package:bleed_client/flutterkit.dart';
import 'package:bleed_client/modules/modules.dart';
import 'package:bleed_client/styles.dart';
import 'package:bleed_client/toString.dart';
import 'package:bleed_client/ui/compose/hudUI.dart';
import 'package:bleed_client/ui/dialogs.dart';
import 'package:bleed_client/ui/style.dart';
import 'package:bleed_client/ui/views.dart';
import 'package:bleed_client/user-service-client/firestoreService.dart';
import 'package:bleed_client/utils.dart';
import 'package:flutter/material.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_math/Vector2.dart';
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
    return margin(
      top: 16,
      right: 16,
      child: Row(
            children: [
              _buttonClear(),
              width16,
              _buttonLoad(),
              width16,
              _buttonSave(),
              width16,
              _buttonExit(),
            ],
          ),
    );
  }


  List<Widget> _tabObjects() {
    return ObjectType.values.map(buildEnvironmentType).toList();
  }

  List<Widget> _tabTiles() {
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

  List<Widget> _tabAll() {
    return modules.isometric.state.environmentObjects.map((env) {
      return NullableWatchBuilder<Vector2?>(editor.state.selected,
              (Vector2? selected) {
            return button(enumString(env.type), () {
              editor.state.selected.value = env;
              cameraCenter(env.x, env.y);
              engine.actions.redrawCanvas();
            }, fillColor: env == selected ? _highlight : colours.transparent,
              width: style.buttonWidth,
            );
          });
    }).toList();
  }

  List<Widget> _tabMisc() {
    return [
      // button("Copy to Clipboard", copyCompiledGameToClipboard, width: _width),
      Row(
        children: [
          WatchBuilder(modules.isometric.state.totalRows, (int total){
            return text("Rows $total");
          }),
          button("-", isometric.actions.removeRow),
          button("+", isometric.actions.addRow)
        ],
      ),
      Row(
        children: [
            WatchBuilder(modules.isometric.state.totalColumns, (int total){
               return text("Columns $total");
            }),
            button("-", isometric.actions.removeColumn),
            button("+", isometric.actions.addColumn)
        ],
      ),
      Row(children: [
         text("Start Hour:"),
          width8,
          WatchBuilder(modules.isometric.state.time, (int value){
            return text(modules.game.properties.timeInHours);
          }),
        width8,
        button("-", (){
          modules.isometric.state.time.value -= (60 * 60);
        }),
        width8,
        button("+", (){
          modules.isometric.state.time.value += (60 * 60);
        }),
      ],)
    ];
  }

  Widget _buttonClear() => text("Clear", onPressed: editor.actions.clear);

  Widget _buttonLoad() => text("Load", onPressed: editor.actions.showDialogLoadMap);

  Widget _buttonSave() => text("Save", onPressed: editor.actions.showDialogSave);

  Widget _buttonExit() => text("Exit", onPressed: actions.setModePlay);

  Widget _buildEditorDialog(){
    return WatchBuilder(editor.state.dialog, (EditorDialog dialog){
      print("buildEditorDialog($dialog)");
      switch(dialog){
        case EditorDialog.None:
          return empty;
        case EditorDialog.Load:
          return buildEditorDialogLoadMaps();
        case EditorDialog.Save:
          return _dialogSaveMap();
        case EditorDialog.Loading_Map:
          return buildDialogMessage("Loading Map");
      }
    });
  }

  Widget _buildTabs(ToolTab toolTab) {
    return Row(
      children: ToolTab.values.map((tab) {
        bool active = tab == toolTab;

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

  List<Widget> _toolTab(ToolTab toolTab) {
    switch (toolTab) {
      case ToolTab.Tiles:
        return _tabTiles();
      case ToolTab.Objects:
        return _tabObjects();
      case ToolTab.All:
        return _tabAll();
      case ToolTab.Misc:
        return _tabMisc();
      case ToolTab.Units:
        return _tabUnits();
    }
  }

  List<Widget> _tabUnits() {
    return characterTypes.map((unit) {
      return WatchBuilder(state.characterType, (selected) {
        return button(enumString(unit), () {
          state.characterType.value = unit;
        },
            width: _buttonWidth,
            alignment: Alignment.centerLeft,
            fillColor: selected == unit ? _highlight : colours.transparent);
      });
    }).toList();
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

  Widget _dialogSaveMap(){
    return buildDialog(
        width: style.dialogWidthMedium,
        height: style.dialogHeightMedium,
        child: Column(children: [
          TextField(controller: state.mapNameController),
        ],),
        bottomLeft: buildButton('cancel', editor.actions.closeDialog),
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
              height: engine.state.screen.height - 100,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: axis.cross.start,
                  children: _toolTab(tab),
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



