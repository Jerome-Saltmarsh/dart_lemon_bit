
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:gamestream_flutter/isometric.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/functions/format_bytes.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/functions/format_percentage.dart';
import 'package:gamestream_flutter/gamestream/server_response_reader.dart';
import 'package:gamestream_flutter/ui.dart';
import 'package:gamestream_flutter/library.dart';

import 'debug_tab.dart';

extension isometricDebugUI on IsometricDebug {

  Widget buildUI() =>
      buildWatchBool(gamestream.isometric.player.debugging, () =>
          GSContainer(
            child: WatchBuilder(tab, (DebugTab activeTab) => Column(
              children: [
                buildRowDebugTabs(activeTab),
                height16,
                Container(
                  constraints: BoxConstraints(
                      minWidth: 300,
                      maxWidth: 400,
                      minHeight: 300,
                      maxHeight: gamestream.engine.screen.height - 150),
                  child: SingleChildScrollView(
                    child: switch (activeTab) {
                      DebugTab.Selected => buildTabSelected(),
                      DebugTab.Network => buildTabNetwork(),
                      DebugTab.Stats => buildTabStats(),
                      DebugTab.Lighting => buildTabLighting(),
                      DebugTab.Engine => buildTabEngine(),
                      DebugTab.Objects => buildTabObjects(),
                      DebugTab.Isometric => buildTabIsometric(),
                    },
                  ),
                ),
              ],
            )),
          )
      );

  Row buildRowDebugTabs(DebugTab activeTab) => Row(children: DebugTab.values.map((e) => onPressed(
      action: () => tab.value = e,
      child: Container(
          margin: const EdgeInsets.only(right: 16),
          child: buildText(
            e.name,
            bold: activeTab == e,
            underline: activeTab == e,
          )
      ))
  ).toList(growable: false));

  Widget buildTabSelected() => WatchBuilder(
      selectedCollider,
      (selectedCollider) => !selectedCollider
          ? buildText('Nothing Selected')
          : WatchBuilder(selectedColliderType,
              (colliderType) => switch (colliderType) {
                IsometricType.Character => buildSelectedColliderTypeCharacter(),
                IsometricType.GameObject => buildSelectedColliderTypeGameObject(),
                _ => nothing
              }));

  Widget buildDropDownCharacterType() => buildWatch(
      characterType,
          (debugCharacterType) => DropdownButton<int>(
        value: debugCharacterType,
        onChanged: (int? newValue) {
          if (newValue == null) return;
          isometric.debugCharacterSetCharacterType(newValue);
        },
        items: CharacterType.values.map((int characterType) => DropdownMenuItem<int>(
          value: characterType,
          child: buildText(
            CharacterType.getName(characterType),
            color: Colors.black87,
          ),
        )).toList(),
      ));

  Widget buildDropDownWeaponType() => buildWatch(
      weaponType,
          (weaponType) => DropdownButton<int>(
        value: weaponType,
        onChanged: (int? newValue) {
          if (newValue == null) return;
          isometric.debugCharacterSetWeaponType(newValue);
        },
        items: WeaponType.values.map((int weaponType) => DropdownMenuItem<int>(
          value: weaponType,
          child: buildText(
            WeaponType.getName(weaponType),
            color: Colors.black87,
          ),
        )).toList(),
      ));

