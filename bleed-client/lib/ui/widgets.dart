import 'package:bleed_client/classes/Authentication.dart';
import 'package:bleed_client/common/CharacterType.dart';
import 'package:bleed_client/common/ClientRequest.dart';
import 'package:bleed_client/constants/colours.dart';
import 'package:bleed_client/flutterkit.dart';
import 'package:bleed_client/modules/modules.dart';
import 'package:bleed_client/modules/website/enums.dart';
import 'package:bleed_client/send.dart';
import 'package:bleed_client/server/server.dart';
import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/ui/actions/signInWithFacebook.dart';
import 'package:bleed_client/ui/build.dart';
import 'package:bleed_client/ui/dialogs.dart';
import 'package:bleed_client/ui/state/decorationImages.dart';
import 'package:bleed_client/ui/style.dart';
import 'package:bleed_client/utils/widget_utils.dart';
import 'package:flutter/material.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_math/random.dart';
import 'package:lemon_watch/watch_builder.dart';

import '../styles.dart';
import 'compose/hudUI.dart';

final closeDialogButton = button("close", setDialogGames, borderColor: colours.none);

final _Widgets widgets = _Widgets();
final _Buttons buttons = _Buttons();
final _Logos logos = _Logos();

final _BuildDialog buildHudDialog = _BuildDialog();

class _Logos {
  Widget google = Container(
    width: 30,
    height: 30,
    decoration: BoxDecoration(image: decorationImages.google),
  );
  Widget facebook = Container(
    width: 30,
    height: 30,
    decoration: BoxDecoration(
        color: none,
        image: decorationImages.facebook),
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
            text("Hero", size: 30),
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
                            size: fontSize),
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
  final Widget title = build.title();
  final Widget totalZombies = build.totalZombies();
  final Widget timeZone = build.timeZone();
  final Widget theme = build.theme();

  final textUpgrade = button(
    text("PURCHASE", color: green, bold: true),
    core.actions.openStripeCheckout,
    fillColor: none,
    borderColor: green,
    borderColorMouseOver: green,
    borderWidth: 2,
  );

  final textReactivateSubscription = button(
    text("Activate", color: green, underline: true),
    core.actions.openStripeCheckout,
    fillColor: none,
    borderColorMouseOver: green,
    borderColor: none,
  );

  final buttonClose = buildButton("Close", website.actions.showDialogGames);
  final buttonOkay = buildButton("Okay", website.actions.showDialogGames);
  final buttonGreat = buildButton("Great", website.actions.showDialogGames);

  final buttonNo = button(text("No", color: colours.white80), website.actions.showDialogGames, fillColor: colours.none,
    fillColorMouseOver: none,
    borderColor: colours.none,
    width: 100,
  );

  final buttonChangeDisplayName = button(text("Change Public Name", color: colours.green), website.actions.showDialogChangePublicName, borderColor: colours.green);

  final subscribeButton = button(
      Row(
        children: [
          icons.creditCard,
          width4,
          text("SUBSCRIBE", bold: true),
          width4,
        ],
      ),
      core.actions.openStripeCheckout,
      fillColor: colours.green,
      borderColor: colours.none,
      fillColorMouseOver: colours.green);
}

final authenticationRequired = Exception("Authentication Required");

final _iconLogin = Container(
  width: 32,
  height: 32,
  decoration: BoxDecoration(
      image: decorationImages.login
  ),
);

final _iconSettings = Container(
  width: 32,
  height: 32,
  decoration: BoxDecoration(
      image: decorationImages.settings2
  ),
);

class _Buttons {

  final Widget login = button(Row(
    mainAxisAlignment: axis.main.center,
    children: [
      width16,
      text("LOGIN", size: 20, weight: bold),
      width16,
      _iconLogin,
    ],
  ), (){
    website.state.dialog.value = WebsiteDialog.Login;
  }, width: style.buttonWidth, height: style.buttonHeight, borderWidth: 3,
    fillColor: colours.none,
    borderColor: colours.none,
    fillColorMouseOver: colours.green,
    borderColorMouseOver: colours.green,
    borderRadius: borderRadius2,
  );

  final Widget loginTestUser01 = _buildFakeLoginButton('test_01', "(Active Sub)");
  final Widget loginTestUser02 = _buildFakeLoginButton('test_02', "(Expired Sub)");
  final Widget loginTestUser03 = _buildFakeLoginButton('test_03', "(No Sub)");

  final Widget spawnRandomUser = button("Random User", (){
    final userId = 'random_${random.nextInt(9999999)}';
    core.actions.login(Authentication(userId: userId, name: userId, email: "$userId@email.com"));
  });

  final Widget showDialogSubscribed = button("Sub Success", website.actions.showDialogSubscriptionSuccessful);


  final Widget signInWithFacebookButton = button(
    Container(
      width: 220,
    padding: EdgeInsets.symmetric(horizontal: 8),
    child: Row(
      mainAxisAlignment: axis.main.apart,
      children: [
        logos.facebook,
        width16,
        text("Continue", color: Colors.white),
      ],
    ),
  ), getAuthenticationFacebook,
    fillColor: colours.facebook,
    fillColorMouseOver: colours.facebook,
    borderColorMouseOver: none,
    borderColor: none,
    borderWidth: 1,
  );

