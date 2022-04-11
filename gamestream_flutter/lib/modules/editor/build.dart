

import 'package:bleed_common/CharacterType.dart';
import 'package:bleed_common/ItemType.dart';
import 'package:bleed_common/enums/ObjectType.dart';
import 'package:bleed_common/enums/Shade.dart';
import 'package:firestore_client/firestoreService.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/constants/colours.dart';
import 'package:gamestream_flutter/styles.dart';
import 'package:gamestream_flutter/toString.dart';
import 'package:gamestream_flutter/ui/compose/hudUI.dart';
import 'package:gamestream_flutter/ui/dialogs.dart';
import 'package:gamestream_flutter/ui/style.dart';
import 'package:gamestream_flutter/utils.dart';
import 'package:golden_ratio/constants.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_math/Vector2.dart';
import 'package:lemon_watch/watch_builder.dart';

import '../../flutterkit.dart';
import '../../ui/views.dart';
import '../modules.dart';
import 'enums.dart';
import 'state.dart';


class EditorBuild {

  final _buttonWidth = 230.0;
  final _highlight = colours.purple;

  EditorState get state => editor.state;

  Widget buildEditorUI() {
    print('editor.build.buildEditorUI()');
    return layout(
        topLeft: _toolTabs(),
        topRight: _mainMenu(),
        bottomRight: _buildSelected(),
        child: _buildEditorDialog()
    );
  }



  Widget _mainMenu() {
    return margin(
      top: 16,
      right: 16,
      child: Row(
            children: [
              _buttonPlay(),
              width16,
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
    // return Tile.values.map((tile) {
    //   return WatchBuilder(state.tile, (Tile selected) {
    //     return button(enumString(tile), () {
    //       state.tile.value = tile;
    //     },
    //         width: _buttonWidth,
    //         alignment: Alignment.centerLeft,
    //         fillColor: selected == tile ? _highlight : colours.transparent);
    //   });
    // }).toList();
    return [];
  }

  List<Widget> _tabAll() {
    return modules.isometric.environmentObjects.map((env) {
      return WatchBuilder(editor.state.selected, (Vector2? selected) {
            return button(enumString(env.type), () {
              editor.state.selected.value = env;
              engine.cameraCenter(env.x, env.y);
              engine.redrawCanvas();
            }, fillColor: env == selected ? _highlight : colours.transparent,
              width: style.buttonWidth,
            );
          });
    }).toList();
  }

  List<Widget> _tabMisc() {

    final _textWidth = 150.0;

    return [
      Row(
        children: [
          Container(
            width: _textWidth,
            child: WatchBuilder(modules.isometric.totalRows, (int total){
              return text("Rows $total");
            }),
          ),
          button("-", isometric.removeRow),
          button("+", isometric.addRow)
        ],
      ),
      Row(
        children: [
            Container(
              width: _textWidth,
              child: WatchBuilder(modules.isometric.totalColumns, (int total){
                 return text("Columns $total");
              }),
            ),
            button("-", isometric.removeColumn),
            button("+", isometric.addColumn)
        ],
      ),
      Row(
        children: [
          text("Hour "),
          WatchBuilder(modules.isometric.hours, (int hours){
            return text(hours);
          }),
          width8,
          button("-", modules.isometric.detractHour),
          width8,
          button("+", modules.isometric.addHour),
          width8,
        ],
      ),
        WatchBuilder(modules.isometric.ambient, (int ambient){
      return text(shadeName(ambient));
        }),
      Row(children: [
        Container(
          width: _textWidth,
          child: WatchBuilder(modules.editor.state.timeSpeed, (TimeSpeed timeSpeed){
            return text("Time Speed ${timeSpeed.name}");
          }),
        ),
        width8,
        button("-", modules.editor.actions.timeSpeedDecrease),
        width8,
        button("+", modules.editor.actions.timeSpeedIncrease),
        ],
      ),
      height8,
      WatchBuilder(state.teamType, (TeamType teamType) {
        return Row(
          children: [
            onPressed(
              callback: () => state.teamType.value = TeamType.Solo,
              child: Container(
                  color: teamType == TeamType.Solo ? colours.purple : colours.purpleDarkest,
                  width: 120,
                  alignment: Alignment.center,
                  height: 100 * goldenRatio_0381,
                  child: text(TeamType.Solo.name, color: teamType == TeamType.Solo ? colours.white : colours.white618)
              ),
            ),
            onPressed(
              callback: () => state.teamType.value = TeamType.Teams,
              child: Container(
                  color: teamType == TeamType.Teams ? colours.purple : colours.purpleDarkest,
                  width: 120,
                  alignment: Alignment.center,
                  height: 100 * goldenRatio_0381,
                  child: text(TeamType.Teams.name, color: teamType == TeamType.Teams ? colours.white : colours.white618)
              ),
            )
          ],
        );
      }),
    ];
  }

  Widget _buttonPlay() => text("Play", onPressed: editor.actions.play);

  Widget _buttonClear() => text("Clear", onPressed: editor.actions.clear);

  Widget _buttonLoad() => text("Load", onPressed: editor.actions.showDialogLoadMap);

  Widget _buttonSave() => text("Save", onPressed: editor.actions.showDialogSave);

  Widget _buttonExit() => text("Exit", onPressed: core.actions.setModeWebsite);

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
      case ToolTab.Items:
        return _tabItems();
    }
  }

  List<Widget> _tabItems(){
     return itemTypes.map((itemType){
       return WatchBuilder(state.itemType, (selectedItemType){
         return tabButton(
            enumString(itemType), (){
              state.itemType.value = itemType;
         }, itemType == selectedItemType
         );
       });
     }).toList();
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

  Widget tabButton(String value, Function callback, bool selected){
    return button(value, callback,
        width: _buttonWidth,
        alignment: Alignment.centerLeft,
        fillColor: selected ? _highlight : colours.transparent);
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
              height: engine.screen.height - 100,
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
          core.actions.setError(response.error.toString());
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
                    editor.actions.loadMap(name);
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

  Widget _buildSelected() {
    return WatchBuilder(state.selected, (Vector2? selected){
        if (selected == null) return empty;

        return Container(
            color: colours.white618,
            width: style.dialogHeightMedium,
            height: style.dialogWidthSmall,
            padding: padding16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                text("Position ${selected.x.toInt()} ${selected.y.toInt()}"),
                text("Snap To Grid", onPressed: (){
                  snapToGrid(selected);
                })
            ],),
        );
    });
  }
}



