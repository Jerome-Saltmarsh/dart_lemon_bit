import 'package:lemon_watch/watch.dart';
import 'dart:math';

import 'package:bleed_client/common/CharacterType.dart';
import 'package:bleed_client/common/GameStatus.dart';
import 'package:bleed_client/common/GameType.dart';
import 'package:bleed_client/common/StoreItem.dart';
import 'package:bleed_client/common/WeaponType.dart';
import 'package:bleed_client/constants/colours.dart';
import 'package:bleed_client/flutterkit.dart';
import 'package:bleed_client/modules/modules.dart';
import 'package:bleed_client/send.dart';
import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/styles.dart';
import 'package:bleed_client/ui/compose/buildTextBox.dart';
import 'package:bleed_client/ui/compose/hudUI.dart';
import 'package:bleed_client/ui/dialogs.dart';
import 'package:bleed_client/ui/state/hud.dart';
import 'package:bleed_client/ui/style.dart';
import 'package:bleed_client/ui/views.dart';
import 'package:bleed_client/ui/widgets.dart';
import 'package:bleed_client/utils/widget_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:golden_ratio/constants.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_watch/watch_builder.dart';

import '../../toString.dart';
import 'state.dart';

class GameBuild {

  final GameState state;
  GameBuild(this.state);

  Widget buildUIGame() {
    return WatchBuilder(state.player.uuid, (String uuid) {
      if (uuid.isEmpty) {
        return buildLayoutLoadingGame();
      }
      return WatchBuilder(state.status, (GameStatus gameStatus) {
        switch (gameStatus) {
          case GameStatus.Counting_Down:
            return buildDialog(
                width: style.dialogWidthMedium,
                height: style.dialogHeightMedium,
                child: WatchBuilder(game.countDownFramesRemaining, (int frames){
                  final seconds =  frames ~/ 30.0;
                  return Center(child: text("Starting in $seconds seconds"));
                }));
          case GameStatus.Awaiting_Players:
            return buildLayoutLobby() ;
          case GameStatus.In_Progress:
            switch (game.type.value) {
              case GameType.MMO:
                // return playerCharacterType();
                return layoutRoyal();
              case GameType.Custom:
                return playerCharacterType();
              case GameType.Moba:
                return playerCharacterType();
              case GameType.BATTLE_ROYAL:
                return layoutRoyal();
              case GameType.CUBE3D:
                return buildUI3DCube();
              default:
                return text(game.type.value);
            }
          case GameStatus.Finished:
            return buildDialogGameFinished();
          default:
            return text(enumString(gameStatus));
        }
      });
    });
  }

  Widget playerCharacterType() {
    return WatchBuilder(modules.game.state.player.characterType, (CharacterType value) {
      if (value == CharacterType.Human) {
        return _buildHudWeapons();
      }
      return _buildHudAbilities();
    });
  }

  Widget _buildHudWeapons(){
    return WatchBuilder(modules.game.state.player.weaponType, (WeaponType weaponType){
      return layout(
          padding: 16,
          topLeft: buildTime(),
          topRight: buttons.exit,
          bottomLeft: buildWeaponMenu(),
      );
    });
  }

  Widget layoutRoyal(){
    return layout(
        children: [
          Positioned(
              right: 16,
              top: 50,
              child: Container(
              width: 150,
              height: 300,
              color: colours.red,
                child: Column(
                  children: [
                    columnOrbs(),
                    columnStore(),
                    height16,
                    columnPlayerSlots()
                  ],
                ),
          )),
        ],
    );
  }

  Column columnPlayerSlots() {
    return Column(
                    children: state.player.slots.list.map(playerSlot).toList(),
                  );
  }

  Column columnStore() {
    return Column(
      children: [
        button("Pendant", () {
          if (state.player.orbs.ruby.value <= 0) return;
          final emptySlot = state.player.slots.emptySlot;
          if (emptySlot == null) return;
          state.player.orbs.ruby.value--;
          emptySlot.value = SlotType.Pendant;
        }),
      ],
    );
  }

  Widget columnOrbs(){
    return Column(
      children: [
        WatchBuilder(state.player.orbs.emerald, (int emeralds){
          return text("Emeralds $emeralds");
        }),
        width8,
        WatchBuilder(state.player.orbs.topaz, (int topaz){
          return text("Topaz $topaz");
        }),
        width8,
        WatchBuilder(state.player.orbs.ruby, (int rubies){
          return text("Rubies $rubies");
        }),
      ],
    );
  }

  Widget _buildHudAbilities(){
    return WatchBuilder(modules.game.state.player.alive, (bool alive) {
      return Stack(
        children: [
          buildTextBox(),
          if (alive) buildBottomRight(),
          buildTopLeft(),
          if (alive) buildBottomCenter(),
          if (!hud.state.observeMode && !alive) _buildViewRespawn(),
          if (!alive && hud.state.observeMode) _buildRespawnLight(),
          _buildServerText(),
          buildTopRight(),
          buildNumberOfPlayersRequiredDialog(),
          // bottomLeft(child: fps),
        ],
      );
    });
  }

