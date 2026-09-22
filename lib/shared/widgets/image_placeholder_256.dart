import 'package:flutter/widgets.dart';

class ImagePlaceholder256 extends StatelessWidget {
  const ImagePlaceholder256({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/placeholder_256.png',
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
    );
  }
}
