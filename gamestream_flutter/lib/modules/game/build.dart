import 'package:bleed_common/library.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/audio.dart';
import 'package:gamestream_flutter/bytestream_parser.dart';
import 'package:gamestream_flutter/colours.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/game.dart';
import 'package:gamestream_flutter/modules/game/actions.dart';
import 'package:gamestream_flutter/modules/game/enums.dart';
import 'package:gamestream_flutter/modules/game/update.dart';
import 'package:gamestream_flutter/modules/isometric/utilities.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:gamestream_flutter/modules/ui/module.dart';
import 'package:gamestream_flutter/resources.dart';
import 'package:gamestream_flutter/ui/compose/buildTextBox.dart';
import 'package:gamestream_flutter/ui/compose/hudUI.dart';
import 'package:gamestream_flutter/ui/dialogs.dart';
import 'package:gamestream_flutter/ui/functions/build_panel_highlighted_structure_type.dart';
import 'package:gamestream_flutter/ui/functions/build_panel_highlighted_tech_type_upgrade.dart';
import 'package:gamestream_flutter/ui/functions/build_panel_primary.dart';
import 'package:gamestream_flutter/ui/style.dart';
import 'package:gamestream_flutter/ui/views.dart';
import 'package:golden_ratio/constants.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_watch/watch_builder.dart';

import '../isometric/enums.dart';
import 'state.dart';

class GameBuild {

  final GameState state;
  final GameActions actions;

  static const empty = SizedBox();

  final slotSize = 50.0;

  GameBuild(this.state, this.actions);

  Widget buildUIGame() {
    print("buildUIGame()");

    return WatchBuilder(core.state.status, (GameStatus gameStatus) {
      switch (gameStatus) {
        case GameStatus.Counting_Down:
          return buildLayoutCountDown();
        case GameStatus.Awaiting_Players:
          return ui.layouts.buildLayoutLoading();
        case GameStatus.In_Progress:
          return buildLayoutInProgress();
        case GameStatus.Finished:
          return buildDialogGameFinished();
        default:
          return ui.layouts.buildLayoutLoading();
      }
    });
  }

  Widget buildLayoutCountDown() {
    return buildDialog(
        width: style.dialogWidthMedium,
        height: style.dialogHeightMedium,
        child: WatchBuilder(game.countDownFramesRemaining, (int frames){
          final seconds =  frames ~/ 30.0;
          return Center(child: text("Starting in $seconds seconds"));
        }));
  }