  Widget _buildViewRespawn() {
    print("buildViewRespawn()");
    return Container(
      width: engine.state.screen.width,
      height: engine.state.screen.height,
      child: Row(
        mainAxisAlignment: axis.main.center,
        crossAxisAlignment: axis.cross.center,
        children: [
          Container(
              padding: padding16,
              width: max(engine.state.screen.width * goldenRatio_0381, 480),
              decoration: BoxDecoration(
                  borderRadius: borderRadius4, color: Colors.black38),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: axis.cross.center,
                  children: [
                    Container(
                        decoration: BoxDecoration(
                          borderRadius: borderRadius4,
                          color: colours.blood,
                        ),
                        padding: padding8,
                        child: text("BLEED beta v1.0.0")),
                    height16,
                    text("YOU DIED", size: 30, underline: true),
                    height16,
                    Container(
                      padding: padding16,
                      decoration: BoxDecoration(
                        borderRadius: borderRadius4,
                        color: black26,
                      ),
                      child: Column(
                        crossAxisAlignment: axis.cross.center,
                        children: [
                          text("Please Support Me"),
                          height16,
                          Row(
                            mainAxisAlignment: axis.main.even,
                            children: [
                              onPressed(
                                child: border(
                                    child: Container(
                                        width: 70,
                                        alignment: Alignment.center,
                                        child: text(
                                          "Paypal",
                                        )),
                                    radius: borderRadius4,
                                    padding: padding8),
                                callback: () {
                                  // openLink(links.paypal);
                                },
                                // hint: links.paypal
                              ),
                              onPressed(
                                child: border(
                                    child: Container(
                                        width: 70,
                                        alignment: Alignment.center,
                                        child: text("Patreon")),
                                    radius: borderRadius4,
                                    padding: padding8),
                                callback: () {
                                  // openLink(links.patreon);
                                },
                                // hint: links.patreon
                              )
                            ],
                          ),
                          height8,
                        ],
                      ),
                    ),
                    height8,
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: borderRadius4,
                        color: black26,
                      ),
                      padding: padding16,
                      child: Column(
                        children: [
                          text("Hints"),
                          Row(
                            mainAxisAlignment: axis.main.center,
                            crossAxisAlignment: axis.cross.center,
                            children: [
                              Container(
                                  width: 350,
                                  alignment: Alignment.center,
                                  child: text(hud.currentTip)),
                              width16,
                            ],
                          ),
                        ],
                      ),
                    ),
                    height32,
                    Row(
                      mainAxisAlignment: axis.main.between,
                      children: [
                        onPressed(
                            child: Container(
                                padding: padding16, child: text("Close")),
                            callback: () {
                              hud.state.observeMode = true;
                            }),
                        width16,
                        mouseOver(
                            builder: (BuildContext context, bool mouseOver) {
                              return onPressed(
                                child: border(
                                    child: text(
                                      "RESPAWN",
                                      weight: bold,
                                    ),
                                    padding: padding16,
                                    radius: borderRadius4,
                                    color: Colors.white,
                                    borderWidth: 1,
                                    fillColor: mouseOver ? black54 : black26),
                                callback: sendRequestRevive,
                                hint: "Click to respawn",
                              );
                            })
                      ],
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildServerText() {
    return WatchBuilder(modules.game.state.player.message, (String value) {
      if (value.isEmpty) return blank;

      return Positioned(
          child: Container(
            width: engine.state.screen.width,
            alignment: Alignment.center,
            child: Container(
              width: 300,
              color: Colors.black45,
              padding: padding16,
              child: Column(
                children: [
                  text(modules.game.state.player.message.value),
                  height16,
                  button("Next", clearPlayerMessage),
                ],
              ),
            ),
          ),
          bottom: 100);
    });
  }

  Positioned _buildRespawnLight() {
    return Positioned(
        top: 30,
        child: Container(
            width: engine.state.screen.width,
            child: Column(
              crossAxisAlignment: axis.cross.center,
              children: [
                Row(mainAxisAlignment: axis.main.center, children: [
                  onPressed(
                      callback: () {
                        sendRequestRevive();
                        hud.state.observeMode = false;
                      },
                      child: border(
                          child: text("Respawn", size: 30),
                          padding: padding8,
                          radius: borderRadius4))
                ]),
                height32,
                text("Hold E to pan camera")
              ],
            )));
  }


  Widget playerSlot(Watch<SlotType> slot){
    return WatchBuilder(slot, (SlotType slotType) {
          return text(slotType.name);
    });
  }
}