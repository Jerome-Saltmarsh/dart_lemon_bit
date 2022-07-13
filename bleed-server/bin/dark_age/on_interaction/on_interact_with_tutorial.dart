
import '../../classes/player.dart';

void onInteractWithTutorial(Player player){
    player.interact(message: "(Scroll down with middle mouse). Use the mouse to move around and interact with your environment. To talk to someone hover the mouse over them and left click. You can also use the W,A,S,D keys to move. Try talking to different people, who knows what kind of adventures it might lead to?", responses: {
       "Got it!": player.endInteraction,
    });
}