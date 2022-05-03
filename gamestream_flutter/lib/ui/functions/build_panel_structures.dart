import 'package:bleed_common/library.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/colours.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:gamestream_flutter/resources.dart';
import 'package:gamestream_flutter/styles.dart';

Widget buildPanelStructures() {
  final state = modules.game.state;

  return visibleBuilder(
      state.canBuild,
      Container(
        key: state.keyPanelStructure,
        decoration: BoxDecoration(
          color: colours.brownDark,
          borderRadius: borderRadius4,
        ),
        child: Row(
          children: [
            MouseRegion(
              onEnter: (event) {
                state.highlightStructureType.value = StructureType.Tower;
              },
              onExit: (event) {
                if (state.highlightStructureType.value != StructureType.Tower)
                  return;
                state.highlightStructureType.value = null;
              },
              child: onPressed(
                callback: modules.game.enterBuildModeTower,
                child: Container(
                  child: resources.icons.structures.tower,
                  width: 64,
                  height: 64,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: colours.brownDark,
                    borderRadius: borderRadius4,
                  ),
                ),
              ),
            ),
            MouseRegion(
              onEnter: (event) {
                state.highlightStructureType.value = StructureType.Palisade;
              },
              onExit: (event) {
                if (state.highlightStructureType.value !=
                    StructureType.Palisade) return;
                state.highlightStructureType.value = null;
              },

              child: onPressed(
                callback: modules.game.enterBuildModePalisade,
                child: Container(
                  child: resources.icons.structures.palisade,
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: colours.brownDark,
                    borderRadius: borderRadius4,
                  ),
                ),
              ),
            ),
            MouseRegion(
              onEnter: (event) {
                state.highlightStructureType.value = StructureType.Torch;
              },
              onExit: (event) {
                if (state.highlightStructureType.value != StructureType.Torch)
                  return;
                state.highlightStructureType.value = null;
              },
              child: onPressed(
                callback: modules.game.enterBuildModeTorch,
                child: Container(
                  child: resources.icons.structures.torch,
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: colours.brownDark,
                    borderRadius: borderRadius4,
                  ),
                ),
              ),
            )
          ],
        ),
      ));
}