  Widget buildMagicBar() {
    final width = 280.0;
    final height = width *
        goldenRatio_0381 *
        goldenRatio_0381;

    return WatchBuilder(state.player.magic, (double magic) {
      final maxMagic = state.player.maxMagic.value;
      if (maxMagic <= 0) return empty;
      final percentage = magic / maxMagic;
      return Container(
        width: width,
        height: height,
        alignment: Alignment.centerLeft,
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            Container(
              color: colours.blueDarkest,
              width: width,
              height: height,
            ),
            Container(
              color: colours.blue,
              width: width * percentage,
              height: height,
            ),
            Container(
              color: Colors.transparent,
              width: width,
              height: height,
              alignment: Alignment.center,
              child: text('${magic.toInt()} / ${state.player.maxMagic.value}'),
            ),
          ],
        ),
      );
    });
  }

  Widget respawnButton(){
    return button("Respawn", actions.respawn);
  }

  Widget buildLayoutInProgress(){
    const _pad = 8.0;

    return WatchBuilder(state.player.alive, (bool alive){
      return layout(
          children: [
            Positioned(
                left: _pad,
                top: _pad,
                child: WatchBuilder(state.debugPanelVisible, (bool visible){
                  return visible ? buildDebugPanel() : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    ],
                  );
                })
            ),
            buildTextBox(),
            buildTopRight(),
            if (!alive)
            respawnButton(),
            buildPanelHighlightedStructureType(),
            buildPanelHighlightedTechTypeUpgrade(),
            buildPanelPrimary(),
          ]);
    });
  }

  Row buildDebugMenu() {
    return Row(
      children: [
        toggleDebugMode(),
        width8,
        button("Edit Map", () {
          core.actions.openMapEditor(newScene: false);
        }),
      ],
    );
  }

  Widget buildTopRight(){
    final menu = Row(
      children: [
        buildButtonFullScreen(),
        width8,
        buildButtonToggleCameraMode(),
        width8,
        buildButtonSkipTrack(),
        width8,
        buildToggleEnabledSound(),
        width8,
        buildToggleEnabledMusic(),
        width8,
        buildButtonExit(),
      ],
    );
    return Positioned(
      right: 8.0,
      top: 8.0,
      child: boolBuilder(modules.hud.menuVisible, widgetTrue: menu, widgetFalse: empty),
    );
  }

  Widget buildButtonExit() => button("Exit", core.actions.disconnect);

  Widget panel({required Widget child, Alignment? alignment, EdgeInsets? padding, double? width}){
    return Container(
        color: colours.brownLight,
        child: child,
        alignment: alignment,
        padding: padding,
        width: width,
    );
  }

  Widget mapStoreTabToIcon(StoreTab value) {
    switch (value) {
      case StoreTab.Weapons:
        return resources.icons.sword;
      case StoreTab.Armor:
        return resources.icons.shield;
      case StoreTab.Items:
        return resources.icons.books.grey;
    }
  }

  Widget getSlotTypeImage(int value){
    return _slotTypeImages[value] ?? resources.icons.unknown;
  }

  Widget mousePosition() {
    return Refresh((){
      return text("Mouse Screen: x: ${engine.mousePosition.x}, y: ${engine.mousePosition.y}");
    });
  }

  Widget mouseDownState(){
    return WatchBuilder(engine.mouseLeftDown, (bool down){
      return text("Mouse Down: $down");
    });
  }

  Widget mouseRowColumn(){
    return Refresh((){
      return text("Mouse Row:$mouseRow, Column: $mouseColumn");
    });
  }

  Widget buildFramesSinceUpdate(){
    return WatchBuilder(framesSinceUpdateReceived, (int frames){
      return text("Frames Since Update: $frames");
    });
  }

  Widget buildFramesSmoothed(){
    return WatchBuilder(state.framesSmoothed, (int frames){
      return text("Frames Smoothed: $frames");
    });
  }

  Widget buildTotalEvents(){
    return WatchBuilder(totalEvents, (int frames){
      return text("Events: $frames");
    });
  }

  Widget buildMSSinceUpdate(){
    return WatchBuilder(averageUpdate, (double frames){
      return text("Milliseconds Since Last: $frames");
    });
  }

  Widget buildSync(){
    return WatchBuilder(sync, (double frames){
      return text("Sync: $frames");
    });
  }

  Widget buildTotalFrames(){
    return WatchBuilder(totalUpdates, (int frames){
      return text("Frames: $frames");
    });
  }

  Widget get buildTotalParticles {
    return Refresh((){
      return text("Particles: ${isometric.particles.length}");
    });
  }

  Widget get playerScreen {
    return Refresh(() {
      return text("Player Screen: x: ${worldToScreenX(state.player.x)}, y: ${worldToScreenY(state.player.y)}");
    });
  }

  Widget get buildActiveParticles {
    return Refresh((){
      return text("Active Particles: ${isometric.totalActiveParticles}");
    });
  }

  Widget get tileAtMouse {
    return Refresh((){
      return text("Tile: ${isometric.tileAtMouse}");
    });
  }

  Widget get playerPosition {
    final character = modules.game.state.player;
    return Refresh((){
      return text("Player Position: X: ${character.x}, Y: ${character.y}");
    });
  }

  Widget get playerId {
    final character = modules.game.state.player;
    return Refresh((){
      return text("Player Id: ${character.id}");
    });
  }

  Widget get mousePositionWorld {
    return Refresh((){
      return text("Mouse World: x: ${mouseWorldX.toInt()}, y: ${mouseWorldY.toInt()}");
    });
  }

  Widget get mousePositionScreen {
    return Refresh((){
      return text("Mouse Screen: x: ${engine.mousePosition.x.toInt()}, y: ${engine.mousePosition.y.toInt()}");
    });
  }

  Widget get cameraZoom {
    return Refresh((){
      return text("Zoom: ${engine.zoom}");
    });
  }

  Widget get byteCountWatcher {
    return WatchBuilder(byteLength, (int count){
        return text("Bytes: $count");
    });
  }

  Widget get bufferLengthWatcher {
    return WatchBuilder(bufferSize, (int count){
      return text("Buffer Size: $count");
    });
  }

  Widget buildVersion(){
    return text(version, color: colours.white618);
  }

  Widget toggleDebugMode(){
    return WatchBuilder(state.compilePaths, (bool compilePaths){
      return button("Debug Mode: $compilePaths", actions.toggleDebugPaths);
    });
  }

  Widget buildToggleEnabledSound(){
    return WatchBuilder(audio.soundEnabled, (bool enabled){
      return button(text("Sound", decoration: enabled
          ? TextDecoration.none
          : TextDecoration.lineThrough
      ), audio.toggleEnabledSound);
    });
  }

  Widget buildToggleEnabledMusic(){
    return WatchBuilder(audio.musicEnabled, (bool enabled){
      return button(text("Music", decoration: enabled
          ? TextDecoration.none
          : TextDecoration.lineThrough
      ), audio.toggleEnabledMusic);
    });
  }

  Widget buildButtonToggleCameraMode(){
    return WatchBuilder(modules.game.state.cameraMode, (CameraMode mode){
       return button(mode.name, modules.game.actions.nextCameraMode);
    });
  }

  Widget buildButtonSkipTrack(){
    return button("Next", audio.nextSong);
  }

  Widget buildButtonFullScreen(){
    return button("Fullscreen", engine.fullscreenToggle);
  }

  Widget buildScoreBoard(){
    return SingleChildScrollView(
      child: Container(
          constraints: BoxConstraints(maxHeight: 400),
          child: textBuilder(game.scoreText)),
    );
  }

  Widget buildTotalZombies() {
    return WatchBuilder(game.totalZombies, (int value) {
      return text('Zombies: $value');
    });
  }


  Widget buildDebugPanel(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
          ui.widgets.time,
          buildTotalZombies(),
          buildTotalPlayers(),
          mouseRowColumn(),
          buildVersion(),
          buildTotalParticles,
          buildActiveParticles,
          tileAtMouse,
          mousePositionWorld,
          mousePositionScreen,
          byteCountWatcher,
          bufferLengthWatcher,
          playerPosition,
          cameraZoom,
          buildFramesSinceUpdate(),
          buildFramesSmoothed(),
          playerScreen,
          buildTotalEvents(),
          buildTotalFrames(),
          buildMSSinceUpdate(),
          buildSync(),
      ],
    );
  }
}

