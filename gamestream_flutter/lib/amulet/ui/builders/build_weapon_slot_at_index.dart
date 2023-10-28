import 'package:flutter/material.dart';
import 'package:gamestream_flutter/amulet/amulet.dart';
import 'package:gamestream_flutter/gamestream/ui.dart';
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

  final backgroundNoChargesRemaining =  GSContainer(
    color: Colors.red.withOpacity(0.5),
    width: size,
    height: size,
    rounded: true,
  );

  final weapons = amulet.weapons;
  final itemSlotWeapon = weapons[index];

  final chargeColorFull = Colors.green;
  final chargeColorEmpty = Colors.green.withOpacity(0.2);

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
            height: size * goldenRatio_0381,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(topLeft: radius, bottomLeft: radius),
              color: rechargeBarColorFull,
            ),
          ),
          Container(
            width: chargeWidthRight,
            height: size * goldenRatio_0381,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(topRight: radius, bottomRight: radius),
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
            height: size * goldenRatio_0381,
            decoration: BoxDecoration(
              color: index < charges ? chargeColorFull : chargeColorEmpty,
              borderRadius: borderRadius2,
            ),
          );
        }),
      );
    });
  });

  return buildWatch(itemSlotWeapon.amuletItem, (AmuletItem? amuletItem) {

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
              buildWatch(itemSlotWeapon.chargesRemaining, (t) {
                if (t){
                  return nothing;
                }
                return backgroundNoChargesRemaining;
              }),
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
              // if (amuletItem != null)
              // Positioned(
              //     bottom: 8,
              //     right: 8,
              //     child: buildWatch(
              //         weapons[index].cooldownPercentage,
              //         buildTextPercentage,
              //     )
              // ),
              // if (amuletItem != null)
              // Positioned(
              //     bottom: 8,
              //     left: 8,
              //     child: buildWatch(weapons[index].charges, buildText)
              // ),
              // if (amuletItem != null)
              // Positioned(
              //     top: 8,
              //     right: 8,
              //     child: buildWatch(weapons[index].max, buildText)
              // )
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
        height2,
        watchCharges,
      ],

    );
  });


}

