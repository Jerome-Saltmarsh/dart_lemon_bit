import 'package:bleed_client/assets.dart';
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
import 'package:lemon_engine/game.dart';
import 'package:lemon_engine/properties/fullscreen_active.dart';
import 'package:lemon_watch/watch_builder.dart';

import '../logic.dart';
import '../stripe.dart';
import '../styles.dart';
import '../toString.dart';
import 'compose/hudUI.dart';

final _Widgets widgets = _Widgets();
final _Buttons buttons = _Buttons();
final _Logos logos = _Logos();

final _BuildDialog buildDialog = _BuildDialog();

class _Logos {
  Widget google = Container(
    width: 30,
    height: 30,
    decoration: BoxDecoration(image: decorationImages.google),
  );
}

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
  final Widget totalZombies = build.totalZombies();
  final Widget timeZone = build.timeZone();
  final Widget theme = build.theme();


  final Widget settingsMenu = Column(
    children: [
      buttons.account,
      height4,
      buttons.logout,
      height4,
      buttons.subscribe,
    ],
  );
}

final authenticationRequired = Exception("Authentication Required");

void openStripeCheckout(){
  print("openStripeCheckout()");
  if (!authenticated){
    throw authenticationRequired;
  }
  stripeCheckout(
      userId: authorization.value!.userId,
      email: authorization.value!.email
  );
}

class _Buttons {

  final Widget login = button("Login", (){
      game.dialog.value = Dialogs.Login;
  }, width: 200, height: 63, borderWidth: 2);

  final Widget signInWithGoogleB = button(Container(
    padding: EdgeInsets.symmetric(horizontal: 8),
    child: Row(
      mainAxisAlignment: axis.main.apart,
      children: [
        logos.google,
        width16,
        text("Sign in with Google", color: Colors.black),
      ],
    ),
  ), signInWithGoogle,
    fillColor: Colors.white,
    fillColorMouseOver: Colors.white,
    borderColorMouseOver: colours.blue,
    borderWidth: 3,
  );

  final Widget account = button("Account", () {
    game.dialog.value = Dialogs.Account;
  }, width: 200);
  final Widget logout = NullableWatchBuilder<Authorization?>(authorization, (Authorization? authorization){
    if (authorization == null){
      text ('No User Logged In');
    }
    return button('Logout ${authorization?.displayName}', signOut, width: 200);
  });
  final Widget subscribe =
      button("Subscribe \$4.99", openStripeCheckout, width: 200);

  final Widget menu = NullableWatchBuilder<Authorization?>(authorization,
      (Authorization? authorization) {

    if (authorization == null) {
      return buttons.login;
    }
    return mouseOver(builder: (BuildContext context, bool mouseOver) {
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

    const _width = 200.0;
    const _height = 63.0;

    return onHover((bool hovering){

      if (!hovering){
        return button(
          text(enumString(region), fontSize: 20),
          logic.deselectRegion,
          width: _width,
          hint: 'Region',
          height: _height,
          fillColor: colours.green,
          borderColor: colours.green,
          borderWidth: 6,
          borderRadius: BorderRadius.only(topRight: radius4, bottomRight: radius4),
        );
      }

      return Container(
        color: colours.black20,
        child: Column(
          children: [
            border(
                width: _width,
                height: _height,
                fillColor: colours.green,
                color: colours.green,
                radius: borderRadius0,
                child: text("Region", fontSize: 20)),
            ...selectableRegions.map((value) {
            return button(text(enumString(value)), (){
              game.region.value = value;
            },
            fillColor: region == value ? Colors.red : Colors.orange,
            width: _width,
            height: _height,
              borderRadius: borderRadius0,
            );
          }).toList()],
        ),
      );

    });
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
              image: decorationImages.fullscreen, width: 20, height: 20, borderWidth: 0),
        ],
      ),
    ),
  );
}
