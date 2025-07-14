import 'package:artist/config/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextFormField extends StatelessWidget {
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
  const AppTextFormField({
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
  Widget build(BuildContext context) {
    var field = TextFormField(
      inputFormatters: inputFormatters,
      maxLength: maxLength,
      enabled: enabled,
      key: fieldKey,
      style: GoogleFonts.poppins(
        color: black,
        letterSpacing: 1.5,
        fontSize: 14.00,
        fontWeight: FontWeight.normal,
      ),
      keyboardType: keyboardType,
      cursorColor: Colors.black,
      controller: controller,
      readOnly: readOnly,
      minLines: minLines,
      maxLines: maxLines,
      validator: validator,
      onSaved: onSaved,
      onTap: onTap,
      onChanged: onChanged,
      obscureText: obscureText,
      focusNode: focusNode,
      autofocus: autofocus,
      decoration: InputDecoration(
        isDense: true,
        hintText: hintText,
        labelText: labelText,
        hintStyle:
            GoogleFonts.poppins(
              letterSpacing: 1.5,
              color: textGray,
              fontSize: 14.00,
              fontWeight: FontWeight.normal,
            ),
        fillColor: white,
        filled: true,
        contentPadding: EdgeInsets.fromLTRB(16, 14, 16, 14),
        suffixIcon: suffixIcon,
        prefixIcon: prefixIcon,
        suffixIconConstraints: suffixIconConstraints,
        errorMaxLines: 3,
        counterText: "",
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: Colors.red, width: 1),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(borderRadius),
          ),
          borderSide:
              BorderSide(color: borderColor ?? Colors.transparent, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
          borderSide:
              BorderSide(color: borderColor ?? Colors.transparent, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
          borderSide:
              BorderSide(color: borderColor ?? Colors.transparent, width: 1),
        ),
      ),
    );
    return titleText == null
        ? field
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                titleText!,
                style: GoogleFonts.urbanist(
                  color: Colors.grey,
                  fontSize: 14.00,
                  fontWeight: FontWeight.normal,
                ),
              ),
              const SizedBox(height: 6),
              field,
            ],
          );
  }
}
