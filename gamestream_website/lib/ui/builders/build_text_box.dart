import 'package:flutter/material.dart';
import 'package:gamestream_flutter/isometric/message_box.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:gamestream_flutter/styles.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_watch/watch_builder.dart';

import '../../flutterkit.dart';

Widget buildPanelWriteMessage() {
  return WatchBuilder(messageBoxVisible, (bool visible){
    if (!visible) return blank;
    return Positioned(
        bottom: 100,
        child: Container(
          width: engine.screen.width,
          alignment: Alignment.center,
          child: Container(
            width: 400,
            decoration: BoxDecoration(
                borderRadius: borderRadius4,
                color: Colors.black54),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
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
                      focusNode: modules.game.state.textFieldMessage,
                      controller: modules.game.state.textEditingControllerMessage,
                      maxLength: 50,
                      style: TextStyle(color: Colors.white),
                    )),
                Container(
                  margin: EdgeInsets.only(left: 8, bottom: 16),
                  child: Row(
                    children: [
                      onPressed(callback: modules.game.actions.sendAndCloseTextBox, child: border(child: text("Send")), hint: "(Press Enter)"),
                      width16,
                      onPressed(callback: messageBoxHide, child: text("Cancel", decoration: TextDecoration.underline), hint: ("(Press Escape")),
                    ],
                  ),
                )
              ],
            ),
          ),
        ));
  },);
}
