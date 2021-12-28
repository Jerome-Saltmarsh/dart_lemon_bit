

import 'dart:math';

import 'package:bleed_client/Bool.dart';
import 'package:bleed_client/common/CharacterType.dart';
import 'package:bleed_client/common/WeaponType.dart';
import 'package:bleed_client/constants/colours.dart';
import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/toString.dart';
import 'package:bleed_client/ui/compose/buildSkillTree.dart';
import 'package:bleed_client/ui/compose/buildTextBox.dart';
import 'package:bleed_client/ui/compose/hudUI.dart';
import 'package:bleed_client/ui/compose/widgets.dart';
import 'package:bleed_client/utils/widget_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:lemon_engine/state/screen.dart';
import 'package:lemon_math/golden_ratio.dart';
import 'package:lemon_math/pi2.dart';
import 'package:lemon_watch/watch.dart';
import 'package:lemon_watch/watch_builder.dart';

import '../../send.dart';
import '../widgets.dart';
import 'flutter_constants.dart';
import 'tips.dart';


// properties
bool get textFieldFocused => hud.focusNodes.textFieldMessage.hasPrimaryFocus;
String get currentTip => tips[hud.state.tipIndex];

final _Hud hud = _Hud();

class _Hud {
  final Bool skillTreeVisible = Bool(false);
  final _State state = _State();
  final _FocusNodes focusNodes = _FocusNodes();
  final _TextEditingControllers textEditingControllers = _TextEditingControllers();
  final _Properties properties = _Properties();
  bool get textBoxFocused => focusNodes.textFieldMessage.hasFocus;

  final _BuildView buildView = _BuildView();
}

class _BuildView {
  Widget standardMagic() {
    return WatchBuilder(game.player.characterType, (CharacterType value) {
      if (value == CharacterType.None) {
        return buildDialogSelectCharacterType();
      }

      if (value == CharacterType.Human) {
        return WatchBuilder(game.player.weaponType, (WeaponType weaponType){
          return Stack(
            children: [
              topLeft(child: text(enumString(weaponType))),
              topRight(child: buttons.exit),
            ],
          );
        });
      }

      return WatchBuilder(game.player.alive, (bool alive) {
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
            buildSkillTree(),
            buildNumberOfPlayersRequiredDialog(),
          ],
        );
      });
    });
  }
}


class _State {
  int tipIndex = 0;
  Watch<bool> textBoxVisible = Watch(false);
  bool observeMode = false;
  bool showServers = false;
  bool expandScore = false;
  Watch<bool> menuVisible = Watch(false);
}

class _Properties {
  double iconSize = 45;
  Border border = Border.all(color: Colors.black, width: 5.0, style: BorderStyle.solid);
}

class _TextEditingControllers {
  final TextEditingController speak = TextEditingController();
  final TextEditingController playerName = TextEditingController();
}

class _FocusNodes {
  FocusNode textFieldMessage = FocusNode();
}

class Ring {
  List<Offset> points = [];
  double sides;

  Ring(this.sides, {double radius = 12}) {
    double radianPerSide = pi2 / sides;
    for (int side = 0; side <= sides; side++) {
      double radians = side * radianPerSide;
      points.add(Offset(cos(radians) * radius, sin(radians) * radius));
    }
  }
}

Positioned _buildRespawnLight() {
  return Positioned(
      top: 30,
      child: Container(
          width: screen.width,
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
                        child: text("Respawn", fontSize: 30),
                        padding: padding8,
                        radius: borderRadius4))
              ]),
              height32,
              text("Hold E to pan camera")
            ],
          )));
}

Widget _buildServerText() {
  return WatchBuilder(game.player.message, (String value) {
    if (value.isEmpty) return blank;

    return Positioned(
        child: Container(
          width: screen.width,
          alignment: Alignment.center,
          child: Container(
            width: 300,
            color: Colors.black45,
            padding: padding16,
            child: Column(
              children: [
                text(game.player.message.value),
                height16,
                button("Next", clearPlayerMessage),
              ],
            ),
          ),
        ),
        bottom: 100);
  });
}

Widget _buildViewRespawn() {
  print("buildViewRespawn()");
  return Container(
    width: screen.width,
    height: screen.height,
    child: Row(
      mainAxisAlignment: axis.main.center,
      crossAxisAlignment: axis.cross.center,
      children: [
        Container(
            padding: padding16,
            width: max(screen.width * goldenRatioInverseB, 480),
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
                  text("YOU DIED", fontSize: 30, decoration: underline),
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
                                child: text(currentTip)),
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
                                    fontWeight: bold,
                                  ),
                                  padding: padding16,
                                  radius: borderRadius4,
                                  color: Colors.white,
                                  width: 1,
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
