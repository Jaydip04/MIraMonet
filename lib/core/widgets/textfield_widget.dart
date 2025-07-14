// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

class ConstantTextFieldWidget extends StatelessWidget {
  final String? hintText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final Color? borderColor;
  final double? borderRadius;
  final TextStyle? style;

  const ConstantTextFieldWidget({
    Key? key,
    this.hintText,
    this.controller,
    this.keyboardType,
    this.borderColor,
    this.borderRadius,
    this.style,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textAlign: TextAlign.center,
      style: style ??
          const TextStyle(
            fontSize: 12,
          ),
      decoration: InputDecoration(
        hintText: hintText,
      ),
    );
  }
}
