import 'package:bleed_common/grid_node_type.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/isometric/edit_state.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/isometric/grid.dart';
import 'package:gamestream_flutter/isometric/light_mode.dart';
import 'package:gamestream_flutter/isometric/player.dart';
import 'package:gamestream_flutter/isometric/time.dart';
import 'package:gamestream_flutter/isometric/utils/mouse.dart';
import 'package:gamestream_flutter/client_request_sender.dart';
import 'package:gamestream_flutter/ui/builders/build_layout.dart';
import 'package:lemon_watch/watch_builder.dart';

import 'build_column_set_weapon.dart';

Widget buildHudMapEditor() {
  return Stack(
    children: [
      Positioned(
        top: 0,
        left: 0,
        child: buildPanelEditor(),
      ),
      Positioned(
        bottom: 0,
        right: 0,
        child: buildColumnSetWeapon(),
      ),
    ],
  );
}


Widget buildPanelEditor(){
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      buildColumnEditTile(),
      buildColumnEdit(),
      _button("Recenter", (){
         edit.z.value = player.indexZ;
         edit.row.value = player.indexRow;
         edit.column.value = player.indexColumn;
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

Widget _buildControlTime() {
  return Container(
          height: 50,
          width: 200,
          color: Colors.grey,
          child: Row(
            children: [
              text("Time: "),
              watch(hours, (num hour) => text(padZero(hour))),
              text(":"),
              watch(minutes, (num hour) => text(padZero(hour))),
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

Widget buildColumnEditTile(){
  return Column(
    children: [
      _buildSetType(GridNodeType.Empty, "Empty"),
      _buildSetType(GridNodeType.Bricks, "Bricks"),
      _buildSetType(GridNodeType.Grass, "Grass"),
      _buildSetType(GridNodeType.Grass_Long, "Long Grass"),
      _buildSetType(GridNodeType.Stairs_North, "Stairs North"),
      _buildSetType(GridNodeType.Stairs_West, "Stairs West"),
      _buildSetType(GridNodeType.Stairs_South, "Stairs South"),
      _buildSetType(GridNodeType.Stairs_East, "Stairs East"),
      _buildSetType(GridNodeType.Water, "Water"),
      _buildSetType(GridNodeType.Torch, "Torch"),
      _buildSetType(GridNodeType.Tree_Top_Pine, "Tree Top Pine"),
      _buildSetType(GridNodeType.Tree_Bottom_Pine, "Tree Bottom Top"),
      _buildSetType(GridNodeType.Player_Spawn, "Player Spawn"),
      _buildSetType(GridNodeType.Wooden_Wall_Row, "Wooden Wall Row"),
      _button("Zombie", () {
        sendClientRequestSpawnZombie(
          z: edit.z.value,
          row: edit.row.value,
          column: edit.column.value,
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

Widget buildColumnEdit(){
  return Column(
      children: [
        onPressed(
          callback: editZIncrease,
          child: Container(
              alignment: Alignment.center,
              child: text("+"),
              width: 50,
              height: 50,
              color: Colors.grey,
          ),
        ),
        watch(edit.z, (int z){
           return Container(
             alignment: Alignment.center,
             child: text('Z:$z'),
             width: 50,
             height: 50,
             color: Colors.grey,
           );
        }),
        onPressed(
          callback: editZDecrease,
          child: Container(
            alignment: Alignment.center,
            child: text("-"),
            width: 50,
            height: 50,
            color: Colors.grey,
          ),
        ),
      ],
  );
}