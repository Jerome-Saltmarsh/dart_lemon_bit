import 'package:bleed_client/authentication.dart';
import 'package:bleed_client/common/CharacterType.dart';
import 'package:bleed_client/common/ClientRequest.dart';
import 'package:bleed_client/constants/colours.dart';
import 'package:bleed_client/enums/Region.dart';
import 'package:bleed_client/send.dart';
import 'package:bleed_client/server/server.dart';
import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/ui/build.dart';
import 'package:bleed_client/flutterkit.dart';
import 'package:bleed_client/ui/state/decorationImages.dart';
import 'package:bleed_client/ui/ui.dart';
import 'package:bleed_client/utils/widget_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lemon_engine/functions/fullscreen_enter.dart';
import 'package:lemon_engine/functions/fullscreen_exit.dart';
import 'package:lemon_engine/properties/fullscreen_active.dart';
import 'package:lemon_watch/watch_builder.dart';

import '../logic.dart';
import '../styles.dart';
import '../toString.dart';
import 'compose/hudUI.dart';

final _Widgets widgets = _Widgets();
final _Buttons buttons = _Buttons();

final _BuildDialog buildDialog = _BuildDialog();

class _BuildDialog {
  Widget selectCharacterType() {
    final fontSize = 20;
    return dialog(
        color: Colors.white24,
        child: Column(
          children: [
            height16,
            text("Hero", fontSize: 30),
            height16,
            ...playableCharacterTypes.map((characterType) {
              return mouseOver(
                builder: (BuildContext context, bool mouseOver) {
                  return onPressed(
                    callback: () {
                      server.send.selectCharacterType(characterType);
                    },
                    child: border(
                      margin: EdgeInsets.only(bottom: 16),
                      fillColor: mouseOver ? Colors.black87 : Colors.black26,
                      child: Container(
                        width: 200,
                        child: text(characterTypeToString(characterType),
                            fontSize: fontSize),
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          ],
        ));
  }
}

class _Widgets {
  final Widget experienceBar = build.experienceBar();
  final Widget healthBar = build.healthBar();
  final Widget magicBar = build.magicBar();
  final Widget abilities = build.abilities();
  final Widget gamesList = build.gamesList();
  final Widget title = build.title();

  final Widget settingsMenu = Column(
    children: [
      buttons.account,
      height4,
      buttons.logout,
    ],
  );
}

class _Buttons {
  final Widget account = button("Account", (){
    ui.dialog.value = Dialogs.Account;
  }, width: 200);
  final Widget logout =   button('Logout', signOut, width: 200);
  final Widget menu = NullableWatchBuilder<UserCredential?>(userCredentials, (UserCredential? credentials){
    if (credentials == null || credentials.user == null){
      return button(
          "Login / Register", signInWithGoogle,
          fillColor: colours.green
      );
    }
    return mouseOver(builder: (BuildContext context, bool mouseOver){
      return mouseOver ? widgets.settingsMenu : buttons.account;
    });
  });
  final Widget debug = button("Debug", toggleDebugMode);
  final Widget exit = button('Exit', logic.exit);
  final Widget edit = button("Edit", logic.toggleEditMode);
  final Widget editor = button("Editor", logic.openEditor);
  final Widget register = button("Register", logic.openEditor);
  final Widget changeCharacter = button("Change Hero", () {
    sendClientRequest(ClientRequest.Reset_Character_Type);
  });
  final Widget audio = WatchBuilder(game.settings.audioMuted, (bool audio) {
    return onPressed(
        callback: logic.toggleAudio,
        child: border(child: text(audio ? "Audio On" : "Audio Off")));
  });

  final Widget region = WatchBuilder(game.region, (Region region) {
    return button(text(enumString(region), fontSize: 20),
        logic.deselectRegion,
        width: 185, hint: 'Region',
        height: 63,
        fillColor: colours.orange,
        borderColor: colours.orange,
        borderWidth: 6,
        borderRadius: BorderRadius.only(topRight: radius4, bottomRight: radius4),
    );
  });
}

Widget buildToggleFullscreen() {
  return onPressed(
    callback: () {
      if (fullScreenActive) {
        fullScreenExit();
      } else {
        fullScreenEnter();
      }
    },
    hint: "F11",
    child: border(
      child: Row(
        children: [
          text(fullScreenActive ? "Exit Fullscreen" : "Fullscreen"),
          width4,
          buildDecorationImage(
              image: icons.fullscreen, width: 20, height: 20, borderWidth: 0),
        ],
      ),
    ),
  );
}
