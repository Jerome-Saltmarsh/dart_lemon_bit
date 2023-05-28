import 'package:firestore_client/firestoreService.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/game_account.dart';
import 'package:gamestream_flutter/game_website.dart';
import 'package:gamestream_flutter/gamestream/games/isometric/game_isometric_colors.dart';
import 'package:gamestream_flutter/instances/engine.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:gamestream_flutter/ui/builders/build_layout.dart';
import 'package:gamestream_flutter/ui/style.dart';
import 'package:gamestream_flutter/ui/views.dart';
import 'package:gamestream_flutter/ui/widgets.dart';
import 'package:golden_ratio/constants.dart';

import '../game_widgets.dart';

Widget buildDialogAccount(){

  return watchAccount((account){
    if (account == null) {
      return buildLayout(
        bottomLeft: buttons.login,
        bottomRight: button("Close", website.actions.showDialogGames),
        child: dialog(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                border(child: text("ACCOUNT")),
                height16,
                text("Authentication Required"),
              ],
            )
        ),
      );
    }

    return buildDialog(
        width: style.dialogWidthMedium,
        height: style.dialogWidthMedium * goldenRatio_1618,
        // bottomLeft: margin(child: _buildSubscriptionStatus(account.subscriptionStatus), bottom: 32),
        bottomRight: margin(child: widgets.buttonClose, bottom: 32),
        child:
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        height32,
        text("MY ACCOUNT",
            size: 30,
            weight: bold,
            color: GameIsometricColors.white85
        ),
        height32,
        _buildRow("Private Name", account.privateName),
        height8,
        onPressed(
            child: _buildRow(
                "Public Name",
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // buildIconEdit(),
                    text(account.publicName,
                        color: GameIsometricColors.white60, size: 16)
                  ],
                )),
            action: website.actions.showDialogChangePublicName),
        height8,
        _buildRow("Email", account.email),
        height8,
        _buildRow("Joined", GameWebsite.formatDate(account.accountCreationDate)),
        height50,
        _buildSubscriptionPanel(account),
      ],
    )
    );
  });
}

Widget _buildSubscriptionPanel(Account account){
  final subscriptionStartDate = account.subscriptionStartDate;
  final subscriptionEndDate = account.subscriptionEndDate;
  return buildPanel(
      child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          text("PREMIUM", bold: true, color: GameIsometricColors.white80),
          if (!account.subscriptionActive) widgets.textReactivateSubscription,
          if (account.subscriptionActive)
            panelDark(
              expand: false,
              child: onHover((hovering) {
                return text("Cancel",
                    color: hovering ? GameIsometricColors.orange : GameIsometricColors.white80,
                    onPressed: website.actions.showDialogConfirmCancelSubscription,
                );
              }),
            ),
        ],
      ),
      height16,
      _buildRow(
          "Status",
          text(formatSubscriptionStatus(account.subscriptionStatus),
              color: getSubscriptionStatusColor(account.subscriptionStatus)
          )
      ),
      height8,
      _buildRow(
          "Started",
          subscriptionStartDate == null
              ? "-"
              : GameWebsite.formatDate(subscriptionStartDate)),
      height8,
      _buildRow(
          account.subscriptionActive
              ? "Renews"
              : account.subscriptionEnded
                  ? "Ended"
                  : "Ends",
          subscriptionEndDate == null ? "-" : GameWebsite.formatDate(subscriptionEndDate)),
    ],
  ));
}

Color getSubscriptionStatusColor(SubscriptionStatus value){
  if (value == SubscriptionStatus.Active){
    return GameIsometricColors.green;
  }
  if (value == SubscriptionStatus.Not_Subscribed){
    return GameIsometricColors.white80;
  }
  return GameIsometricColors.orange;
}

Widget _buildRow(String title, dynamic value){
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      text(title, color: GameIsometricColors.white85),
      Container(
        height: 40,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.all(8),
          width: style.dialogWidthMedium * goldenRatio_0618,
          decoration: BoxDecoration(
            color: GameIsometricColors.black382,
            borderRadius: borderRadius4,
          ),
          child: value is Widget ? value : text(value, color: GameIsometricColors.white60, size: 16)),
    ],
  );
}

Widget buildDialog({
  required double width,
  required double height,
  required Widget child,
  Widget? bottomRight,
  Widget? bottomLeft,
}){
  return dialog(
      color: GameIsometricColors.white05,
      borderColor: GameIsometricColors.none,
      padding: 16,
      width: width,
      height: height,
      child: buildLayout(
          child: child,
          bottomLeft: bottomLeft,
          bottomRight: bottomRight
      )
  );
}

Widget buildDialogMedium({required Widget child, Widget? bottomLeft, Widget? bottomRight}){
  return buildDialog(
      width: style.dialogWidthMedium,
      height: style.dialogHeightMedium,
      bottomLeft: bottomLeft,
      bottomRight: bottomRight,
      child: child
  );
}

Widget buildDialogLarge({required Widget child, Widget? bottomLeft, Widget? bottomRight}){
  return buildDialog(
      width: style.dialogWidthLarge,
      height: style.dialogHeightLarge,
      bottomLeft: bottomLeft,
      bottomRight: bottomRight,
      child: child,
  );
}

Widget buildDialogMax({required Widget child, Widget? bottomLeft, Widget? bottomRight}){
  return buildDialog(
    width: style.dialogWidthLarge,
    height: double.infinity,
    bottomLeft: bottomLeft,
    bottomRight: bottomRight,
    child: child,
  );
}

