import 'package:bleed_client/classes/Ability.dart';
import 'package:bleed_client/common/AbilityType.dart';
import 'package:bleed_client/common/GameType.dart';
import 'package:bleed_client/constants/colors/white.dart';
import 'package:bleed_client/constants/colours.dart';
import 'package:bleed_client/enums/Region.dart';
import 'package:bleed_client/send.dart';
import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/toString.dart';
import 'package:bleed_client/flutterkit.dart';
import 'package:bleed_client/ui/state/decorationImages.dart';
import 'package:bleed_client/styles.dart';
import 'package:bleed_client/ui/widgets.dart';
import 'package:bleed_client/utils/widget_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lemon_math/golden_ratio.dart';
import 'package:lemon_watch/watch_builder.dart';

import 'compose/hudUI.dart';

final _Build build = _Build();

class _Build {
  final _buttonWidth = 220.0;

  Widget buildAbility(Ability ability) {
    return WatchBuilder(ability.type, (AbilityType type) {
      if (type == AbilityType.None) return emptyContainer;

      return Column(
        mainAxisAlignment: axis.main.end,
        children: [
          WatchBuilder(game.player.skillPoints, (int points) {
            if (points == 0) return emptyContainer;

            return onPressed(
              callback: () {
                sendRequest.upgradeAbility(ability.index);
              },
              child: mouseOver(builder: (BuildContext context, bool mouseOver) {
                return border(
                  child: text("+", fontSize: 25),
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
          buildAbility(game.player.ability1),
          width4,
          buildAbility(game.player.ability2),
          width4,
          buildAbility(game.player.ability3),
          width4,
          buildAbility(game.player.ability4),
        ],
      ),
    );
  }

  Widget title(){
    return WatchBuilder(game.region, (Region region){
      return Row(
        children: [
          border(
              // child: Text("GAMESTREAM.ONLINE",
              //     style: TextStyle(
              //         fontSize: 30,
              //         fontWeight: bold,
              //         fontFamily: 'PressStart2P',
              //         color: white,
              //     ),
              //
              // ),
              child: text("GAMESTREAM.ONLINE",
                fontSize: 30,
              ),
              borderWidth: 6,
              radius: const BorderRadius.only(topLeft: radius4, bottomLeft: radius4)
          ),
          if (region != Region.None)
            buttons.region,
        ],
      );
    });


  }

  Widget gamesList(){
    return Column(
      crossAxisAlignment: axis.cross.stretch,
      children: [
        ...selectableGameTypes.map((GameType value) {
          final Widget type =
          Container(width: 160, child: text(enumString(value).toUpperCase()));
          final Widget joinButton = button(
              text(gameTypeNames[value], fontSize: 20, fontWeight: FontWeight.bold),
                  () {
                game.type.value = value;
                game.type.value = value;
              }, width: _buttonWidth, borderWidth: 3,
            fillColor: colours.black05,
          );
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: Row(
              mainAxisAlignment: axis.main.center,
              children: [
                joinButton,
                width16,
                type,
              ],
            ),
          );
        }).toList()
      ],
    );
  }

  Widget magicBar() {
    double width = 200;
    double height = width *
        goldenRatioInverse *
        goldenRatioInverse *
        goldenRatioInverse *
        goldenRatioInverse;

    return WatchBuilder(game.player.magic, (double magic) {
      double percentage = magic / game.player.maxMagic.value;
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
              child: text('${magic.toInt()} / ${game.player.maxMagic.value}'),
            ),
          ],
        ),
      );
    });
  }

  Widget healthBar() {
    double width = 200;
    double height = width *
        goldenRatioInverse *
        goldenRatioInverse *
        goldenRatioInverse *
        goldenRatioInverse;

    return WatchBuilder(game.player.health, (double health) {
      double percentage = health / game.player.maxHealth;
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
              child: text('${health.toInt()} / ${game.player.maxHealth}'),
            ),
          ],
        ),
      );
    });
  }

  Widget experienceBar() {
    double levelBarWidth = 200;
    double levelBarHeight = levelBarWidth *
        goldenRatioInverse *
        goldenRatioInverse *
        goldenRatioInverse *
        goldenRatioInverse;

    return WatchBuilder(game.player.experiencePercentage, (double percentage) {
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
              child: text('Level ${game.player.level.value}'),
            ),
          ],
        ),
      );
    });
  }
}
