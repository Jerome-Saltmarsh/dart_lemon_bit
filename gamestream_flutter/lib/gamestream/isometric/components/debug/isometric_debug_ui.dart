
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/debug/isometric_debug.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/functions/format_bytes.dart';
import 'package:gamestream_flutter/ui.dart';
import 'package:gamestream_flutter/library.dart';

import 'debug_tab.dart';

extension isometricDebugUI on IsometricDebug {

  Widget buildUI() =>
      buildWatchBool(player.debugging, () =>
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildDebugTabs(),
              buildActiveTabContent(),
            ],
          )
      );

  Widget buildActiveTabContent() => buildWatch(
      tab,
      (activeTab) => GSContainer(
        child: Container(
              constraints: BoxConstraints(
                  minWidth: 300,
                  maxWidth: 400,
                  minHeight: 300,
                  maxHeight: engine.screen.height - 150),
              child: SingleChildScrollView(
                child: switch (activeTab) {
                  DebugTab.Selected => buildTabSelected(),
                  DebugTab.Network => buildTabNetwork(),
                  DebugTab.Stats => buildTabStats(),
                  DebugTab.Lighting => buildTabLighting(),
                  DebugTab.Engine => buildTabEngine(),
                  DebugTab.Objects => buildTabObjects(),
                  DebugTab.Isometric => buildTabIsometric(),
                  DebugTab.Player => buildTabPlayer(),
                  DebugTab.Options => buildTabOptions(),
                  DebugTab.Particles => buildTabParticles(),
                },
              ),
            ),
      ));

  Widget buildDebugTabs() => GSContainer(
    child: buildWatch(
        tab,
        (activeTab) => Row(
            children: DebugTab.values
                .map((e) => onPressed(
                    action: () => tab.value = e,
                    child: Container(
                        margin: const EdgeInsets.only(right: 16),
                        child: buildText(
                          e.name,
                          bold: activeTab == e,
                          underline: activeTab == e,
                        ))))
                .toList(growable: false))),
  );

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
          network.sendIsometricRequestDebugCharacterSetCharacterType(newValue);
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
          network.sendIsometricRequestDebugCharacterSetWeaponType(newValue);
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
      buildWatch(options.serverFPS, (serverFPS) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          buildWatch(network.websocket.connectionStatus, (connectionStatus) => buildText('connection-status: ${connectionStatus.name}')),
          GSRefresh(() => buildText(
              'connection-duration: ${formattedConnectionDuration}\n'
          )),
          buildText('network-server-fps: $serverFPS'),
          buildWatch(network.parser.bufferSize, (int bytes) => buildText('network-bytes: $bytes')),
          buildWatch(network.parser.bufferSize, (int bytes) => buildText('network-bytes-per-frame: ${formatBytes(bytes)}')),
          buildWatch(network.parser.bufferSize, (int bytes) => buildText('network-bytes-per-second: ${formatBytes(bytes * serverFPS)}')),
          buildWatch(network.parser.bufferSize, (int bytes) => buildText('network-bytes-per-minute: ${formatBytes(bytes * serverFPS * 60)}')),
          buildWatch(network.parser.bufferSize, (int bytes) => buildText('network-bytes-per-hour: ${formatBytes(bytes * serverFPS * 60 * 60)}')),
          height8,
          buildWatch(io.updateSize, (int bytes) => buildText('network-bytes-up: $bytes')),
          buildWatch(io.updateSize, (int bytes) => buildText('network-bytes-up-per-hour: ${formatBytes(bytes * serverFPS * 60 * 60)}')),
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
              'mouse-scene: x: ${mouse.positionX.toInt()}, y: ${mouse.positionY.toInt()}\n'
                  'mouse-world: x: ${engine.mouseWorldX.toInt()}, y: ${engine.mouseWorldY.toInt()}\n'
                  'mouse-screen: x: ${engine.mousePositionX.toInt()}, y: ${engine.mousePositionY.toInt()}\n'
                  'aim-target-action: ${TargetAction.getName(player.aimTargetAction.value)}\n'
                  'aim-target-type: ${player.aimTargetType}\n'
                  'aim-target-position: ${player.aimTargetPosition}\n'
                  'target-position: ${player.targetPosition}\n'
                  'scene-light-sources: ${scene.nodeLightSourcesTotal}\n'
                  'scene-light-active: ${scene.totalActiveLights}\n'
                  'scene.smoke-sources: ${scene.smokeSourcesTotal}\n'
                  'total-gameobjects: ${scene.gameObjects.length}\n'
                  'total-characters: ${scene.totalCharacters}\n'
                  'total-particles: ${particles.children.length}\n'
                  'total-particles-active: ${particles.countActiveParticles}\n'
          )),
          buildWatch(options.gameType, (GameType value) => buildText('game-type: ${value.name}')),
          // buildWatch(engine.deviceType, (int deviceType) => buildText('device-type: ${DeviceType.getName(deviceType)}', onPressed: engine.toggleDeviceType)),
          // buildWatch(io.inputMode, (int inputMode) => buildText('input-mode: ${InputMode.getName(inputMode)}', onPressed: io.actionToggleInputMode)),
          buildWatch(engine.watchMouseLeftDown, (bool mouseLeftDown) => buildText('mouse-left-down: $mouseLeftDown')),
          buildWatch(engine.mouseRightDown, (bool rightDown) => buildText('mouse-right-down: $rightDown')),
          // watch(GameEditor.nodeSelectedIndex, (int index) => text("edit-state-node-index: $index")),
        ],
      );

  Widget buildTabLighting() =>
      Column(
        children: [
          onPressed(
              child: GSRefresh(() => buildText('blend-mode: ${engine.bufferBlendMode.name}')),
              action: (){
                final currentIndex = BlendMode.values.indexOf(engine.bufferBlendMode);
                final nextIndex = currentIndex + 1 >= BlendMode.values.length ? 0 : currentIndex + 1;
                engine.bufferBlendMode = BlendMode.values[nextIndex];
              }
          ),
          height8,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            // children: [
            //   buildText('<-', onPressed: (){
            //     scene.setInterpolationLength(scene.interpolationLength - 1);
            //   }),
            //   GSRefresh(() => buildText('light-size: ${scene.interpolationLength}')),
            //   buildText('->', onPressed: (){
            //     scene.setInterpolationLength(scene.interpolationLength + 1);
            //   }),
            // ],
          ),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: [
          //     buildText('<-', onPressed: (){
          //       final indexCurrent = EaseType.values.indexOf(scene.interpolationEaseType.value);
          //       final indexNext = indexCurrent - 1 >= 0 ? indexCurrent - 1 : EaseType.values.length - 1;
          //       scene.interpolationEaseType.value = EaseType.values[indexNext];
          //     }),
          //     buildWatch(scene.interpolationEaseType, buildText),
          //     buildText('->', onPressed: (){
          //       final indexCurrent = EaseType.values.indexOf(scene.interpolationEaseType.value);
          //       final indexNext = indexCurrent + 1 >= EaseType.values.length ? 0 : indexCurrent + 1;
          //       scene.interpolationEaseType.value = EaseType.values[indexNext];
          //     }),
          //   ],
          // ),

          height16,
          buildText('ambient-color'),
          // ColorPicker(
          //   portraitOnly: true,
          //   pickerColor: HSVColor.fromAHSV(
          //     ambientAlpha / 255,
          //     // ambientHue.toDouble(),
          //     // ambientSaturation / 100,
          //     // ambientValue / 100,
          //   ).toColor(),
          //   onColorChanged: (color){
          //     overrideColor.value = true;
          //     final hsvColor = HSVColor.fromColor(color);
          //     ambientAlpha = (hsvColor.alpha * 255).round();
          //     // ambientHue = hsvColor.hue.round();
          //     // ambientSaturation = (hsvColor.saturation * 100).round();
          //     // ambientValue = (hsvColor.value * 100).round();
          //     resetNodeColorsToAmbient();
          //   },
          // ),
        ],
      );

  Widget buildTabEngine() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      GSRefresh(() => buildText('engine-zoom: ${engine.zoom.toStringAsFixed(3)}')),
      GSRefresh(() => buildText('engine-touch-world: x: ${io.touchCursorWorldX.toInt()}, y: ${io.touchCursorWorldY.toInt()}')),
      GSRefresh(() => buildText('engine-render-batches: ${engine.batchesRendered}')),
      GSRefresh(() => buildText('engine-render-batch-1: ${engine.batches1Rendered}')),
      GSRefresh(() => buildText('engine-render-batch-2: ${engine.batches2Rendered}')),
      GSRefresh(() => buildText('engine-render-batch-4: ${engine.batches4Rendered}')),
      GSRefresh(() => buildText('engine-render-batch-8: ${engine.batches8Rendered}')),
      GSRefresh(() => buildText('engine-render-batch-16: ${engine.batches16Rendered}')),
      GSRefresh(() => buildText('engine-render-batch-32: ${engine.batches32Rendered}')),
      GSRefresh(() => buildText('engine-render-batch-64: ${engine.batches64Rendered}')),
      GSRefresh(() => buildText('engine-render-batch-128: ${engine.batches128Rendered}')),
      GSRefresh(() => buildText('engine-camera-zoom: ${engine.targetZoom.toStringAsFixed(3)}')),
      GSRefresh(() => buildText('engine-render-frame: ${engine.paintFrame}')),
      GSRefresh(() => buildText('engine-update-frame: ${engine.updateFrame}')),
      buildRowWatchInt(text: 'engine.ms-render', watch: engine.msRender),
      buildRowWatchInt(text: 'engine.ms-update', watch: engine.msUpdate),
      buildWatch(engine.msRender, (t) {
        return buildRowText(text: 'engine.fps-render', value: t <= 0 ? '0' : (1000 ~/ t).toString());
      }),
      buildWatch(engine.msUpdate, (t) {
        return buildRowText(text: 'engine.fps-update', value: t <= 0 ? '0' : (1000 ~/ t).toString());
      }),
      buildWatch(engine.renderFramesSkipped, (t) {
        return buildRowText(text: 'render.frames-skipped', value:t);
      }),
      onPressed(
          action: () => engine.drawCanvasAfterUpdate = !engine.drawCanvasAfterUpdate,
          child: GSRefresh(() => buildText(' engine.drawCanvasAfterUpdate = ${engine.drawCanvasAfterUpdate}'))
      ),
      onPressed(
          action: () => options.renderResponse = !options.renderResponse,
          child: GSRefresh(() => buildText(' renderResponse = ${options.renderResponse}'))
      ),

      buildText('engine-color'),
      ColorPicker(
          portraitOnly: true,
          pickerColor: engine.color, onColorChanged: (selectedColor){
        engine.color = selectedColor;
      })
    ],
  );

  Widget buildTabObjects() => GSRefresh(
        () => Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: scene.gameObjects
              .map((gameObject) => onPressed(
                action: () => network.sendIsometricRequestSelectGameObject(gameObject),
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
    text,
    WatchBuilder(watch, (x) => buildText(x.toInt())),
  );

  static Widget buildRowWatchInt({
    required Watch<int> watch,
    required String text,
  }) => buildRow(text, WatchBuilder(watch, buildText));

  static Widget buildRowWatchBool({
    required Watch<bool> watch,
    required String text,
  }) => buildRow(text, WatchBuilder(watch, buildText));

  static Widget buildRowWatchString({
    required String text,
    required Watch<String> watch,
  }) => buildRow(text, WatchBuilder(watch, buildText));

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

  static Widget buildRow(String text, Widget value) => Container(
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
        buildRow('target-type', buildText('-')),
        buildRow('target-x', buildText('-')),
        buildRow('target-y', buildText('-')),
        buildRow('target-z', buildText('-')),
      ],
    );

    return WatchBuilder(targetSet, (targetSet) => targetSet ? columnSet : notSet);
  }

  Widget buildSelectedColliderTypeCharacter() => SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        onPressed(
          action: network.sendIsometricRequestDebugCharacterDebugUpdate,
          child: buildText('DEBUG'), ),
        height8,
        onPressed(
          child: buildRow(
            'camera-target',
            GSRefresh((){
              final target = camera.target;
              if (target == null) {
                return buildValueText('-');
              }
              return buildValueText(target.runtimeType);
            }),
          ),
        ),
        buildRowWatchString(text: 'runtime-type', watch: runTimeType),
        buildRow('action', buildWatch(characterAction, (t) => buildText(CharacterAction.getName(t)))),
        buildRow('goal', buildWatch(goal, (t) => buildText(CharacterGoal.getName(t)))),
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
        buildRow('character-type', buildDropDownCharacterType()),
        buildRow('character-state', buildWatch(characterState, (t) => buildText(CharacterState.getName(t)))),
        buildRowWatchInt(text: 'character-state-duration', watch: characterStateDuration),
        buildRowWatchInt(text: 'character-state-duration-remaining', watch: characterStateDurationRemaining),
        buildRow('weapon-type', buildDropDownWeaponType()),
        buildRowWatchInt(text: 'weapon-damage', watch: weaponDamage),
        buildRowWatchInt(text: 'weapon-range', watch: weaponRange),
        // buildRow('weapon-state', buildWatch(weaponState, (t) => buildText(WeaponState.getName(t)))),
        buildRowWatchInt(text: 'weapon-state-duration', watch: weaponStateDuration),
        onPressed(
            action: network.sendIsometricRequestDebugCharacterToggleAutoAttackNearbyEnemies,
            child: buildRowWatchBool(text: 'auto-attack', watch: autoAttack)
        ),
        onPressed(
            action: network.sendIsometricRequestDebugCharacterTogglePathFindingEnabled,
            child: buildRowWatchBool(text: 'path-finding-enabled', watch: pathFindingEnabled)
        ),
        onPressed(
            action: network.sendIsometricRequestDebugCharacterToggleRunToDestination,
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
              buildRow('type', buildText(GameObjectType.getName(type))),
              buildRow('sub-type', WatchBuilder(selectedGameObjectSubType, (subType) => buildText(GameObjectType.getNameSubType(type, subType))))
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
            action: compositor.rendererNodes.toggleDynamicResolutionEnabled,
            child: buildRow('dynamic-resolution-enabled', GSRefresh(() => buildText(compositor.rendererNodes.dynamicResolutionEnabled))),
        ),
        GSRefresh(() => buildText(
            'camera-target: ${camera.target}\n'
        )),
        buildRow('high-resolution', GSRefresh(() => buildText(compositor.rendererNodes.highResolution))),
        buildRow('nodes-screen-on', GSRefresh(() => buildText(compositor.rendererNodes.onscreenNodes))),
        buildRow('nodes-screen-off', GSRefresh(() => buildText(compositor.rendererNodes.offscreenNodes))),
        buildRow('order-shift-y', GSRefresh(() => buildValueText(compositor.rendererNodes.orderShiftY))),
        onPressed(
          action: compositor.rendererNodes.increaseOrderShiftY,
          child: buildText('increase'),
        ),
        onPressed(
          action: compositor.rendererNodes.decreaseOrderShiftY,
          child: buildText('decrease'),
        ),
        onPressed(
          action: options.toggleRenderHealthbarAllies,
          child: buildRow('render-health-ally', GSRefresh(() => buildValueText(options.renderHealthBarAllies))),
        ),
        onPressed(
            action: options.toggleRenderHealthbarAllies,
            child: buildRow('render-health-ally', GSRefresh(() => buildValueText(options.renderHealthBarAllies))),
        ),
        onPressed(
            action: options.toggleRenderHealthBarEnemies,
            child: buildRow('render-health-enemy', GSRefresh(() => buildValueText(options.renderHealthBarEnemies))),
        ),
        onPressed(
            action: player.toggleControlsRunInDirectionEnabled,
            child: buildRowWatchBool(
                watch: player.controlsRunInDirectionEnabled,
                text: 'controlsRunInDirectionEnabled',
            ),
        ),

        onPressed(
            action: player.toggleControlsCanTargetEnemies,
            child: buildRowWatchBool(
                watch: player.controlsCanTargetEnemies,
                text: 'controlsCanTargetEnemies',
            ),
        ),
      ],
    );





  String get formattedConnectionDuration {
    final duration = network.websocket.connectionDuration;
    if (duration == null) return 'not connected';
    final seconds = duration.inSeconds % 60;
    final minutes = duration.inMinutes;
    return 'minutes: $minutes, seconds: $seconds';
  }

  String formatAverageBufferSize(int bytes){
    final duration = network.websocket.connectionDuration;
    if (duration == null) return 'not connected';
    final seconds = duration.inSeconds;
    final bytesPerSecond = (bytes / seconds).round();
    final bytesPerMinute = bytesPerSecond * 60;
    final bytesPerHour = bytesPerMinute * 60;
    return 'per second: $bytesPerSecond, per minute: $bytesPerMinute, per hour: $bytesPerHour';
  }

  String formatAverageBytePerSecond(int bytes){
    final duration = network.websocket.connectionDuration;
    if (duration == null) return 'not connected';
    if (duration.inSeconds <= 0) return '-';
    return formatBytes((bytes / duration.inSeconds).round());
  }

  String formatAverageBytePerMinute(int bytes){
    final duration = network.websocket.connectionDuration;
    if (duration == null) return 'not connected';
    if (duration.inSeconds <= 0) return '-';
    return formatBytes((bytes / duration.inSeconds).round() * 60);
  }

  String formatAverageBytePerHour(int bytes){
    final duration = network.websocket.connectionDuration;
    if (duration == null) return 'not connected';
    if (duration.inSeconds <= 0) return '-';
    return formatBytes((bytes / duration.inSeconds).round() * 3600);
  }

  Widget buildTabPlayer() =>
      buildTab(
        children: [
          buildRowMapped('legs-type', player.legsType, LegType.getName),
          buildRowMapped('body-type', player.bodyType, BodyType.getName),
          buildRowMapped('head-type', player.headType, HeadType.getName),
          buildRowMapped('hand-type-left', player.handTypeLeft, HandType.getName),
          buildRowMapped('hand-type-right', player.handTypeRight, HandType.getName),
        ],
      );

  Widget buildTabParticles() => GSRefresh(
      () => Container(
        constraints: BoxConstraints(
          maxHeight: engine.screen.height - 300,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: particles.children.map((particle) => onPressed(
                  action: () => selectParticle(particle),
                  child: buildText(
                      ParticleType.getName(particle.type),
                      color: particle.active ? colors.white : colors.white70
                  ))).toList(growable: false)
          ),
        ),
      ),
    seconds: 1,
  );

  Widget buildTabOptions() =>
      buildTab(
        children: [
          buildRowToggle(
             text: 'render character animation frame',
             action: options.toggleRenderCharacterAnimationFrame,
             value: () => options.renderCharacterAnimationFrame,
          ),
          buildRowToggle(
             text: 'render rain twice',
             action: options.toggleRenderRainTwice,
             value: () => options.renderRainFallingTwice,
          ),
        ],
      );

  Widget buildRowMapped<T>(String text, Watch<T> watch, dynamic mapper(T t)) =>
      buildRow(text, buildWatchMapText(watch, mapper));

  Widget buildTab({required List<Widget> children}) => Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
    );

  Widget buildRowToggle({
    required String text,
    required Function action,
    required Function value,
  }) =>
      onPressed(
        action: action,
        child: buildRow(text,
          GSRefresh(() => buildValueText(value())),
        ),
      );
}

Widget buildWatchMapText<T>(Watch<T> watch, dynamic mapper(T t))
  => buildWatch(watch, (t) => buildText(mapper(t)));

