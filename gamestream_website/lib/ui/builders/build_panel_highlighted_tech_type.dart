


// Widget buildPanelHighlightedTechType() {
//   return WatchBuilder(state.highlightedTechType, (int? type) {
//     if (type == null) return const SizedBox();
//
//     final level = state.player.getTechTypeLevel(type);
//     final cost = TechType.getCost(type, level);
//     final acquired = level > 0;
//     final name = TechType.getName(type);
//
//     final key = state.panelTypeKey[type];
//     if (key == null) {
//       return empty;
//     }
//     final context = key.currentContext;
//     if (context == null) return const SizedBox();
//     final renderBox = context.findRenderObject() as RenderBox;
//     return Positioned(
//       right: 238,
//       top: renderBox.localToGlobal(Offset.zero).dy,
//       child: Container(
//         width: 200,
//         padding: padding8,
//         decoration: boxStandard,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             text(acquired ? 'Equip $name' : 'Acquire $name'),
//             height8,
//             if (acquired)
//               text("Level $level"),
//             if (!acquired && cost != null)
//               buildCost(cost),
//           ],
//         ),
//       ),
//     );
//   });
// }
