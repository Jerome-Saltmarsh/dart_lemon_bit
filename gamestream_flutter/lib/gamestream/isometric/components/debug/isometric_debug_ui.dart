
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/isometric.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/functions/format_bytes.dart';
import 'package:gamestream_flutter/ui.dart';
import 'package:gamestream_flutter/library.dart';

import 'debug_tab.dart';

extension isometricDebugUI on IsometricDebug {

  Widget buildUI() =>
      buildWatchBool(isometric.player.debugging, () =>
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
                      maxHeight: isometric.engine.screen.height - 150),
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
          isometric.network.sendIsometricRequestDebugCharacterSetCharacterType(newValue);
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
          isometric.network.sendIsometricRequestDebugCharacterSetWeaponType(newValue);
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
      buildWatch(isometric.serverFPS, (serverFPS) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          buildWatch(isometric.network.websocket.connectionStatus, (connectionStatus) => buildText('connection-status: ${connectionStatus.name}')),
          GSRefresh(() => buildText(
              'connection-duration: ${formattedConnectionDuration}\n'
          )),
          buildText('network-server-fps: $serverFPS'),
          buildWatch(isometric.network.responseReader.bufferSize, (int bytes) => buildText('network-bytes: $bytes')),
          buildWatch(isometric.network.responseReader.bufferSize, (int bytes) => buildText('network-bytes-per-frame: ${formatBytes(bytes)}')),
          buildWatch(isometric.network.responseReader.bufferSize, (int bytes) => buildText('network-bytes-per-second: ${formatBytes(bytes * serverFPS)}')),
          buildWatch(isometric.network.responseReader.bufferSize, (int bytes) => buildText('network-bytes-per-minute: ${formatBytes(bytes * serverFPS * 60)}')),
          buildWatch(isometric.network.responseReader.bufferSize, (int bytes) => buildText('network-bytes-per-hour: ${formatBytes(bytes * serverFPS * 60 * 60)}')),
          height8,
          buildWatch(isometric.io.updateSize, (int bytes) => buildText('network-bytes-up: $bytes')),
          buildWatch(isometric.io.updateSize, (int bytes) => buildText('network-bytes-up-per-hour: ${formatBytes(bytes * serverFPS * 60 * 60)}')),
        ],
      )),
      height16,
    ],
  );

  Widget buildTabStats() =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          GSRefresh(() =>  buildText(
              'mouse-scene: x: ${isometric.mouse.positionX.toInt()}, y: ${isometric.mouse.positionY.toInt()}\n'
                  'mouse-world: x: ${isometric.engine.mouseWorldX.toInt()}, y: ${isometric.engine.mouseWorldY.toInt()}\n'
                  'mouse-screen: x: ${isometric.engine.mousePositionX.toInt()}, y: ${isometric.engine.mousePositionY.toInt()}\n'
                  'player-alive: ${isometric.player.alive.value}\n'
                  'player-position: ${isometric.player.position}\n'
                  'player-render: x: ${isometric.player.position.renderX}, y: ${isometric.player.position.renderY}\n'
                  'player-screen: x: ${isometric.player.positionScreenX.toInt()}, y: ${isometric.player.positionScreenY.toInt()}\n'
                  'player-index: z: ${isometric.player.position.indexZ}, row: ${isometric.player.position.indexRow}, column: ${isometric.player.position.indexColumn}\n'
                  'player-legs: ${LegType.getName(isometric.player.legs.value)}\n'
                  'player-body: ${BodyType.getName(isometric.player.body.value)}\n'
                  'player-head: ${HeadType.getName(isometric.player.head.value)}\n'
                  'player-weapon: ${WeaponType.getName(isometric.player.weapon.value)}\n'
                  'aim-target-category: ${TargetCategory.getName(isometric.player.aimTargetCategory)}\n'
                  'aim-target-type: ${isometric.player.aimTargetType}\n'
                  'aim-target-name: ${isometric.player.aimTargetName}\n'
                  'aim-target-position: ${isometric.player.aimTargetPosition}\n'
                  'target-position: ${isometric.player.targetPosition}\n'
                  'scene-light-sources: ${isometric.scene.nodeLightSourcesTotal}\n'
                  'scene-light-active: ${isometric.scene.totalActiveLights}\n'
                  'scene.smoke-sources: ${isometric.scene.smokeSourcesTotal}\n'
                  'total-gameobjects: ${isometric.scene.gameObjects.length}\n'
                  'total-characters: ${isometric.scene.totalCharacters}\n'
                  'total-particles: ${isometric.particles.particles.length}\n'
                  'total-particles-active: ${isometric.particles.countActiveParticles}\n'
          )),
          buildWatch(isometric.gameType, (GameType value) => buildText('game-type: ${value.name}')),
          buildWatch(isometric.engine.deviceType, (int deviceType) => buildText('device-type: ${DeviceType.getName(deviceType)}', onPressed: isometric.engine.toggleDeviceType)),
          buildWatch(isometric.io.inputMode, (int inputMode) => buildText('input-mode: ${InputMode.getName(inputMode)}', onPressed: isometric.io.actionToggleInputMode)),
          buildWatch(isometric.engine.watchMouseLeftDown, (bool mouseLeftDown) => buildText('mouse-left-down: $mouseLeftDown')),
          buildWatch(isometric.engine.mouseRightDown, (bool rightDown) => buildText('mouse-right-down: $rightDown')),
          // watch(GameEditor.nodeSelectedIndex, (int index) => text("edit-state-node-index: $index")),
        ],
      );

  Widget buildTabLighting() =>
      Column(
        children: [
          onPressed(
              child: GSRefresh(() => buildText('blend-mode: ${isometric.engine.bufferBlendMode.name}')),
              action: (){
                final currentIndex = BlendMode.values.indexOf(isometric.engine.bufferBlendMode);
                final nextIndex = currentIndex + 1 >= BlendMode.values.length ? 0 : currentIndex + 1;
                isometric.engine.bufferBlendMode = BlendMode.values[nextIndex];
              }
          ),
          height8,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buildText('<-', onPressed: (){
                isometric.scene.setInterpolationLength(isometric.scene.interpolationLength - 1);
              }),
              GSRefresh(() => buildText('light-size: ${isometric.scene.interpolationLength}')),
              buildText('->', onPressed: (){
                isometric.scene.setInterpolationLength(isometric.scene.interpolationLength + 1);
              }),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buildText('<-', onPressed: (){
                final indexCurrent = EaseType.values.indexOf(isometric.scene.interpolationEaseType.value);
                final indexNext = indexCurrent - 1 >= 0 ? indexCurrent - 1 : EaseType.values.length - 1;
                isometric.scene.interpolationEaseType.value = EaseType.values[indexNext];
              }),
              buildWatch(isometric.scene.interpolationEaseType, buildText),
              buildText('->', onPressed: (){
                final indexCurrent = EaseType.values.indexOf(isometric.scene.interpolationEaseType.value);
                final indexNext = indexCurrent + 1 >= EaseType.values.length ? 0 : indexCurrent + 1;
                isometric.scene.interpolationEaseType.value = EaseType.values[indexNext];
              }),
            ],
          ),

          height16,
          buildText('ambient-color'),
          // ColorPicker(
          //   portraitOnly: true,
          //   pickerColor: HSVColor.fromAHSV(
          //     isometric.ambientAlpha / 255,
          //     // isometric.ambientHue.toDouble(),
          //     // isometric.ambientSaturation / 100,
          //     // isometric.ambientValue / 100,
          //   ).toColor(),
          //   onColorChanged: (color){
          //     isometric.overrideColor.value = true;
          //     final hsvColor = HSVColor.fromColor(color);
          //     isometric.ambientAlpha = (hsvColor.alpha * 255).round();
          //     // isometric.ambientHue = hsvColor.hue.round();
          //     // isometric.ambientSaturation = (hsvColor.saturation * 100).round();
          //     // isometric.ambientValue = (hsvColor.value * 100).round();
          //     isometric.resetNodeColorsToAmbient();
          //   },
          // ),
        ],
      );

  Widget buildTabEngine() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      GSRefresh(() => buildText('engine-zoom: ${isometric.engine.zoom.toStringAsFixed(3)}')),
      GSRefresh(() => buildText('engine-touch-world: x: ${isometric.io.touchCursorWorldX.toInt()}, y: ${isometric.io.touchCursorWorldY.toInt()}')),
      GSRefresh(() => buildText('engine-render-batches: ${isometric.engine.batchesRendered}')),
      GSRefresh(() => buildText('engine-render-batch-1: ${isometric.engine.batches1Rendered}')),
      GSRefresh(() => buildText('engine-render-batch-2: ${isometric.engine.batches2Rendered}')),
      GSRefresh(() => buildText('engine-render-batch-4: ${isometric.engine.batches4Rendered}')),
      GSRefresh(() => buildText('engine-render-batch-8: ${isometric.engine.batches8Rendered}')),
      GSRefresh(() => buildText('engine-render-batch-16: ${isometric.engine.batches16Rendered}')),
      GSRefresh(() => buildText('engine-render-batch-32: ${isometric.engine.batches32Rendered}')),
      GSRefresh(() => buildText('engine-render-batch-64: ${isometric.engine.batches64Rendered}')),
      GSRefresh(() => buildText('engine-render-batch-128: ${isometric.engine.batches128Rendered}')),
      GSRefresh(() => buildText('engine-camera-zoom: ${isometric.engine.targetZoom.toStringAsFixed(3)}')),
      GSRefresh(() => buildText('engine-render-frame: ${isometric.engine.paintFrame}')),
      GSRefresh(() => buildText('engine-update-frame: ${isometric.engine.updateFrame}')),
      buildRowWatchInt(text: 'engine.ms-render', watch: isometric.engine.msRender),
      buildRowWatchInt(text: 'engine.ms-update', watch: isometric.engine.msUpdate),
      buildWatch(isometric.engine.msRender, (t) {
        return buildRowText(text: 'engine.fps-render', value: t <= 0 ? '0' : (1000 ~/ t).toString());
      }),
      buildWatch(isometric.engine.msUpdate, (t) {
        return buildRowText(text: 'engine.fps-update', value: t <= 0 ? '0' : (1000 ~/ t).toString());
      }),
      buildWatch(isometric.engine.renderFramesSkipped, (t) {
        return buildRowText(text: 'render.frames-skipped', value:t);
      }),
      onPressed(
          action: () => isometric.engine.drawCanvasAfterUpdate = !isometric.engine.drawCanvasAfterUpdate,
          child: GSRefresh(() => buildText(' engine.drawCanvasAfterUpdate = ${isometric.engine.drawCanvasAfterUpdate}'))

      ),
      onPressed(
          action: () => isometric.renderResponse = !isometric.renderResponse,
          child: GSRefresh(() => buildText(' isometric.renderResponse = ${isometric.renderResponse}'))
      ),
    ],
  );

  Widget buildTabObjects() => GSRefresh(
        () => Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: isometric.scene.gameObjects
              .map((gameObject) => onPressed(
                action: () => isometric.network.sendIsometricRequestSelectGameObject(gameObject),
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
          action: isometric.network.sendIsometricRequestDebugCharacterDebugUpdate,
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
            action: isometric.network.sendIsometricRequestDebugCharacterToggleAutoAttackNearbyEnemies,
            child: buildRowWatchBool(text: 'auto-attack', watch: autoAttack)
        ),
        onPressed(
            action: isometric.network.sendIsometricRequestDebugCharacterTogglePathFindingEnabled,
            child: buildRowWatchBool(text: 'path-finding-enabled', watch: pathFindingEnabled)
        ),
        onPressed(
            action: isometric.network.sendIsometricRequestDebugCharacterToggleRunToDestination,
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
            action: isometric.compositor.rendererNodes.toggleDynamicResolutionEnabled,
            child: buildRow(text: 'dynamic-resolution-enabled', value: GSRefresh(() => buildText(isometric.compositor.rendererNodes.dynamicResolutionEnabled))),
        ),
        GSRefresh(() => buildText(
            'camera-target: ${isometric.camera.target}\n'
        )),
        buildRow(text: 'high-resolution', value: GSRefresh(() => buildText(isometric.compositor.rendererNodes.highResolution))),
        buildRow(text: 'ambient-screen-on', value: GSRefresh(() => buildText(isometric.totalAmbientOnscreen))),
        buildRow(text: 'ambient-screen-off', value: GSRefresh(() => buildText(isometric.totalAmbientOffscreen))),
        buildRow(text: 'nodes-screen-on', value: GSRefresh(() => buildText(isometric.compositor.rendererNodes.onscreenNodes))),
        buildRow(text: 'nodes-screen-off', value: GSRefresh(() => buildText(isometric.compositor.rendererNodes.offscreenNodes))),
        buildRow(text: 'order-shift-y', value: GSRefresh(() => buildValueText(isometric.compositor.rendererNodes.orderShiftY))),
        onPressed(
          action: isometric.compositor.rendererNodes.increaseOrderShiftY,
          child: buildText('increase'),
        ),
        onPressed(
          action: isometric.compositor.rendererNodes.decreaseOrderShiftY,
          child: buildText('decrease'),
        ),
        onPressed(
          action: isometric.options.toggleRenderHealthbarAllies,
          child: buildRow(text: 'render-health-ally', value: GSRefresh(() => buildValueText(isometric.options.renderHealthBarAllies))),
        ),
        onPressed(
            action: isometric.options.toggleRenderHealthbarAllies,
            child: buildRow(text: 'render-health-ally', value: GSRefresh(() => buildValueText(isometric.options.renderHealthBarAllies))),
        ),
        onPressed(
            action: isometric.options.toggleRenderHealthBarEnemies,
            child: buildRow(text: 'render-health-enemy', value: GSRefresh(() => buildValueText(isometric.options.renderHealthBarEnemies))),
        ),
        onPressed(
            action: isometric.player.toggleControlsRunInDirectionEnabled,
            child: buildRowWatchBool(
                watch: isometric.player.controlsRunInDirectionEnabled,
                text: 'controlsRunInDirectionEnabled',
            ),
        ),

        onPressed(
            action: isometric.player.toggleControlsCanTargetEnemies,
            child: buildRowWatchBool(
                watch: isometric.player.controlsCanTargetEnemies,
                text: 'controlsCanTargetEnemies',
            ),
        ),
      ],
    );





  String get formattedConnectionDuration {
    final duration = isometric.network.websocket.connectionDuration;
    if (duration == null) return 'not connected';
    final seconds = duration.inSeconds % 60;
    final minutes = duration.inMinutes;
    return 'minutes: $minutes, seconds: $seconds';
  }

  String formatAverageBufferSize(int bytes){
    final duration = isometric.network.websocket.connectionDuration;
    if (duration == null) return 'not connected';
    final seconds = duration.inSeconds;
    final bytesPerSecond = (bytes / seconds).round();
    final bytesPerMinute = bytesPerSecond * 60;
    final bytesPerHour = bytesPerMinute * 60;
    return 'per second: $bytesPerSecond, per minute: $bytesPerMinute, per hour: $bytesPerHour';
  }

  String formatAverageBytePerSecond(int bytes){
    final duration = isometric.network.websocket.connectionDuration;
    if (duration == null) return 'not connected';
    if (duration.inSeconds <= 0) return '-';
    return formatBytes((bytes / duration.inSeconds).round());
  }

  String formatAverageBytePerMinute(int bytes){
    final duration = isometric.network.websocket.connectionDuration;
    if (duration == null) return 'not connected';
    if (duration.inSeconds <= 0) return '-';
    return formatBytes((bytes / duration.inSeconds).round() * 60);
  }

  String formatAverageBytePerHour(int bytes){
    final duration = isometric.network.websocket.connectionDuration;
    if (duration == null) return 'not connected';
    if (duration.inSeconds <= 0) return '-';
    return formatBytes((bytes / duration.inSeconds).round() * 3600);
  }
}

