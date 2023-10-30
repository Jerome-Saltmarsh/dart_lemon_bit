
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/amulet/amulet.dart';
import 'package:gamestream_flutter/amulet/classes/item_slot.dart';
import 'package:gamestream_flutter/amulet/ui/widgets/mmo_item_image.dart';
import 'package:gamestream_flutter/gamestream/ui/builders/build_watch.dart';
import 'package:lemon_widgets/lemon_widgets.dart';

Widget buildItemSlot(ItemSlot itemSlot, {
  required Amulet amulet,
  Color? color,
  Widget? onEmpty,
}) {

  return buildWatch(amulet.highlightedAmuletItem, (highlightedAmuletItem){
    return Container(
      margin: const EdgeInsets.all(2),
      child: buildWatch(itemSlot.amuletItem, (item) {
        return buildWatch(amulet.dragging, (dragging) => DragTarget(
          onWillAccept: (value) => true,
          onAccept: (value) {
            if (value is! ItemSlot) return;
            amulet.reportItemSlotDragged(src: value, target: itemSlot);
          },
          builder: (context, data, rejectData) {
            return Container(
            width: 64.0,
            height: 64.0,
            color:
            highlightedAmuletItem != null && highlightedAmuletItem == item ? Colors.white :

            dragging != null && itemSlot.acceptsDragFrom(dragging)
                ? amulet.colors.teal_4
                : (color ?? amulet.colors.brown_3),
            alignment: Alignment.center,
            child: item == null
                ? (onEmpty ?? nothing)
                : Draggable(
              data: itemSlot,
              feedback: MMOItemImage(item: item, size: 64),
              onDragStarted: () {
                amulet.setInventoryOpen(true);
                amulet.dragging.value = itemSlot;
              },
              onDraggableCanceled: (velocity, offset){
                amulet.clearDragging();
              },
              onDragEnd: (details) {
                if (amulet.engine.mouseOverCanvas){
                  amulet.dropItemSlot(itemSlot);
                }
                amulet.clearDragging();
              },
              child: onPressed(
                onRightClick: () =>
                    amulet.dropItemSlot(itemSlot),
                action: () => amulet.useItemSlot(itemSlot),
                child: MMOItemImage(item: item, size: 64),
              ),
            ),
          );
          },
        ));
      }
      ),
    );
  });

  // return buildWatch(amulet.highlightedAmuletItem, (highlightedAmuletItem){
  //   return buildWatch(itemSlot.amuletItem, (amuletItem) {
  //      if (highlightedAmuletItem != null && highlightedAmuletItem == amuletItem) {
  //        return buildBorder(
  //            width: 4,
  //            color: Colors.white,
  //            child: container);
  //      }
  //
  //      return container;
  //   });
  // });
}
