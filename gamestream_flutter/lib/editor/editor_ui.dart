

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

  static Widget buildRowWeatherControls() =>
      Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          buildControlTime(),
          width2,
          buildRowRainIcons(),
          width2,
          buildRowLightningIcons(),
          width2,
          buildRowWindIcons(),
        ],
      );


  static Widget buildIconWeatherControl({
    required String tooltip,
    required Function action,
    required Widget icon,
    required bool isActive,
  }) => Tooltip(
      message: tooltip,
      child: Stack(
        children: [
          onPressed(
            action: isActive ? null  : action,
            child: icon,
          ),
          if (isActive)
            Container(
              width: 64,
              height: 64,
              decoration: GameUI.buildDecorationBorder(
                colorBorder: Colors.white,
                colorFill: Colors.transparent,
                width: 2,
                borderRadius: 0,
              ),
            ),
        ],
      ),
    );

  static Widget buildIconRain(Rain rain) =>
      watch(ServerState.rain, (Rain activeRain) =>
        buildIconWeatherControl(
            tooltip: '${rain.name} Rain',
            action: () => GameNetwork.sendClientRequestWeatherSetRain(rain),
            icon: GameUI.buildAtlasIconType(convertRainToIconType(rain), size: 64),
            isActive: rain == activeRain,
        )
      );

  static Widget buildIconLightning(Lightning lightning) =>
      watch(ServerState.lightning, (Lightning activeLightning) =>
          buildIconWeatherControl(
            tooltip: '${lightning.name} Lightning',
            action: () => GameNetwork.sendClientRequestWeatherSetLightning(lightning),
            icon: GameUI.buildAtlasIconType(convertLightningToIconType(lightning), size: 64),
            isActive: lightning == activeLightning,
          )
      );

  static Widget buildIconWind(Wind wind) =>
      watch(ServerState.windAmbient, (Wind active) =>
          buildIconWeatherControl(
            tooltip: '${wind.name} Wind',
            action: () => GameNetwork.sendClientRequestWeatherSetWind(wind),
            icon: GameUI.buildAtlasIconType(convertWindToIconType(wind), size: 64),
            isActive: wind == active,
          )
      );

  static int convertRainToIconType(Rain rain){
    switch (rain) {
      case Rain.None:
        return IconType.Rain_None;
      case Rain.Light:
        return IconType.Rain_Light;
      case Rain.Heavy:
        return IconType.Rain_Heavy;
    }
  }

  static int convertLightningToIconType(Lightning lightning){
    switch (lightning) {
      case Lightning.Off:
        return IconType.Lightning_Off;
      case Lightning.Nearby:
        return IconType.Lightning_Nearby;
      case Lightning.On:
        return IconType.Lightning_On;
    }
  }

  static int convertWindToIconType(Wind wind){
    switch (wind) {
      case Wind.Calm:
        return IconType.Wind_Calm;
      case Wind.Gentle:
        return IconType.Wind_Gentle;
      case Wind.Strong:
        return IconType.Wind_Strong;
    }
  }

  static Widget buildRowRainIcons() =>
      Row(children: Rain.values.map(buildIconRain).toList());

  static Widget buildRowLightningIcons() =>
      Row(children: Lightning.values.map(buildIconLightning).toList());

  static Widget buildRowWindIcons() =>
      Row(children: Wind.values.map(buildIconWind).toList());

  static String convertHourToString(int hour){
     if (hour < 0) return 'invalid time';
     if (hour == 0) return 'midnight';
     if (hour < 3) return 'night';
     if (hour < 6) return 'early morning';
     if (hour < 10) return 'morning';
     if (hour < 12) return 'late morning';
     if (hour == 12) return 'midday';
     if (hour < 15) return 'afternoon';
     if (hour < 17) return 'late afternoon';
     if (hour < 19) return 'evening';
     return 'night';
  }

  static Widget buildControlTime() {
    const totalWidth = 300.0;
    const buttonWidth = totalWidth / 24.0;
    final buttons = watch(ServerState.hours, (int hours) {
      final buttons1 = <Widget>[];
      final buttons2 = <Widget>[];

      for (var i = 0; i <= hours; i++) {
        buttons1.add(
          Tooltip(
            message: '$i - ${convertHourToString(i)}',
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
            message: '$i - ${convertHourToString(i)}',
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
        watch(ServerState.hours, (num hour) => text(padZero(hour))),
        text(":"),
        watch(ServerState.minutes, (num hour) => text(padZero(hour))),
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