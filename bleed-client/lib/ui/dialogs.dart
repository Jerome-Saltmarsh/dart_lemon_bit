import 'package:bleed_client/game_engine/engine_state.dart';
import 'package:bleed_client/send.dart';
import 'package:flutter/material.dart';

Future showCreateGameDialog() async {

  TextEditingController nameController = TextEditingController();

  return showDialog<void>(
    context: globalContext,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Create Game'),
        content: Column(
          children: [
            Text("Game Name"),
            TextField(controller: nameController),
          ],
        ),
        actions: <Widget>[
          TextButton(
              child: const Text('Create'),
              onPressed: () {
                pop(context);
                sendRequestCreateLobby();
              }),
        ],
      );
    },
  );
}

void pop(BuildContext context){
  Navigator.of(context).pop();
}
