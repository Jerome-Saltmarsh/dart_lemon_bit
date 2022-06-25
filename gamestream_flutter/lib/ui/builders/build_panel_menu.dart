import 'package:flutter/material.dart';
import 'package:gamestream_flutter/isometric/audio.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/icons.dart';
import 'package:gamestream_flutter/isometric/play_mode.dart';
import 'package:gamestream_flutter/isometric/ui/watch_inventory_visible.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:gamestream_flutter/ui/builders/build_panel.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_watch/watch_builder.dart';

Widget buildPanelMenu() {
  return buildPanel(
      width: 300,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          onPressed(
            callback: engine.fullscreenToggle,
            child: WatchBuilder(engine.fullScreen, (bool fullscreen){
              return fullscreen ?
                Tooltip(
                    child: icons.symbols.fullscreenEnter,
                    message: 'Exit Fullscreen'
                ) :
                Tooltip(
                    child: icons.symbols.fullscreenExit,
                    message: 'Enter Fullscreen'
                );
            }),
          ),
          onPressed(
            callback: playModeToggle,
            child: WatchBuilder(playMode, (PlayMode mode) {
              return text(mode.name);
            }),
          ),
          onPressed(
            callback: actionToggleInventoryVisible,
            child: WatchBuilder(watchInventoryVisible, (bool inventoryVisible) {
              if (inventoryVisible){
                return icons.bag;
              }
              return icons.bagGray;
            }),
          ),
          onPressed(
            callback: audio.toggleSoundEnabled,
            child: WatchBuilder(audio.soundEnabled, (bool soundEnabled) {
              return soundEnabled
                  ? Tooltip(
                      child: icons.symbols.soundEnabled,
                      message: 'Disable Sound')
                  : Tooltip(
                      child: icons.symbols.soundDisabled,
                      message: 'Enable Sound');
      }),
          ),
          onPressed(
            callback: core.actions.exitGame,
            child: Tooltip(
                child: icons.symbols.home,
                message: 'EXIT'
            ),
          ),
        ],
    )
  );
}