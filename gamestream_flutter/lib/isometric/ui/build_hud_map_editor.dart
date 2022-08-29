import 'package:bleed_common/library.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/isometric/classes/node.dart';
import 'package:gamestream_flutter/isometric/edit_state.dart';
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
import 'package:gamestream_flutter/network/send_client_request.dart';
import 'package:gamestream_flutter/styles.dart';
import 'package:gamestream_flutter/ui/builders/build_layout.dart';
import 'package:lemon_watch/watch_builder.dart';

import 'constants/colors.dart';
import 'maps/map_node_type_to_src.dart';

Widget buildPanelMaxZRender() {
  return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    container(
        child: "+",
        action: () {
          maxZRender.value++;
        },
        alignment: Alignment.center),
    container(
        child: watch(maxZRender, (int max) {
          return text('MaxZRender: $max');
        }),
        alignment: Alignment.center),
    container(
        child: "-",
        action: () {
          maxZRender.value--;
        },
        alignment: Alignment.center),
  ]);
}

Widget buildControlsWeather() {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.end,
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
      buildControlTime(),
      width4,
      buildToggleRain(),
      width4,
      buildButtonLightning(),
      width4,
      buildControlWind(),
    ],
  );
}

Widget buildControlWind() {
  final segments = windValues.length;
  return watch(windAmbient, (Wind wind) {
    final list = <Widget>[];
    for (var i = 0; i < segments; i++) {
      final active = wind.index == i;
      final value = windValues[i];
      list.add(
          container(
            width: 50,
            height: 50,
            alignment: Alignment.center,
            child: buildIconWind(value, active),
            action: () => sendClientRequestWeatherSetWind(value),
            toolTip: 'Wind ${value.name}',
          )
      );
    }
    return Row(children: list);
  });
}

Widget buildIconRain(Rain rain, bool active) {
  return buildCanvasImage(
    srcX: active ? 4352 : 4287,
    srcY: 64.0 * rain.index,
    srcWidth: 64.0,
    srcHeight: 64.0,
    scale: 50 / 64.0,
  );
}

Widget buildIconLightning(Lightning lightning, bool active) {
  return buildCanvasImage(
    srcX: active ? 4352 : 4287,
    srcY:
        lightning == Lightning.Off ? 0 : (64.0 * 2) + (64.0 * lightning.index),
    srcWidth: 64.0,
    srcHeight: 64.0,
    scale: 50 / 64.0,
  );
}

Widget buildIconWind(Wind wind, bool active) {
  return buildIconWeather([0.0, 320.0, 384.0][wind.index], active);
}

Widget buildIconWeather(double srcY, bool active) {
  return buildCanvasImage(
    srcX: active ? 4352 : 4287,
    srcY: srcY,
    srcWidth: 64.0,
    srcHeight: 64.0,
    scale: 50 / 64.0,
  );
}

Widget buildToggleRain() {
  final segments = rainValues.length;

  return watch(rain, (Rain rain) {
    final list = <Widget>[];
    for (var i = 0; i < segments; i++) {
      final active = rain.index == i;
      final value = rainValues[i];
      list.add(
        onPressed(
          child: Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            child: buildIconRain(value, active),
            decoration: BoxDecoration(
              border: Border.all(color: active ? purple3 : purple5, width: 2),
              borderRadius: borderRadius2,
            ),
            margin: const EdgeInsets.only(right: 2),
          ),
          callback: () => sendClientRequestWeatherSetRain(value),
          hint: 'Rain ${value.name}',
        ),
      );
    }
    return Row(
      children: list,
    );
  });
}

Widget buildButtonRecenter() {
  return container(
      child: "Recenter",
      action: () {
        edit.z.value = player.indexZ;
        edit.row.value = player.indexRow;
        edit.column.value = player.indexColumn;
      });
}

Widget buildButtonLightning() {
  final segments = lightningValues.length;
  return watch(lightning, (Lightning lightning) {
    final list = <Widget>[];
    for (var i = 0; i < segments; i++) {
      final active = lightning.index == i;
      final value = lightningValues[i];
      list.add(
          container(
            action: () => sendClientRequestWeatherSetLightning(value),
            toolTip: "Lightning ${value.name}",
            width: 50,
            height: 50,
            alignment: Alignment.center,
            child: buildIconLightning(value, active),
          )
      );
    }
    return Row(
      children: list,
    );
  });
}

Widget buildButtonBreeze() => watch(weatherBreeze, (bool weatherBreezeOn) {
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

Widget buildToggleLightMode() {
  return watch(lightModeRadial, (bool radial) {
    return container(
      child: radial ? "Radial" : "Square",
      action: toggleLightMode,
    );
  });
}

Widget buildControlTime() {
  const totalWidth = 300.0;
  const buttonWidth = totalWidth / 24.0;
  final buttons = watch(hours, (int hours) {
    final buttons1 = <Widget>[];
    final buttons2 = <Widget>[];

    for (var i = 0; i <= hours; i++) {
      buttons1.add(
        Tooltip(
          message: i.toString(),
          child: container(
            width: buttonWidth,
            color: purple4,
            action: () => sendClientRequestTimeSetHour(i),
          ),
        ),
      );
    }
    for (var i = hours + 1; i < 24; i++) {
      buttons2.add(
        Tooltip(
          message: i.toString(),
          child: container(
            width: buttonWidth,
            color: purple3,
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
      watch(hours, (num hour) => text(padZero(hour))),
      text(":"),
      watch(minutes, (num hour) => text(padZero(hour))),
    ],
  );
  return Container(
    child: Row(
      children: [
        Container(
            color: brownLight,
            alignment: Alignment.center,
            padding: const EdgeInsets.all(8),
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                timeText,
              ],
            )),
        buttons,
      ],
    ),
  );
}

Widget buildIconNodeType(int value){
  return buildCanvasImage(
    srcX: mapNodeTypeToSrcX(value),
    srcY: mapNodeTypeToSrcY(value),
    srcWidth: mapNodeTypeToSrcWidth(value),
    srcHeight: mapNodeTypeToSrcHeight(value),
  );
}

Widget buildButtonSelectNodeType(int value) {
  final canvas = buildCanvasImage(
    srcX: mapNodeTypeToSrcX(value),
    srcY: mapNodeTypeToSrcY(value),
    srcWidth: mapNodeTypeToSrcWidth(value),
    srcHeight: mapNodeTypeToSrcHeight(value),
  );
  return WatchBuilder(edit.selectedNode, (Node node) {
    return container(
        height: 78,
        width: 78,
        alignment: Alignment.center,
        child: canvas,
        action: () {
          if (modeIsPlay) {
            setPlayModeEdit();
            edit.column.value = player.indexColumn;
            edit.row.value = player.indexRow;
            edit.z.value = player.indexZ;
            return;
          }
          edit.paint(value: value);
        },
        color: node.type == value ? greyDark : grey);
  });
}

Widget buildColumnEdit() {
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
      watch(edit.z, (int z) {
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

const editorGridTypesColumn1 = [
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
  NodeType.Soil,
  NodeType.Stone,
  NodeType.Bau_Haus_2,
];

const editorGridTypesColumn2 = [
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
  NodeType.Wooden_Plank
];
