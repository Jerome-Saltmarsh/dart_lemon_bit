import 'package:bleed_common/grid_node_type.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/edit_state.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/game.dart';
import 'package:gamestream_flutter/hud/hud_state.dart';
import 'package:gamestream_flutter/isometric/mouse.dart';
import 'package:gamestream_flutter/send.dart';
import 'package:gamestream_flutter/state/grid.dart';
import 'package:gamestream_flutter/state/light_mode.dart';
import 'package:gamestream_flutter/ui/builders/build_layout.dart';
import 'package:gamestream_flutter/ui/builders/build_panel_menu.dart';
import 'package:lemon_watch/watch_builder.dart';

import 'build_column_set_weapon.dart';
import 'player.dart';

Widget buildHudMapEditor() {
  return Stack(
    children: [
      Positioned(
        top: 0,
        left: 0,
        child: visibleBuilder(hud.editToolsEnabled, buildPanelEditor()),
      ),
      Positioned(
          top: 0,
          right: 0,
          child: buildPanelMenu()
      ),
      Positioned(
        bottom: 0,
        right: 0,
        child: visibleBuilder(hud.editToolsEnabled, buildColumnSetWeapon()),
      ),
    ],
  );
}

Widget buildPanelEditor(){
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // _buildContainerMouseInfo(),
      // _buildContainerPlayerInfo(),
      buildColumnEditTile(),
      _button("Recenter", (){
         edit.z = player.indexZ;
         edit.row = player.indexRow;
         edit.column = player.indexColumn;
      }),
      watch(gridShadows, (bool shadowsOn){
        return _button("Shadows: $shadowsOn", (){
          gridShadows.value = !gridShadows.value;
        });
      }),
      _buildControlLightMode(),
      _buildControlTime(),
      height8,
    ],
  );
}

Widget _buildControlLightMode(){
  return onPressed(
    callback: () => lightModeRadial.value = !lightModeRadial.value,
    child: Container(
        height: 50,
        width: 200,
        alignment: Alignment.centerLeft,
        color: Colors.grey,
        child: watch(lightModeRadial, (bool radial){
           return text(radial ? 'Radial' : "Square");
        })
    ),
  );
}

Widget _buildContainerMouseInfo(){
  return Refresh(() {
     return Container(
       height: 50,
       alignment: Alignment.centerLeft,
       color: Colors.grey,
       child: text("Mouse gridX: ${mouseGridX.toInt()}, gridY: ${mouseGridY.toInt()}, Angle: ${mousePlayerAngle.toStringAsFixed(1)}"),
     );
});
}

Widget _buildContainerPlayerInfo(){
  return Refresh((){
    return Container(
        height: 50,
        alignment: Alignment.centerLeft,
        color: Colors.grey,
        child: text("Player zIndex: ${player.indexZ}, row: ${player.indexRow}, column: ${player.indexColumn}, x: ${player.x}, y: ${player.y}, z: ${player.z}, renderX: ${player.renderX}, renderY: ${player.renderY}, angle: ${player.angle}, mouseAngle: ${player.mouseAngle}",));
  });
}

Widget _buildControlTime() {
  return Container(
          height: 50,
          width: 200,
          color: Colors.grey,
          child: Row(
            children: [
              text("Time: "),
              watch(game.hours, (num hour) => text(padZero(hour))),
              text(":"),
              watch(game.minutes, (num hour) => text(padZero(hour))),
              Expanded(child: Container()),
              onPressed(
                child: Container(
                  width: 30,
                  height: 30,
                  color: Colors.black26,
                  alignment: Alignment.center,
                  child: text("-"),
                ),
                callback: sendClientRequestReverseHour
              ),
              width2,
              onPressed(
                  child: Container(
                    width: 30,
                    height: 30,
                    color: Colors.black26,
                    alignment: Alignment.center,
                    child: text("+"),
                  ),
                  callback: sendClientRequestSkipHour
              ),
              width4,
            ],
          ),
        );
}

Widget _buildTabObjects(){
  return text('objects');
}

Widget buildColumnEditTile(){
  return Column(
    children: [
      _buildSetType(GridNodeType.Empty, "Empty"),
      _buildSetType(GridNodeType.Bricks, "Bricks"),
      _buildSetType(GridNodeType.Grass, "Grass"),
      _buildSetType(GridNodeType.Stairs_North, "Stairs North"),
      _buildSetType(GridNodeType.Stairs_West, "Stairs West"),
      _buildSetType(GridNodeType.Stairs_South, "Stairs South"),
      _buildSetType(GridNodeType.Stairs_East, "Stairs East"),
      _buildSetType(GridNodeType.Water, "Water"),
      _buildSetType(GridNodeType.Torch, "Torch"),
      _buildSetType(GridNodeType.Tree, "Tree"),
      _buildSetType(GridNodeType.Player_Spawn, "Player Spawn"),
      _button("Zombie", () {
        sendClientRequestSpawnZombie(
          z: edit.z,
          row: edit.row,
          column: edit.column,
        );
      }),
    ],
  );
}

Widget _buildSetType(int value, String name) {
  return WatchBuilder(edit.type, (int type) {
        return _button(name, () => edit.setBlockType(value),color: type == value ? Colors.green : Colors.grey
    );
  });
}

Widget _button(String value, Function action, {Color? color}){
  return onPressed(
    callback: action,
    child: Container(
      width: 200,
      height: 50,
      padding: const EdgeInsets.only(left: 6),
      color: color ?? Colors.grey,
      alignment: Alignment.centerLeft,
      child: text(value),
    ),
  );
}

