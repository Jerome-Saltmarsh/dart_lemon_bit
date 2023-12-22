import 'package:flutter/material.dart';
import 'package:amulet_flutter/amulet/amulet.dart';
import 'package:amulet_flutter/gamestream/ui.dart';
import 'package:golden_ratio/constants.dart';
import 'package:lemon_widgets/lemon_widgets.dart';

import '../../classes/item_slot.dart';
import 'build_item_slot.dart';

Widget buildWeaponSlotAtIndex(int index, {
  required Amulet amulet,
  double size = 64,
}) {

  final activeBorder = Container(
    decoration: BoxDecoration(
      border: Border.all(color: Colors.white, width: 2),
      borderRadius: borderRadius4,
        color: Colors.black12
    ),
    width: size,
    height: size,
    // rounded: true,
  );

  final notActiveBorder = Container(
    decoration: BoxDecoration(
      borderRadius: borderRadius4,
      color: Colors.white12
    ),
    width: size,
    height: size,
    // rounded: true,
  );

  final backgroundSelectedWeapon = buildWatch(
      amulet.equippedWeaponIndex,
          (equippedWeaponIndex) => equippedWeaponIndex == index ? activeBorder : notActiveBorder
  );

  final backgroundActivePower = buildWatch(amulet.activatedPowerIndex, (activatedPowerIndex){
    if (index != activatedPowerIndex)
      return nothing;

    return GSContainer(
      color: Colors.purple.withOpacity(0.5),
      width: size,
      height: size,
      rounded: true,
    );
  });




  final weapons = amulet.weapons;
  final itemSlotWeapon = weapons[index];

  final chargeColorFull = Colors.blue;
  final chargeColorEmpty = chargeColorFull.withOpacity(0.2);

  final chargesNotRemainingContainer = GSContainer(
    color: Colors.red.withOpacity(0.5),
    width: size,
    height: size,
    rounded: true,
  );

  final watchChargesRemaining = buildWatch(itemSlotWeapon.chargesRemaining, (chargesRemaining) {
    if (chargesRemaining){
      return nothing;
    }
    return chargesNotRemainingContainer;
  });

  final watchAmuletItem = buildWatch(itemSlotWeapon.amuletItem, (amuletItem){
      if (amuletItem == null){
        return nothing;
      }
      return watchChargesRemaining;
  });

  final height = size * goldenRatio_0381 * goldenRatio_0381;

  final watchCharges = buildWatch(itemSlotWeapon.max, (maxCharges) {
    final chargeWidth = size / maxCharges;
    final rechargeBarColorFull =  Colors.orangeAccent;
    final rechargeBarColorEmpty =  Colors.orangeAccent.withOpacity(0.2);

    final rechargeBar = buildWatch(itemSlotWeapon.cooldownPercentage, (cooldownPerc) {

      final chargeWidthLeft = chargeWidth * cooldownPerc;
      final chargeWidthRight = chargeWidth - chargeWidthLeft;

      const radius = Radius.circular(2);

      return Row(
        children: [
          Container(
            width: chargeWidthLeft,
            height: height,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(topLeft: radius, bottomLeft: radius),
              color: rechargeBarColorFull,
            ),
          ),
          Container(
            width: chargeWidthRight,
            height: height,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(topRight: radius, bottomRight: radius),
              color: rechargeBarColorEmpty,
            ),
          ),
        ],
      );
    });

    return buildWatch(itemSlotWeapon.charges, (charges) {
      return Row(
        children: List.generate(maxCharges, (index) {
          if (index == charges){
            return rechargeBar;
          }
          return Container(
            width: chargeWidth,
            height: height,
            decoration: BoxDecoration(
              color: index < charges ? chargeColorFull : chargeColorEmpty,
              borderRadius: borderRadius2,
            ),
          );
        }),
      );
    });
  });

  return Column(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        child: Stack(
          alignment: Alignment.center,
          children: [
            backgroundSelectedWeapon,
            backgroundActivePower,
            watchAmuletItem,
            Positioned(
                child: buildItemSlot(
                    weapons[index],
                    amulet: amulet,
                    color: Colors.transparent,
                )
            ),
            Positioned(
                top: 8,
                left: 8,
                child: buildText(
                  const['A', 'S', 'D', 'F'][index],
                  color: Colors.white70,
                )
            ),
          ],
        ),
      ),
      watchCharges,
    ],
  );
}

Widget buildWeaponSlotAtIndex2({
  required ItemSlot itemSlot,
  required Amulet amulet,
  double size = 64,
}) {
  final chargeColorFull = Colors.blue;
  final chargeColorEmpty = chargeColorFull.withOpacity(0.2);

  final chargesNotRemainingContainer = GSContainer(
    color: Colors.red.withOpacity(0.5),
    width: size,
    height: size,
    rounded: true,
  );

  final watchChargesRemaining = buildWatch(itemSlot.chargesRemaining, (chargesRemaining) {
    if (chargesRemaining){
      return nothing;
    }
    return chargesNotRemainingContainer;
  });

  final watchAmuletItem = buildWatch(itemSlot.amuletItem, (amuletItem){
      if (amuletItem == null){
        return nothing;
      }
      return watchChargesRemaining;
  });

  final height = size * goldenRatio_0381 * goldenRatio_0381;

  final watchCharges = buildWatch(itemSlot.max, (maxCharges) {
    final chargeWidth = size / maxCharges;
    final rechargeBarColorFull =  Colors.orangeAccent;
    final rechargeBarColorEmpty =  Colors.orangeAccent.withOpacity(0.2);

    final rechargeBar = buildWatch(itemSlot.cooldownPercentage, (cooldownPerc) {

      final chargeWidthLeft = chargeWidth * cooldownPerc;
      final chargeWidthRight = chargeWidth - chargeWidthLeft;

      const radius = Radius.circular(2);

      return Row(
        children: [
          Container(
            width: chargeWidthLeft,
            height: height,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(topLeft: radius, bottomLeft: radius),
              color: rechargeBarColorFull,
            ),
          ),
          Container(
            width: chargeWidthRight,
            height: height,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(topRight: radius, bottomRight: radius),
              color: rechargeBarColorEmpty,
            ),
          ),
        ],
      );
    });

    return buildWatch(itemSlot.charges, (charges) {
      return Row(
        children: List.generate(maxCharges, (index) {
          if (index == charges){
            return rechargeBar;
          }
          return Container(
            width: chargeWidth,
            height: height,
            decoration: BoxDecoration(
              color: index < charges ? chargeColorFull : chargeColorEmpty,
              borderRadius: borderRadius2,
            ),
          );
        }),
      );
    });
  });

  return Column(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        child: Stack(
          alignment: Alignment.center,
          children: [
            watchAmuletItem,
            Positioned(
                child: buildItemSlot(
                    itemSlot,
                    amulet: amulet,
                    color: Colors.transparent,
                )
            ),
          ],
        ),
      ),
      watchCharges,
    ],
  );


}

