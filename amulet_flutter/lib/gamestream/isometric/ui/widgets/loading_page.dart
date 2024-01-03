
import 'package:amulet_flutter/gamestream/ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:amulet_flutter/gamestream/isometric/ui/isometric_colors.dart';
import 'package:lemon_widgets/lemon_widgets.dart';
import 'isometric_builder.dart';

class LoadingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

     return IsometricBuilder(builder: (context, isometric){
       final images = isometric.images;
       final totalImages = buildWatch(images.totalImages, buildText);
       final totalImagesLoaded = buildWatch(images.totalImagesLoaded, buildText);
       return Container(
         color: IsometricColors.Black,
         alignment: Alignment.center,
         child: Column(
           mainAxisAlignment: MainAxisAlignment.center,
           crossAxisAlignment: CrossAxisAlignment.center,
           children: [
             buildText('Lemon Studios', size: 25),
             height16,
             Image.asset('assets/images/loading-icon.png'),
             // Row(
             //   mainAxisAlignment: MainAxisAlignment.center,
             //   children: [
             //     buildText('Images '),
             //     totalImagesLoaded,
             //     buildText('/'),
             //     totalImages,
             //
             //   ],
             // )
           ],
         ),
       );
     });
  }
}