import 'package:artist/config/colors.dart';
import 'package:artist/core/utils/app_font_weight.dart';
import 'package:artist/core/utils/responsive.dart';
import 'package:artist/core/widgets/custom_text_2.dart';
import 'package:flutter/material.dart';

class NotFoundScreen extends StatefulWidget {
  const NotFoundScreen({super.key});

  @override
  State<NotFoundScreen> createState() => _NotFoundScreenState();
}

class _NotFoundScreenState extends State<NotFoundScreen> {
  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return Scaffold(
      backgroundColor: white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: Responsive.getHeight(50),
            ),
            Center(
                child: Image.asset(
              "assets/notfound.png",
              height: Responsive.getHeight(389),
              fit: BoxFit.contain,
            )),
            SizedBox(
              height: Responsive.getHeight(20),
            ),
            WantText2(
                text: "Opps!",
                fontSize: Responsive.getFontSize(24),
                fontWeight: AppFontWeight.bold,
                textColor: black),
            SizedBox(
              height: Responsive.getHeight(10),
            ),
            WantText2(
                text:
                    "We are currently under maintenance.\nPlease try again later.",
                fontSize: Responsive.getFontSize(16),
                textOverflow: TextOverflow.fade,
                textAlign: TextAlign.center,
                fontWeight: AppFontWeight.medium,
                textColor: black)
          ],
        ),
      ),
    );
  }
}
