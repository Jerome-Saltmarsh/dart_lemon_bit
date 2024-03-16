
import 'package:amulet_flutter/isometric/components/isometric_images.dart';
import 'package:amulet_flutter/isometric/consts/height.dart';
import 'package:amulet_flutter/isometric/ui/builders/build_watch.dart';
import 'package:amulet_flutter/isometric/ui/isometric_colors.dart';
import 'package:flutter/material.dart';
import 'package:lemon_widgets/lemon_widgets.dart';

class LoadingPage extends StatelessWidget {

  final IsometricImages images;

  const LoadingPage({super.key, required this.images});

  @override
  Widget build(BuildContext context) {
    final totalImages = buildWatch(images.totalImages, buildText);
    final totalImagesLoaded = buildWatch(images.totalImagesLoaded, buildText);
    return Container(
      color: IsometricColors.Black,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          buildText('AMULET', size: 25),
          height16,
          // Image.asset('assets/images/loading-icon.png'),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // buildText('Images '),
              // totalImagesLoaded,
              // buildText('/'),
              // totalImages,
              // width8,
              buildBorder(
                color: Colors.white,
                padding: const EdgeInsets.all(4),
                child: Container(
                  alignment: Alignment.centerLeft,
                  width: 100,
                  child: buildWatch(images.totalImagesLoadedPercentage, (perc) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 10,
                      width: 100 * perc,
                      color: Colors.white,
                    );
                  }),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}