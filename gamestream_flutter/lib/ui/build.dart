import 'package:bleed_common/AbilityType.dart';
import 'package:bleed_common/GameType.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/assets.dart';
import 'package:gamestream_flutter/classes/Ability.dart';
import 'package:gamestream_flutter/constants/colours.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/modules/core/enums.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:gamestream_flutter/modules/website/enums.dart';
import 'package:gamestream_flutter/send.dart';
import 'package:gamestream_flutter/state/game.dart';
import 'package:gamestream_flutter/styles.dart';
import 'package:gamestream_flutter/ui/state/decorationImages.dart';
import 'package:gamestream_flutter/ui/style.dart';
import 'package:gamestream_flutter/utils/widget_utils.dart';
import 'package:golden_ratio/constants.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_watch/watch_builder.dart';

import 'compose/hudUI.dart';
import 'widgets.dart';

final build = _Build();

final selectableGameTypes = [
  GameType.MMO,
  GameType.SKIRMISH,
  GameType.SWARM,
  GameType.RANDOM,
];

class _Build {

  Widget buildAbility(Ability ability) {
    return WatchBuilder(ability.type, (AbilityType type) {
      if (type == AbilityType.None) return emptyContainer;

      return Column(
        mainAxisAlignment: axis.main.end,
        children: [
          WatchBuilder(modules.game.state.player.skillPoints, (int points) {
            if (points == 0) return emptyContainer;

            return onPressed(
              callback: () {
                // sendRequest.upgradeAbility(ability.index);
              },
              child: mouseOver(builder: (BuildContext context, bool mouseOver) {
                return border(
                  child: text("+", size: 25),
                  color: Colors.white,
                  fillColor: mouseOver ? Colors.white54 : Colors.white12,
                  padding: EdgeInsets.symmetric(horizontal: 5),
                );
              }),
            );
          }),
          height20,
          WatchBuilder(ability.level, (int level) {
            bool unlocked = level > 0;

            if (!unlocked) {
              return Stack(
                children: [
                  buildDecorationImage(
                      image: mapAbilityTypeToDecorationImage[type]!,
                      width: 50,
                      height: 50,
                      borderColor: Colors.black54,
                      borderWidth: 3),
                  Container(
                    width: 50,
                    height: 50,
                    alignment: Alignment.center,
                    color: Colors.black54,
                  )
                ],
              );
            }

            return WatchBuilder(ability.cooldown, (int cooldown) {
              return WatchBuilder(ability.cooldownRemaining,
                      (int cooldownRemaining) {
                    if (cooldownRemaining > 0) {
                      return Stack(
                        children: [
                          buildDecorationImage(
                              image: mapAbilityTypeToDecorationImage[type]!,
                              width: 50,
                              height: 50,
                              borderColor: Colors.black54,
                              borderWidth: 3),
                          Container(
                              width: 50,
                              height: 50,
                              alignment: Alignment.center,
                              color: Colors.black54,
                              child: text("${cooldownRemaining}s"))
                        ],
                      );
                    }

                    return WatchBuilder(ability.canAfford, (bool canAfford) {
                      if (!canAfford) {
                        return Stack(
                          children: [
                            buildDecorationImage(
                                image: mapAbilityTypeToDecorationImage[type]!,
                                width: 50,
                                height: 50,
                                borderColor: Colors.black54,
                                borderWidth: 3),
                            Container(
                              width: 50,
                              height: 50,
                              alignment: Alignment.center,
                              color: Colors.red.withOpacity(0.5),
                            ),
                            Container(
                                color: Colors.black54,
                                padding: padding4,
                                child: text(level))
                          ],
                        );
                      }

                      return WatchBuilder(ability.selected, (bool selected) {
                        return onPressed(
                          hint: abilityTypeToString(ability.type.value),
                          callback: () {
                            sendRequestSelectAbility(ability.index);
                          },
                          child: Stack(
                            children: [
                              mouseOver(
                                  builder: (BuildContext context, bool mouseOver) {
                                    return buildDecorationImage(
                                        image: mapAbilityTypeToDecorationImage[type]!,
                                        width: 50,
                                        height: 50,
                                        borderColor: mouseOver || selected
                                            ? Colors.white
                                            : Colors.green,
                                        borderWidth: 3);
                                  }),
                              Container(
                                  color: Colors.black54,
                                  padding: padding4,
                                  child: text(level)),
                            ],
                          ),
                        );
                      });
                    });
                  });
            });
          }),
        ],
      );
    });
  }

  Widget theme(){
    return onHover((bool hovering){
      const _width = 150.0;
      final theme = border(child: text("Theme"), radius: borderRadius0);
      if (!hovering){
        return theme;
      }else{
        return Row(
          crossAxisAlignment: axis.cross.start,
          children: [
            button("PressStart2P", (){
              engine.themeData.value = themes.pressStart2P;
            }, width: _width, borderRadius: borderRadius0, fillColorMouseOver: colours.green),
            button("Gugi", (){
              engine.themeData.value = themes.gugi;
            }, width: _width, borderRadius: borderRadius0, fillColorMouseOver: colours.green),
            button("GermanioOne", (){
              engine.themeData.value = themes.germaniaOne;
            }, width: _width, borderRadius: borderRadius0, fillColorMouseOver: colours.green),
            button("Slackey", (){
              engine.themeData.value = themes.slackey;
            }, width: _width, borderRadius: borderRadius0, fillColorMouseOver: colours.green),
            button("Standard", (){
              engine.themeData.value = null;
            }, width: _width, borderRadius: borderRadius0, fillColorMouseOver: colours.green),
            theme
          ],
        );
      }
    });
  }

