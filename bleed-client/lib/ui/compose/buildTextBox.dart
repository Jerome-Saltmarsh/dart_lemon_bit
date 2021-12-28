import 'package:bleed_client/ui/logic/hudLogic.dart';
import 'package:bleed_client/ui/logic/showTextBox.dart';
import 'package:bleed_client/ui/state/flutter_constants.dart';
import 'package:bleed_client/ui/state/hud.dart';
import 'package:flutter/material.dart';
import 'package:lemon_engine/state/screen.dart';
import 'package:lemon_watch/watch_builder.dart';

import 'widgets.dart';

Widget buildTextBox() {
  return WatchBuilder(hud.state.textBoxVisible, (bool value){
    if (!value) return blank;

    return Positioned(
        bottom: 100,
        child: Container(
          width: screen.width,
          alignment: Alignment.center,
          child: Container(
            width: 400,
            decoration: BoxDecoration(
                borderRadius: borderRadius4,
                color: Colors.black54),
            child: Column(
              mainAxisAlignment: axis.main.center,
              children: [
                Container(
                    width: 400,
                    height: 100,
                    alignment: Alignment.center,
                    padding: padding8,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'message...',
                        hintStyle: TextStyle(color: Colors.white60),
                        focusColor: Colors.white,
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white60),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white60),
                        ),
                      ),
                      focusNode: hud.focusNodes.textFieldMessage,
                      controller: hud.textEditingControllers.speak,
                      maxLength: 50,
                      style: TextStyle(color: Colors.white),
                    )),
                Container(
                  margin: EdgeInsets.only(left: 8, bottom: 16),
                  child: Row(
                    children: [
                      onPressed(callback: sendAndCloseTextBox, child: border(child: text("Send")), hint: "(Press Enter)"),
                      width16,
                      onPressed(callback: hideTextBox, child: text("Cancel", decoration: TextDecoration.underline), hint: ("(Press Escape")),
                    ],
                  ),
                )
              ],
            ),
          ),
        ));
  },);
}
