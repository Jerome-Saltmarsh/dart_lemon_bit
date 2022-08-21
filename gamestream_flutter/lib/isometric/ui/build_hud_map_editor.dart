import 'package:bleed_common/library.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/isometric/classes/node.dart';
import 'package:gamestream_flutter/isometric/edit_state.dart';
import 'package:gamestream_flutter/isometric/grid.dart';
import 'package:gamestream_flutter/isometric/grid/state/wind.dart';
import 'package:gamestream_flutter/isometric/light_mode.dart';
import 'package:gamestream_flutter/isometric/play_mode.dart';
import 'package:gamestream_flutter/isometric/player.dart';
import 'package:gamestream_flutter/isometric/render/render_sprites.dart';
import 'package:gamestream_flutter/isometric/time.dart';
import 'package:gamestream_flutter/isometric/ui/buttons/build_atlas_button.dart';
import 'package:gamestream_flutter/isometric/ui/widgets/build_container.dart';
import 'package:gamestream_flutter/isometric/watches/lightning.dart';
import 'package:gamestream_flutter/isometric/watches/rain.dart';
import 'package:gamestream_flutter/isometric/weather/breeze.dart';
import 'package:gamestream_flutter/isometric/weather/time_passing.dart';
import 'package:gamestream_flutter/network/send_client_request.dart';
import 'package:gamestream_flutter/ui/builders/build_layout.dart';
import 'package:gamestream_flutter/utils/widget_utils.dart';
import 'package:lemon_engine/render.dart';
import 'package:lemon_watch/watch.dart';
import 'package:lemon_watch/watch_builder.dart';

import 'constants/colors.dart';

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
  const totalWidth = 200.0;
  final segments = windValues.length;
  final segmentWidth = totalWidth / segments;
  return watch(windAmbient, (Wind wind) {
    final list = <Widget>[];
    for (var i = 0; i < segments; i++) {
      final active = wind.index >= i;
      final value = windValues[i];
      list.add(
          onMouseOver(
            builder: (context, mouseOver) {
              return container(
                  width: segmentWidth,
                  height: 50,
                  color: mouseOver ? greyDarkDark : active ? greyDark : grey,
                  action: () => sendClientRequestWeatherSetWind(value),
                  toolTip: value.name,
              );
            }
          )
      );
    }
    return Column(
      children: [
        container(
          child: 'Wind: ${wind.name}',
          width: totalWidth,
          color: brownLight,
        ),
        Row(
          children: list,
        ),
      ],
    );
  });
}

Widget buildToggleShadows() {
  return watch(gridShadows, (bool shadowsOn){
          return container(child: 'Shadows', action: toggleShadows, color: shadowsOn ? greyDark : grey);
        });
}

Widget buildToggleRain() {

  const totalWidth = 200.0;
  final segments = rainValues.length;
  final segmentWidth = totalWidth / segments;

  return watch(rain, (Rain rain) {
    final list = <Widget>[];
    for (var i = 0; i < segments; i++) {
      final active = rain.index >= i;
      final value = rainValues[i];
      list.add(
          container(
              width: segmentWidth,
              height: 50,
              color: active ? greyDark : grey,
              action: () => sendClientRequestWeatherSetRain(value),
              toolTip: value.name
          )
      );
    }
    return Column(
      children: [
        container(
          child: 'Rain: ${rain.name}',
          width: totalWidth,
          color: brownLight,
        ),
        Row(
          children: list,
        ),
      ],
    );
  });
}

Widget buildButtonRecenter() {
  return container(child: "Recenter", action: (){
          edit.z.value = player.indexZ;
          edit.row.value = player.indexRow;
          edit.column.value = player.indexColumn;
        });
}

