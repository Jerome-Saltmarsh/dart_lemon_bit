import 'package:bleed_client/actions.dart';
import 'package:bleed_client/constants/colours.dart';
import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/styles.dart';
import 'package:bleed_client/toString.dart';
import 'package:bleed_client/ui/compose/hudUI.dart';
import 'package:bleed_client/ui/constants.dart';
import 'package:bleed_client/ui/style.dart';
import 'package:bleed_client/ui/views.dart';
import 'package:bleed_client/ui/widgets.dart';
import 'package:bleed_client/user-service-client/userServiceHttpClient.dart';
import 'package:bleed_client/utils/widget_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:golden_ratio/constants.dart';
import 'package:lemon_watch/watch_builder.dart';

import '../flutterkit.dart';


Widget buildDialogAccount(){

  return watchAccount((account){
    if (account == null) {
      return layout(
        bottomLeft: buttons.login,
        bottomRight: button("Close", actions.showDialogGames),
        child: dialog(
            child: Column(
              crossAxisAlignment: axis.cross.start,
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
      crossAxisAlignment: axis.cross.start,
      children: [
        height32,
        text("MY ACCOUNT",
            size: 30,
            weight: bold,
            color: colours.white85
        ),
        height32,
        _buildRow("Private Name", account.privateName),
        height8,
        onPressed(
            child: _buildRow(
                "Public Name",
                Row(
                  mainAxisAlignment: axis.main.apart,
                  children: [
                    buildIconEdit(),
                    text(account.publicName,
                        color: colours.white60, size: 16)
                  ],
                )),
            callback: actions.showDialogChangePublicName),
        height8,
        _buildRow("Email", account.email),
        height8,
        _buildRow("Joined", formatDate(account.accountCreationDate)),
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
  return panel(
      child: Column(
    crossAxisAlignment: axis.cross.start,
    children: [
      Row(
        mainAxisAlignment: axis.main.apart,
        children: [
          text("PREMIUM", bold: true, color: colours.white80),
          if (!account.subscriptionActive) widgets.textReactivateSubscription,
          if (account.subscriptionActive)
            panelDark(
              expand: false,
              child: onHover((hovering) {
                return text("Cancel",
                    color: hovering ? colours.orange : colours.white80,
                    onPressed: actions.showDialogConfirmCancelSubscription,
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
              : formatDate(subscriptionStartDate)),
      height8,
      _buildRow(
          account.subscriptionActive
              ? "Renews"
              : account.subscriptionEnded
                  ? "Ended"
                  : "Ends",
          subscriptionEndDate == null ? "-" : formatDate(subscriptionEndDate)),
    ],
  ));
}

Color getSubscriptionStatusColor(SubscriptionStatus value){
  if (value == SubscriptionStatus.Active){
    return colours.green;
  }
  if (value == SubscriptionStatus.Not_Subscribed){
    return colours.white80;
  }
  return colours.orange;
}

Widget _buildRow(String title, dynamic value){
  return Row(
    mainAxisAlignment: axis.main.apart,
    children: [
      text(title, color: colours.white85),
      Container(
        height: 40,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.all(8),
          width: style.dialogWidthMedium * goldenRatio_0618,
          decoration: BoxDecoration(
            color: colours.black382,
            borderRadius: borderRadius4,
          ),
          child: value is Widget ? value : text(value, color: colours.white60, size: 16)),
    ],
  );
}

Widget buildDialog({
  required Widget child,
  required double width,
  required double height,
  Widget? bottomRight,
  Widget? bottomLeft,
}){
  return dialog(
      color: colours.white05,
      borderColor: none,
      padding: 16,
      width: width,
      height: height,
      child: layout(
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
  return text(value.toUpperCase(), size: style.dialogTitleSize, color: colours.white85);
}

Widget buildDialogSubscriptionCancelled(){
  return buildDialogMessage("Your subscription has been cancelled");
}

Widget buildDialogSubscriptionSuccessful(){
  return buildDialog(
    width: style.dialogWidthMedium,
    height: style.dialogHeightSmall,
    child: Center(child: text("Premium subscription activated", color: colours.white95)),
    bottomRight: widgets.buttonGreat
  );
}

Widget buildDialogAccountCreated(){
  return buildDialogMessage("New account created", bottomRight: widgets.buttonClose);
}

Widget buildDialogWelcome2(){
  return buildDialog(
      width: style.dialogWidthMedium,
      height: style.dialogHeightSmall,
      child: Column(
        crossAxisAlignment: axis.cross.start,
        children: [
          Container(
              width: double.infinity,
              color: colours.white05,
              padding: padding16,
              child: Column(
                crossAxisAlignment: axis.cross.start,
                children: [
                  text("Many of our games can be played for free.", color: colours.white80),
                  height16,
                  text("A premium membership costs \$9.99 per month", color: colours.white80),
                  height8,
                  text("and will unlock every game in our library", color: colours.white80),
                ],
              )),
        ],
      ),
      bottomRight: button(text("PREMIUM MEMBERSHIP", color: green), actions.openStripeCheckout, fillColor: none, borderColor: green),
      bottomLeft: Container(
          padding: padding8,
          child: text("Perhaps Later", onPressed: actions.showDialogGames, color: colours.white80)),
  );
}

final _nameController = TextEditingController();

Widget buildDialogChangePublicName() {
  return NullableWatchBuilder<Account?>(game.account, (Account? account) {
    if (account == null) {
      return buildDialogMessage("Account required to change public name");
    }

    if (!account.subscriptionActive) {
      return buildDialog(
          width: style.dialogWidthMedium,
          height: style.dialogHeightSmall,
          bottomRight: widgets.buttonOkay,
          child: Center(
            child: text("This features requires a premium subscription", color: colours.white80),
          ));
    }

    return dialog(
      child: layout(
        child: TextField(
          controller: _nameController,
        ),
        bottomLeft: button("Save", () {}),
        bottomRight: button("Cancel", setDialogGames, borderColor: none),
      ),
    );
  });
}

Widget buildDialogMessage(String message, {Widget? bottomRight}) {
  return buildDialog(
      width: style.dialogWidthMedium,
      height: style.dialogHeightSmall,
      child: Center(child: text(message, color: colours.white95)),
      bottomRight: bottomRight ?? widgets.buttonOkay
  );
}

Widget buildDialogConfirmCancelSubscription(){
  return buildDialogMedium(child: panel(child: text("Are you sure you want to cancel your subscription?", color: colours.white80)),
    bottomLeft: button(text("YES", color: colours.red, bold: true), actions.cancelSubscription, fillColor: none, borderColor: colours.red, borderWidth: 2, width: 100),
    bottomRight: widgets.buttonNo
  );
}

String formatSubscriptionStatus(value){
  return value == SubscriptionStatus.Canceled ? "Cancelled" : enumString(value);
}

Widget buildButton(String value, Function action){
  return onHover((hovering){
    return text(value, color: hovering ? colours.white80 : colours.white618, underline: true, onPressed: action);
  });
}