
import 'package:amulet_engine/common.dart';
import 'package:amulet_flutter/amulet/amulet.dart';
import 'package:amulet_flutter/amulet/amulet_ui.dart';
import 'package:amulet_flutter/amulet/getters/get_amulet_item_validation_error.dart';
import 'package:amulet_flutter/amulet/ui/enums/quantify_tab.dart';
import 'package:amulet_flutter/amulet/ui/maps/map_item_quality_to_color.dart';
import 'package:amulet_flutter/gamestream/ui/builders/build_watch.dart';
import 'package:amulet_flutter/gamestream/ui/constants/width.dart';
import 'package:amulet_flutter/gamestream/ui/widgets/gs_container.dart';
import 'package:flutter/material.dart';
import 'package:lemon_lang/src.dart';
import 'package:lemon_widgets/lemon_widgets.dart';

class WindowQuantify extends StatelessWidget {
  final Amulet amulet;

  const WindowQuantify({super.key, required this.amulet});

  AmuletUI get amuletUI => amulet.amuletUI;

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
    final damage = amuletItem.damage;
    final damageMin = amuletItem.damageMin;
    final maxHealth = amuletItem.maxHealth;
    final maxMagic = amuletItem.maxMagic;

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
                    child: buildText(amuletItem.name.replaceAll('Weapon_', '')),
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
              if (damage != null)
                buildQuantificationCell('dmg-max', showValue ? amuletItem.getWeaponDamageMax(level) : amuletItem.damage),
              if (damageMin != null)
                buildQuantificationCell('dmg-min', showValue ? amuletItem.getWeaponDamageMin(level) : amuletItem.damageMin),

              buildQuantificationCell('speed', amuletItem.attackSpeed),
              buildQuantificationCell('range', amuletItem.range),
              buildQuantificationCell('health',
                  showValue ? amuletItem.getMaxHealth(level) :
                  amuletItem.maxHealth, renderNull: !amuletItem.isWeapon),
              buildQuantificationCell('magic', amuletItem.maxMagic, renderNull: !amuletItem.isWeapon),
              Container(
                  width: 150,
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      // buildText('skills'),
                      ...amuletItem.skillSet.entries.map((entry) => Row(
                        children: [
                          Container(
                              width: 80,
                              child: buildText(entry.key.name, size: 14, color: Colors.white70)),
                          buildText(entry.value, size: 14, color: Colors.white70)
                        ],
                      ))
                    ],
                  )),
              buildQuantificationCell('quantify', amuletItem.quantify),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildQuantificationCell(String name, double? value, {bool renderNull = false}) {
    if (value == null && !renderNull) {
      return nothing;
    }
    return Container(
        padding: const EdgeInsets.all(8),
        alignment: Alignment.center,
        child: Column(
          children: [
            buildText(name, color: Colors.white70, size: 14),
            buildText(value?.toStringAsFixed(2) ?? 0, color: Colors.white70),
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