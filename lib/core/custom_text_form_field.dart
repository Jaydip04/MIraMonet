import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'widgets/custom_text.dart';

class CustomTextFormField extends StatelessWidget {
  final String titleText;
  final String labelText;
  final TextEditingController controller;
  final bool obscureText;
  final bool isStartShow;
  final TextInputType keyboardType;
  final Widget? suffixIcon;
  final Function(String)? onChanged;
  bool? sizeBox;
  CustomTextFormField({
    required this.titleText,
    required this.labelText,
    required this.controller,
    required this.isStartShow,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.suffixIcon,
    this.onChanged,
    this.sizeBox = true,
  });
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            WantText(
              text: titleText,
              fontSize: width * 0.032,
              fontWeight: FontWeight.w500,
              textColor: Colors.grey,
            ),
            isStartShow ? WantText(
              text: "*",
              fontSize: width * 0.032,
              fontWeight: FontWeight.w500,
              textColor: Colors.red,
            ) : SizedBox()
          ],
        ),
        SizedBox(height: height * 0.01),
        SizedBox(
          height: height * 0.06,
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            style: GoogleFonts.inter(
              color: Color(0XFF4A3AFF),
              fontSize: width * 0.03733,
              fontWeight: FontWeight.w500,
            ),
            // onChanged: onChanged,
            decoration: InputDecoration(
              hintStyle: GoogleFonts.inter(
                color: Colors.grey,
                fontSize: width * 0.03733,
                fontWeight: FontWeight.w500,
              ),
              hintText: labelText,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(width * 0.0266),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(width * 0.0266),
                ),
                borderSide: BorderSide(color: Colors.grey),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(width * 0.0266),
                ),
                borderSide: BorderSide(color: Color(0XFF4A3AFF)), // Blue color
              ),
              suffixIcon: suffixIcon,
            ),
          ),
        ),
        if (sizeBox == true)
          SizedBox(
            height: height * 0.022,
          )
      ],
    );
  }
}