final _slotTypeImages = <int, Widget> {
  SlotType.Empty: resources.icons.empty,
  SlotType.Sword_Short : resources.icons.sword,
  SlotType.Sword_Wooden : resources.icons.swords.wooden,
  SlotType.Golden_Necklace : resources.icons.trinkets.goldenNecklace,
  SlotType.Sword_Long : resources.icons.swords.iron,
  SlotType.Bow_Wooden : resources.icons.bows.wooden,
  SlotType.Bow_Green : resources.icons.bows.green,
  SlotType.Bow_Gold : resources.icons.bows.gold,
  SlotType.Staff_Wooden : resources.icons.staffs.wooden,
  SlotType.Staff_Blue : resources.icons.staffs.blue,
  SlotType.Staff_Golden : resources.icons.staffs.golden,
  SlotType.Spell_Tome_Fireball : resources.icons.books.red,
  SlotType.Spell_Tome_Ice_Ring : resources.icons.books.blue,
  SlotType.Spell_Tome_Split_Arrow : resources.icons.books.blue,
  SlotType.Body_Blue : resources.icons.armour.standard,
  SlotType.Steel_Helmet : resources.icons.heads.steel,
  SlotType.Magic_Hat : resources.icons.heads.magic,
  SlotType.Rogue_Hood : resources.icons.heads.rogue,
  SlotType.Potion_Red : resources.icons.potions.red,
  SlotType.Potion_Blue : resources.icons.potions.blue,
  SlotType.Armour_Padded : resources.icons.armour.padded,
  SlotType.Magic_Robes : resources.icons.armour.magic,
  SlotType.Handgun : resources.icons.firearms.handgun,
  SlotType.Shotgun : resources.icons.firearms.shotgun,
  SlotType.Pickaxe : resources.icons.swords.pickaxe,
};

final techTypeIcons = <int, Widget> {
  TechType.Unarmed: resources.icons.unknown,
  TechType.Sword: resources.icons.swords.wooden,
  TechType.Bow: resources.icons.bows.wooden,
  TechType.Pickaxe: resources.icons.swords.pickaxe,
  TechType.Axe: resources.icons.swords.axe,
  TechType.Hammer: resources.icons.swords.hammer,
  TechType.Bag: resources.icons.bag,
};

final techTypeIconsGray = <int, Widget> {
  TechType.Unarmed: resources.icons.unknown,
  TechType.Sword: resources.icons.swords.woodenGray,
  TechType.Bow: resources.icons.bows.woodenGray,
  TechType.Pickaxe: resources.icons.swords.pickaxeGray,
  TechType.Axe: resources.icons.swords.axeGray,
  TechType.Hammer: resources.icons.swords.hammerGray,
  TechType.Bag: resources.icons.bagGray,
};

