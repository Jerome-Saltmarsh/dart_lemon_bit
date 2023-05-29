import 'package:flutter/material.dart';
import 'package:gamestream_flutter/gamestream/account/account_service.dart';
import 'package:gamestream_flutter/gamestream/account/data_authentication.dart';
import 'package:gamestream_flutter/gamestream/games/isometric/game_isometric_colors.dart';
import 'package:gamestream_flutter/library.dart';
import 'package:gamestream_flutter/modules/website/enums.dart';
import 'package:gamestream_flutter/gamestream/account/sign_in_with_facebook.dart';
import 'package:gamestream_flutter/ui/build.dart';
import 'package:gamestream_flutter/ui/dialogs.dart';
import 'package:gamestream_flutter/ui/style.dart';

final closeDialogButton = button(
    "close",
    gamestream.games.gameWebsite.showDialogGames,
    borderColor: GameIsometricColors.none
);

final widgets = _Widgets();
final buttons = _Buttons();

class _Widgets {
  // final Widget totalZombies = build.totalZombies();
  final Widget timeZone = build.timeZone();

  final textUpgrade = button(
    text("PURCHASE", color: GameIsometricColors.green, bold: true),
    AccountService.openStripeCheckout,
    fillColor: GameIsometricColors.none,
    borderColor: GameIsometricColors.green,
    borderColorMouseOver: GameIsometricColors.green,
    borderWidth: 2,
  );

  final textReactivateSubscription = button(
    text("Activate", color: GameIsometricColors.green, underline: true),
    AccountService.openStripeCheckout,
    fillColor: GameIsometricColors.none,
    borderColorMouseOver: GameIsometricColors.green,
    borderColor: GameIsometricColors.none,
  );

  final buttonClose = buildButton("Close",gamestream.games.gameWebsite.showDialogGames);
  final buttonOkay = buildButton("Okay",gamestream.games.gameWebsite.showDialogGames);
  final buttonGreat = buildButton("Great",gamestream.games.gameWebsite.showDialogGames);

  final buttonNo = button(text("No", color: GameIsometricColors.white80),gamestream.games.gameWebsite.showDialogGames, fillColor: GameIsometricColors.none,
    fillColorMouseOver: GameIsometricColors.none,
    borderColor: GameIsometricColors.none,
    width: 100,
  );

  final buttonChangeDisplayName = button(text("Change Public Name", color: GameIsometricColors.green),gamestream.games.gameWebsite.showDialogChangePublicName, borderColor: GameIsometricColors.green);
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
    gamestream.games.gameWebsite.dialog.value = WebsiteDialog.Login;
  }, width: style.buttonWidth, height: style.buttonHeight, borderWidth: 3,
    fillColor: GameIsometricColors.none,
    borderColor: GameIsometricColors.none,
    fillColorMouseOver: GameIsometricColors.green,
    borderColorMouseOver: GameIsometricColors.green,
    borderRadius: borderRadius2,
  );

  final Widget loginTestUser01 = _buildFakeLoginButton('test_01', "(Active Sub)");
  final Widget loginTestUser02 = _buildFakeLoginButton('test_02', "(Expired Sub)");
  final Widget loginTestUser03 = _buildFakeLoginButton('test_03', "(No Sub)");

  final Widget spawnRandomUser = button("Random User", (){
    final userId = 'random_${random.nextInt(9999999)}';
    AccountService.login(DataAuthentication(userId: userId, name: userId, email: "$userId@email.com"));
  });

  final showDialogSubscribed = button("Sub Success",gamestream.games.gameWebsite.showDialogSubscriptionSuccessful);

  final signInWithFacebookButton = button(
    Container(
      width: 220,
    padding: EdgeInsets.symmetric(horizontal: 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        text("Facebook"),
        width16,
        text("Continue", color: Colors.white),
      ],
    ),
  ), getAuthenticationFacebook,
    fillColor: GameIsometricColors.facebook,
    fillColorMouseOver: GameIsometricColors.facebook,
    borderColorMouseOver: GameIsometricColors.none,
    borderColor: GameIsometricColors.none,
    borderWidth: 1,
  );

  final account = button(_iconSettings, (){
    if (gamestream.games.gameWebsite.dialog.value != WebsiteDialog.Account){
      gamestream.games.gameWebsite.dialog.value = WebsiteDialog.Account;
    }else{
      gamestream.games.gameWebsite.dialog.value = WebsiteDialog.Games;
    }
  },
      height: style.buttonHeight,
      width: style.buttonWidth,
      fillColor: GameIsometricColors.none,
      fillColorMouseOver: GameIsometricColors.green,
      borderColorMouseOver: GameIsometricColors.green,
      borderColor: GameIsometricColors.none,
      borderRadius: borderRadius2,
  );

  Widget buildAccount(bool hovering){
    return button(_iconSettings, (){
      if (gamestream.games.gameWebsite.dialog.value != WebsiteDialog.Account){
        gamestream.games.gameWebsite.dialog.value = WebsiteDialog.Account;
      }else{
        gamestream.games.gameWebsite.dialog.value = WebsiteDialog.Games;
      }
    },
      height: style.buttonHeight,
      width: style.buttonWidth,
      fillColor: hovering ? GameIsometricColors.green : GameIsometricColors.none,
      fillColorMouseOver: GameIsometricColors.green,
      borderColorMouseOver: GameIsometricColors.green,
      borderColor: hovering ? GameIsometricColors.green : GameIsometricColors.none,
      borderRadius: borderRadius2,
    );
  }
}
Widget _buildFakeLoginButton(String userId, String text){
  return button('$userId $text', (){
    AccountService.login(DataAuthentication(userId: userId, name: userId, email: "$userId@email.com"));
  });
}

final backButton = button(text("Back", color: GameIsometricColors.white618), () {
  gamestream.games.gameWebsite.dialog.value = WebsiteDialog.Games;
}, fillColor: GameIsometricColors.none,
  fillColorMouseOver: GameIsometricColors.none,
  borderColor: GameIsometricColors.none,
);

Widget buildMenuButton(String text, Function onPressed){
  return button(text,
    onPressed,
    width: style.buttonWidth,
    height: style.buttonHeight,
    borderColor: GameIsometricColors.none,
    fillColor: GameIsometricColors.white05,
    fillColorMouseOver: GameIsometricColors.black05,
    borderColorMouseOver: GameIsometricColors.none,
    borderRadius: borderRadius0,
    boldOnHover: true
  );
}

Widget panelDark({required Widget child, bool expand = true}){
  return buildPanel(child: child, expand: expand, color: GameIsometricColors.black10);
}

Widget panelLight({required Widget child, bool expand = true}){
  return buildPanel(child: child, expand: expand, color: GameIsometricColors.white05);
}

Widget buildPanel({required Widget child, bool expand = true, Color? color}){
  return Container(
    padding: padding16,
    child: child,
    width: expand ? double.infinity : null,
    decoration: BoxDecoration(
      color: color ?? GameIsometricColors.white05,
      borderRadius: borderRadius4,
    ),
  );
}


