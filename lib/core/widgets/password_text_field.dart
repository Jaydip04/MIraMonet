import 'package:artist/core/utils/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../config/colors.dart';

class PasswordTextField extends StatefulWidget {
  final String? titleText, hintText, labelText;
  final bool readOnly;
  final bool enabled;
  final FocusNode? focusNode;
  final void Function(String?)? onSaved;
  final void Function()? onTap;
  final String? Function(String?)? onChanged;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextEditingController? controller;
  final int? minLines;
  final int maxLines;
  final TextStyle? textStyle;
  final double borderRadius;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final bool obscureText;
  final Color? fillColor;
  final TextStyle? hintStyle;
  final EdgeInsetsGeometry? contentPadding;
  final BoxConstraints? suffixIconConstraints;
  final bool autofocus;
  final Key? fieldKey;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final Color? borderColor;

  const PasswordTextField({
    super.key,
    this.enabled = true,
    this.titleText,
    this.keyboardType,
    this.focusNode,
    this.hintText,
    this.labelText,
    this.onSaved,
    this.onTap,
    this.onChanged,
    this.validator,
    this.controller,
    this.minLines,
    this.suffixIcon,
    this.prefixIcon,
    this.maxLines = 1,
    this.readOnly = false,
    this.autofocus = false,
    this.borderRadius = 36,
    this.textStyle,
    this.obscureText = false,
    this.fillColor,
    this.contentPadding,
    this.hintStyle,
    this.suffixIconConstraints,
    this.fieldKey,
    this.maxLength,
    this.inputFormatters,
    this.borderColor,
  });

  @override
  _PasswordTextFieldState createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  bool _obscureText = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      style: GoogleFonts.poppins(
        color: black,
        letterSpacing: 1.5,
        fontSize: 14.00,
        fontWeight: FontWeight.normal,
      ),
      inputFormatters: widget.inputFormatters,
      maxLength: widget.maxLength,
      enabled: widget.enabled,
      key: widget.fieldKey,
      // style: widget.textStyle ?? TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
      keyboardType: widget.keyboardType,
      cursorColor: Colors.black,
      controller: widget.controller,
      readOnly: widget.readOnly,
      minLines: widget.minLines,
      maxLines: widget.maxLines,
      obscureText: _obscureText,
      validator: widget.validator,
      onSaved: widget.onSaved,
      onTap: widget.onTap,
      onChanged: widget.onChanged,
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      decoration: InputDecoration(
        isDense: true,
        hintText: widget.hintText,
        labelText: widget.labelText,
        hintStyle:  GoogleFonts.poppins(
          letterSpacing: 1.5,
          color: textGray,
          fontSize: 14.00,
          fontWeight: FontWeight.normal,
        ),
        // fillColor: widget.fillColor ?? Colors.white,
        // filled: true,
        contentPadding: EdgeInsets.fromLTRB(16, 11, 16, 11),
        suffixIcon: IconButton(
          icon: Image.asset(_obscureText ? "assets/show_off.png": "assets/show.png",width: Responsive.getWidth(22),height: Responsive.getWidth(22)),
          // Icon( Icons.visibility_off : Icons.visibility),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
        ),
        prefixIcon: widget.prefixIcon,
        suffixIconConstraints: widget.suffixIconConstraints,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: BorderSide(color: widget.borderColor ?? Colors.transparent, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: BorderSide(color: widget.borderColor ?? Colors.transparent, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: BorderSide(color: widget.borderColor ?? Colors.transparent, width: 1),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: BorderSide(color: Colors.red, width: 1),
        ),
      ),
    );
  }
}
