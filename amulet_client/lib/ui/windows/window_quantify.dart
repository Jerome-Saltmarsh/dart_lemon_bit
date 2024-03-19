
import 'package:amulet_client/getters/src.dart';
import 'package:amulet_client/ui/src.dart';
import 'package:amulet_client/ui/widgets/gs_container.dart';
import 'package:amulet_common/src.dart';
import 'package:amulet_client/classes/amulet.dart';
import 'package:amulet_client/classes/amulet_ui.dart';
import 'package:flutter/material.dart';
import 'package:lemon_lang/src.dart';
import 'package:lemon_watch/src.dart';
import 'package:lemon_widgets/lemon_widgets.dart';

class WindowQuantify extends StatelessWidget {
  final AmuletUI amuletUI;

  Amulet get amulet => amuletUI.amulet;

  const WindowQuantify({super.key, required this.amuletUI});

  @override
  Widget build(BuildContext context) =>
      GSContainer(
          child: buildWatch(amuletUI.quantifyTab, buildActiveQuantifyTab)
      );

  Widget buildActiveQuantifyTab(QuantifyTab activeQuantifyTab) => Column(
    children: [
      Row(
        children: QuantifyTab.values
            .map((e) => Container(
          width: 120,
          height: 50,
          color: e == activeQuantifyTab
              ? Colors.black38
              : Colors.black12,
          alignment: Alignment.center,
          child: onPressed(
            action: () => amuletUI.quantifyTab.value = e,
            child: buildText(e.name),
          ),
        ))
            .toList(growable: false),
      ),
      Container(
        constraints:
        BoxConstraints(maxHeight: amulet.engine.screen.height - 150),
        child: SingleChildScrollView(
          child: switch (activeQuantifyTab) {
            QuantifyTab.Amulet_Items => buildQuantifyTabAmuletItems(),
            QuantifyTab.Fiend_Types => buildQuantifyTabFiendTypes(),
          },
        ),
      )
    ],
  );

  Widget buildQuantifyTabFiendTypes() => Column(
      children:
      FiendType.values.map(buildElementFiendType).toList(growable: false));

