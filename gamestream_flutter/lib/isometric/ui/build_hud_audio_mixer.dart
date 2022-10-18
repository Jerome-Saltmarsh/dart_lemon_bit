
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/game_audio.dart';
import 'package:gamestream_flutter/isometric/audio/audio_loop.dart';
import 'package:gamestream_flutter/ui/builders/build_panel_menu.dart';

import '../../game_widgets.dart';
import 'constants/colors.dart';
import 'widgets/build_container.dart';

Widget buildHudAudioMix(){
   return Stack(
      children: [
        Positioned(top: 0, right: 0, child: buildPanelMenu()),
        Positioned(top: 0, left: 0,
          child: buildSounds(),
        )
      ],
   );
}

Widget buildSounds() =>
  Refresh(() =>
      Column(
        children: GameAudio.audioLoops.map(buildAudioLoop).toList(),
      )
  );

Widget buildAudioLoop(AudioLoop audioLoop){
  return Stack(
    children: [
      container(child: audioLoop.name, color: grey),
      container(child: "", width: 200 * audioLoop.volume, color: greyDark),
      container(child: audioLoop.name, color: Colors.transparent),
    ],
  );
}