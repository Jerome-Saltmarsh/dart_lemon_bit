
import 'dart:async';

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

            final child = item == null
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






class ColorChangingContainer extends StatefulWidget {

  final double size;
  final Widget child;

  const ColorChangingContainer({super.key, required this.size, required this.child});

  @override
  _ColorChangingContainerState createState() => _ColorChangingContainerState();
}

class _ColorChangingContainerState extends State<ColorChangingContainer> {
  Color _currentColor = Colors.white;
  Timer? _colorChangeTimer;

  @override
  void initState() {
    super.initState();

    // Start a timer to change the color every second
    _colorChangeTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      setState(() {
        _currentColor = _currentColor == Colors.white ? Colors.transparent : Colors.white;
      });
    });
  }

  @override
  void dispose() {
    _colorChangeTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        width: widget.size,
        height: widget.size,
        color: _currentColor,
        alignment: Alignment.center,
        child: widget.child,
      ),
    );
  }
}