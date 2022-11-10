

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
          buildRowRainIcons(),
          width2,
          buildRowLightningIcons(),
          width2,
          buildRowWindIcons(),
        ],
      );

  static Widget buildIconRain(Rain rain) =>
      watch(GameState.rain, (Rain activeRain) {
        const Size = 64.0;
        final isActive = rain == activeRain;
        return Stack(
          children: [
            onPressed(
              action: isActive ? null : () => GameNetwork.sendClientRequestWeatherSetRain(rain),
              child: GameUI.buildAtlasIconType(convertRainToIconType(rain), size: Size),
            ),
            if (isActive)
              Container(
                 width: Size,
                 height: Size,
                 decoration: GameUI.buildDecorationBorder(
                     colorBorder: Colors.white,
                     colorFill: Colors.transparent,
                     width: 2,
                     borderRadius: 0,
                 ),
              ),
          ],
        );
      });

  static Widget buildIconLightning(Lightning lightning) =>
      watch(GameState.lightning, (Lightning activeLightning) {
        const Size = 64.0;
        final isActive = lightning == activeLightning;
        return Stack(
          children: [
            onPressed(
              action: isActive ? null : () => GameNetwork.sendClientRequestWeatherSetLightning(lightning),
              child: GameUI.buildAtlasIconType(convertLightningToIconType(lightning), size: Size),
            ),
            if (isActive)
              Container(
                width: Size,
                height: Size,
                decoration: GameUI.buildDecorationBorder(
                  colorBorder: Colors.white,
                  colorFill: Colors.transparent,
                  width: 2,
                  borderRadius: 0,
                ),
              ),
          ],
        );
      });

  static Widget buildIconWind(Wind wind) =>
      watch(GameState.windAmbient, (Wind activeWind) {
        const Size = 64.0;
        final isActive = wind == activeWind;
        return Stack(
          children: [
            onPressed(
              action: isActive ? null : () => GameNetwork.sendClientRequestWeatherSetWind(wind),
              child: GameUI.buildAtlasIconType(convertWindToIconType(wind), size: Size),
            ),
            if (isActive)
              Container(
                width: Size,
                height: Size,
                decoration: GameUI.buildDecorationBorder(
                  colorBorder: Colors.white,
                  colorFill: Colors.transparent,
                  width: 2,
                  borderRadius: 0,
                ),
              ),
          ],
        );
      });


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