Widget buildButtonLightning() {
  const totalWidth = 200.0;
  final segments = lightningValues.length;
  final segmentWidth = totalWidth / segments;

  return watch(lightning, (Lightning lightning) {
    final list = <Widget>[];
    for (var i = 0; i < segments; i++) {
      final active = lightning.index >= i;
      final value = lightningValues[i];
      list.add(
          container(
              width: segmentWidth,
              height: 50,
              color: active ? greyDark : grey,
              action: () => sendClientRequestWeatherSetLightning(value),
              toolTip: value.name
          )
      );
    }
    return Column(
      children: [
        container(
          child: 'Lightning: ${lightning.name}',
          width: totalWidth,
          color: brownLight,
        ),
        Row(
          children: list,
        ),
      ],
    );
  });
}

Widget buildButtonTimePassing() => watch(watchTimePassing, (bool timePassing){
  return container(
    child: "Time Passing",
    action: sendClientRequestWeatherToggleTimePassing,
    color: timePassing ? greyDark : grey,
  );
});

Widget buildButtonBreeze() => watch(weatherBreeze, (bool weatherBreezeOn){
  return Column(
    children: [
      container(
        child: "Breeze",
        color: brownLight,
      ),
      container(
          action: sendClientRequestWeatherToggleBreeze,
          color: weatherBreezeOn ? greyDark : grey,
      ),
    ],
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
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                timeText,
                // buildToggleTimePassing(),
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

double mapNodeTypeToMapSrcX(int type) => {
    NodeType.Empty: 7055.0,
    NodeType.Water: 7055.0,
    NodeType.Brick_2: 7104.0,
    NodeType.Grass_2: 7158.0,
    NodeType.Wood_2: 7590.0,
    NodeType.Torch: 2086.0,
}[type] ?? 0;

double mapNodeTypeToMapSrcY(int type) => {
    NodeType.Water: 73.0,
    NodeType.Torch: 64.0,
}[type] ?? 0;

double mapNodeTypeToMapSrcWidth(int type) => {
    NodeType.Torch: 25.0,
}[type] ?? 48;

double mapNodeTypeToMapSrcHeight(int type) => {

}[type] ?? 72;

Widget buildButtonSelectNodeType(int value) {

  final canvas = buildCanvasImage(
      srcX:       mapNodeTypeToMapSrcX      (value),
      srcY:       mapNodeTypeToMapSrcY      (value),
      srcWidth:   mapNodeTypeToMapSrcWidth  (value),
      srcHeight:  mapNodeTypeToMapSrcHeight (value),
  );

  return WatchBuilder(edit.selectedNode, (Node type) {
        return container(
            toolTip:
              NodeType.getName(value),
            child:
              canvas,
            action: () {
              if (modeIsPlay){
                setPlayModeEdit();
                edit.column.value = player.indexColumn;
                edit.row.value = player.indexRow;
                edit.z.value = player.indexZ;
                return;
              }
              edit.paint(value: value);
            },
            color:
              type == value
              ? greyDark
              : grey
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

const editorSelectableGridTypes = [
    NodeType.Empty,
    NodeType.Brick_Top,
    NodeType.Grass_Long,
    NodeType.Grass_Flowers,
    NodeType.Torch,
    NodeType.Fireplace,
    NodeType.Water,
    NodeType.Water_Flowing,
    NodeType.Tree_Top,
    NodeType.Tree_Bottom,
    NodeType.Roof_Tile_North,
    NodeType.Roof_Tile_South,
    NodeType.Soil,
    NodeType.Roof_Hay_South,
    NodeType.Roof_Hay_North,
    NodeType.Stone,
    NodeType.Bau_Haus,
    NodeType.Bau_Haus_Window,
    NodeType.Bau_Haus_Plain,
    NodeType.Chimney,
    NodeType.Bed_Bottom,
    NodeType.Bed_Top,
    NodeType.Table,
    NodeType.Sunflower,
    NodeType.Oven,
    NodeType.Brick_2,
    NodeType.Wood_2,
    NodeType.Cottage_Roof,
    NodeType.Grass_2,
    NodeType.Plain,
    NodeType.Window,
];