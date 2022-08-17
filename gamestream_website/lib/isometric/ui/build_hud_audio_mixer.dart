
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/isometric/audio/audio_loop.dart';
import 'package:gamestream_flutter/ui/builders/build_panel_menu.dart';

import '../../flutterkit.dart';
import '../audio/audio_loops.dart';
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
        children: audioLoops.map(buildAudioLoop).toList(),
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