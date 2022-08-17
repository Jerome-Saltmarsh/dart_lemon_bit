import 'package:flutter/material.dart';
import 'package:gamestream_flutter/colours.dart';
import 'package:gamestream_flutter/control/classes/authentication.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/icons.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:gamestream_flutter/modules/website/enums.dart';
import 'package:gamestream_flutter/ui/actions/sign_in_with_facebook.dart';
import 'package:gamestream_flutter/ui/build.dart';
import 'package:gamestream_flutter/ui/dialogs.dart';
import 'package:gamestream_flutter/ui/style.dart';
import 'package:lemon_math/library.dart';

import '../styles.dart';

final closeDialogButton = button(
    "close",
    modules.website.actions.showDialogGames,
    borderColor: colours.none
);

final widgets = _Widgets();
final buttons = _Buttons();

class _Widgets {
  // final Widget totalZombies = build.totalZombies();
  final Widget timeZone = build.timeZone();

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
}

final authenticationRequired = Exception("Authentication Required");

// final _iconLogin = Container(
//   width: 32,
//   height: 32,
//   decoration: BoxDecoration(
//       image: decorationImages.login
//   ),
// );

final _iconSettings = buildImage('images/icons/icon-settings.png', width: 32, height: 32);

class _Buttons {

  final Widget login = button(Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      text("LOGIN", size: 20, weight: bold),
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

  final showDialogSubscribed = button("Sub Success", website.actions.showDialogSubscriptionSuccessful);

  final signInWithFacebookButton = button(
    Container(
      width: 220,
    padding: EdgeInsets.symmetric(horizontal: 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        icons.facebook,
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

  final signInWithGoogleButton = button(
    Container(
      width: 220,
    padding: EdgeInsets.symmetric(horizontal: 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        icons.google,
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

  final account = button(_iconSettings, (){
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


  final Widget exit = button('Exit', core.actions.exitGame);
  final Widget changeCharacter = button("Change Hero", () {
    // sendClientRequest(ClientRequest.Reset_Character_Type);
  });
}

// Widget buildToggleFullscreen() {
//   return onPressed(
//     callback: () {
//       if (fullScreenActive) {
//         engine.fullScreenExit();
//       } else {
//         engine.fullScreenEnter();
//       }
//     },
//     hint: "F11",
//     child: border(
//       child: Row(
//         children: [
//           text(fullScreenActive ? "Exit Fullscreen" : "Fullscreen"),
//           width4,
//           buildDecorationImage(
//               image: decorationImages.fullscreen, width: 20, height: 20, borderWidth: 0),
//         ],
//       ),
//     ),
//   );
// }

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


