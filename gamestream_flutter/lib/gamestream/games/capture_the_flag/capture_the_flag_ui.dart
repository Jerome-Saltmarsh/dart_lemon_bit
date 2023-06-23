
import 'package:gamestream_flutter/gamestream/games/capture_the_flag/capture_the_flag_power.dart';
import 'package:gamestream_flutter/gamestream/ui/widgets/build_text.dart';
import 'package:gamestream_flutter/gamestream/ui/widgets/gs_button.dart';
import 'package:gamestream_flutter/gamestream/ui/widgets/gs_checkbox.dart';
import 'package:gamestream_flutter/gamestream/ui/widgets/gs_container.dart';
import 'package:gamestream_flutter/gamestream/ui/widgets/gs_dialog.dart';
import 'package:gamestream_flutter/gamestream/ui/widgets/nothing.dart';
import 'package:gamestream_flutter/gamestream/ui/widgets/on_pressed.dart';

import 'capture_the_flag_actions.dart';

import 'package:flutter/material.dart';
import 'package:gamestream_flutter/gamestream/games/capture_the_flag/capture_the_flag_game.dart';
import 'package:gamestream_flutter/gamestream/isometric/atlases/atlas_items.dart';
import 'package:gamestream_flutter/library.dart';


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
      buildDebugMode(
        child: GSDialog(
          child: GSContainer(
            child: WatchBuilder(
                tab,
                (selectedTab) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (selectedTab ==
                            CaptureTheFlagUITabs.Selected_Character)
                          buildWindowSelectedCharacter(),
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
          ),
        ),
      );

  WatchBuilder<CaptureTheFlagGameStatus> buildWindowGameStatus() {
    return WatchBuilder(gameStatus, (value){
      if (value == CaptureTheFlagGameStatus.In_Progress) return nothing;
      return buildFullscreen(
        child: buildWindow(
          width: 300,
          height: 200,
          alignment: Alignment.center,
          child: Column(
            children: [
              buildText(value.name),
              WatchBuilder(nextGameCountDown, (nextGameCountDown) =>
                  buildText("NEXT GAME STARTS IN $nextGameCountDown")),
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
      WatchBuilder(flagRedStatus, (status) => buildText("RED STATUS: ${CaptureTheFlagFlagStatus.getName(status)}")),
      WatchBuilder(flagBlueStatus, (status) => buildText("BLUE STATUS: ${CaptureTheFlagFlagStatus.getName(status)}")),
    ],
  );

  Widget buildWindowScore() => buildWindow(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildText("SCORE"),
          WatchBuilder(scoreRed, (score) => buildText("RED: $score")),
          WatchBuilder(scoreBlue, (score) => buildText("BlUE: $score")),
        ],
      ),
    );

  WatchBuilder<bool> buildWindowSelectClass() => WatchBuilder(selectClass, (value){
      if (!value) return const SizedBox();
      return buildFullscreen(
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
            child:   watch(isometric.clientState.sceneChanged, (_){
              return engine.buildCanvas(paint: (Canvas canvas, Size size){
                const scale = 2.0;
                canvas.scale(scale, scale);
                final screenCenterX = size.width * 0.5;
                final screenCenterY = size.height * 0.5;
                const ratio = 2 / 48.0;

                final chaseTarget = isometric.camera.chaseTarget;
                if (chaseTarget != null){
                  final targetX = chaseTarget.renderX * ratio;
                  final targetY = chaseTarget.renderY * ratio;
                  final translate = mapSize / 4;
                  final cameraX = targetX - (screenCenterX / scale) - translate;
                  final cameraY = targetY - (screenCenterY / scale) - translate;
                  canvas.translate(-cameraX, -cameraY);
                }

                isometric.minimap.renderCanvas(canvas);

                final serverState = isometric.server;
                final player = isometric.player;
                final totalCharacters = serverState.totalCharacters;

                for (var i = 0; i < totalCharacters; i++) {
                  final character = serverState.characters[i];
                  final isPlayer = player.isCharacter(character);
                  engine.renderExternalCanvas(
                      canvas: canvas,
                      image: GameImages.atlas_gameobjects,
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
                      image: GameImages.atlas_gameobjects,
                      srcX: AtlasItems.getSrcX(ItemType.GameObjects_Flag_Red),
                      srcY: AtlasItems.getSrcY(ItemType.GameObjects_Flag_Red),
                      srcWidth: AtlasItems.getSrcWidth(
                          ItemType.GameObjects_Flag_Red),
                      srcHeight: AtlasItems.getSrcHeight(
                          ItemType.GameObjects_Flag_Red),
                      dstX: flagPositionRed.renderX * ratio,
                      dstY: flagPositionRed.renderY * ratio,
                      scale: 0.1
                  );
                }

                if (flagBlueStatus.value != CaptureTheFlagFlagStatus.Respawning) {
                  engine.renderExternalCanvas(
                      canvas: canvas,
                      image: GameImages.atlas_gameobjects,
                      srcX: AtlasItems.getSrcX(ItemType.GameObjects_Flag_Blue),
                      srcY: AtlasItems.getSrcY(ItemType.GameObjects_Flag_Blue),
                      srcWidth: AtlasItems.getSrcWidth(ItemType.GameObjects_Flag_Blue),
                      srcHeight: AtlasItems.getSrcHeight(ItemType.GameObjects_Flag_Blue),
                      dstX: flagPositionBlue.renderX * ratio,
                      dstY: flagPositionBlue.renderY * ratio,
                      scale: 0.1
                  );
                }

                engine.renderExternalCanvas(
                    canvas: canvas,
                    image: GameImages.atlas_gameobjects,
                    srcX: AtlasItems.getSrcX(ItemType.GameObjects_Base_Red),
                    srcY: AtlasItems.getSrcY(ItemType.GameObjects_Base_Red),
                    srcWidth: AtlasItems.getSrcWidth(ItemType.GameObjects_Base_Red),
                    srcHeight: AtlasItems.getSrcHeight(ItemType.GameObjects_Base_Red),
                    dstX: basePositionRed.renderX * ratio,
                    dstY: basePositionRed.renderY * ratio,
                    scale: 0.05
                );

                engine.renderExternalCanvas(
                    canvas: canvas,
                    image: GameImages.atlas_gameobjects,
                    srcX: AtlasItems.getSrcX(ItemType.GameObjects_Base_Blue),
                    srcY: AtlasItems.getSrcY(ItemType.GameObjects_Base_Blue),
                    srcWidth: AtlasItems.getSrcWidth(ItemType.GameObjects_Base_Blue),
                    srcHeight: AtlasItems.getSrcHeight(ItemType.GameObjects_Base_Blue),
                    dstX: basePositionBlue.renderX * ratio,
                    dstY: basePositionBlue.renderY * ratio,
                    scale: 0.05
                );
              });
            })
        ),
      ),
    ),
  );

  Widget buildDebugMode({required Widget child}) =>
      WatchBuilder(debugMode, (t) => t ? child : nothing);

  Widget buildWindowGameObjects()=> Column(
      children: [
        Container(
          height: 200,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: gamestream.isometric.server.gameObjects.map((e){
                return onPressed(
                    action: () {

                    },
                    child: buildText(ItemType.getName(e.type))
                );
              }).toList(growable: false),
            ),
          ),
        )
      ],
    );

  Widget buildWindowSelectedCharacter() =>
      WatchBuilder(characterSelected, (characterSelected){
        if (!characterSelected) return nothing;
        return Container(
          width: 300,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              WatchBuilder(characterSelectedRuntimeType, (runtimeType) => buildText("type: $runtimeType")),
              WatchBuilder(characterSelectedX, (x) => buildText("position-x: ${x.toInt()}")),
              WatchBuilder(characterSelectedY, (y) => buildText("position-y: ${y.toInt()}")),
              WatchBuilder(characterSelectedZ, (z) => buildText("position-z: ${z.toInt()}")),
              WatchBuilder(characterSelectedPathIndex, (pathIndex) => buildText("path-index: $pathIndex")),
              WatchBuilder(characterSelectedPathEnd, (pathEnd) => buildText("path-end: $pathEnd")),
              WatchBuilder(characterSelectedIsAI, (isAI) => !isAI ? nothing : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    WatchBuilder(characterSelectedAIDecision, (decision) => buildText("ai-decision: ${decision.name}")),
                    onPressed(
                        action: toggleSelectedCharacterAIRole,
                        child: WatchBuilder(characterSelectedAIRole, (role) => buildText("ai-role: ${role.name}"))),
                    onPressed(
                        action: debugSelectAI,
                        child: buildText("DEBUG")),
                ],
              )),
              const SizedBox(height: 1,),
              WatchBuilder(characterSelectedTarget, (characterSelectedTarget){
                if (!characterSelectedTarget) return nothing;
                return Container(
                  color: Colors.white12,
                  padding: GameStyle.Container_Padding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildText("TARGET"),
                      WatchBuilder(characterSelectedTargetType, (type) => buildText("type: $type")),
                      WatchBuilder(characterSelectedTargetX, (x) => buildText("x: ${x.toInt()}")),
                      WatchBuilder(characterSelectedTargetY, (y) => buildText("y: ${y.toInt()}")),
                      WatchBuilder(characterSelectedTargetZ, (z) => buildText("z: ${z.toInt()}")),
                    ],
                  ),
                );
              }),
            ],
          ),
        );
      });

  Widget buildToggleRow({required String title, required WatchBool watchBool}) => onPressed(
      action: watchBool.toggle,
      child: watch(watchBool, (value)=> Row(
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
      GSDialog(child: Container(
        alignment: alignment,
        padding: GameStyle.Container_Padding,
        color: GameStyle.Container_Color,
        child: child,
        width: width,
        height: height,
      ));

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
        watch(playerLevel, (t) => buildText("LEVEL: $t")),
        width8,
        watch(playerExperienceRequiredForNextLevel, (experienceRequired) =>
          (experienceRequired <= 0) ? nothing :
            watch(playerExperience, (experience) =>
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
          watch(skillPoints, (skillPoints) => (skillPoints <= 0) ? nothing :
             GSDialog(
               child: GSButton(
                 action: () => upgradePower(power),
                 child: Container(
                    color: GameStyle.Container_Color,
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    child: buildText("+"),
                   margin: const EdgeInsets.only(bottom: 6),
                 ),
               ),
             )
          ),
          watch(power.activated, (activated) =>
            GSDialog(
              child: Stack(
                  alignment: Alignment.center,
                  children: [
                    watch(power.cooldown, (cooldown) =>
                        watch(power.cooldownRemaining, (cooldownRemaining) =>
                            Container(
                              decoration: BoxDecoration(
                                color: GameStyle.Container_Color,
                                shape: BoxShape.circle,
                              ),
                               width: size,
                               height: size * power.cooldownPercentage,
                            ))),
                    watch(power.type, (powerType) =>
                        watch(power.coolingDown, (coolingDown) => Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            buildText(powerType.name, color: coolingDown ? Colors.red : Colors.green),
                            watch(power.level, buildText),
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
   Selected_Character,
   GameObjects,
   Flag_Status,
}