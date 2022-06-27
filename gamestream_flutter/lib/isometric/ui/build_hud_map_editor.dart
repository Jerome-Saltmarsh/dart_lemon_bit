import 'package:bleed_common/grid_node_type.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/isometric/edit_state.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/isometric/grid.dart';
import 'package:gamestream_flutter/isometric/light_mode.dart';
import 'package:gamestream_flutter/isometric/player.dart';
import 'package:gamestream_flutter/isometric/render/weather.dart';
import 'package:gamestream_flutter/isometric/time.dart';
import 'package:gamestream_flutter/client_request_sender.dart';
import 'package:gamestream_flutter/isometric/ui/build_container.dart';
import 'package:gamestream_flutter/ui/builders/build_layout.dart';
import 'package:gamestream_flutter/ui/builders/build_panel_menu.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_watch/watch_builder.dart';

import 'build_panel_store.dart';

Widget buildHudMapEditor(){
  return Stack(
    children: [
      Positioned(top: 0, right: 0, child: buildPanelMenu()),
      Positioned(top: 0, left: 0, child: buildEditTools()),
    ],
  );
}

Widget buildEditTools(){
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      buildColumnEditTile(),
      buildColumnSettings(),
      // buildColumnEdit(),
      // buildWatchEnemySpawn(),
    ],
  );
}

Column buildColumnSettings() {
  return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildToggleRain(),
            buildButtonRecenter(),
            buildToggleLightMode(),
            buildControlTime(),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildButtonLighning(),
            buildToggleShadows(),
          ],
        )
      ],
    );
}

Widget buildWatchEnemySpawn() {
  return watch(edit.type, (int type){
          if (type != GridNodeType.Enemy_Spawn) return const SizedBox();
          return Container(
            color: Colors.grey,
            padding: EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                text("ENEMY SPAWN"),
                text("Amount"),
                text("Health"),
              ],
            ),
          );
        });
}

Widget buildToggleShadows() {
  return watch(gridShadows, (bool shadowsOn){
          return container(child: 'Shadows', action: apiGridActionToggleShadows, color: shadowsOn ? greyDark : grey);
        });
}

Widget buildToggleRain() {
  return watch(rainingWatch, (bool isRaining){
          return container(child: 'Rain', action: toggleRaining, color: isRaining ? greyDark : grey);
        });
}

Widget buildButtonRecenter() {
  return container(child: "Recenter", action: (){
          edit.z.value = player.indexZ;
          edit.row.value = player.indexRow;
          edit.column.value = player.indexColumn;
        });
}

Widget buildButtonLighning() => container(child: "Lightning", action: actionLightningFlash);

Widget buildToggleLightMode(){
  return watch(lightModeRadial, (bool radial){
     return container(
         child: radial ? "Radial" : "Square",
         action: toggleLightMode,
     );
  });
}

Widget buildControlTime() {
  return container(child: Row(
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
  ));
}

Widget buildColumnEditTile(){
  return Container(
    height: engine.screen.height,
    child: SingleChildScrollView(
      child: Column(
        children: GridNodeType.values.map(buildButtonSelectGridNodeType).toList(),
      ),
    ),
  );
}

Widget buildButtonSpawnZombie(){
  return _button("Zombie", () {
    sendClientRequestSpawnZombie(
      z: edit.z.value,
      row: edit.row.value,
      column: edit.column.value,
    );
  });
}

Widget buildButtonSelectGridNodeType(int value) {
  return WatchBuilder(edit.type, (int type) {
        return container(
            child: GridNodeType.getName(value),
            action: () => edit.setBlockType(value),color:
              type == value
              ? Colors.green
              : Colors.grey
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