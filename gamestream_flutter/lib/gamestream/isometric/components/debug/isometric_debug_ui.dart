
import 'package:gamestream_flutter/gamestream/ui/builders/build_watch.dart';
import 'package:gamestream_flutter/gamestream/ui/builders/build_watch_bool.dart';
import 'package:gamestream_flutter/gamestream/ui/constants/height.dart';
import 'package:gamestream_flutter/packages/common.dart';
import 'package:golden_ratio/constants.dart';
import 'package:lemon_watch/src.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/debug/isometric_debug.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/functions/format_bytes.dart';
import 'package:gamestream_flutter/gamestream/ui/widgets/gs_container.dart';
import 'package:gamestream_flutter/gamestream/ui/widgets/gs_refresh.dart';
import 'package:lemon_widgets/lemon_widgets.dart';
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
                  DebugTab.Environment => buildTabEnvironment(),
                  DebugTab.Scene => buildTabScene(),
                  DebugTab.Amulet => buildTabAmulet(),
                  DebugTab.Server => buildTabServer(),
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
              'audio-volume-flame: ${audio.audioLoopFire.volume}\n'
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
          buildText('ambient-color'),
          buildRowRefresh('bake-stack-recording', () => scene.bakeStackRecording),
          onPressed(
            action: scene.recordBakeStack,
            child: buildText('record bake'),
          ),
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
          child: GSRefresh(() => buildText('blend-mode: ${engine.bufferBlendMode.name}')),
          action: (){
            final currentIndex = BlendMode.values.indexOf(engine.bufferBlendMode);
            final nextIndex = currentIndex + 1 >= BlendMode.values.length ? 0 : currentIndex + 1;
            engine.bufferBlendMode = BlendMode.values[nextIndex];
          }
      ),
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
                    '${ItemType.getName(gameObject.type)} - ${ItemType.getNameSubType(gameObject.type, gameObject.subType)}'),
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
          action: sendIsometricRequestDebugCharacterDebugUpdate,
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
        buildRow('character-complexion', buildWatch(characterComplexion, (complexion) => onPressed(
            action: selectCharacterComplexion,
            child: buildText(complexion)))
        ),
        buildRowWatchInt(text: 'character-state-duration', watch: characterStateDuration),
        buildRowWatchInt(text: 'character-state-duration-remaining', watch: characterStateDurationRemaining),
        buildRow('weapon-type', buildDropDownWeaponType()),
        buildRowWatchInt(text: 'weapon-damage', watch: weaponDamage),
        buildRowWatchInt(text: 'weapon-range', watch: weaponRange),
        buildRowWatchInt(text: 'weapon-state-duration', watch: weaponStateDuration),
        onPressed(
            action: sendIsometricRequestDebugCharacterToggleAutoAttackNearbyEnemies,
            child: buildRowWatchBool(text: 'auto-attack', watch: autoAttack)
        ),
        onPressed(
            action: sendIsometricRequestDebugCharacterTogglePathFindingEnabled,
            child: buildRowWatchBool(text: 'path-finding-enabled', watch: pathFindingEnabled)
        ),
        onPressed(
            action: sendIsometricRequestDebugCharacterToggleRunToDestination,
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
              buildRow('type', buildText(ItemType.getName(type))),
              buildRow('sub-type', WatchBuilder(selectedGameObjectSubType, (subType) => buildText(ItemType.getNameSubType(type, subType))))
            ],
          ))

      ],
    ),
  );

  Widget buildTabIsometric() => Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GSRefresh(() => buildText(
            'camera-target: ${camera.target}\n'
        )),
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
          buildRowRefresh('position', () {
            final position = player.position;
            return 'x: ${position.x.toInt()}, y: ${position.y.toInt()}, z: ${position.z.toInt()}';
          }),
          onPressed(
            action: player.toggleGender,
            child: buildRowMapped('gender', player.gender, Gender.getName)
          ),
          buildRowMapped('legs type', player.legsType, LegType.getName),
          buildRowMapped('body type', player.bodyType, BodyType.getName),
          onPressed(
            action: () => ui.showDialogGetHairType(onSelected: player.setHairType),
            child: buildRowMapped('hair type', player.hairType, HairType.getName)
          ),
          onPressed(
            action: () => ui.showDialogGetColor(onSelected: player.setHairColor),
            child: buildRowWatch('hair color', player.hairColor, (hairColor) => Container(
              width: 50,
              height: 50,
              color: colors.palette[hairColor],
            )),
          ),
          buildRowMapped('helm type', player.helmType, HelmType.getName),
          buildRowMapped('hand type left', player.handTypeLeft, HandType.getName),
          onPressed(
            action: player.showDialogChangeComplexion,
            child: buildRowWatch('complexion', player.complexion, (complexion) => Container(
                width: 50,
                height: 50,
                color: colors.palette[complexion],
              )),
          ),
          onPressed(
            action: player.changeName,
            child: buildRowWatch('name', player.name, (value){
              return Container(
                  width: 100,
                  height: 50,
                  child: buildText(value));
            }),
          ),
          buildButtonAcquireItem(),
          onPressed(
            action: amulet.requestGainLevel,
            child: buildText('GAIN LEVEL'),
          ),
        ],
      );

  Widget buildTabParticles() => GSRefresh(
      () => Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GSContainer(
            color: colors.brownLight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildText('total: ${particles.children.length}'),
                buildText('total-active: ${particles.countActiveParticles}'),
                buildText('total-deactive: ${particles.countDeactiveParticles}'),
              ],
            ),
          ),
          height16,
          Container(
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
        ],
      ),
    seconds: 1,
  );

  Widget buildTabOptions() =>
      buildTab(
        children: [
          buildRowToggle(
            text: 'render_north',
            action: () => options.renderNorth = !options.renderNorth,
            value: () => options.renderNorth,
          ),
          buildRowToggle(
            text: 'render_east',
            action: () => options.renderEast = !options.renderEast,
            value: () => options.renderEast,
          ),
          buildRowToggle(
            text: 'characters effect particles',
            action: () => options.charactersEffectParticles = !options.charactersEffectParticles,
            value: () => options.charactersEffectParticles,
          ),
          buildRowToggle(
            text: 'alpha blend',
            action: () => ui.showDialogGetInt(onSelected: (int value){
              options.alphaBlend = value;
            }),
            value: () => options.alphaBlend,
          ),
          buildRowToggle(
            text: 'ambient alpha',
            action: () => ui.showDialogGetInt(onSelected: (int value){
              scene.ambientAlpha = value;
            }),
            value: () => scene.ambientAlpha,
          ),
          buildRowToggle(
            text: 'render wind velocity',
            action: () => options.renderWindVelocity = !options.renderWindVelocity,
            value: () => options.renderWindVelocity,
          ),
          buildRowRefresh('total_skipped', () => rendererNodes.totalSkipped),
          buildRowToggle(
             text: 'renderCameraTargets',
             action: options.toggleRenderCameraTargets,
             value: () => options.renderCameraTargets,
          ),
          buildRowToggle(
             text: 'render height map',
             action: () => options.renderHeightMap = !options.renderHeightMap,
             value: () => options.renderHeightMap,
          ),
          buildRowToggle(
             text: 'render run line',
             action: () => options.renderRunLine = !options.renderRunLine,
             value: () => options.renderRunLine,
          ),
          buildRowToggle(
             text: 'render visibility beams',
             action: () => options.renderVisibilityBeams = !options.renderVisibilityBeams,
             value: () => options.renderVisibilityBeams,
          ),
          buildRowToggle(
             text: 'render character animation frame',
             action: options.toggleRenderCharacterAnimationFrame,
             value: () => options.renderCharacterAnimationFrame,
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

  Widget buildTabScene()=> Column(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
         buildRowRefresh('total-marks', () => rendererEditor.getTotal()),
         buildRowRefresh('light-sources-total', () => scene.nodeLightSourcesTotal),
         buildRowRefresh('light-sources-active', () => scene.totalActiveLights),
         buildRowRefresh('smoke-sources', () => scene.smokeSourcesTotal),
         buildRowRefresh('total-gameobjects', () => scene.gameObjects.length),
         buildRowRefresh('total-characters', () => scene.totalCharacters),
         buildRowRefresh('total_columns', () => scene.totalColumns),
         buildRowRefresh('total_rows', () => scene.totalRows),
         buildRowRefresh('total_z', () => scene.totalZ),
    ],
  );

  Widget buildTabEnvironment() => Column(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          onPressed(
            action: environment.requestLightningFlash,
            child: buildText('LIGHTNING FLASH'),
          ),
          buildRowRefresh('lightningFlashing01', () => environment.lightningFlashing01),
          buildRowWatch('myst', environment.myst, (activeMyst) =>
                Row(
                    children: MystType.values
                        .map((mystType) => onPressed(
                          action: () => environment.setMystType(mystType),
                          child: GSContainer(
                              color: activeMyst == mystType ? colors.aqua_2 : colors.brownLight,
                              child: buildText(mystType)))
                          )
                        .toList(growable: false)
                )
            ),
          buildRowWatch('lightning', environment.lightningType, (lightning) =>
                Row(
                    children: MystType.values
                        .map((lightningType) => onPressed(
                          action: () => environment.setLightningType(lightningType),
                          child: GSContainer(
                              color: lightning == lightningType ? colors.aqua_2 : colors.brownLight,
                              child: buildText(lightningType)))
                          )
                        .toList(growable: false)
                )
            )
        ],
      );

  Widget buildRowWatch<T>(String text, Watch<T> watch, Widget build(T t)) =>
      buildRow(text, buildWatch(watch, build));

  Widget buildRowRefresh(String text,  dynamic getValue()) =>
      buildRow(text, GSRefresh(() => buildText(getValue())));

  void selectCharacterComplexion() =>
      ui.showDialogGetColor(
        onSelected: (index) => network.sendRequest(
          NetworkRequest.Debug,
          NetworkRequestDebug.Set_Complexion,
          index,
        )
    );

  Widget buildTabAmulet() => GSContainer(
      child: Column(
        children: [
          buildRowRefresh('world_row', () => amulet.worldRow),
          buildRowRefresh('world_column', () => amulet.worldColumn),
          buildText('CHANGE GAME'),
          buildWatch(amulet.amuletScene, (activeAmuletScene) => Column(
              children: AmuletScene.values.map((amuletScene) => onPressed(
                action: () =>
                    network.sendNetworkRequest(
                      NetworkRequest.Amulet,
                      NetworkRequestAmulet.Player_Change_Game.index,
                      amuletScene.index,
                    ),
                child: GSContainer(
                  color: activeAmuletScene == amuletScene ? Colors.white12 : Colors.black12,
                  child: buildText(amuletScene.name),
                ),
              )).toList(growable: false),
            )),
        ],
      ),
    );

  Widget buildTabServer() {
    return Column(
      children: [

      ],
    );
  }

  Widget buildButtonAcquireItem() {
    return onPressed(
        action: (){
          ui.showDialog(child: GSContainer(
            width: 400,
            height: 400 * goldenRatio_1381,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    buildText('Acquire Item'),
                    onPressed(
                      action: ui.closeDialog,
                      child: buildText('Close'),
                    ),
                  ],
                ),
                Container(
                  height: 300,
                  child: SingleChildScrollView(
                    child: Column(
                      children:
                      AmuletItem.values.map((e) {
                        return onPressed(
                          action: (){
                            amulet.requestAcquireAmuletItem(e);
                          },
                          child: GSContainer(
                              color: Colors.green,
                              margin: const EdgeInsets.only(bottom: 4),
                              child: buildText(e.name)),
                        );
                      }).toList(growable: false)
                      ,
                    ),
                  ),
                )
              ],
            ),
          ));
        },
        child: buildText('acquire item'));
  }

}



Widget buildWatchMapText<T>(Watch<T> watch, dynamic mapper(T t))
  => buildWatch(watch, (t) => buildText(mapper(t)));


