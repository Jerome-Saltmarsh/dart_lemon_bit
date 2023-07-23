
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/gamestream/games/fight2d/game_fight2d.dart';
import 'package:gamestream_flutter/gamestream/ui/src.dart';
import 'package:gamestream_flutter/isometric.dart';
import 'package:gamestream_flutter/library.dart';
import 'package:gamestream_flutter/ui/isometric_builder.dart';

class GameFight2DUI extends StatelessWidget {
  final GameFight2D game;
  final tutorialVisible = WatchBool(true);

  GameFight2DUI(this.game);

  @override
  Widget build(BuildContext context) {
    return IsometricBuilder(
      builder: (context, isometric) {
        return Stack(
          children: [
            buildWatch(tutorialVisible, (tutorialVisible) {
               return Positioned(
                   left: 16,
                   top: 16,
                   child: tutorialVisible ? buildContainerTutorial() : nothing,
               );
            }),
            Positioned(
                top: 16,
                right: 16,
                child: isometric.buildWindowMenu(
                    children: [
                      onPressed(
                        action: tutorialVisible.toggle,
                        child: Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              buildText('TUTORIAL', size: 20, color: Colors.white70),
                              buildWatch(tutorialVisible, (bool renderName) => isometric.buildIconCheckbox(renderName)),
                            ],
                          ),
                        ),
                      ),
                      if (game.isometric.engine.isLocalHost)
                        height6,
                      if (game.isometric.engine.isLocalHost)
                        onPressed(
                          action: game.togglePlayerEdit,
                          child: Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                buildText('EDIT', size: 20, color: Colors.white70),
                                BoolWatchBuilderCheckBox(watchBool: game.player.edit),
                              ],
                            ),
                          ),
                        ),
                      if (game.isometric.engine.isLocalHost)
                        height6,
                      if (game.isometric.engine.isLocalHost)
                        onPressed(
                          action: game.renderCharacterState.toggle,
                          child: Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                buildText('DEBUG', size: 20, color: Colors.white70),
                                buildWatch(game.renderCharacterState, (bool renderName) => isometric.buildIconCheckbox(renderName)),
                              ],
                            ),
                          ),
                        )
                    ]
                )
            )
          ],
        );
      }
    );
  }

  
  
  Widget buildContainerTutorial() {
    
    const padding = 6.0;
    const gap = SizedBox(height: padding);
    return Container(
      alignment: Alignment.center,
      color: GameStyle.Container_Color,
      padding: const EdgeInsets.all(padding),
      child: Column(
        children: [
          onPressed(
              action: tutorialVisible.setFalse,
              child: buildText('CLOSE'),
          ),
          gap,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  buildTextBox('W'),
                  gap,
                  buildTextBox('A'),
                  gap,
                  buildTextBox('S'),
                  gap,
                  buildTextBox('D'),
                  gap,
                  buildTextBox('SPACE'),
                ],
              ),
              width6,
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  buildTextBox('Jump'),
                  gap,
                  buildTextBox('RUN LEFT'),
                  gap,
                  buildTextBox('CROUCH'),
                  gap,
                  buildTextBox('RUN RIGHT'),
                  gap,
                  buildTextBox('ATTACK'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget buildTextBox(String value){
    return Container(
        width: 80,
        height: 20,
        alignment: Alignment.center,
        color: Colors.white12,
        child: buildText(value, color: Colors.white70));
  }
}