
import 'package:bleed_client/constants/colours.dart';
import 'package:bleed_client/flutterkit.dart';
import 'package:bleed_client/modules/modules.dart';
import 'package:bleed_client/modules/ui/style.dart';
import 'package:bleed_client/modules/ui/widgets.dart';
import 'package:bleed_client/ui/compose/hudUI.dart';
import 'package:flutter/widgets.dart';

class UILayouts {

  final UIStyle style;
  final UIWidgets widgets;

  UILayouts(this.style, this.widgets);

  Widget waitingForGame(){
    return layout(
      padding: style.layoutPadding,
      topLeft: widgets.title,
      child: Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          height16,
          text("FINDING GAME...", size: style.font.large),
          height16,
          text("CANCEL", size: style.font.regular, color: colours.white382, onPressed: core.actions.disconnect),
        ],
      )),
    );
  }

}