  Widget timeZone(){
    return text(DateTime.now().timeZoneName);
  }

  Widget totalZombies(){
    return WatchBuilder(game.totalZombies, (int zombies){
      return text("Zombies: $zombies");
    });
  }

  Widget title(){
    final child = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        text("GAME",
            size: 60,
            color: Colors.white,
            family: assets.fonts.libreBarcode39Text
        ),
        text("STREAM",
            size: 60,
            color: colours.red,
            family: assets.fonts.libreBarcode39Text,
        ),
      ],
    );


    return onPressed(
      callback: (){
        game.type.value = GameType.None;
        if (website.state.dialog.value == WebsiteDialog.Games){
          website.actions.showDialogAccount();
        }else{
          website.actions.showDialogGames();
        }
      },
      child: border(
        height: style.buttonHeight,
        radius: borderRadius2,
        child: child,
        color: none,
        borderWidth: 2,
      ),
    );
  }

  Widget gamesList(){
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          widgets.title,
          height32,
          ...selectableGameTypes.map((gameType) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: mouseOver(
                builder: (BuildContext context, bool mouseOver) {
                  final gameName = gameTypeNames[gameType];

                  if (mouseOver){
                    return loadingText(gameName!, (){
                      game.type.value = gameType;
                      core.actions.connectToSelectedGame();
                    });
                  }


                  return text(mouseOver ? '-$gameName-' : gameName, color: mouseOver ? colours.white : colours.white85, onPressed: (){
                    game.type.value = gameType;
                    core.actions.connectToSelectedGame();
                  }, size: style.fontSize.large, bold: true);
                },
            ),
          );
        }
        ),
          height(120),
         ].toList(),
      ),
    );

  }

  Widget magicBar() {
    final width = 200.0;
    final height = width *
        goldenRatio_0381 *
        goldenRatio_0381 *
        goldenRatio_0381 *
        goldenRatio_0381;

    return WatchBuilder(modules.game.state.player.magic, (double magic) {
      double percentage = magic / modules.game.state.player.maxMagic.value;
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 2),
            borderRadius: borderRadius4),
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.all(2),
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            Container(
              color: colours.blueDarkest,
              width: width,
              height: height,
            ),
            Container(
              color: colours.blue,
              width: width * percentage,
              height: height,
            ),
            Container(
              color: Colors.transparent,
              width: width,
              height: height,
              alignment: Alignment.center,
              child: text('${magic.toInt()} / ${modules.game.state.player.maxMagic.value}'),
            ),
          ],
        ),
      );
    });
  }

  Widget healthBar() {
    double width = 200;
    double height = width *
        goldenRatio_0381 *
        goldenRatio_0381 *
        goldenRatio_0381 *
        goldenRatio_0381;

    return WatchBuilder(modules.game.state.player.health, (double health) {
      double percentage = health / modules.game.state.player.maxHealth;
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 2),
            borderRadius: borderRadius4),
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.all(2),
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            Container(
              color: colours.redDarkest,
              width: width,
              height: height,
            ),
            Container(
              color: colours.red,
              width: width * percentage,
              height: height,
            ),
            Container(
              color: Colors.transparent,
              width: width,
              height: height,
              alignment: Alignment.center,
              child: text('${health.toInt()} / ${modules.game.state.player.maxHealth}'),
            ),
          ],
        ),
      );
    });
  }

  Widget experienceBar() {
    double levelBarWidth = 200;
    double levelBarHeight = levelBarWidth *
        goldenRatio_0381 *
        goldenRatio_0381 *
        goldenRatio_0381 *
        goldenRatio_0381;

    return WatchBuilder(modules.game.state.player.experiencePercentage, (double percentage) {
      return Container(
        width: levelBarWidth,
        height: levelBarHeight,
        decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 2),
            borderRadius: borderRadius4),
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.all(2),
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            Container(
              color: colours.purpleDarkest,
              width: levelBarWidth,
              height: levelBarHeight,
            ),
            Container(
              color: colours.purple,
              width: levelBarWidth * percentage,
              height: levelBarHeight,
            ),
            Container(
              color: Colors.transparent,
              width: levelBarWidth,
              height: levelBarHeight,
              alignment: Alignment.center,
              child: text('Level ${modules.game.state.player.level.value}'),
            ),
          ],
        ),
      );
    });
  }
}


Region detectRegion(){
  print("detectRegion()");
  final timeZoneName = DateTime.now().timeZoneName.toLowerCase();

  if (timeZoneName.contains('australia')){
    print('australia detected');
    return Region.Australia;
  }
  if (timeZoneName.contains('new zealand')){
    print('australia detected');
    return Region.Australia;
  }
  if (timeZoneName.contains('european')){
    return Region.Germany;
  }

  return Region.Australia;
}

final Map<GameType, DecorationImage> gameTypeDecorationImage = {
  GameType.MMO: decorationImages.atlas,
  GameType.BATTLE_ROYAL: decorationImages.zombieRoyal,
  GameType.Moba: decorationImages.heroesLeague,
  GameType.CUBE3D: decorationImages.cube,
  GameType.DeathMatch: decorationImages.counterStrike,
};

