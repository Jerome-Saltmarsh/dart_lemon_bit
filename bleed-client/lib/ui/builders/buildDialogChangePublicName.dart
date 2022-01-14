import 'package:bleed_client/constants/colours.dart';
import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/ui/buildDialog.dart';
import 'package:bleed_client/ui/compose/hudUI.dart';
import 'package:bleed_client/user-service-client/userServiceHttpClient.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lemon_watch/watch_builder.dart';

import '../../flutterkit.dart';
import '../../styles.dart';
import '../widgets.dart';

final nameController = TextEditingController();

Widget buildDialogChangePublicName() {
  return NullableWatchBuilder<Account?>(game.account, (Account? account) {
    if (account == null) {
      return buildDialogMessage("Account required to change public name");
    }

    if (!account.subscriptionActive) {
      return buildDialogMedium(
          bottomLeft: widgets.subscriptionButton,
          child: Column(
            crossAxisAlignment: axis.cross.start,
            children: [
              buildDialogTitle("OOPS!"),
              height16,
              text("An active subscription is needed to change your public name", color: colours.white618),
            ],
          ));
    }

    return dialog(
      child: layout(
        child: TextField(
          controller: nameController,
        ),
        bottomLeft: button("Save", () {}),
        bottomRight: button("Cancel", setDialogGames, borderColor: none),
      ),
    );
  });
}

Widget buildDialogMessage(String message) {
  return buildDialogMedium(child: text(message));
}
