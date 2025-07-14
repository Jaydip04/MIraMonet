import 'package:artist/core/utils/responsive.dart';
import 'package:flutter/material.dart';

import '../../../../config/colors.dart';

class FullScreenImage extends StatefulWidget {
  final String image;
  const FullScreenImage({super.key, required this.image});

  @override
  State<FullScreenImage> createState() => _FullScreenImageState();
}

class _FullScreenImageState extends State<FullScreenImage> {
  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body:SafeArea(
        child: Stack(
          children: [
            Image.network(
              widget.image,
              fit: BoxFit.contain,
              width: Responsive.getMainWidth(context),
              height: Responsive.getMainHeight(context),
            ),
            Positioned(
              left: 30,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: Responsive.getWidth(41),
                  height: Responsive.getHeight(41),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                      BorderRadius.circular(Responsive.getWidth(12)),
                      border: Border.all(
                          color: textFieldBorderColor, width: 1.0)),
                  child: Icon(
                    Icons.arrow_back_ios_new_outlined,
                    size: Responsive.getWidth(19),
                  ),
                ),
              ),
            ),
          ],
        ),
      )

    );
  }
}
