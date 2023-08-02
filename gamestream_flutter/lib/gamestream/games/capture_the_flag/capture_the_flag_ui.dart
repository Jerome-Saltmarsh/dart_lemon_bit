
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/gamestream/games/capture_the_flag/capture_the_flag_game.dart';
import 'package:gamestream_flutter/gamestream/games/capture_the_flag/capture_the_flag_power.dart';
import 'package:gamestream_flutter/gamestream/isometric/atlases/atlas.dart';
import 'package:gamestream_flutter/gamestream/isometric/atlases/atlas_src_objects.dart';
import 'package:gamestream_flutter/gamestream/ui/src.dart';
import 'package:gamestream_flutter/gamestream/ui/widgets/gs_checkbox.dart';
import 'package:gamestream_flutter/library.dart';

import 'capture_the_flag_actions.dart';


extension CaptureTheFlagUI on CaptureTheFlagGame {

  Widget buildCaptureTheFlagGameUI() => Stack(
      children: [
        Positioned(
          bottom: 0,
          right: 0,
          child: buildWindowGameStatus(),
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: buildWindowMap(),
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: buildWindowSelectClass(),
        ),
        Positioned(
          top: 16,
          left: 16,
          child: buildWindowScore(),
        ),
        Positioned(
            bottom: 16,
            left: 16,
            child: buildDebugWindow(),
        ),
        Positioned(
          bottom: 16,
          child: buildWindowPlayer(),
        ),
      ],
    );

