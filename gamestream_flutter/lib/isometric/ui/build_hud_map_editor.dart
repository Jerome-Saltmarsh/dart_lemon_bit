import 'package:bleed_common/grid_node_type.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/isometric/edit_state.dart';
import 'package:gamestream_flutter/isometric/grid.dart';
import 'package:gamestream_flutter/isometric/grid/state/wind.dart';
import 'package:gamestream_flutter/isometric/light_mode.dart';
import 'package:gamestream_flutter/isometric/play_mode.dart';
import 'package:gamestream_flutter/isometric/player.dart';
import 'package:gamestream_flutter/isometric/render/render_sprites.dart';
import 'package:gamestream_flutter/isometric/render/weather.dart';
import 'package:gamestream_flutter/isometric/time.dart';
import 'package:gamestream_flutter/isometric/ui/build_container.dart';
import 'package:gamestream_flutter/isometric/weather/breeze.dart';
import 'package:gamestream_flutter/isometric/weather/lightning.dart';
import 'package:gamestream_flutter/isometric/weather/time_passing.dart';
import 'package:gamestream_flutter/network/send_client_request.dart';
import 'package:gamestream_flutter/ui/builders/build_layout.dart';
import 'package:gamestream_flutter/ui/builders/build_panel_menu.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_engine/render.dart';
import 'package:lemon_engine/screen.dart';
import 'package:lemon_watch/watch.dart';
import 'package:lemon_watch/watch_builder.dart';

import 'colors.dart';

Widget buildHudMapEditor(){
  return Stack(
    children: [
      // Positioned(top: 0, right: 0, child: buildPanelMenu()),
      Positioned(top: 0, left: 0, child: buildColumnEditTile()),
      Positioned(right: 0, child: Container(
          height: screen.height,
          alignment: Alignment.center,
          child: buildPanelMaxZRender())),
    ],
  );
}


Widget buildPanelMaxZRender(){
  return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
     container(child: "+", action: () {
       maxZRender.value++;
     }, alignment: Alignment.center),
     container(child: watch(maxZRender, (int max){
       return text('MaxZRender: $max');
     }), alignment: Alignment.center),
    container(child: "-", action: () {
      maxZRender.value--;
    }, alignment: Alignment.center),
  ]);
}

Column buildColumnSettings(){
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
      buildToggleShadows(),
      buildToggleLightMode(),
      // buildColumnEditBlendMode(),
    ],
  );
}

final blend = Watch(renderBlendMode, onChanged: setRenderBlendMode);

Widget buildColumnEditBlendMode(){
  return watch(blend, (activeBlendMode){
    return Container(
      height: 300,
      child: SingleChildScrollView(
        child: Column(
          children: BlendMode.values.map((e) {
              return container(
                  child: e.name,
                  action: () => blend(e),
                  color: e == activeBlendMode ? green : grey,
              );
          }).toList(),
        ),
      ),
    );
  });
}

Widget buildControlsWeather() {
  return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        buildControlTime(),
        width4,
        buildToggleRain(),
        width4,
        buildButtonLightning(),
        width4,
        buildButtonBreeze(),
        width4,
        buildControlWind(),
      ],
    );
}

Widget buildControlWind(){
   return watch(windAmbient, (int value){
     return container(child: "Wind: $value", action: sendClientRequestWeatherToggleWind);
   });
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
          return container(child: 'Shadows', action: toggleShadows, color: shadowsOn ? greyDark : grey);
        });
}

Widget buildToggleRain() {
  return watch(rainingWatch, (bool isRaining){
          return container(child: 'Rain', action: sendClientRequestWeatherToggleRain, color: isRaining ? greyDark : grey);
        });
}

Widget buildButtonRecenter() {
  return container(child: "Recenter", action: (){
          edit.z.value = player.indexZ;
          edit.row.value = player.indexRow;
          edit.column.value = player.indexColumn;
        });
}

Widget buildButtonLightning() => watch(weatherLightning, (bool lightningOn){
  return container(
    child: "Lightning",
    action: sendClientRequestWeatherToggleLightning,
    color: lightningOn ? greyDark : grey,
  );
});

Widget buildButtonTimePassing() => watch(watchTimePassing, (bool timePassing){
  return container(
    child: "Time Passing",
    action: sendClientRequestWeatherToggleTimePassing,
    color: timePassing ? greyDark : grey,
  );
});

Widget buildButtonBreeze() => watch(weatherBreeze, (bool weatherBreezeOn){
  return container(
      child: "Breeze",
      action: sendClientRequestWeatherToggleBreeze,
      color: weatherBreezeOn ? greyDark : grey,
  );
});

Widget buildToggleLightMode(){
  return watch(lightModeRadial, (bool radial){
     return container(
         child: radial ? "Radial" : "Square",
         action: toggleLightMode,
     );
  });
}

Widget buildControlTime(){
  const totalWidth = 300.0;
  const buttonWidth = totalWidth / 24.0;
  final buttons = watch(hours, (int hours){
     final buttons1 = <Widget>[];
     final buttons2 = <Widget>[];

     for (var i = 0; i <= hours; i++){
        buttons1.add(
          Tooltip(
            message: i.toString(),
            child: container(
              width: buttonWidth,
              color: greyDark,
              action: () => sendClientRequestTimeSetHour(i),
            ),
          ),
        );
     }
     for (var i = hours + 1; i < 24; i++){
       buttons2.add(
         Tooltip(
           message: i.toString(),
           child: container(
             width: buttonWidth,
             color: grey,
             action: () => sendClientRequestTimeSetHour(i),
           ),
         ),
       );
     }

     return Row(
       children: [
         ...buttons1,
         ...buttons2,
       ],
     );
  });

  final timeText = Row(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      text("Time: "),
      watch(hours, (num hour) => text(padZero(hour))),
      text(":"),
      watch(minutes, (num hour) => text(padZero(hour))),
    ],
  );
  return Container(
    width: totalWidth,
    child: Column(
      children: [
        Container(
            color: brownLight,
            width: totalWidth,
            alignment: Alignment.center,
            padding: const EdgeInsets.all(8),
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                timeText,
                buildToggleTimePassing(),
              ],
            )
        ),
        buttons,
      ],
    ),
  );
}

Widget buildToggleTimePassing(){
   return watch(watchTimePassing, (bool timePassing){
       return text(
           timePassing ? "Pause" : "Resume",
           onPressed: sendClientRequestWeatherToggleTimePassing
       );
   });
}

Widget buildColumnEditTile(){
  return Container(
    height: engine.screen.height,
    child: SingleChildScrollView(
      child: Column(
        children: selectableTiles.map(buildButtonSelectGridNodeType).toList(),
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
            action: () {
              if (playModePlay){
                setPlayModeEdit();
                edit.column.value = player.indexColumn;
                edit.row.value = player.indexRow;
                edit.z.value = player.indexZ;
                return;
              }
              edit.setBlockType(value);
            },
            color:
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

const selectableTiles = [
    GridNodeType.Empty,
    GridNodeType.Stairs_North,
    GridNodeType.Stairs_East,
    GridNodeType.Stairs_South,
    GridNodeType.Stairs_West,
    GridNodeType.Bricks,
    GridNodeType.Grass,
    GridNodeType.Grass_Long,
    GridNodeType.Torch,
    GridNodeType.Fireplace,
    GridNodeType.Wood,
    GridNodeType.Water,
    // GridNodeType.,

];