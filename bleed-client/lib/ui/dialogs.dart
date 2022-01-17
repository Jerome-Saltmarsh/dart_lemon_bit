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
        bottomRight: margin(child: widgets.closeButton, bottom: 32),
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
          text("MY SUBSCRIPTION", bold: true, color: colours.white80),
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
  return watchAccount((account){
    return buildDialogLarge(
        bottomLeft: widgets.buttonChangeDisplayName,
        bottomRight: widgets.closeButton,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: axis.main.apart,
              children: [
                Row(
                  children: [
                    buildDialogTitle("Inbox"),
                    width16,
                    icons.mail,
                  ],
                ),
                border(
                    padding: padding16,
                    color: none,
                    fillColor: colours.black15,
                    child: buildDialogTitle("Subscription Activated")),
              ],
            ),
            height16,
            buildInfo(child: Column(
              crossAxisAlignment: axis.cross.start,
              children: [
                text("Dear ${account != null ? account.privateName : "Anonymous"}", color: colours.white618),
                height32,
                text("Congratulations! Your premium account has officially been activated.", color: colours.white618),
                height16,
                text("This means you have access to all the games in the library plus a ton more", color: colours.white618),
                height16,
                Row(
                  children: [
                    text("such as ", color: colours.white618),
                    text("Change your in game name", color: colours.green, onPressed: actions.showDialogChangePublicName),
                  ],
                ),
                height32,
                text("You can cancel your subscription any time via the account dialog", color: colours.white618),
                height32,
                text("Kind regards,", color: colours.white618),
                height16,
                text("From Jerome (founder and ceo)", color: colours.white618),
              ],
            ))
          ],
        )
    );
  });
}

Widget buildDialogWelcome1(){
  return watchAccount((account){
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
                      text("Hi ${account == null ? 'anon': account.privateName}", color: colours.white80),
                      height32,
                      text("Thank you for joining gamestream!", color: colours.white80)
                    ],
                  )),
            ],
          ),
        bottomRight: text("Next", onPressed: actions.showDialogWelcome2, color: colours.white80)
      );
  });
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
      return buildDialogMedium(
          bottomLeft: widgets.subscribeButton,
          child: Column(
            crossAxisAlignment: axis.cross.start,
            children: [
              buildDialogTitle("OOPS!"),
              height32,
              border(
                fillColor: colours.white05,
                color: none,
                padding: padding16,
                child: Column(
                  crossAxisAlignment: axis.cross.start,
                  children: [
                    Row(
                      children: [
                        text("An ", color: colours.white618),
                        text("active subscription", color: colours.green, bold: true, onPressed: actions.openStripeCheckout),
                        text(" is needed to change", color: colours.white618),
                      ],
                    ),
                    text("your public name", color: colours.white618),
                  ],
                ),
              ),
            ],
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

Widget buildDialogMessage(String message) {
  return buildDialogMedium(child: panel(child: text(message, color: colours.white80)),
    bottomRight: widgets.buttonOkay,
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