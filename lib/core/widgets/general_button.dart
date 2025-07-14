import 'package:artist/config/colors.dart';
import 'package:artist/core/utils/responsive.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GeneralButton extends StatelessWidget {
  const GeneralButton(
      {Key? key,
      required this.Width,
      required this.onTap,
      this.isSelected = false,
      this.icon,
      this.isIconShow = false,
      this.buttonClick = false,
      this.isBoarderRadiusLess = false,
      required this.label})
      : super(key: key);
  final double Width;
  final Function()? onTap;
  final String label;
  final IconData? icon;
  final bool isSelected;
  final bool isIconShow;
  final bool buttonClick;
  final bool isBoarderRadiusLess;
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: Responsive.getHeight(45),
        width: Width,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
                color: Colors.black),
            color: isSelected
                ? black
                : buttonClick
                    ? Colors.white
                    : Colors.black,
            borderRadius: BorderRadius.circular(
                isBoarderRadiusLess ? width * 0.02133 : width * 0.1333),
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  label.toUpperCase(),
                  style: GoogleFonts.poppins(
                    letterSpacing: 1.5,
                    textStyle: TextStyle(
                      fontSize: Responsive.getFontSize(18),
                      color: buttonClick ? Colors.black : Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                isIconShow ?  SizedBox(width: Responsive.getWidth(20),) : SizedBox(),
                isIconShow ? Icon(icon,color: isSelected
                    ? white
                    : buttonClick
                    ? Colors.black
                    : Colors.white,) : SizedBox()
              ],
            ),
          ),
        ),
      ),
    );
  }
}
