
import 'package:flutter/material.dart';
import 'package:amulet_flutter/amulet/amulet.dart';
import 'package:amulet_flutter/amulet/classes/item_slot.dart';
import 'package:amulet_flutter/amulet/ui/widgets/mmo_item_image.dart';
import 'package:amulet_flutter/gamestream/ui/builders/build_watch.dart';
import 'package:amulet_flutter/gamestream/ui/widgets/color_changing_container.dart';
import 'package:lemon_widgets/lemon_widgets.dart';

Widget buildItemSlot(ItemSlot itemSlot, {
  required Amulet amulet,
  Color? color,
  Widget? onEmpty,
}) {

  return buildWatch(amulet.highlightedAmuletItem, (highlightedAmuletItem){
    const size = 64.0;
    return Container(
      margin: const EdgeInsets.all(2),
      child: buildWatch(itemSlot.amuletItem, (item) {

        final image = item == null ? nothing : MMOItemImage(item: item, size: size);

        return buildWatch(amulet.dragging, (dragging) => DragTarget(
          onWillAccept: (value) => true,
          onAccept: (value) {
            if (value is! ItemSlot) return;
            amulet.reportItemSlotDragged(src: value, target: itemSlot);
          },
          builder: (context, data, rejectData) {
            final child = item == null
                ? (onEmpty ?? nothing)
                : Builder(
                  builder: (context) {
                    return buildWatch(amulet.elementsChangedNotifier, (t) {
                      final level = amulet.getAmuletPlayerItemLevel(item);

                      return Container(
                        width: size,
                        height: size,
                        child: Draggable(
                          data: itemSlot,
                          feedback: image,
                          onDragStarted: () {
                            amulet.setInventoryOpen(true);
                            amulet.dragging.value = itemSlot;
                          },
                          onDraggableCanceled: (velocity, offset) {
                            amulet.clearDragging();
                          },
                          onDragEnd: (details) {
                            if (amulet.engine.mouseOverCanvas) {
                              amulet.dropItemSlot(itemSlot);
                            }
                            amulet.clearDragging();
                          },
                          child: onPressed(
                            onRightClick: () =>
                                amulet.dropItemSlot(itemSlot),
                            action: () => amulet.useItemSlot(itemSlot),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                image,
                                // Positioned(
                                //   bottom: 8,
                                //   right: 8,
                                //   child: buildText(level),
                                // ),
                              ],
                            ),
                          ),
                        ),
                      );
                    });

                  }
                );

            final isHighlighted = highlightedAmuletItem != null &&
                highlightedAmuletItem == item;

            if (!isHighlighted){
              return Container(
                width: 64.0,
                height: 64.0,
                color: dragging != null &&
                    itemSlot.acceptsDragFrom(dragging)
                    ? amulet.colors.teal_4
                    : (color ?? amulet.colors.brown_3),
                alignment: Alignment.center,
                child: child,
              );
            }

                    return ColorChangingContainer(
                      size: 64.0,
                      child: child,
                    );
                  },
                ));
      }
      ),
    );
  });
}

