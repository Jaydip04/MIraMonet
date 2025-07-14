
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import '../../config/colors.dart';
import '../../core/api_service/base_url.dart';
import '../../core/utils/app_font_weight.dart';
import '../../core/utils/responsive.dart';
import '../../core/widgets/general_button.dart';
import '../../core/widgets/password_text_field.dart';
import '../../config/toast.dart';
import 'account_created_screen.dart';
import 'package:http/http.dart' as http;

class ResetPassword extends StatefulWidget {
  final String email;
  const ResetPassword({super.key, required this.email});

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  TextEditingController newPassword = TextEditingController();
  TextEditingController newConfirmPassword = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String message = "";

  bool isLoding = false;

  @override
  void dispose() {
    newPassword.dispose();
    newConfirmPassword.dispose();
    super.dispose();
  }
  @override
  void initState() {
    super.initState();
    print(widget.email);
  }

  Future<void> resetPassword() async {
    setState(() {
      isLoding = true;
    });
    final url = Uri.parse('$serverUrl/updatePassword');

    final Map<String, String> body = {
      "email": widget.email,
      "type": "customer",
      "password": newPassword.text.toString()
    };

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        setState(() {
          isLoding = false;
        });
        final responseData = json.decode(response.body);
        message = responseData['message'] ?? 'No message';
        showToast(message: message);
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/SignIn/ForgotPassword/PasswordChanged',
              (route) => false,
        );
      } else {
        setState(() {
            isLoding = true;
          message = 'Failed to reset password';
        });
        showToast(message: message);
      }
    } catch (error) {

      setState(() {
        isLoding = true;
        message = 'An error occurred: $error';
      });
      showToast(message: message);
      print('Error sending data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Container(
            width: Responsive.getWidth(331),
            height: Responsive.getMainHeight(context),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: Responsive.getHeight(12)),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: Responsive.getWidth(41),
                        height: Responsive.getHeight(41),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(Responsive.getWidth(12)),
                          border: Border.all(color: textFieldBorderColor, width: 1.0),
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new_outlined,
                          size: Responsive.getWidth(19),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: Responsive.getHeight(28)),
                  Text(
                    "Create new password",
                    style: GoogleFonts.urbanist(
                      color: textBlack,
                      fontSize: Responsive.getFontSize(30),
                      fontWeight: AppFontWeight.bold,
                    ),
                  ),
                  SizedBox(height: Responsive.getHeight(10)),
                  Text(
                    "Your new password must be unique from those previously used.",
                    style: GoogleFonts.urbanist(
                      color: textGray,
                      fontSize: Responsive.getFontSize(16),
                      fontWeight: AppFontWeight.medium,
                    ),
                  ),
                  SizedBox(height: Responsive.getHeight(32)),
                  PasswordTextField(
                    obscureText: true,
                    fillColor: Color.fromRGBO(247, 248, 249, 1),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: Responsive.getWidth(18),
                      vertical: Responsive.getHeight(18),
                    ),
                    borderRadius: Responsive.getWidth(8),
                    controller: newPassword,
                    borderColor: textFieldBorderColor,
                    hintStyle: GoogleFonts.poppins(
                      color: textGray,
                      fontSize: Responsive.getFontSize(15),
                      fontWeight: AppFontWeight.medium,
                    ),
                    textStyle: GoogleFonts.poppins(
                      color: textBlack,
                      fontSize: Responsive.getFontSize(15),
                      fontWeight: AppFontWeight.medium,
                    ),
                    hintText: "Enter your password",
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password cannot be empty';
                      }
                      final passwordRegex = RegExp(
                        r'^(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{6,}$',
                      );
                      if (!passwordRegex.hasMatch(value)) {
                        return 'Password must be at least 6 characters, contain an uppercase letter, a number, and a special character';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: Responsive.getHeight(12)),
                  PasswordTextField(
                    obscureText: true,
                    fillColor: Color.fromRGBO(247, 248, 249, 1),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: Responsive.getWidth(18),
                      vertical: Responsive.getHeight(18),
                    ),
                    borderRadius: Responsive.getWidth(8),
                    controller: newConfirmPassword,
                    borderColor: textFieldBorderColor,
                    hintStyle: GoogleFonts.poppins(
                      color: textGray,
                      fontSize: Responsive.getFontSize(15),
                      fontWeight: AppFontWeight.medium,
                    ),
                    textStyle: GoogleFonts.poppins(
                      color: textBlack,
                      fontSize: Responsive.getFontSize(15),
                      fontWeight: AppFontWeight.medium,
                    ),
                    hintText: "Enter Confirm your password",
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Confirm password cannot be empty';
                      }
                      if (value != newPassword.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: Responsive.getHeight(38)),
                  // Align(
                  //   alignment: Alignment.center,
                  //   child:
                  //   // GeneralButton(
                  //   //   Width: Responsive.getWidth(331),
                  //
                  //   //   label: "Reset Password",
                  //   //   isBoarderRadiusLess: true,
                  //   // ),
                  // ),
                  Align(
                    alignment: Alignment.center,
                    child: GestureDetector(
                        onTap: () {
                          if (_formKey.currentState?.validate() ?? false) {
                            resetPassword();
                          } else {
                            showToast(
                              message:
                              "Password must be at least 6 characters, contain an uppercase letter, a number, and a special character",
                            );
                          }
                        },
                      child: Container(
                        height: Responsive.getHeight(45),
                        width: Responsive.getWidth(331),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black),
                            color: black,
                            borderRadius:
                            BorderRadius.circular(Responsive.getWidth(8)),
                          ),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                isLoding
                                    ? Center(
                                  child: SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 3,
                                      color: Colors.white,
                                    ),
                                  ),
                                )
                                    : Text(
                                  "RESET PASSWORD",
                                  style: GoogleFonts.urbanist(
                                    textStyle: TextStyle(
                                      fontSize:
                                      Responsive.getFontSize(18),
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: Responsive.getHeight(20),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