  Widget buildTabNetwork() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
      buildWatch(gamestream.serverFPS, (serverFPS) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          GSRefresh(() => buildText('connection-duration: ${gamestream.isometric.client.formattedConnectionDuration}\n')),
          buildText('network-server-fps: $serverFPS'),
          buildWatch(gamestream.bufferSizeTotal, (int bytes) => buildText('network-bytes-total: ${formatBytes(bytes)}')),
          buildWatch(gamestream.bufferSize, (int bytes) => buildText('network-bytes: $bytes')),
          buildWatch(gamestream.bufferSize, (int bytes) => buildText('network-bytes-per-frame: ${formatBytes(bytes)}')),
          buildWatch(gamestream.bufferSize, (int bytes) => buildText('network-bytes-per-second: ${formatBytes(bytes * serverFPS)}')),
          buildWatch(gamestream.bufferSize, (int bytes) => buildText('network-bytes-per-minute: ${formatBytes(bytes * serverFPS * 60)}')),
          buildWatch(gamestream.bufferSize, (int bytes) => buildText('network-bytes-per-hour: ${formatBytes(bytes * serverFPS * 60 * 60)}')),
          height8,
          buildWatch(gamestream.io.updateSize, (int bytes) => buildText('network-bytes-up: $bytes')),
          buildWatch(gamestream.io.updateSize, (int bytes) => buildText('network-bytes-up-per-hour: ${formatBytes(bytes * serverFPS * 60 * 60)}')),
        ],
      )),
      height16,
      buildWatch(gamestream.bufferSize, (bytes){
        bytes--; // remove the final end byte
        var text = '';
        for (var i = 0; i < ServerResponseReader.serverResponseStackIndex; i++){
          final serverResponse = ServerResponseReader.serverResponseStack[i];
          final length = ServerResponseReader.serverResponseStackLength[i];
          final lengthPercentage = formatPercentage(length / bytes);
          text += '${ServerResponse.getName(serverResponse)}, ($length / $bytes, $lengthPercentage\n';
        }
        return buildText(text);
      }),
    ],
  );

  Widget buildTabStats() =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          GSRefresh(() =>  buildText(
              'mouse-scene: x: ${IsometricMouse.positionX.toInt()}, y: ${IsometricMouse.positionY.toInt()}\n'
                  'mouse-world: x: ${gamestream.engine.mouseWorldX.toInt()}, y: ${gamestream.engine.mouseWorldY.toInt()}\n'
                  'mouse-screen: x: ${gamestream.engine.mousePositionX.toInt()}, y: ${gamestream.engine.mousePositionY.toInt()}\n'
                  'player-alive: ${gamestream.isometric.player.alive.value}\n'
                  'player-position: ${gamestream.isometric.player.position}\n'
                  'player-render: x: ${gamestream.isometric.player.position.renderX}, y: ${gamestream.isometric.player.position.renderY}\n'
                  'player-screen: x: ${gamestream.isometric.player.positionScreenX.toInt()}, y: ${gamestream.isometric.player.positionScreenY.toInt()}\n'
                  'player-index: z: ${gamestream.isometric.player.position.indexZ}, row: ${gamestream.isometric.player.position.indexRow}, column: ${gamestream.isometric.player.position.indexColumn}\n'
                  'player-legs: ${LegType.getName(gamestream.isometric.player.legs.value)}\n'
                  'player-body: ${BodyType.getName(gamestream.isometric.player.body.value)}\n'
                  'player-head: ${HeadType.getName(gamestream.isometric.player.head.value)}\n'
                  'player-weapon: ${WeaponType.getName(gamestream.isometric.player.weapon.value)}\n'
                  'aim-target-category: ${TargetCategory.getName(gamestream.isometric.player.aimTargetCategory)}\n'
                  'aim-target-type: ${gamestream.isometric.player.aimTargetType}\n'
                  'aim-target-name: ${gamestream.isometric.player.aimTargetName}\n'
                  'aim-target-position: ${gamestream.isometric.player.aimTargetPosition}\n'
                  'target-position: ${gamestream.isometric.player.targetPosition}\n'
                  'scene-light-sources: ${gamestream.isometric.scene.nodesLightSourcesTotal}\n'
                  'scene-light-active: ${gamestream.isometric.client.lights_active}\n'
                  'total-gameobjects: ${gamestream.isometric.server.gameObjects.length}\n'
                  'total-characters: ${gamestream.isometric.server.totalCharacters}\n'
                  'total-particles: ${gamestream.isometric.particles.particles.length}\n'
                  'total-particles-active: ${gamestream.isometric.particles.countActiveParticles}\n'
          )),
          buildWatch(gamestream.updateFrame, (t) => buildText('update-frame: $t')),
          buildWatch(gamestream.gameType, (GameType value) => buildText('game-type: ${value.name}')),
          buildWatch(gamestream.engine.deviceType, (int deviceType) => buildText('device-type: ${DeviceType.getName(deviceType)}', onPressed: gamestream.engine.toggleDeviceType)),
          buildWatch(gamestream.io.inputMode, (int inputMode) => buildText('input-mode: ${InputMode.getName(inputMode)}', onPressed: gamestream.io.actionToggleInputMode)),
          buildWatch(gamestream.engine.watchMouseLeftDown, (bool mouseLeftDown) => buildText('mouse-left-down: $mouseLeftDown')),
          buildWatch(gamestream.engine.mouseRightDown, (bool rightDown) => buildText('mouse-right-down: $rightDown')),
          // watch(GameEditor.nodeSelectedIndex, (int index) => text("edit-state-node-index: $index")),
        ],
      );

  Widget buildTabLighting() =>
      Column(
        children: [
          onPressed(
              action: gamestream.isometric.client.toggleDynamicShadows,
              child: GSRefresh(() => buildText('dynamic-shadows-enabled: ${gamestream.isometric.client.dynamicShadows}'))
          ),
          onPressed(
              child: GSRefresh(() => buildText('blend-mode: ${gamestream.engine.bufferBlendMode.name}')),
              action: (){
                final currentIndex = BlendMode.values.indexOf(gamestream.engine.bufferBlendMode);
                final nextIndex = currentIndex + 1 >= BlendMode.values.length ? 0 : currentIndex + 1;
                gamestream.engine.bufferBlendMode = BlendMode.values[nextIndex];
              }
          ),
          height8,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buildText('<-', onPressed: (){
                gamestream.isometric.scene.setInterpolationLength(gamestream.isometric.scene.interpolationLength - 1);
              }),
              GSRefresh(() => buildText('light-size: ${gamestream.isometric.scene.interpolationLength}')),
              buildText('->', onPressed: (){
                gamestream.isometric.scene.setInterpolationLength(gamestream.isometric.scene.interpolationLength + 1);
              }),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buildText('<-', onPressed: (){
                final indexCurrent = EaseType.values.indexOf(gamestream.isometric.scene.interpolationEaseType.value);
                final indexNext = indexCurrent - 1 >= 0 ? indexCurrent - 1 : EaseType.values.length - 1;
                gamestream.isometric.scene.interpolationEaseType.value = EaseType.values[indexNext];
              }),
              buildWatch(gamestream.isometric.scene.interpolationEaseType, buildText),
              buildText('->', onPressed: (){
                final indexCurrent = EaseType.values.indexOf(gamestream.isometric.scene.interpolationEaseType.value);
                final indexNext = indexCurrent + 1 >= EaseType.values.length ? 0 : indexCurrent + 1;
                gamestream.isometric.scene.interpolationEaseType.value = EaseType.values[indexNext];
              }),
            ],
          ),

          height16,
          buildText('ambient-color'),
          ColorPicker(
            portraitOnly: true,
            pickerColor: HSVColor.fromAHSV(
              gamestream.isometric.scene.ambientAlpha / 255,
              gamestream.isometric.scene.ambientHue.toDouble(),
              gamestream.isometric.scene.ambientSaturation / 100,
              gamestream.isometric.scene.ambientValue / 100,
            ).toColor(),
            onColorChanged: (color){
              gamestream.isometric.client.overrideColor.value = true;
              final hsvColor = HSVColor.fromColor(color);
              gamestream.isometric.scene.ambientAlpha = (hsvColor.alpha * 255).round();
              gamestream.isometric.scene.ambientHue = hsvColor.hue.round();
              gamestream.isometric.scene.ambientSaturation = (hsvColor.saturation * 100).round();
              gamestream.isometric.scene.ambientValue = (hsvColor.value * 100).round();
              gamestream.isometric.scene.resetNodeColorsToAmbient();
            },
          ),
        ],
      );

  Widget buildTabEngine() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      GSRefresh(() => buildText('engine-touch-world: x: ${gamestream.io.touchCursorWorldX.toInt()}, y: ${gamestream.io.touchCursorWorldY.toInt()}')),
      GSRefresh(() => buildText('engine-render-batches: ${gamestream.engine.batchesRendered}')),
      GSRefresh(() => buildText('engine-render-batch-1: ${gamestream.engine.batches1Rendered}')),
      GSRefresh(() => buildText('engine-render-batch-2: ${gamestream.engine.batches2Rendered}')),
      GSRefresh(() => buildText('engine-render-batch-4: ${gamestream.engine.batches4Rendered}')),
      GSRefresh(() => buildText('engine-render-batch-8: ${gamestream.engine.batches8Rendered}')),
      GSRefresh(() => buildText('engine-render-batch-16: ${gamestream.engine.batches16Rendered}')),
      GSRefresh(() => buildText('engine-render-batch-32: ${gamestream.engine.batches32Rendered}')),
      GSRefresh(() => buildText('engine-render-batch-64: ${gamestream.engine.batches64Rendered}')),
      GSRefresh(() => buildText('engine-render-batch-128: ${gamestream.engine.batches128Rendered}')),
      GSRefresh(() => buildText('engine-camera-zoom: ${gamestream.engine.targetZoom.toStringAsFixed(3)}')),
      GSRefresh(() => buildText('engine-render-frame: ${gamestream.engine.paintFrame}')),
      GSRefresh(() => buildText('engine-update-frame: ${gamestream.engine.updateFrame}')),
      buildRowWatchInt(text: 'engine.ms-render', watch: gamestream.engine.msRender),
      buildRowWatchInt(text: 'engine.ms-update', watch: gamestream.engine.msUpdate),
      buildWatch(gamestream.engine.msRender, (t) {
        return buildRowText(text: 'engine.fps-render', value: t <= 0 ? '0' : (1000 ~/ t).toString());
      }),
      buildWatch(gamestream.engine.msUpdate, (t) {
        return buildRowText(text: 'engine.fps-update', value: t <= 0 ? '0' : (1000 ~/ t).toString());
      }),
      buildWatch(gamestream.engine.renderFramesSkipped, (t) {
        return buildRowText(text: 'render.frames-skipped', value:t);
      }),
      onPressed(
          action: () => gamestream.engine.drawCanvasAfterUpdate = !gamestream.engine.drawCanvasAfterUpdate,
          child: GSRefresh(() => buildText(' engine.drawCanvasAfterUpdate = ${gamestream.engine.drawCanvasAfterUpdate}'))

      ),
      onPressed(
          action: () => gamestream.renderResponse = !gamestream.renderResponse,
          child: GSRefresh(() => buildText(' gamestream.renderResponse = ${gamestream.renderResponse}'))
      ),
    ],
  );

  Widget buildTabObjects() => GSRefresh(
        () => Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: gamestream.isometric.server.gameObjects
              .map((gameObject) => onPressed(
                action: () => gamestream.isometric.selectGameObject(gameObject),
                child: buildText(
                    '${GameObjectType.getName(gameObject.type)} - ${GameObjectType.getNameSubType(gameObject.type, gameObject.subType)}'),
              ))
              .toList(growable: false),
        ),
        seconds: 1,
      );

  static Widget buildRowWatchDouble({
    required Watch<double> watch,
    required String text,
  }) => buildRow(
    text: text,
    value: WatchBuilder(watch, (x) => buildText(x.toInt())),
  );

  static Widget buildRowWatchInt({
    required Watch<int> watch,
    required String text,
  }) => buildRow(text: text, value: WatchBuilder(watch, buildText));

  static Widget buildRowWatchBool({
    required Watch<bool> watch,
    required String text,
  }) => buildRow(text: text, value: WatchBuilder(watch, buildText));

  static Widget buildRowWatchString({
    required String text,
    required Watch<String> watch,
  }) => buildRow(text: text, value: WatchBuilder(watch, buildText));

  static Widget buildRowText({required String text, required dynamic value}) => Container(
    margin: const EdgeInsets.only(bottom: 2),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        buildValue(buildText(text), color: Colors.black12),
        buildValue(buildText(value)),
      ],
    ),
  );

  static Widget buildRow({required String text, required Widget value}) => Container(
    margin: const EdgeInsets.only(bottom: 2),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        buildValue(buildText(text), color: Colors.black12),
        buildValue(value),
      ],
    ),
  );

  static Widget buildValueText(dynamic value, {Color color = Colors.white12}) =>
      buildValue(buildText(value));

  static Widget buildValue(Widget child, {Color color = Colors.white12}) => Container(
    width: 140,
    alignment: Alignment.centerLeft,
    color: color,
    padding: const EdgeInsets.all(4),
    child: FittedBox(child: child),
  );

  Widget buildTarget(){

    final columnSet = Column(
      children: [
        buildRowWatchString(text: 'target-type', watch: targetType),
        buildRowWatchDouble(text: 'target-x', watch: targetX),
        buildRowWatchDouble(text: 'target-y', watch: targetY),
        buildRowWatchDouble(text: 'target-z', watch: targetZ),
      ],
    );

    final notSet = Column(
      children: [
        buildRow(text: 'target-type', value: buildText('-')),
        buildRow(text: 'target-x', value: buildText('-')),
        buildRow(text: 'target-y', value: buildText('-')),
        buildRow(text: 'target-z', value: buildText('-')),
      ],
    );

    return WatchBuilder(targetSet, (targetSet) => targetSet ? columnSet : notSet);
  }

  Widget buildSelectedColliderTypeCharacter() => SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        onPressed(
          action: isometric.debugCharacterDebugUpdate,
          child: buildText('DEBUG'), ),
        height8,
        onPressed(
          child: buildRow(
            text: 'camera-target',
            value: GSRefresh((){
              final target = isometric.camera.target;
              if (target == null) {
                return buildValueText('-');
              }
              return buildValueText(target.runtimeType);
            }),
          ),
        ),
        buildRowWatchString(text: 'runtime-type', watch: runTimeType),
        buildRow(text: 'action', value: buildWatch(action, (t) => buildText(CharacterAction.getName(t)))),
        buildRow(text: 'goal', value: buildWatch(action, (t) => buildText(CharacterGoal.getName(t)))),
        buildRowWatchInt(text: 'team', watch: team),
        buildRowWatchInt(text: 'radius', watch: radius),
        buildWatch(healthMax, (healthMax) => buildWatch(health, (health) =>
            buildRowText(text: 'health', value: '$health / $healthMax'))),
        buildRowWatchDouble(text: 'x', watch: x),
        buildRowWatchDouble(text: 'y', watch: y),
        buildRowWatchDouble(text: 'z', watch: z),
        buildRowWatchInt(text: 'path-index', watch: pathIndex),
        buildRowWatchInt(text: 'path-end', watch: pathEnd),
        buildRowWatchInt(text: 'path-target-index', watch: pathTargetIndex),
        buildRow(text: 'character-type', value: buildDropDownCharacterType()),
        buildRow(text: 'character-state', value: buildWatch(characterState, (t) => buildText(CharacterState.getName(t)))),
        buildRowWatchInt(text: 'character-state-duration', watch: characterStateDuration),
        buildRowWatchInt(text: 'character-state-duration-remaining', watch: characterStateDurationRemaining),
        buildRow(text: 'weapon-type', value: buildDropDownWeaponType()),
        buildRowWatchInt(text: 'weapon-damage', watch: weaponDamage),
        buildRowWatchInt(text: 'weapon-range', watch: weaponRange),
        buildRow(text: 'weapon-state', value: buildWatch(weaponState, (t) => buildText(WeaponState.getName(t)))),
        buildRowWatchInt(text: 'weapon-state-duration', watch: weaponStateDuration),
        onPressed(
            action: isometric.debugCharacterToggleAutoAttack,
            child: buildRowWatchBool(text: 'auto-attack', watch: autoAttack)
        ),
        onPressed(
            action: isometric.debugCharacterTogglePathFindingEnabled,
            child: buildRowWatchBool(text: 'path-finding-enabled', watch: pathFindingEnabled)
        ),
        onPressed(
            action: isometric.debugCharacterToggleRunToDestination,
            child: buildRowWatchBool(text: 'run-to-destination', watch: runToDestinationEnabled)
        ),
        buildTarget(),
      ],
    ),
  );

  Widget buildSelectedColliderTypeGameObject() => SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildRowWatchString(text: 'runtime-type', watch: runTimeType),
        buildRowWatchInt(text: 'team', watch: team),
        buildWatch(healthMax, (healthMax) => buildWatch(health, (health) =>
            buildRowText(text: 'health', value: '$health / $healthMax'))),
        buildRowWatchInt(text: 'radius', watch: radius),
        buildRowWatchDouble(text: 'x', watch: x, ),
        buildRowWatchDouble(text: 'y', watch: y),
        buildRowWatchDouble(text: 'z', watch: z),
        WatchBuilder(selectedGameObjectType, (type) => Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildRow(text: 'type', value: buildText(GameObjectType.getName(type))),
              buildRow(text: 'sub-type', value: WatchBuilder(selectedGameObjectSubType, (subType) => buildText(GameObjectType.getNameSubType(type, subType))))
            ],
          ))

      ],
    ),
  );

  Widget buildTabIsometric() => Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        onPressed(
            action: isometric.options.toggleRenderHealthbarAllies,
            child: buildRow(text: 'render-health-ally', value: GSRefresh(() => buildValueText(isometric.options.renderHealthBarAllies))),
        ),
        onPressed(
            action: isometric.options.toggleRenderHealthBarEnemies,
            child: buildRow(text: 'render-health-enemy', value: GSRefresh(() => buildValueText(isometric.options.renderHealthBarEnemies))),
        ),
      ],
    );
}