Widget buildDialogSmall({required Widget child, Widget? bottomLeft, Widget? bottomRight}){
  return buildDialog(
      width: style.dialogWidthSmall,
      height: style.dialogHeightSmall,
      bottomLeft: bottomLeft,
      bottomRight: bottomRight,
      child: child
  );
}

Widget buildDialogTitle(String value){
  return text(value.toUpperCase(), size: 20, color: GameIsometricColors.white85);
}

Widget buildDialogSubscriptionCancelled(){
  return buildDialogMessage("Premium subscription cancelled");
}

Widget buildDialogPremiumAccountRequired(){
  return buildDialogMessage("Premium subscription required", bottomRight: buildButton("okay", (){
    website.actions.showDialogGames();
  }));
}

Widget buildDialogSubscriptionStatus(){
  final account = GameWebsite.account.value;
  if (account == null){
    return buildDialogMessage("Account is null");
  }

  final subscriptionStatus = account.subscriptionStatus;

  switch(subscriptionStatus){
    case SubscriptionStatus.Active:
      return buildDialogSubscriptionSuccessful();
    case SubscriptionStatus.Canceled:
      return buildDialogSubscriptionCancelled();
    default:
      return buildDialogMessage("Premium subscription ${engine.enumString(subscriptionStatus)}");
  }
}

Widget buildDialogSubscriptionSuccessful(){
  return buildDialogMessage("Premium subscription active", bottomRight: widgets.buttonGreat);
}

Widget buildDialogAccountCreated(){
  return buildDialogMessage("New account created", bottomRight: widgets.buttonClose);
}

Widget buildDialogWelcome2(){
  return buildDialog(
      width: style.dialogWidthMedium,
      height: style.dialogHeightSmall,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              width: double.infinity,
              color: GameIsometricColors.white05,
              padding: padding16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  text("Many of our games can be played for free.", color: GameIsometricColors.white80),
                  height16,
                  text("A premium membership costs \$9.99 per month", color: GameIsometricColors.white80),
                  height8,
                  text("and will unlock every game in our library", color: GameIsometricColors.white80),
                ],
              )),
        ],
      ),
      bottomRight: button(text("PREMIUM MEMBERSHIP", color: GameIsometricColors.green), AccountService.openStripeCheckout, fillColor: GameIsometricColors.none, borderColor: GameIsometricColors.green),
      bottomLeft: Container(
          padding: padding8,
          child: text("Perhaps Later", onPressed: website.actions.showDialogGames, color: GameIsometricColors.white80)),
  );
}

final _nameController = TextEditingController();

Widget buildDialogChangePublicName() {
  final account = GameWebsite.account.value;

  if (account == null){
    return buildDialogMessage("Account is null");
  }

  if (!account.isPremium){
    return buildDialogMessage("Premium subscription required");
  }

  _nameController.text = account.publicName;

  return buildDialog(
    width: style.dialogWidthMedium,
    height: style.dialogHeightSmall,
    bottomLeft: buildButtonPrimary("Save", (){
      AccountService.changeAccountPublicName(_nameController.text);
    },),
    bottomRight: buildButton('back', website.actions.showDialogAccount),
      child: TextField(
        controller: _nameController,
        autofocus: true,
        cursorColor: GameIsometricColors.white80,
        style: TextStyle(
          color: GameIsometricColors.white90
        ),
        decoration: InputDecoration(
          hintText: "Public Name",
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: GameIsometricColors.white618)
          ),
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: GameIsometricColors.white618)
          ),
          hoverColor: GameIsometricColors.white80,
          focusColor: GameIsometricColors.white80,
          fillColor: GameIsometricColors.white80
        ),
      ),
  );

}

Widget buildDialogMessage(dynamic message, {Widget? bottomRight}) {
  return buildDialog(
      width: style.dialogWidthMedium,
      height: style.dialogHeightSmall,
      child: Center(child: message is Widget ? message : text(message, color: GameIsometricColors.white95)),
      bottomRight: bottomRight ?? widgets.buttonOkay
  );
}

Widget buildDialogConfirmCancelSubscription(){
  return buildDialog(
    width: style.dialogWidthMedium,
    height: style.dialogHeightSmall,
    child: Center(child: text("Cancel premium subscription?", color: GameIsometricColors.white90)),
    bottomLeft: button(text("YES", color: GameIsometricColors.red, bold: false), AccountService.cancelSubscription, fillColor: GameIsometricColors.none, borderColor: GameIsometricColors.none, width: 100),
    bottomRight: button(text("NO", color: GameIsometricColors.green, bold: true), website.actions.showDialogAccount, fillColor: GameIsometricColors.none, borderColor: GameIsometricColors.green, width: 100, borderWidth: 2),
  );
}

String formatSubscriptionStatus(value){
  return value == SubscriptionStatus.Canceled ? "Cancelled" : engine.enumString(value);
}

Widget buildButton(String value, Function action, {bool underline = false}){
  return Container(
    padding: padding16,
    child: onHover((hovering){
      return text(value, color: hovering ? GameIsometricColors.white80 : GameIsometricColors.white618, underline: underline, onPressed: action);
    }),
  );
}

Widget buildButtonPrimary(String value, Function action){
  return Container(
    padding: padding16,
    child: onHover((hovering){
      return text(value, color: GameIsometricColors.green, underline: true, onPressed: action, bold: true);
    }),
  );
}