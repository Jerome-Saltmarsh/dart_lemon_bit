
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firestore_client/firestoreService.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/colours.dart';
import 'package:gamestream_flutter/control/state/game_type.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/modules/core/enums.dart';
import 'package:gamestream_flutter/modules/core/init.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:gamestream_flutter/modules/ui/module.dart';
import 'package:gamestream_flutter/modules/website/enums.dart';
import 'package:gamestream_flutter/servers.dart';
import 'package:gamestream_flutter/shared_preferences.dart';
import 'package:gamestream_flutter/to_string.dart';
import 'package:gamestream_flutter/ui/builders/build_layout.dart';
import 'package:gamestream_flutter/ui/dialogs.dart';
import 'package:gamestream_flutter/ui/style.dart';
import 'package:gamestream_flutter/ui/widgets.dart';
import 'package:gamestream_flutter/utils.dart';
import 'package:gamestream_flutter/utils/widget_utils.dart';
import 'package:gamestream_flutter/website/build/build_column_games.dart';
import 'package:gamestream_flutter/website/build_layout_website.dart';
import 'package:golden_ratio/constants.dart';
import 'package:lemon_engine/actions.dart';
import 'package:lemon_watch/watch_builder.dart';

import '../isometric/ui/build_hud.dart';
import '../network/web_socket.dart';
import '../styles.dart';
import 'build.dart';

final nameController = TextEditingController();

Widget buildDialogLogin() {
  return dialog(
      padding: 16,
      color: colours.white05,
      borderColor: colours.none,
      height: 400,
      borderWidth: 3,
      child: buildLayout(
          bottomLeft: button("Sign up", (){}),
          bottomRight: button("Back", () {
            website.state.dialog.value = WebsiteDialog.Games;
          }, fillColor: colours.none,
            borderColor: colours.none,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              height32,
              buttons.signInWithGoogleButton,
              height16,
              buttons.signInWithFacebookButton,
              height32,
            ],
          )));
}

Widget buildWatchErrorMessage(){
  return WatchBuilder(core.state.error, (String? message){
    if (message == null) return empty;
    return buildErrorDialog(message);
  });
}

Widget buildErrorDialog(String message, {Widget? bottomRight}){
  return dialog(
      width: style.dialogWidthMedium,
      height: style.dialogHeightVerySmall,
      color: colours.brownDark,
      borderColor: colours.none,
      child: buildLayout(
          child: Center(
            child: text(message, color: colours.white),
          ),
          bottomRight: bottomRight ?? text("okay", onPressed: core.actions.clearError)
      )
  );
}

Widget buildAccount(Account? account) {
  return buildWatchConnection(account);
}

WatchBuilder<Connection> buildWatchConnection(Account? account) {
  return WatchBuilder(webSocket.connection, (Connection connection) {
    switch (connection) {
      case Connection.Connecting:
        return ui.layouts.buildLayoutLoading();
      case Connection.Connected:
        return buildHud();
      case Connection.None:
        return buildPageWebsite();
      default:
        return _views.connection;
    }
  });
}

Positioned buildLoginSuggestionBox() {
  return Positioned(
        top: 8,
        right: 8,
        child: Container(
          padding: padding16,
            decoration: BoxDecoration(
              color: colours.white,
              borderRadius: borderRadius4,
            ),
            width: 230.0 * goldenRatio_1618,
            height: 230,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                height16,
                buttons.signInWithGoogleButton,
                height16,
                buttons.signInWithFacebookButton,
                height32,
                text("Close", color: colours.black618, underline: true),
              ],
            ))
    );
}

