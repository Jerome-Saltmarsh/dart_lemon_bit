import 'package:flutter/material.dart';
import 'package:gamestream_flutter/colours.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/icons.dart';
import 'package:gamestream_flutter/isometric/audio.dart';
import 'package:gamestream_flutter/isometric/camera_mode.dart';
import 'package:gamestream_flutter/isometric/enums/camera_mode.dart';
import 'package:gamestream_flutter/isometric/player.dart';
import 'package:gamestream_flutter/isometric/server_response_reader.dart';
import 'package:gamestream_flutter/modules/game/actions.dart';
import 'package:gamestream_flutter/modules/game/enums.dart';
import 'package:gamestream_flutter/modules/game/update.dart';
import 'package:golden_ratio/constants.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_watch/watch_builder.dart';

import 'state.dart';

class GameBuild {

  final GameState state;
  final GameActions actions;

  static const empty = SizedBox();

  final slotSize = 50.0;

  GameBuild(this.state, this.actions);

  Widget buildMagicBar() {
    final width = 280.0;
    final height = width *
        goldenRatio_0381 *
        goldenRatio_0381;

    return WatchBuilder(player.magic, (double magic) {
      final maxMagic = player.maxMagic.value;
      if (maxMagic <= 0) return empty;
      final percentage = magic / maxMagic;
      return Container(
        width: width,
        height: height,
        alignment: Alignment.centerLeft,
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            Container(
              color: colours.blueDarkest,
              width: width,
              height: height,
            ),
            Container(
              color: colours.blue,
              width: width * percentage,
              height: height,
            ),
            Container(
              color: Colors.transparent,
              width: width,
              height: height,
              alignment: Alignment.center,
              child: text('${magic.toInt()} / ${player.maxMagic.value}'),
            ),
          ],
        ),
      );
    });
  }

  Widget panel({required Widget child, Alignment? alignment, EdgeInsets? padding, double? width}){
    return Container(
        color: colours.brownLight,
        child: child,
        alignment: alignment,
        padding: padding,
        width: width,
    );
  }

  Widget mapStoreTabToIcon(StoreTab value) {
    switch (value) {
      case StoreTab.Weapons:
        return icons.sword;
      case StoreTab.Armor:
        return icons.shield;
      case StoreTab.Items:
        return icons.books.grey;
    }
  }

  Widget mousePosition() {
    return Refresh((){
      return text("Mouse Screen: x: ${engine.mousePosition.x}, y: ${engine.mousePosition.y}");
    });
  }

  Widget mouseDownState(){
    return WatchBuilder(engine.mouseLeftDown, (bool down){
      return text("Mouse Down: $down");
    });
  }

  Widget buildTotalEvents(){
    return WatchBuilder(totalEvents, (int frames){
      return text("Events: $frames");
    });
  }

  Widget buildMSSinceUpdate(){
    return WatchBuilder(averageUpdate, (double frames){
      return text("Milliseconds Since Last: $frames");
    });
  }

  Widget buildSync(){
    return WatchBuilder(sync, (double frames){
      return text("Sync: $frames");
    });
  }

  Widget buildTotalFrames(){
    return WatchBuilder(totalUpdates, (int frames){
      return text("Frames: $frames");
    });
  }

  Widget buildToggleEnabledSound(){
    return WatchBuilder(audio.soundEnabled, (bool enabled){
      return button(text("Sound", decoration: enabled
          ? TextDecoration.none
          : TextDecoration.lineThrough
      ), audio.toggleSoundEnabled);
    });
  }

  Widget buildToggleEnabledMusic(){
    return WatchBuilder(audio.musicEnabled, (bool enabled){
      return button(text("Music", decoration: enabled
          ? TextDecoration.none
          : TextDecoration.lineThrough
      ), audio.toggleEnabledMusic);
    });
  }

  Widget buildButtonToggleCameraMode(){
    return WatchBuilder(cameraModeWatch, (CameraMode mode){
       return button(mode.name, cameraModeNext);
    });
  }

  Widget buildButtonFullScreen(){
    return button("Fullscreen", engine.fullscreenToggle);
  }
}



