
import 'package:bleed_client/editor/editor.dart';
import 'package:bleed_client/editor/events/onEditorKeyDownEvent.dart';
import 'package:bleed_client/editor/state/editState.dart';
import 'package:bleed_client/editor/state/keys.dart';
import 'package:bleed_client/editor/state/panning.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

void onEditorKeyEvent(RawKeyEvent event) {
  if (event is RawKeyDownEvent) {
    onEditorKeyDownEvent(event);
    return;
  }
  if (event is RawKeyUpEvent) {
    if (event.logicalKey == keys.pan) {
      panning = false;
    }
    if (event.logicalKey == keys.selectTileType) {
      editState.tile = tileAtMouse;
    }
  }
}