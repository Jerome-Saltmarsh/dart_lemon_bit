import 'package:flutter/material.dart';
import 'package:gamestream_flutter/library.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:gamestream_flutter/modules/website/enums.dart';
import 'package:gamestream_flutter/ui/actions/sign_in_with_facebook.dart';
import 'package:gamestream_flutter/ui/build.dart';
import 'package:gamestream_flutter/ui/dialogs.dart';
import 'package:gamestream_flutter/ui/style.dart';

final closeDialogButton = button(
    "close",
    modules.website.actions.showDialogGames,
    borderColor: GameColors.none
);

final widgets = _Widgets();
final buttons = _Buttons();

class _Widgets {
  // final Widget totalZombies = build.totalZombies();
  final Widget timeZone = build.timeZone();

  final textUpgrade = button(
    text("PURCHASE", color: GameColors.green, bold: true),
    AccountService.openStripeCheckout,
    fillColor: GameColors.none,
    borderColor: GameColors.green,
    borderColorMouseOver: GameColors.green,
    borderWidth: 2,
  );

  final textReactivateSubscription = button(
    text("Activate", color: GameColors.green, underline: true),
    AccountService.openStripeCheckout,
    fillColor: GameColors.none,
    borderColorMouseOver: GameColors.green,
    borderColor: GameColors.none,
  );

  final buttonClose = buildButton("Close", website.actions.showDialogGames);
  final buttonOkay = buildButton("Okay", website.actions.showDialogGames);
  final buttonGreat = buildButton("Great", website.actions.showDialogGames);

  final buttonNo = button(text("No", color: GameColors.white80), website.actions.showDialogGames, fillColor: GameColors.none,
    fillColorMouseOver: GameColors.none,
    borderColor: GameColors.none,
    width: 100,
  );

  final buttonChangeDisplayName = button(text("Change Public Name", color: GameColors.green), website.actions.showDialogChangePublicName, borderColor: GameColors.green);
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
    fillColor: GameColors.none,
    borderColor: GameColors.none,
    fillColorMouseOver: GameColors.green,
    borderColorMouseOver: GameColors.green,
    borderRadius: borderRadius2,
  );

  final Widget loginTestUser01 = _buildFakeLoginButton('test_01', "(Active Sub)");
  final Widget loginTestUser02 = _buildFakeLoginButton('test_02', "(Expired Sub)");
  final Widget loginTestUser03 = _buildFakeLoginButton('test_03', "(No Sub)");

  final Widget spawnRandomUser = button("Random User", (){
    final userId = 'random_${random.nextInt(9999999)}';
    AccountService.login(DataAuthentication(userId: userId, name: userId, email: "$userId@email.com"));
  });

  final showDialogSubscribed = button("Sub Success", website.actions.showDialogSubscriptionSuccessful);

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
    fillColor: GameColors.facebook,
    fillColorMouseOver: GameColors.facebook,
    borderColorMouseOver: GameColors.none,
    borderColor: GameColors.none,
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
      fillColor: GameColors.none,
      fillColorMouseOver: GameColors.green,
      borderColorMouseOver: GameColors.green,
      borderColor: GameColors.none,
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
      fillColor: hovering ? GameColors.green : GameColors.none,
      fillColorMouseOver: GameColors.green,
      borderColorMouseOver: GameColors.green,
      borderColor: hovering ? GameColors.green : GameColors.none,
      borderRadius: borderRadius2,
    );
  }
}
Widget _buildFakeLoginButton(String userId, String text){
  return button('$userId $text', (){
    AccountService.login(DataAuthentication(userId: userId, name: userId, email: "$userId@email.com"));
  });
}

final backButton = button(text("Back", color: GameColors.white618), () {
  website.state.dialog.value = WebsiteDialog.Games;
}, fillColor: GameColors.none,
  fillColorMouseOver: GameColors.none,
  borderColor: GameColors.none,
);


Widget buildInfo({required Widget child}){
  return border(
    fillColor: GameColors.white05,
    color: GameColors.none,
    padding: padding16,
    child: child,
  );
}

Widget buildMenuButton(String text, Function onPressed){
  return button(text,
    onPressed,
    width: style.buttonWidth,
    height: style.buttonHeight,
    borderColor: GameColors.none,
    fillColor: GameColors.white05,
    fillColorMouseOver: GameColors.black05,
    borderColorMouseOver: GameColors.none,
    borderRadius: borderRadius0,
    boldOnHover: true
  );
}

Widget panelDark({required Widget child, bool expand = true}){
  return buildPanel(child: child, expand: expand, color: GameColors.black10);
}

Widget panelLight({required Widget child, bool expand = true}){
  return buildPanel(child: child, expand: expand, color: GameColors.white05);
}

Widget buildPanel({required Widget child, bool expand = true, Color? color}){
  return Container(
    padding: padding16,
    child: child,
    width: expand ? double.infinity : null,
    decoration: BoxDecoration(
      color: color ?? GameColors.white05,
      borderRadius: borderRadius4,
    ),
  );
}


