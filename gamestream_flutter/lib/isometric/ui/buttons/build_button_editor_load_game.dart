import 'package:flutter/material.dart';
import 'package:gamestream_flutter/isometric/ui/widgets/build_container.dart';
import 'package:gamestream_flutter/network/send_client_request.dart';

Widget buildButtonEditorLoadGame(String gameName) {
  return container(
    child: gameName,
    action: () => sendClientRequestEditorLoadGame(gameName),
  );
}