WatchBuilder<WebsiteDialog> buildWatchBuilderDialog() {
  return WatchBuilder(website.state.dialog, (WebsiteDialog dialogs) {
      switch (dialogs) {
        case WebsiteDialog.Custom_Maps:
          return website.build.dialogCustomMaps();

        case WebsiteDialog.Subscription_Status_Changed:
          return buildDialogSubscriptionStatus();

        case WebsiteDialog.Subscription_Cancelled:
          return buildDialogSubscriptionCancelled();

        case WebsiteDialog.Subscription_Successful:
          return buildDialogSubscriptionSuccessful();

        case WebsiteDialog.Account_Created:
          return buildDialogAccountCreated();

        case WebsiteDialog.Welcome_2:
          return buildDialogWelcome2();

        case WebsiteDialog.Change_Region:
          return buildDialogChangeRegion();

        case WebsiteDialog.Login_Error:
          return dialog(
              child: buildLayout(
                  child: text("Login Error"), bottomRight: backButton));

        case WebsiteDialog.Change_Public_Name:
          return buildDialogChangePublicName();

        case WebsiteDialog.Account:
          return buildDialogAccount();

        case WebsiteDialog.Login:
          return buildDialogLogin();

        case WebsiteDialog.Invalid_Arguments:
          return dialog(child: text("Invalid Arguments"));

        case WebsiteDialog.Subscription_Required:
          return dialog(child: text("Subscription Required"));

        case WebsiteDialog.Games:
          return buildColumnGames();

        case WebsiteDialog.Confirm_Logout:
          return dialog(child: text("Confirm Logout"));

        case WebsiteDialog.Confirm_Cancel_Subscription:
          return buildDialogConfirmCancelSubscription();
      }
    });
}

Widget buildDialogChangeRegion() {
  return dialog(
      height: 500,
      padding: 16,
      borderColor: colours.none,
      color: colours.white05,
      child: buildLayout(
          bottomRight: widgets.buttonClose,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...selectableRegions.map((region) {
                return button(enumString(region), () {
                  core.state.region.value = region;
                  modules.website.actions.showDialogGames();
                },
                    fillColor: region == core.state.region.value
                        ? colours.black20
                        : colours.white05,
                    borderColor: colours.none,
                    fillColorMouseOver: colours.green,
                    borderColorMouseOver: colours.green,
                    margin: const EdgeInsets.only(bottom: 8));
              }).toList()
            ],
          )));
}


Widget? buildMenuDebug() {
  return dev(onHover((bool hovering){
      return Container(
        width: style.buttonWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hovering) ...[
              buttons.showDialogSubscribed,
              buttons.loginTestUser01,
              buttons.loginTestUser02,
              buttons.loginTestUser03,
              buttons.spawnRandomUser,
              button("Show Dialog - Welcome", website.actions.showDialogWelcome),
            ],
            border(child: "Debug")
          ],
        ),
      );
    }
    ));
}

final _views = _Views();
final _buildView = _BuildView();

class _Views {
  final Widget selectRegion = _buildView.selectRegion();
  final Widget connecting = _buildView.connecting();
  final Widget connection = _buildView.connection();
}

final Map<Connection, String> connectionMessage = {
  Connection.Done: "Connection to the server was lost",
  Connection.Error: "An error occurred with the connection to the server",
  Connection.Connected: "Connected to server",
  Connection.Connecting: "Connecting to server",
  Connection.Failed_To_Connect: "Unable to establish a connection",
  Connection.None: "There is no connection to the server",
};

class _BuildView {
  Widget connection() {
    return WatchBuilder(webSocket.connection, (Connection value) {
      return center(Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          buildTitle(),
          height64,
          text(connectionMessage[value], size: FontSize.Large),
          height16,
          button("Cancel", () {
            core.actions.exitGame();
            webSocket.disconnect();
          }, width: 100),
          height64,
        ],
      ));
    });
  }

  Widget selectRegion() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          margin: EdgeInsets.only(top: 140),
          child: SingleChildScrollView(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                      child: text("SELECT REGION",
                          size: 50, weight: bold)),
                  height16,
                  ...selectableServerTypes.map(_buildSelectRegionButton)
                ]),
          ),
        ),
      ],
    );
  }


  Widget connecting() {
    return WatchBuilder(core.state.region, (Region region) {
      return center(Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 80,
            child: AnimatedTextKit(repeatForever: true, animatedTexts: [
              RotateAnimatedText("Connecting to ${enumString(gameType.value)} (${enumString(region)})",
                  textStyle: TextStyle(color: Colors.white, fontSize: 30)),
            ]),
          ),
          height32,
          onPressed(
              child: text("Cancel"),
              callback: () {
                sharedPreferences.remove('server');
                refreshPage();
              }),
        ],
      ));
    });
  }
}