  Widget buildQuantifyTabAmuletItems() =>
      buildWatch(
      amuletUI.quantifyShowValue,
      (showValue) => buildWatch(
          amuletUI.quantifyLevel,
          (level) => buildWatch(
              amuletUI.quantifyAmuletItemSlotType,
              (activeSlotType) => Column(
                    children: [
                      Row(
                        children: [
                          onPressed(
                            action: amuletUI.quantifyLevel.decrement,
                            child: GSContainer(
                                child: buildText('-'), color: Colors.black26),
                          ),
                          width8,
                          buildText('level $level'),
                          width8,
                          onPressed(
                            action: amuletUI.quantifyLevel.increment,
                            child: GSContainer(
                                child: buildText('+'), color: Colors.black26),
                          ),
                          width16,
                          onPressed(
                            action: amuletUI.quantifyShowValue.toggle,
                            child: Container(
                                padding: const EdgeInsets.all(8),
                                color: Colors.black12,
                                child: Row(
                                  children: [
                                    buildText('Show Value'),
                                    width8,
                                    amuletUI.buildWatchCheckbox(amuletUI.quantifyShowValue),
                                  ],
                                )),
                          )
                        ],
                      ),
                      Row(
                        children: SlotType.values
                            .map((slotType) => onPressed(
                                action: () => amuletUI
                                    .quantifyAmuletItemSlotType
                                    .value = slotType,
                                child: Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 6),
                                    child: buildText(slotType.name,
                                        bold: slotType == activeSlotType))))
                            .toList(),
                      ),
                      Container(
                        height: amulet.engine.screen.height - 100,
                        child: SingleChildScrollView(
                          child: Column(
                              children: AmuletItem.values
                                  .where((element) =>
                                      element.slotType == activeSlotType)
                                  .toList()
                                  .sortBy((value) => value.quantify)
                                  .map((amuletItem) => buildQuantifyAmuletItem(
                                      amuletItem, level, showValue))
                                  .toList()),
                        ),
                      )
                    ],
                  ))));

  Widget buildQuantifyAmuletItem(AmuletItem amuletItem, int level, bool showValue) {

    final validationError = getAmuletItemValidationError(amuletItem);
    // final damageMax = showValue ? amuletItem.getWeaponDamageMax(level) : amuletItem.damage;
    // final damageMin = showValue ? amuletItem.getWeaponDamageMin(level) : amuletItem.damageMin;
    // final healthMax = showValue ? amuletItem.getMaxHealth(level)?.floor() : amuletItem.maxHealth;
    // final magicMax = showValue ? amuletItem.getMaxMagic(level)?.floor() : amuletItem.maxMagic;
    final renderNull = !amuletItem.isWeapon;

    return onPressed(
      action: () => amulet.spawnAmuletItem(
        amuletItem: amuletItem,
        level: level,
      ),
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        child: Container(
          padding: const EdgeInsets.all(8),
          color: Colors.white12,
          child: Row(
            children: [
              amuletUI.buildIconAmuletItem(amuletItem),
              width8,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    width: 250,
                    child: buildText(amuletItem.label),
                  ),
                  buildText(
                    amuletItem.quality.name,
                    color: mapItemQualityToColor(amuletItem.quality),
                  ),
                ],
              ),
              Container(
                width: 80,
                alignment: Alignment.center,
                child: validationError != null ? buildText(validationError.name, color: Colors.red) : null,
              ),
              // if (damageMax != null)
              //   buildQuantificationCell('dmg-max', damageMax),
              // if (damageMin != null)
              //   buildQuantificationCell('dmg-min', damageMin),

              // buildQuantificationCell('speed', amuletItem.attackSpeed),
              buildQuantificationCell('range', amuletItem.range),
              Container(
                  width: 150,
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      ...amuletItem.skillSet.entries.map((entry) {
                        if (showValue) {
                          final skillLevel = (entry.value * level).floor();
                          if (skillLevel <= 0) return nothing;
                          return Row(
                            children: [
                              Container(
                                  width: 80,
                                  child: buildText(entry.key.name, size: 14, color: Colors.white70),
                              ),
                              buildText(skillLevel, size: 14, color: Colors.white70)
                            ],
                          );
                        }

                        return Row(
                        children: [
                          Container(
                              width: 80,
                              child: buildText(entry.key.name, size: 14, color: Colors.white70),
                          ),
                          buildText(entry.value, size: 14, color: Colors.white70)
                        ],
                      );
                      })
                    ],
                  )),
              buildQuantificationCell('cost', amuletItem.getUpgradeCost(level)),
              buildQuantificationCell('quantify', amuletItem.quantify),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildQuantificationCell(String name, num? value, {bool renderNull = false}) {
    if (value == null && !renderNull) {
      return nothing;
    }

    dynamic textValue = 0;

    if (value is double) {
      textValue = value.toStringAsFixed(2);
    }

    if (value is int) {
      textValue = value.toString();
    }

    return Container(
        padding: const EdgeInsets.all(8),
        alignment: Alignment.center,
        child: Column(
          children: [
            buildText(name, color: Colors.white70, size: 14),
            buildText(textValue, color: Colors.white70),
          ],
        ));
  }

  Widget buildElementFiendType(FiendType fiendType) => Container(
    margin: const EdgeInsets.only(top: 8),
    child: Container(
      padding: const EdgeInsets.all(8),
      color: Colors.white12,
      // width: 500,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            alignment: Alignment.centerLeft,
            width: 300,
            child: buildText(fiendType.name),
          ),
          buildText('quantify: ${fiendType.quantify.toStringAsFixed(2)}'),
        ],
      ),
    ),
  );
}