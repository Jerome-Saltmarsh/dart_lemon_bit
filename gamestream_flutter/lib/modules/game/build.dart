import 'package:bleed_common/library.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/audio.dart';
import 'package:gamestream_flutter/colours.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/game.dart';
import 'package:gamestream_flutter/icons.dart';
import 'package:gamestream_flutter/modules/game/actions.dart';
import 'package:gamestream_flutter/modules/game/enums.dart';
import 'package:gamestream_flutter/modules/game/update.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:gamestream_flutter/modules/ui/layouts.dart';
import 'package:gamestream_flutter/ui/builders/build_debug_panel.dart';
import 'package:gamestream_flutter/ui/builders/build_hud_map_editor.dart';
import 'package:gamestream_flutter/ui/builders/build_hud_random.dart';
import 'package:gamestream_flutter/ui/builders/build_layout.dart';
import 'package:gamestream_flutter/ui/builders/build_text_box.dart';
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
          return buildLayoutWaitingForPlayers();
        case GameStatus.In_Progress:
          return buildLayoutInProgress();
        case GameStatus.Finished:
          return buildDialogGameFinished();
        default:
          return empty;
      }
    });
  }

  Widget buildLayoutCountDown() {
    return WatchBuilder(game.countDownFramesRemaining, (int frames){
      final seconds =  frames ~/ 45.0;
      return Center(child: text("Game starts in $seconds", size: FontSize.Large));
    });
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
    return buildLayout(
        children: [
          Positioned(
              left: 8,
              top: 8,
              child: visibleBuilder(state.debug, buildPanelDebug())
          ),
          buildPanelWriteMessage(),
          if (game.type.value == GameType.RANDOM)
            buildHudRandom(),
          if (game.type.value == GameType.FRONTLINE)
            buildHudMapEditor(),
        ]);
  }

  Widget buildTextLivesRemaining(){
    return Positioned(
      right: 20,
      bottom: 20,
      child: WatchBuilder(modules.game.state.lives, (int lives){
         return text('Lives: $lives');
      }),
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
        return icons.sword;
      case StoreTab.Armor:
        return icons.shield;
      case StoreTab.Items:
        return icons.books.grey;
    }
  }

  Widget getSlotTypeImage(int value){
    return _slotTypeImages[value] ?? icons.unknown;
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

  Widget buildToggleEnabledSound(){
    return WatchBuilder(audio.soundEnabled, (bool enabled){
      return button(text("Sound", decoration: enabled
          ? TextDecoration.none
          : TextDecoration.lineThrough
      ), audio.toggleSoundEnabled);
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
}

final _slotTypeImages = <int, Widget> {
  SlotType.Empty: icons.empty,
  SlotType.Sword_Short : icons.sword,
  SlotType.Sword_Wooden : icons.swords.wooden,
  SlotType.Golden_Necklace : icons.trinkets.goldenNecklace,
  SlotType.Sword_Long : icons.swords.iron,
  SlotType.Bow_Wooden : icons.bows.wooden,
  SlotType.Bow_Green : icons.bows.green,
  SlotType.Bow_Gold : icons.bows.gold,
  SlotType.Staff_Wooden : icons.staffs.wooden,
  SlotType.Staff_Blue : icons.staffs.blue,
  SlotType.Staff_Golden : icons.staffs.golden,
  SlotType.Spell_Tome_Fireball : icons.books.red,
  SlotType.Spell_Tome_Ice_Ring : icons.books.blue,
  SlotType.Spell_Tome_Split_Arrow : icons.books.blue,
  SlotType.Body_Blue : icons.armour.standard,
  SlotType.Steel_Helmet : icons.heads.steel,
  SlotType.Magic_Hat : icons.heads.magic,
  SlotType.Rogue_Hood : icons.heads.rogue,
  SlotType.Potion_Red : icons.potions.red,
  SlotType.Potion_Blue : icons.potions.blue,
  SlotType.Armour_Padded : icons.armour.padded,
  SlotType.Magic_Robes : icons.armour.magic,
  SlotType.Handgun : icons.firearms.handgun,
  SlotType.Shotgun : icons.firearms.shotgun,
  SlotType.Pickaxe : icons.swords.pickaxe,
};

final techTypeIcons = <int, Widget> {
  TechType.Unarmed: icons.unknown,
  TechType.Sword: icons.swords.wooden,
  TechType.Bow: icons.bows.wooden,
  TechType.Pickaxe: icons.swords.pickaxe,
  TechType.Axe: icons.swords.axe,
  TechType.Hammer: icons.swords.hammer,
  TechType.Bag: icons.bag,
};

final techTypeIconsGray = <int, Widget> {
  TechType.Unarmed: icons.unknown,
  TechType.Sword: icons.swords.woodenGray,
  TechType.Bow: icons.bows.woodenGray,
  TechType.Pickaxe: icons.swords.pickaxeGray,
  TechType.Axe: icons.swords.axeGray,
  TechType.Hammer: icons.swords.hammerGray,
  TechType.Bag: icons.bagGray,
};

