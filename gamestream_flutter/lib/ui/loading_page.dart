
import 'package:flutter/cupertino.dart';
import 'package:gamestream_flutter/gamestream/isometric/ui/isometric_colors.dart';
import 'package:gamestream_flutter/ui.dart';

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
             buildText('Loading GameStream'),
             Row(
               mainAxisAlignment: MainAxisAlignment.center,
               children: [
                 buildText('Images '),
                 totalImagesLoaded,
                 buildText('/'),
                 totalImages,

               ],
             )
           ],
         ),
       );
     });
  }
}