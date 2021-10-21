import 'package:bleed_client/game_engine/game_widget.dart';
import 'package:bleed_client/ui/state/flutter_constants.dart';
import 'package:bleed_client/ui/state/hudState.dart';
import 'package:flutter/material.dart';

import 'widgets.dart';

Widget buildTextBox() {
  return StatefulBuilder(builder: (BuildContext context, StateSetter setState){
    hud.stateSetters.messageText = setState;

    if (!hud.state.textBoxVisible) return blank;

    return Positioned(
        bottom: 100,
        child: Container(
          width: screenWidth,
          child: Row(
            mainAxisAlignment: main.center,
            children: [
              Container(
                  width: 300,
                  height: 100,
                  alignment: Alignment.center,
                  decoration: boxDecoration(
                    fillColor: Colors.black45
                  ),
                  padding: padding8,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Press Enter to send',
                      hintStyle: TextStyle(color: Colors.white60),
                      focusColor: Colors.white,
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white60),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white60),
                      ),
                      suffixText: "(Press Enter)"
                    ),
                    focusNode: hud.focusNodes.textFieldMessage,
                    controller: hud.textEditingControllers.speak,
                    maxLength: 75,
                    style: TextStyle(color: Colors.white),
                  )),
            ],
          ),
        ));
  },);
}
