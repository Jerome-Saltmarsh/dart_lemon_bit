
import 'package:bleed_client/assets.dart';
import 'package:bleed_client/constants/colours.dart';
import 'package:bleed_client/flutterkit.dart';
import 'package:flutter/material.dart';


class Widgets {
  final title = Row(
    children: [
      text("GAME",
          size: 60,
          color: Colors.white,
          family: assets.fonts.libreBarcode39Text
      ),
      text("STREAM",
        size: 60,
        color: colours.red,
        family: assets.fonts.libreBarcode39Text,
      ),
    ],
  );
}