

import '../../classes/player.dart';
import '../../common/library.dart';

void onInteractWithJulia(Player player) {
  player.interact(
    message: "Hello dear, are you looking for new clothing?",
    responses: {
      "Pants": (){
         player.interact(message: "Which color are you looking for?",
              responses: {
                  "brown": (){
                    player.setCharacterStateChanging();
                    player.equippedPants = PantsType.brown;
                    player.endInteraction();
                  },
                  "blue": (){
                    player.setCharacterStateChanging();
                    player.equippedPants = PantsType.blue;
                    player.endInteraction();
                  },
                  "red": (){
                    player.setCharacterStateChanging();
                    player.equippedPants = PantsType.red;
                    player.endInteraction();
                  },
                  "green": (){
                    player.setCharacterStateChanging();
                    player.equippedPants = PantsType.green;
                    player.endInteraction();
                  },
                  "white": (){
                    player.setCharacterStateChanging();
                    player.equippedPants = PantsType.white;
                    player.endInteraction();
                  },

                  "I changed my mind": player.endInteraction
              }
         );
      },
      "Shirt": (){

      },
    }
  );
}