// import 'package:bleed_common/card_type.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:gamestream_flutter/colours.dart';
// import 'package:gamestream_flutter/flutterkit.dart';
// import 'package:gamestream_flutter/isometric/player.dart';
// import 'package:gamestream_flutter/isometric/ui/build_card_type_icon.dart';
// import 'package:gamestream_flutter/send_client_request.dart';
// import 'package:gamestream_flutter/ui/builders/build_panel.dart';
// import 'package:golden_ratio/constants.dart';
// import 'package:lemon_watch/watch_builder.dart';
//
// Widget buildPanelCardChoices() {
//   return WatchBuilder(player.cardChoices, (List<CardType> cardChoices) {
//     if (cardChoices.isEmpty) return empty;
//
//     return Row(
//       children: spread(cardChoices.map((cardType) {
//         const height = 110.0;
//             return onPressed(
//               callback: ()=> sendClientRequestDeckAddCard(cardType),
//               child: buildPanel(
//                 width: height,
//                 height: height * goldenRatio_1618,
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     Expanded(
//                       child: text(
//                         getCardTypeName(cardType),
//                         align: TextAlign.center,
//                         color: colours.white85
//                       ),
//                     ),
//                     Container(
//                         width: 50,
//                         height: 50,
//                         decoration: BoxDecoration(
//                             color: colours.white10,
//                             shape: BoxShape.circle
//                         ),
//                         child: buildCardTypeIcon(cardType)),
//                     height6,
//                     FittedBox(child: text(getCardTypeGenre(cardType).name, color: colours.white60)),
//                   ],
//                 ),
//               ),
//             );
//           }
//       ).toList(), const EdgeInsets.only(right: 8)),
//     );
//   });
// }
