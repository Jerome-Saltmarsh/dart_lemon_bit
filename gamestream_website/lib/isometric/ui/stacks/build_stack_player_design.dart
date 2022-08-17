import 'package:flutter/cupertino.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/isometric/ui/build_panel_store.dart';
import 'package:gamestream_flutter/isometric/ui/columns/build_columns_select_player_weapon.dart';
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
        top: 0,
        child: Container(
          width: screen.width,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: PlayerDesignTab.values.map((tab) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  container(
                    margin: EdgeInsets.symmetric(horizontal: 3),
                    child: tab.name,
                    action: () => activePlayerDesignTab.value = tab,
                    color: tab == activePlayerDesignTabValue ? brownDark : brownLight,
                    alignment: Alignment.center,
                  ),
                  Builder(builder: (context){
                    switch (tab){
                      case PlayerDesignTab.Class:
                        return buildColumnSelectPlayerWeapon();
                      case PlayerDesignTab.Head:
                        return buildColumnSelectPlayerHead();
                      case PlayerDesignTab.Body:
                        return buildColumnSelectPlayerArmour();
                      case PlayerDesignTab.Legs:
                        return buildColumnSelectPlayerPants();
                      default:
                        throw Exception();
                    }
                  })
                ],
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
    ]);
  });
}