Widget _buildSelectRegionButton(Region region) {
  return button(
    text(
      enumString(region),
      size: 25,
      // fontWeight: FontWeight.bold
    ),
    () {
      core.state.region.value = region;
    },
    margin: EdgeInsets.only(bottom: 8),
    width: 200,
    borderWidth: 3,
    // fillColor: colours.black15,
    fillColorMouseOver: colours.black15,
  );
}

Widget? dev(Widget child){
  return isLocalHost ? child : null;
}

Widget margin({
  required Widget child,
  double left = 0,
  double top = 0,
  double right = 0,
  double bottom = 0
}){
  return Container(
    child: child,
    margin: EdgeInsets.only(
        left: left,
        top: top,
        right: right,
        bottom: bottom
    )
  );
}


Widget watchAccount(Widget builder(Account? value)) {
  return WatchBuilder(core.state.account, (Account? account) {
    return builder(account);
  });
}

Widget buildTopMessage(){
  print("buildTopMessage()");
  return watchAccount((account) {
    return WatchBuilder(website.state.dialog, (dialog){

      if (dialog != WebsiteDialog.Games) return empty;

      if (account == null){
        return onHover((hovering){
          return margin(
            top: 10,
            child: Row(
              children: [
                text("Sign in and subscribe", color: colours.green, underline: hovering, onPressed: website.actions.showDialogLogin),
                text(" to unlock all games", color: colours.white618, onPressed: website.actions.showDialogLogin, underline: hovering),
              ],
            ),
          );
        });
      }

      if (account.subscriptionActive) {
        return margin(
          top: 10,
          child: text("Premium",
              color: colours.green,
              size: 18,
              onPressed: website.actions.showDialogAccount),
        );
      }

      if (account.subscriptionNone) {
        return button(
            Row(
              children: [
                text("Subscribe", color: colours.green, bold: true, size: 20),
                onPressed(
                    child: text(" for \$9.99 per month to unlock all games",
                        color: colours.white80, size: 20),
                    callback: core.actions.openStripeCheckout),
              ],
            ),
            core.actions.openStripeCheckout,
            fillColorMouseOver: none,
            borderColor: none,
            borderColorMouseOver: colours.white80);
      }

      if (account.subscriptionEnded) {
        return Row(
          children: [
            onPressed(
              callback: core.actions.openStripeCheckout,
              child: text(
                  "Your subscription expired on ${formatDate(account.subscriptionEndDate!)}",
                  color: colours.red),
            ),
            width16,
            button(text("Renew", color: green), core.actions.openStripeCheckout,
                borderColor: colours.green),
          ],
        );
      }

      if (account.subscriptionStatus == SubscriptionStatus.Canceled){
        final subscriptionEndDate = account.subscriptionEndDate;
        if (subscriptionEndDate != null){
          return margin(
            top: 10,
              child:                   text("Premium subscription cancelled : ends ${formatDate(subscriptionEndDate)}", color: colours.white618,
                  onPressed: website.actions.showDialogAccount
              ));
        }
      }

      return empty;
    });
  });
}

Widget buildDialogGameFinished(){
  return buildDialogMedium(
      child: Center(
          child: text("Game Over")),
          bottomRight: buildButton("Exit", core.actions.exitGame),
  );
}

bool isAccountName(String publicName){
  final account = core.state.account.value;
  if (account == null) return false;
  return account.publicName == publicName;
}

Widget statefulBuilder(Widget Function(Function rebuild) build) {
  return StatefulBuilder(builder: (context, setState){
    Function rebuild = (){
      setState((){});
    };
    return build(rebuild);
  });
}