  final Widget signInWithGoogleButton = button(
    Container(
      width: 220,
    padding: EdgeInsets.symmetric(horizontal: 8),
    child: Row(
      mainAxisAlignment: axis.main.apart,
      children: [
        logos.google,
        width16,
        text("Continue", color: Colors.black),
      ],
    ),
  ), core.actions.loginWithGoogle,
    borderColor: colours.black618,
    borderColorMouseOver: colours.black618,
    fillColor: Colors.white,
    fillColorMouseOver: Colors.white,
    borderWidth: 1,
  );

  final Widget signInWithUsernamePassword = button(
    Container(
      width: 220,
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: axis.main.apart,
        children: [
          logos.facebook,
          width16,
          text("Enter Username Password", color: Colors.white),
        ],
      ),
    ), () async {

  },
    fillColor: colours.facebook,
    fillColorMouseOver: colours.facebook,
    borderColorMouseOver: none,
    borderColor: none,
    borderWidth: 1,
  );

  final Widget account = button(_iconSettings, (){
    if (website.state.dialog.value != WebsiteDialog.Account){
      website.state.dialog.value = WebsiteDialog.Account;
    }else{
      website.state.dialog.value = WebsiteDialog.Games;
    }
  },
      height: style.buttonHeight,
      width: style.buttonWidth,
      fillColor: colours.none,
      fillColorMouseOver: colours.green,
      borderColorMouseOver: colours.green,
      borderColor: colours.none,
      borderRadius: borderRadius2,
  );

  Widget buildAccount(bool hovering){
    return button(_iconSettings, (){
      if (website.state.dialog.value != WebsiteDialog.Account){
        website.state.dialog.value = WebsiteDialog.Account;
      }else{
        website.state.dialog.value = WebsiteDialog.Games;
      }
    },
      height: style.buttonHeight,
      width: style.buttonWidth,
      fillColor: hovering ? colours.green : colours.none,
      fillColorMouseOver: colours.green,
      borderColorMouseOver: colours.green,
      borderColor: hovering ? colours.green : colours.none,
      borderRadius: borderRadius2,
    );
  }

  final Widget buttonLogout = buildMenuButton("Logout", core.actions.logout);
  final Widget buttonAccount = buildMenuButton("Account", website.actions.showDialogAccount);
  final Widget buttonGames = buildMenuButton("Games", website.actions.showDialogGames);


  final Widget debug = button("Debug", toggleDebugMode);
  final Widget exit = button('Exit', core.actions.exitGame);
  final Widget edit = button("Edit", core.actions.toggleEditMode);
  final Widget editor = button("Editor", core.actions.openMapEditor);
  final Widget register = button("Register", core.actions.openMapEditor);
  final Widget changeCharacter = button("Change Hero", () {
    sendClientRequest(ClientRequest.Reset_Character_Type);
  });
  final Widget audio = WatchBuilder(game.settings.audioMuted, (bool audio) {
    return onPressed(
        callback: core.actions.toggleAudio,
        child: border(child: text(audio ? "Audio On" : "Audio Off")));
  });
}

Widget buildToggleFullscreen() {
  return onPressed(
    callback: () {
      if (fullScreenActive) {
        engine.actions.fullScreenExit();
      } else {
        engine.actions.fullScreenEnter();
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

Widget _buildFakeLoginButton(String userId, String text){
  return button('$userId $text', (){
     core.actions.login(Authentication(userId: userId, name: userId, email: "$userId@email.com"));
  });
}

final backButton = button(text("Back", color: colours.white618), () {
  website.state.dialog.value = WebsiteDialog.Games;
}, fillColor: colours.none,
  fillColorMouseOver: none,
  borderColor: colours.none,
);

final icons = _Icons();

class _Icons {
  final creditCard = buildDecorationImage(image: decorationImages.creditCard, color: none, width: 32, height: 32, borderColor: none);
  final cherries = buildDecorationImage(image: decorationImages.cherries, color: none, width: 32, height: 32, borderColor: none);
  final mail = buildDecorationImage(image: decorationImages.mail, color: none, width: 48, height: 48, borderColor: none);
}


Widget buildInfo({required Widget child}){
  return border(
    fillColor: colours.white05,
    color: none,
    padding: padding16,
    child: child,
  );
}

Widget buildMenuButton(String text, Function onPressed){
  return button(text,
    onPressed,
    width: style.buttonWidth,
    height: style.buttonHeight,
    borderColor: none,
    fillColor: colours.white05,
    fillColorMouseOver: colours.black05,
    borderColorMouseOver: colours.none,
    borderRadius: borderRadius0,
    boldOnHover: true
  );
}

Widget panelDark({required Widget child, bool expand = true}){
  return panel(child: child, expand: expand, color: colours.black10);
}

Widget panelLight({required Widget child, bool expand = true}){
  return panel(child: child, expand: expand, color: colours.white05);
}

Widget panel({required Widget child, bool expand = true, Color? color}){
  return Container(
    padding: padding16,
    child: child,
    width: expand ? double.infinity : null,
    decoration: BoxDecoration(
      color: color ?? colours.white05,
      borderRadius: borderRadius4,
    ),
  );
}


