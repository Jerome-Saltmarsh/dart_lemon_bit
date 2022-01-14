
import 'package:bleed_client/constants/colours.dart';
import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/ui/compose/hudUI.dart';
import 'package:bleed_client/user-service-client/userServiceHttpClient.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lemon_watch/watch_builder.dart';

import '../../flutterkit.dart';

final nameController = TextEditingController();

Widget buildDialogChangePublicName(){

  return NullableWatchBuilder<Account?>(game.account, (Account? account){

    if (account == null){
        return buildDialogMessage("Account required to change public name");
    }

    if (!account.subscriptionActive){
      return buildDialogMessage("Oops you must be subscribed to change your public name");
    }

    return dialog(
      child: layout(
        child: TextField(
          controller: nameController,
        ),
        bottomLeft: button("Save", (){}),
        bottomRight: button("Cancel", setDialogGames, borderColor: none),
      ),
    );
  });
}

Widget buildDialogMessage(String message){
  return dialog(
      color: colours.white05,
      borderColor: none,
      child: layout(
        child: text(message)
    )
  );
}
