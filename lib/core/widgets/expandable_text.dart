import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../config/colors.dart';
import '../utils/app_font_weight.dart';
import '../utils/responsive.dart';

class ExpandableText extends StatefulWidget {
  final String text;
  final int maxLines;

  ExpandableText({required this.text, required this.maxLines});

  @override
  _ExpandableTextState createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _isExpanded ? widget.text : widget.text.length > 100
              ? widget.text.substring(0, 100) + "..."
              : widget.text,
          style: GoogleFonts.poppins(
            letterSpacing: 1.5,
            color: textBlack4,
            fontSize: Responsive.getFontSize(16),
            fontWeight: AppFontWeight.regular,
          ),
        ),

        if (widget.text.length > 100)
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Text(
              _isExpanded ? "See Less" : "See More",
              style: GoogleFonts.poppins(
                fontSize: Responsive.getFontSize(14),
                fontWeight: AppFontWeight.bold,
                color: Colors.black, // Change to match your theme
              ),
            ),
          ),
      ],
    );
  }
}
