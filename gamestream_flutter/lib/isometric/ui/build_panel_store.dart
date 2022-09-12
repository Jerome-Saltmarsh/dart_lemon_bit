
import 'package:bleed_common/attack_type.dart';
import 'package:bleed_common/library.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/isometric/enums/equipment_type.dart';
import 'package:gamestream_flutter/isometric/player.dart';
import 'package:gamestream_flutter/isometric/player_store.dart';
import 'package:gamestream_flutter/isometric/ui/buttons/build_atlas_image.dart';
import 'package:gamestream_flutter/isometric/ui/widgets/build_container.dart';
import 'package:gamestream_flutter/network/send_client_request.dart';
import 'package:lemon_watch/watch.dart';

import '../classes/weapon.dart';
import 'constants/colors.dart';

final storeEquipmentType = Watch(EquipmentType.Weapon);

final weaponInformation = Watch<Weapon?>(null);

Widget buildPanelStore(){
  return watch(storeItems, (List<Weapon> weapons){
      if (weapons.isEmpty) return SizedBox();
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              container(child: "PURCHASE"),
              container(child: SizedBox()),
              container(child: "CLOSE", action: sendClientRequestStoreClose),
            ],
          ),
          height6,
          Row(children: EquipmentType.values.map((tab) {
            return watch(storeEquipmentType, (active){
              return container(
                child: text(tab.name),
                action: () => storeEquipmentType.value = tab,
                color: tab == storeEquipmentType.value ? greyDark : grey,
              );
            });
          }).toList()),
          height6,
          watch(storeEquipmentType, (tab){
            switch (tab){
              case EquipmentType.Weapon:
                return buildStoreTabWeapons();
              case EquipmentType.Armour:
                return buildColumnSelectPlayerArmour();
              case EquipmentType.Head:
                return buildColumnSelectPlayerHead();
              case EquipmentType.Pants:
                return buildColumnSelectPlayerPants();
              default:
                return text("not available");
            }
          })
        ],
      );
  });
}

Widget buildColumnSelectPlayerArmour(){
   return Column(
      children: ArmourType.values.map(_buildSelectArmourType).toList(),
   );
}

Widget buildStoreTabWeapons(){
   return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
     children: [
        buildWatchPlayerStoreItems(),
        width6,
        buildWatchWeaponInformation(),
     ],
   );
}

Widget buildWatchPlayerStoreItems() {
  return watch(storeItems, (List<Weapon> weapons){
      if (weapons.isEmpty) return const SizedBox();
      return Column(
        children: weapons.map(_buildButtonPurchaseWeapon).toList(),
      );
  });
}

Widget buildWatchWeaponInformation(){
   return watch(weaponInformation, (Weapon? weapon){
      return Container(
         color: grey,
         width: 200,
         padding: const EdgeInsets.all(6),
         child: weapon == null ? null : Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               text(weapon.name),
               text('Damage: ${weapon.damage}'),
             ],
         ),
      );
   });
}

Widget buildColumnSelectPlayerHead(){
   return Column(
      children: HeadType.values.map(buildButtonSelectPlayerHead).toList(),
   );
}

Widget buildColumnSelectPlayerPants(){
  return Column(
    children: PantsType.values.map(_buildButtonPants).toList(),
  );
}

Widget buildButtonSelectPlayerHead(int headType) {
   return watch(player.headType, (int playerHeadType){
      return container(
          child: text(HeadType.getName(headType)),
          action: () => sendClientRequestSetHeadType(headType),
          color: headType == playerHeadType ? greyDark : grey,
      );
   });
}

Widget _buildButtonPants(int pantsType) {
  return watch(player.pantsType, (int playerPantsType){
    return container(
      child: text(PantsType.getName(pantsType)),
      action: () => sendClientRequestSetPantsType(pantsType),
      color: pantsType == playerPantsType ? green : grey,
    );
  });
}

Widget buildColumnPlayerWeapons(int activePlayerAttackType) =>
  Container(
    color: brownLight,
    padding: const EdgeInsets.all(6),
    child: Column(
      children: [
        buildButtonEquipAttackType(AttackType.Shotgun, activePlayerAttackType),
        buildButtonEquipAttackType(AttackType.Handgun, activePlayerAttackType),
        buildButtonEquipAttackType(AttackType.Teleport, activePlayerAttackType),
        buildButtonEquipAttackType(AttackType.Node_Cannon, activePlayerAttackType),
        buildButtonEquipAttackType(AttackType.Weather, activePlayerAttackType),
        buildButtonEquipAttackType(AttackType.Time, activePlayerAttackType),
        buildButtonEquipAttackType(AttackType.Blade, activePlayerAttackType),
        buildButtonEquipAttackType(AttackType.Assault_Rifle, activePlayerAttackType),
      ],
    ),
  );

Widget buildButtonEquipAttackType(int weaponType, int activeWeaponType){
  const unknown = AtlasImage(srcX: 11827, srcY: 133, width: 26, height: 20);
  final weaponTypeAtlasImage = attackTypeAtlasImages[weaponType] ?? unknown;

  return onPressed(
    action: () => sendClientRequestPlayerEquipAttackType1(weaponType),
    onRightClick: () => sendClientRequestPlayerEquipAttackType2(weaponType),
    child: Container(
      width: 100,
      height: 75,
      child: Column(
        children: [
          buildCanvasImageButton(
            action: () => sendClientRequestPlayerEquipAttackType1(weaponType),
              srcX: weaponTypeAtlasImage.srcX,
              srcY: weaponTypeAtlasImage.srcY,
              srcWidth: weaponTypeAtlasImage.width,
              srcHeight: weaponTypeAtlasImage.height,
          ),
          height4,
          text(
              AttackType.getName(weaponType),
              bold: weaponType == activeWeaponType,
              size: 15
          ),
        ],
      ),
    ),
  );
}

const attackTypeAtlasImages = {
   AttackType.Blade: AtlasImage(srcX: 11859, srcY: 164, width: 25, height: 25),
   AttackType.Fireball : AtlasImage(srcX: 12117, srcY: 4, width: 22, height: 25),
   AttackType.Handgun  : AtlasImage(srcX: 11824, srcY: 726, width: 12, height: 10),
   AttackType.Shotgun  : AtlasImage(srcX: 11888, srcY: 693, width: 32, height: 11),
   AttackType.Assault_Rifle  : AtlasImage(srcX: 11824, srcY: 691, width: 31, height: 13),
};

class AtlasImage {
  final double srcX;
  final double srcY;
  final double width;
  final double height;

  const AtlasImage({
    required this.srcX, 
    required this.srcY, 
    required this.width, 
    required this.height,
  });
}

Widget _buildButtonPurchaseWeapon(Weapon weapon) {
  return MouseRegion(
    onEnter: (event){
      weaponInformation.value = weapon;
    },
    onExit: (event){
       if (weaponInformation.value != weapon) return;
       weaponInformation.value = null;
    },
    child: container(
        child: text(weapon.name),
        action: () => sendClientRequestPurchaseWeapon(weapon.type),
    ),
  );
}

Widget _buildSelectArmourType(int type) {
   return watch(player.armourType, (int equipped){
     return container(
         child: text(ArmourType.getName(type)),
         action: () => sendClientRequestSetArmour(type),
         color: equipped == type ? green : grey,
     );
   });
}

