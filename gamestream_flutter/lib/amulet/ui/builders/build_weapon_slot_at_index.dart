import 'package:flutter/material.dart';
import 'package:gamestream_flutter/amulet/amulet.dart';
import 'package:gamestream_flutter/amulet/ui/widgets/build_text_percentage.dart';
import 'package:gamestream_flutter/gamestream/ui/builders/build_watch.dart';
import 'package:gamestream_flutter/gamestream/ui/constants/height.dart';
import 'package:gamestream_flutter/gamestream/ui/widgets/gs_container.dart';
import 'package:gamestream_flutter/packages/common/src/amulet/amulet_item.dart';
import 'package:golden_ratio/constants.dart';
import 'package:lemon_widgets/lemon_widgets.dart';

import 'build_item_slot.dart';

Widget buildWeaponSlotAtIndex(int index, {
  required Amulet amulet,
  double size = 64,
}) {
  final backgroundSelectedWeapon = buildWatch(
      amulet.equippedWeaponIndex,
          (equippedWeaponIndex) => GSContainer(
        color: index == equippedWeaponIndex
            ? Colors.green
            : Colors.white12,
        // ? Colors.white12
        // : Colors.black12,
        width: size,
        height: size,
        rounded: true,
      ));

  final backgroundActivePower = buildWatch(amulet.activatedPowerIndex, (activatedPowerIndex){
    if (index != activatedPowerIndex)
      return nothing;

    return GSContainer(
      color: Colors.green.withOpacity(0.5),
      width: size,
      height: size,
      rounded: true,
    );
  });

  final weapons = amulet.weapons;
  final itemSlotWeapon = weapons[index];

  final chargeColorFull = Colors.green;
  final chargeColorEmpty = Colors.green.withOpacity(0.2);

  final watchCharges = buildWatch(itemSlotWeapon.max, (maxCharges) {

    final chargeWidth = size / maxCharges;

    final rechargeBar = buildWatch(itemSlotWeapon.cooldownPercentage, (cooldownPerc) {

      final chargeWidthLeft = chargeWidth * cooldownPerc;
      final chargeWidthRight = chargeWidth - chargeWidthLeft;

      return Row(
        children: [
          Container(
            width: chargeWidthLeft,
            height: size * goldenRatio_0381,
            color: Colors.orangeAccent,
          ),
          Container(
            width: chargeWidthRight,
            height: size * goldenRatio_0381,
            color: Colors.orangeAccent.withOpacity(0.2),
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
            height: size * goldenRatio_0381,
            color: index < charges ? chargeColorFull : chargeColorEmpty,
          );
        }),
      );
    });
  });

  return buildWatch(itemSlotWeapon.amuletItem, (AmuletItem? amuletItem) {

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        watchCharges,
        height4,
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          child: Stack(
            alignment: Alignment.center,
            children: [
              backgroundSelectedWeapon,
              backgroundActivePower,
              Positioned(
                  child: buildItemSlot(
                      weapons[index],
                      amulet: amulet,
                      color: Colors.transparent
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
              if (amuletItem != null)
              Positioned(
                  bottom: 8,
                  right: 8,
                  child: buildWatch(
                      weapons[index].cooldownPercentage,
                      buildTextPercentage,
                  )
              ),
              if (amuletItem != null)
              Positioned(
                  bottom: 8,
                  left: 8,
                  child: buildWatch(weapons[index].charges, buildText)
              ),
              if (amuletItem != null)
              Positioned(
                  top: 8,
                  right: 8,
                  child: buildWatch(weapons[index].max, buildText)
              )
            ],
          ),
        ),
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.center,
        //   children: [
        //     Container(width: 8, height: 8, color: Colors.white,),
        //     width4,
        //     Container(width: 8, height: 8, color: Colors.white,),
        //     width4,
        //     Container(width: 8, height: 8, color: Colors.white38,),
        //   ],
        // )
      ],
    );
  });


}