  Widget buildDebugWindow() =>
      GSContainer(
        child: WatchBuilder(
            tab,
                (selectedTab) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (selectedTab == CaptureTheFlagUITabs.GameObjects)
                  buildWindowGameObjects(),
                if (selectedTab == CaptureTheFlagUITabs.Flag_Status)
                  buildWindowFlagStatus(),
                height8,
                Row(
                  children: CaptureTheFlagUITabs.values
                      .map((e) => onPressed(
                      action: () => tab.value = e,
                      child: Container(
                          color: e == selectedTab
                              ? Colors.white12
                              : null,
                          padding: const EdgeInsets.all(8),
                          child: buildText(e.name))))
                      .toList(growable: false),
                )
              ],
            )),
      );

  WatchBuilder<CaptureTheFlagGameStatus> buildWindowGameStatus() {
    return WatchBuilder(gameStatus, (value){
      if (value == CaptureTheFlagGameStatus.In_Progress) return nothing;
      return buildFullScreen(
        child: buildWindow(
          width: 300,
          height: 200,
          alignment: Alignment.center,
          child: Column(
            children: [
              buildText(value.name),
              WatchBuilder(nextGameCountDown, (nextGameCountDown) =>
                  buildText('NEXT GAME STARTS IN $nextGameCountDown')),
            ],
          ),
        ),
      );
    });
  }

  Widget buildWindowMap() => buildMiniMap(mapSize: 200);

  Widget buildWindowFlagStatus() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      WatchBuilder(flagRedStatus, (status) => buildText('RED STATUS: ${CaptureTheFlagFlagStatus.getName(status)}')),
      WatchBuilder(flagBlueStatus, (status) => buildText('BLUE STATUS: ${CaptureTheFlagFlagStatus.getName(status)}')),
    ],
  );

  Widget buildWindowScore() => buildWindow(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildText('SCORE'),
          WatchBuilder(scoreRed, (score) => buildText('RED: $score')),
          WatchBuilder(scoreBlue, (score) => buildText('BlUE: $score')),
        ],
      ),
    );

  WatchBuilder<bool> buildWindowSelectClass() => WatchBuilder(selectClass, (value){
      if (!value) return const SizedBox();
      return buildFullScreen(
        child: buildWindow(
          width: 300,
          height: 400,
          child: Column(
            children: CaptureTheFlagCharacterClass.values
                .map((characterClass) => onPressed(
                child: Container(
                    alignment: Alignment.center,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: buildText(characterClass.name, size: 20)),
                action: () => selectCharacterClass(characterClass)))
                .toList(growable: false),
          ),
        ),
      );
    });


  Widget buildMiniMap({required double mapSize}) => IgnorePointer(
    child: Container(
      width: mapSize + 3,
      height: mapSize + 3,
      alignment: Alignment.center,
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black38, width: 3),
          color: Colors.black38
      ),
      child: ClipOval(
        child: Container(
            alignment: Alignment.topLeft,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
            ),
            width: mapSize,
            height: mapSize,
            child:   buildWatch(scene.nodesChangedNotifier, (_){
              return engine.buildCanvas(paint: (Canvas canvas, Size size){
                const scale = 2.0;
                canvas.scale(scale, scale);
                final screenCenterX = size.width * 0.5;
                final screenCenterY = size.height * 0.5;
                const ratio = 2 / 48.0;

                final chaseTarget = camera.target;
                if (chaseTarget != null){
                  final targetX = chaseTarget.renderX * ratio;
                  final targetY = chaseTarget.renderY * ratio;
                  final translate = mapSize / 4;
                  final cameraX = targetX - (screenCenterX / scale) - translate;
                  final cameraY = targetY - (screenCenterY / scale) - translate;
                  canvas.translate(-cameraX, -cameraY);
                }

                minimap.renderCanvas(canvas);

                final totalCharacters = scene.totalCharacters;

                for (var i = 0; i < totalCharacters; i++) {
                  final character = scene.characters[i];
                  final isPlayer = player.isCharacter(character);
                  engine.renderExternalCanvas(
                      canvas: canvas,
                      image: images.atlas_gameobjects,
                      srcX: 0,
                      srcY: isPlayer ? 96 : character.allie ? 81 : 72,
                      srcWidth: 8,
                      srcHeight: 8,
                      dstX: character.renderX * ratio,
                      dstY: character.renderY * ratio,
                      scale: 0.25
                  );
                }

                if (flagRedStatus.value != CaptureTheFlagFlagStatus.Respawning) {

                  engine.renderExternalCanvas(
                      canvas: canvas,
                      image: images.atlas_gameobjects,
                      srcX: AtlasSrcObjects.Flag_Red[Atlas.SrcX],
                      srcY: AtlasSrcObjects.Flag_Red[Atlas.SrcY],
                      srcWidth: AtlasSrcObjects.Flag_Red[Atlas.SrcWidth],
                      srcHeight: AtlasSrcObjects.Flag_Red[Atlas.SrcHeight],
                      dstX: flagPositionRed.renderX * ratio,
                      dstY: flagPositionRed.renderY * ratio,
                      scale: 0.1
                  );
                }

                if (flagBlueStatus.value != CaptureTheFlagFlagStatus.Respawning) {
                  engine.renderExternalCanvas(
                      canvas: canvas,
                      image: images.atlas_gameobjects,
                      srcX: AtlasSrcObjects.Flag_Blue[Atlas.SrcX],
                      srcY: AtlasSrcObjects.Flag_Blue[Atlas.SrcY],
                      srcWidth: AtlasSrcObjects.Flag_Blue[Atlas.SrcWidth],
                      srcHeight: AtlasSrcObjects.Flag_Blue[Atlas.SrcHeight],
                      dstX: flagPositionRed.renderX * ratio,
                      dstY: flagPositionRed.renderY * ratio,
                      scale: 0.1
                  );
                }

                engine.renderExternalCanvas(
                    canvas: canvas,
                    image: images.atlas_gameobjects,
                    srcX: AtlasSrcObjects.Base_Red[Atlas.SrcX],
                    srcY: AtlasSrcObjects.Base_Red[Atlas.SrcY],
                    srcWidth: AtlasSrcObjects.Base_Red[Atlas.SrcWidth],
                    srcHeight: AtlasSrcObjects.Base_Red[Atlas.SrcHeight],
                    dstX: flagPositionRed.renderX * ratio,
                    dstY: flagPositionRed.renderY * ratio,
                    scale: 0.1
                );

                engine.renderExternalCanvas(
                    canvas: canvas,
                    image: images.atlas_gameobjects,
                    srcX: AtlasSrcObjects.Base_Blue[Atlas.SrcX],
                    srcY: AtlasSrcObjects.Base_Blue[Atlas.SrcY],
                    srcWidth: AtlasSrcObjects.Base_Blue[Atlas.SrcWidth],
                    srcHeight: AtlasSrcObjects.Base_Blue[Atlas.SrcHeight],
                    dstX: flagPositionRed.renderX * ratio,
                    dstY: flagPositionRed.renderY * ratio,
                    scale: 0.1
                );
              });
            })
        ),
      ),
    ),
  );

  Widget buildWindowGameObjects()=> Column(
      children: [
        Container(
          height: 200,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: scene.gameObjects.map((e){
                return onPressed(
                    action: () {

                    },
                    child: buildText(e.type.toString()),
                );
              }).toList(growable: false),
            ),
          ),
        )
      ],
    );

  Widget buildToggleRow({required String title, required WatchBool watchBool}) => onPressed(
      action: watchBool.toggle,
      child: buildWatch(watchBool, (value)=> Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            buildText(title),
            GSCheckBox(value),
          ],
        ),
      ),
    );

  Widget buildWindow({
    required Widget child,
    double? width,
    double? height,
    Alignment? alignment,
  }) =>
      Container(
        alignment: alignment,
        padding: GameStyle.Container_Padding,
        color: GameStyle.Container_Color,
        child: child,
        width: width,
        height: height,
      );

  Widget buildWindowPlayer() => Container(
      width: engine.screen.width,
      alignment: Alignment.center,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          buildControlPlayerPowers(),
          height6,
          buildControlPlayerLevel(),
        ],
      ),
    );

  Widget buildControlPlayerLevel({double width = 200, double height = 20}) => Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        buildWatch(playerLevel, (t) => buildText('LEVEL: $t')),
        width8,
        buildWatch(playerExperienceRequiredForNextLevel, (experienceRequired) =>
          (experienceRequired <= 0) ? nothing :
            buildWatch(playerExperience, (experience) =>
                Tooltip(
                  message: '$experience / $experienceRequired',
                  child: Container(
                    width: width,
                    height: height,
                    color: Colors.white38,
                    alignment: Alignment.centerLeft,
                    child: Container(
                      height: height - 2,
                      width: width * (experience / experienceRequired),
                      color: Colors.white,
                    ),
              ),
                ))),
      ],
    );

  Widget buildControlPower(CaptureTheFlagPower power, {double size = 80}) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          buildWatch(skillPoints, (skillPoints) => (skillPoints <= 0) ? nothing :
          GSButton(
            action: () => upgradePower(power),
            child: Container(
              // color: GameStyle.Container_Color,
              color: GS_CONTAINER_COLOR,
              width: 40,
              height: 40,
              alignment: Alignment.center,
              child: buildText('+'),
              margin: const EdgeInsets.only(bottom: 6),
            ),
          )),
          buildWatch(power.activated, (activated) =>
            GSContainer(
              child: Stack(
                  alignment: Alignment.center,
                  children: [
                    buildWatch(power.cooldown, (cooldown) =>
                        buildWatch(power.cooldownRemaining, (cooldownRemaining) =>
                            Container(
                              constraints: BoxConstraints(
                                minHeight: size,
                                maxHeight: size,
                              ),
                              decoration: BoxDecoration(
                                color: GameStyle.Container_Color,
                                shape: BoxShape.circle,
                              ),
                               width: size,
                               height: size * power.cooldownPercentage,
                            ))),
                    buildWatch(power.type, (powerType) =>
                        buildWatch(power.coolingDown, (coolingDown) => Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            buildText(powerType.name, color: coolingDown ? Colors.red : Colors.green),
                            buildWatch(power.level, buildText),
                          ],
                        ))),
                    Container(
                        width: size,
                        height: size,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            // color: GameStyle.Container_Color,
                            border: Border.all(
                              color: activated ? Colors.white : Colors.transparent,
                              width: 2,
                            )
                        )
                    ),
                  ],
                ),
            ),
  ),
        ],
      );


  Widget buildControlPlayerPowers() => Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        buildControlPower(playerPower1),
        width8,
        buildControlPower(playerPower2),
        width8,
        buildControlPower(playerPower3),
      ],
    );
}



enum CaptureTheFlagUITabs {
   GameObjects,
   Flag_Status,
}