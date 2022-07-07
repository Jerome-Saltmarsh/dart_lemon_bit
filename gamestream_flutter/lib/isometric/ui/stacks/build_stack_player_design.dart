import 'package:flutter/cupertino.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/isometric/ui/build_panel_store.dart';
import 'package:gamestream_flutter/isometric/ui/constants/colors.dart';
import 'package:gamestream_flutter/isometric/ui/enums/player_design_tab.dart';
import 'package:gamestream_flutter/isometric/ui/widgets/build_container.dart';
import 'package:gamestream_flutter/isometric/watches/design_equipment_tab.dart';
import 'package:gamestream_flutter/network/send_client_request.dart';
import 'package:golden_ratio/constants.dart';
import 'package:lemon_engine/screen.dart';

Widget buildStackPlayerDesign() {
  return watch(activePlayerDesignTab, (activePlayerDesignTabValue) {
    return Stack(children: [
      Positioned(
        top: 50,
        child: Container(
          width: screen.width,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: PlayerDesignTab.values.map((tab) {
              return container(
                child: tab.name,
                action: () => activePlayerDesignTab.value = tab,
                color: tab == activePlayerDesignTabValue ? brownDark : brownLight,
                alignment: Alignment.center,
              );
            }).toList(),
          ),
        ),
      ),
      Positioned(
          bottom: 100,
          child: Container(
            width: screen.width,
            alignment: Alignment.center,
            child: container(
                width: 200,
                height: 200 * goldenRatio_0381,
                child: text("START", bold: true),
                alignment: Alignment.center,
                color: green,
                action: sendClientRequestSubmitPlayerDesign,
            ),
          ),
      ),
      Positioned(top: 150, left: 50, child: Builder(
        builder: (context) {
            switch (activePlayerDesignTabValue){
              case PlayerDesignTab.Head:
                return buildColumnSelectPlayerHead();
              case PlayerDesignTab.Body:
                return buildColumnSelectPlayerArmour();
              case PlayerDesignTab.Legs:
                return buildColumnSelectPlayerPants();
              default:
                throw Exception();
            }
        },
      ),)
    ]);
  });
}
