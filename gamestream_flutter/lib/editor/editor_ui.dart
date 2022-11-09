

import 'package:flutter/material.dart';
import 'package:gamestream_flutter/isometric/ui/constants/colors.dart';
import 'package:gamestream_flutter/isometric/ui/widgets/build_container.dart';
import 'package:gamestream_flutter/library.dart';
import 'package:gamestream_flutter/ui/builders/build_layout.dart';

class EditorUI {
  static Widget buildPanelMaxZRender() {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      container(
          child: "+",
          action: () {
            GameRender.maxZRender.value++;
          },
          alignment: Alignment.center),
      container(
          child: watch(GameRender.maxZRender, (int max) {
            return text('MaxZRender: $max');
          }),
          alignment: Alignment.center),
      container(
          child: "-",
          action: () {
            GameRender.maxZRender.value--;
          },
          alignment: Alignment.center),
    ]);
  }

  static Widget buildControlsWeather() =>
      Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          buildControlTime(),
          width2,
          buildToggleRain(),
          width2,
          buildButtonLightning(),
          width2,
          buildControlWind(),
        ],
      );

  static Widget buildControlWind() {
    final segments = windValues.length;
    return watch(GameState.windAmbient, (Wind wind) {
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
              action: () => GameNetwork.sendClientRequestWeatherSetWind(value),
              toolTip: 'Wind ${value.name}',
            )
        );
      }
      return Row(children: list);
    });
  }

  // TODO Fix active
  static Widget buildIconRain(Rain rain, bool active) {
    switch (rain) {
      case Rain.None:
        return GameUI.buildAtlasIconType(IconType.Rain_None);
      case Rain.Light:
        return GameUI.buildAtlasIconType(IconType.Rain_Light);
      case Rain.Heavy:
        return GameUI.buildAtlasIconType(IconType.Rain_Heavy);
    }
  }

  // TODO Fix active
  static Widget buildIconLightning(Lightning lightning, bool active) {
    switch (lightning) {
      case Lightning.Off:
        return GameUI.buildAtlasIconType(IconType.Lightning_Off);
      case Lightning.Nearby:
        return GameUI.buildAtlasIconType(IconType.Lightning_Nearby);
      case Lightning.On:
        return GameUI.buildAtlasIconType(IconType.Lightning_On);
    }
  }

  static Widget buildIconWind(Wind wind, bool active) {
    switch (wind) {
      case Wind.Calm:
        return GameUI.buildAtlasIconType(IconType.Wind_Calm);
      case Wind.Gentle:
        return GameUI.buildAtlasIconType(IconType.Wind_Gentle);
      case Wind.Strong:
        return GameUI.buildAtlasIconType(IconType.Wind_Strong);
    }
  }

  static Widget buildToggleRain() {
    final segments = rainValues.length;

    return watch(GameState.rain, (Rain rain) {
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
            action: () => GameNetwork.sendClientRequestWeatherSetRain(value),
            hint: 'Rain ${value.name}',
          ),
        );
      }
      return Row(
        children: list,
      );
    });
  }

  static Widget buildButtonLightning() {
    final segments = lightningValues.length;
    return watch(GameState.lightning, (Lightning lightning) {
      final list = <Widget>[];
      for (var i = 0; i < segments; i++) {
        final active = lightning.index == i;
        final value = lightningValues[i];
        list.add(
            container(
              action: () => GameNetwork.sendClientRequestWeatherSetLightning(value),
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

  static Widget buildButtonBreeze() => watch(GameState.weatherBreeze, (bool weatherBreezeOn) {
    return Column(
      children: [
        container(
          child: "Breeze",
          color: brownLight,
        ),
        container(
          action: GameNetwork.sendClientRequestWeatherToggleBreeze,
          color: weatherBreezeOn ? greyDark : grey,
        ),
      ],
    );
  });

  static Widget buildControlTime() {
    const totalWidth = 300.0;
    const buttonWidth = totalWidth / 24.0;
    final buttons = watch(GameState.hours, (int hours) {
      final buttons1 = <Widget>[];
      final buttons2 = <Widget>[];

      for (var i = 0; i <= hours; i++) {
        buttons1.add(
          Tooltip(
            message: i.toString(),
            child: container(
              width: buttonWidth,
              color: purple4,
              action: () => GameNetwork.sendClientRequestTimeSetHour(i),
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
              action: () => GameNetwork.sendClientRequestTimeSetHour(i),
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
        watch(GameState.hours, (num hour) => text(padZero(hour))),
        text(":"),
        watch(GameState.minutes, (num hour) => text(padZero(hour))),
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

  // static Widget buildIconNodeType(int nodeType) =>
  //     Engine.buildAtlasImage(
  //       image: GameImages.atlasNodes,
  //       srcX: AtlasNodeX.mapNodeType(nodeType),
  //       srcY: AtlasNodeY.mapNodeType(nodeType),
  //       srcWidth: AtlasNodeWidth.mapNodeType(nodeType),
  //       srcHeight: AtlasNodeHeight.mapNodeType(nodeType),
  //     );

  static Widget buildButtonSelectNodeType(int nodeType) {
    final canvas = Engine.buildAtlasImage(
      image: GameImages.atlasNodes,
      srcX: AtlasNodeX.mapNodeType(nodeType),
      srcY: AtlasNodeY.mapNodeType(nodeType),
      srcWidth: AtlasNodeWidth.mapNodeType(nodeType),
      srcHeight: AtlasNodeHeight.mapNodeType(nodeType),
    );
    return WatchBuilder(GameEditor.nodeSelectedType, (int selectedNodeType) {
      return container(
          height: 78,
          width: 78,
          alignment: Alignment.center,
          child: Tooltip(child: canvas, message: NodeType.getName(nodeType),),
          action: () {
            if (GameState.playMode) {
              GameActions.actionSetModePlay();
              return;
            }
            GameEditor.paint(nodeType: nodeType);
          },
          color: selectedNodeType == nodeType ? greyDark : grey);
    });
  }
}