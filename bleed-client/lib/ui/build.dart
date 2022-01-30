import 'package:bleed_client/assets.dart';
import 'package:bleed_client/classes/Ability.dart';
import 'package:bleed_client/common/AbilityType.dart';
import 'package:bleed_client/common/GameType.dart';
import 'package:bleed_client/constants/colours.dart';
import 'package:bleed_client/enums/Region.dart';
import 'package:bleed_client/flutterkit.dart';
import 'package:bleed_client/modules/modules.dart';
import 'package:bleed_client/modules/website/enums.dart';
import 'package:bleed_client/send.dart';
import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/styles.dart';
import 'package:bleed_client/ui/state/decorationImages.dart';
import 'package:bleed_client/ui/style.dart';
import 'package:bleed_client/utils/widget_utils.dart';
import 'package:flutter/material.dart';
import 'package:golden_ratio/constants.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_watch/watch_builder.dart';

import 'compose/hudUI.dart';

final _Build build = _Build();

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
                sendRequest.upgradeAbility(ability.index);
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


  Widget abilities() {
    return Container(
      child: Row(
        crossAxisAlignment: axis.cross.end,
        children: [
          buildAbility(modules.game.state.player.ability1),
          width4,
          buildAbility(modules.game.state.player.ability2),
          width4,
          buildAbility(modules.game.state.player.ability3),
          width4,
          buildAbility(modules.game.state.player.ability4),
        ],
      ),
    );
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
              engine.state.themeData.value = themes.pressStart2P;
            }, width: _width, borderRadius: borderRadius0, fillColorMouseOver: colours.green),
            button("Gugi", (){
              engine.state.themeData.value = themes.gugi;
            }, width: _width, borderRadius: borderRadius0, fillColorMouseOver: colours.green),
            button("GermanioOne", (){
              engine.state.themeData.value = themes.germaniaOne;
            }, width: _width, borderRadius: borderRadius0, fillColorMouseOver: colours.green),
            button("Slackey", (){
              engine.state.themeData.value = themes.slackey;
            }, width: _width, borderRadius: borderRadius0, fillColorMouseOver: colours.green),
            button("Standard", (){
              engine.state.themeData.value = null;
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
    final account = core.state.account.value;
    final premiumActive = account != null && account.isPremium;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 120),
      child: SingleChildScrollView(
        child: Column(
          children: [
            ...selectableGameTypes.map((GameType gameType) {

              return onHover((hovering){
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  color: colours.white05,
                  width: 500,
                  child: onPressed(
                    callback: (){
                      game.type.value = gameType;
                    },
                    child: border(
                      color: hovering ? colours.white05 : colours.none,
                      borderWidth: 3,
                      child: Row(
                        crossAxisAlignment: axis.cross.center,
                        children: [
                          Stack(
                            children: [
                              Container(
                                width: 180,
                                height: 111,
                                decoration: BoxDecoration(
                                  image: gameTypeDecorationImage[gameType] ?? decorationImages.royal,
                                ),
                              ),
                              if (hovering)
                              Positioned(
                                  left: 60,
                                  height: 100,
                                  child: playIcon),
                            ],
                          ),
                          width8,
                          Expanded(child: Center(child:

                          text(gameTypeNames[gameType],
                              size: hovering ? 25 : 20,
                              weight: FontWeight.bold,
                              color: premiumActive || freeToPlay.contains(gameType) ? colours.white80 : colours.white382

                          )
                          )),
                        ],
                      ),
                    ),
                  ),
                );
              });

            }).toList()
          ],
        ),
      ),
    );
  }

  Widget magicBar() {
    double width = 200;
    double height = width *
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

