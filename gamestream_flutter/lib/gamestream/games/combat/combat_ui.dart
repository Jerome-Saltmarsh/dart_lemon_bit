
import 'package:bleed_common/src.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/ui.dart';
import 'package:gamestream_flutter/game_style.dart';
import 'package:gamestream_flutter/gamestream/games/combat/combat_game.dart';
import 'package:gamestream_flutter/gamestream/isometric/ui/game_isometric_colors.dart';
import 'package:gamestream_flutter/gamestream/isometric/ui/game_isometric_ui.dart';
import 'package:gamestream_flutter/instances/gamestream.dart';
import 'package:golden_ratio/constants.dart';

extension CombatUI on CombatGame {

  Widget buildStackPlay() => StackFullscreen(children: [
      // buildWatchBool(gamestream.isometric.clientState.window_visible_player_creation, buildWindowCharacterCreation),
      // buildWatchBool(gamestream.isometric.clientState.control_visible_respawn_timer, () =>
      //     Positioned(
      //       bottom: GameStyle.Default_Padding,
      //       left: 0,
      //       child: Container(
      //           width: engine.screen.width,
      //           alignment: Alignment.center,
      //           child: buildWindowPlayerRespawnTimer()),
      //     )
      // ),
    // buildWatchBool(gamestream.isometric.clientState.control_visible_player_power, (){
    //   return buildWatchBool(gamestream.isometric.player.powerReady, () =>
    //       Positioned(
    //         child: buildIconPlayerCombatPowerType(),
    //         left: GameStyle.Default_Padding,
    //         bottom: GameStyle.Default_Padding,
    //       )
    //   );
    // }),

  ]);


  Widget buildWindowCharacterCreation() {

    const textSize = 22;

    const weaponTypes = const [
      ItemType.Weapon_Ranged_Plasma_Rifle,
      ItemType.Weapon_Ranged_Plasma_Pistol,
      ItemType.Weapon_Ranged_Shotgun,
      ItemType.Weapon_Ranged_Bazooka,
      ItemType.Weapon_Ranged_Sniper_Rifle,
      ItemType.Weapon_Ranged_Flamethrower,
      ItemType.Weapon_Ranged_Teleport,
      // ItemType.Weapon_Melee_Knife,
      ItemType.Weapon_Melee_Crowbar,
      ItemType.Weapon_Melee_Sword,
    ];

    const titleFontSize = 22;
    const titleFontColor = Colors.white24;

    const containerWidth = 150.0;
    const containerHeight = 300.0;

    final columnPowers = Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        buildText('space-bar', size: titleFontSize, color: titleFontColor, italic: true),
        height12,
        buildIconPlayerCombatPowerType(),
        height24,
        Container(
          width: containerWidth,
          height: containerHeight,
          child: SingleChildScrollView(
            child: Column(
                children: const <int> [
                  CombatPowerType.Bomb,
                  CombatPowerType.Stun,
                  CombatPowerType.Invisible,
                  CombatPowerType.Shield,
                  CombatPowerType.Teleport,
                ].map((int powerType) => onPressed(
                    action: () => sendClientRequestSelectPower(powerType),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      child: buildWatch(gamestream.isometric.player.powerType, (int playerCombatPowerType){
                        return buildText(CombatPowerType.getName(powerType),
                          color: powerType == playerCombatPowerType ? GameIsometricColors.orange : GameIsometricColors.white80,
                          size: textSize,
                        );
                      }),
                    ),
                  )).toList(growable: false)
            ),
          ),
        ),
      ],
    );

    final columnSelectWeaponLeft = buildWatch(gamestream.isometric.player.weaponPrimary, (int weaponPrimary) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          buildText('left-click', size: titleFontSize, color: titleFontColor, italic: true),
          height12,
          buildIconPlayerWeaponPrimary(),
          height24,
          Container(
            height: containerHeight,
            width: containerWidth,
            child: SingleChildScrollView(
              child: Column(
                children: (weaponTypes).map((int itemType) => Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  child: onPressed(
                      action: () => sendClientRequestSelectWeaponPrimary(itemType),
                      child: buildText(ItemType.getName(itemType),
                        color: weaponPrimary == itemType ? GameIsometricColors.orange : GameIsometricColors.white80,
                        size: textSize,
                      )),
                ),
                ).toList(growable: false),
              ),
            ),
          ),
          // buildIconPlayerWeaponPrimary(),
        ],
      );
    });

    final columnSelectWeaponRight = buildWatch(gamestream.isometric.player.weaponSecondary, (int weaponSecondary) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          buildText('right-click', size: titleFontSize, color: titleFontColor, italic: true),
          height12,
          buildIconPlayerWeaponSecondary(),
          height24,
          Container(
            width: containerWidth,
            height: containerHeight,
            child: SingleChildScrollView(
              child: Column(
                children: (weaponTypes).map((int itemType) => Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  child: onPressed(
                      action: () => sendClientRequestSelectWeaponSecondary(itemType),
                      child: buildText(ItemType.getName(itemType),
                        color: weaponSecondary == itemType ? GameIsometricColors.orange : GameIsometricColors.white80,
                        size: textSize,
                      )),
                ),
                ).toList(growable: false),
              ),
            ),
          ),
        ],
      );
    });

    final buttonPlay = onPressed(
      action: gamestream.isometric.revive,
      child: MouseOver(
          builder: (mouseOver) {
            return Container(
              width: 150,
              height: 150 * goldenRatio_0381,
              alignment: Alignment.center,
              color: GameIsometricColors.green.withAlpha(mouseOver ? 140 : 100),
              child: buildText("START", size: 45, color: GameIsometricColors.green),
            );
          }
      ),
    );

    return buildFullScreen(
      child: GSDialog(
        child: Container(
          width: 600,
          padding: GameStyle.Padding_6,
          color: GameStyle.Container_Color,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              height32,
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  columnSelectWeaponLeft,
                  columnPowers,
                  columnSelectWeaponRight,
                ],
              ),
              height64,
              buttonPlay,
            ],
          ),
        ),
      ),
    );
  }

  Widget buildWindowPlayerRespawnTimer(){
    return Container(
      width: 240,
      height: 240 * goldenRatio_0381,
      color: GameStyle.Container_Color,
      padding: GameStyle.Container_Padding,
      alignment: Alignment.center,
      child: buildWatch(gamestream.isometric.player.respawnTimer, (int respawnTimer){
        return buildText("RESPAWN: ${respawnTimer ~/ GameIsometricUI.Server_FPS}", size: 25);
      }),
    );
  }

  Container buildIconPlayerWeaponSecondary() {
    return Container(
      constraints: BoxConstraints(maxWidth: 120),
      height: 64,
      child: buildWatch(gamestream.isometric.player.weaponSecondary, GameIsometricUI.buildAtlasItemType),
    );
  }

  Container buildIconPlayerWeaponPrimary() {
    return Container(
      constraints: BoxConstraints(maxWidth: 120, maxHeight: 64),
      height: 64,
      child: buildWatch(gamestream.isometric.player.weaponPrimary, GameIsometricUI.buildAtlasItemType),
    );
  }

  Widget buildIconPlayerCombatPowerType(){
    return buildWatch(gamestream.isometric.player.powerReady, (bool powerReady) {
      return !powerReady ? width64 :
      buildWatch(gamestream.isometric.player.powerType, GameIsometricUI.buildIconCombatPowerType);
    });
  }

}