import 'package:artist/config/toast.dart';
import 'package:artist/view/auth/sign_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import '../../config/colors.dart';
import '../../core/utils/app_font_weight.dart';
import '../../core/utils/responsive.dart';
import '../../core/widgets/app_text_form_field.dart';
import '../../core/widgets/custom_text.dart';
import '../../core/widgets/general_button.dart';
import '../../core/api_service/api_service.dart';
import 'otp_verification_via_email_screen.dart';
import 'reset_password.dart';
import 'signup_screen.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  TextEditingController emailController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();
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
                      SizedBox(
                        height: Responsive.getHeight(12),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: Responsive.getWidth(41),
                            height: Responsive.getHeight(41),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(
                                    Responsive.getWidth(12)),
                                border: Border.all(
                                    color: textFieldBorderColor, width: 1.0)),
                            child: Icon(
                              Icons.arrow_back_ios_new_outlined,
                              size: Responsive.getWidth(19),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: Responsive.getHeight(28),
                      ),
                      Text(
                        "Forgot Password?",
                        style: GoogleFonts.urbanist(
                          color: textBlack,
                          fontSize: Responsive.getFontSize(30),
                          fontWeight: AppFontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: Responsive.getHeight(10),
                      ),
                      Text(
                        "Don't worry! It occurs. Please enter the email address linked with your account.",
                        style: GoogleFonts.urbanist(
                          color: textGray,
                          fontSize: Responsive.getFontSize(16),
                          fontWeight: AppFontWeight.medium,
                        ),
                      ),
                      SizedBox(
                        height: Responsive.getHeight(32),
                      ),
                      AppTextFormField(
                        fillColor: Color.fromRGBO(247, 248, 249, 1),
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: Responsive.getWidth(18),
                            vertical: Responsive.getHeight(18)),
                        borderRadius: Responsive.getWidth(8),
                        controller: emailController,
                        borderColor: textFieldBorderColor,
                        hintStyle: GoogleFonts.urbanist(
                          color: textGray,
                          fontSize: Responsive.getFontSize(15),
                          fontWeight: AppFontWeight.medium,
                        ),
                        textStyle: GoogleFonts.urbanist(
                          color: textBlack,
                          fontSize: Responsive.getFontSize(15),
                          fontWeight: AppFontWeight.medium,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email cannot be empty';
                          }
                          final emailRegex = RegExp(
                            r'^[a-z0-9][a-z0-9._%+-]*@[a-z0-9.-]+\.[a-z]{2,}$',
                            caseSensitive: false,
                          );
                          if (!emailRegex.hasMatch(value)) {
                            return 'Email is not valid';
                          }
                          return null;
                        },
                        hintText: "Enter your email",
                      ),
                      SizedBox(
                        height: Responsive.getHeight(38),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: GestureDetector(
                          onTap: () async {
                            if (_formKey.currentState?.validate() ?? false) {
                              if (emailController.text.isEmpty) {
                                showToast(message: "Enter your Email");
                              } else  {
                                setState(() {
                                  isLoading = true;
                                });

                                try {
                                  final response = await ApiService().send_otp_email(
                                    emailController.text.trim(),
                                  );

                                  if (response['status'] == 'true') {
                                    Navigator.push(
                                      context,
                                      PageTransition(
                                        child: OtpVerificationViaEmailScreen(
                                          email: emailController.text.trim(),
                                        ),
                                        type: PageTransitionType.rightToLeft,
                                      ),
                                    );
                                  } else {
                                    showToast(message: response['message']); // Show error message from API
                                  }
                                } catch (e) {
                                  showToast(message: "Something went wrong. Please try again.");
                                  print(e);
                                }

                                setState(() {
                                  isLoading = false;
                                });

                              }
                            } else {
                              showToast(message: "Invalid Data");
                              // showToast(
                              //     message:
                              //         "Password must be at least 6 characters,`Test@123`");
                              print("Password is invalid");
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
                                    isLoading
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
                                            "SEND CODE",
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
                      Spacer(),
                      Align(
                          alignment: Alignment.center,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              WantText(
                                  text: "Remember Password?",
                                  fontSize: Responsive.getFontSize(15),
                                  fontWeight: AppFontWeight.medium,
                                  textColor: buttonBlack),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushNamedAndRemoveUntil(
                                    context,
                                    '/SignIn',
                                    (Route<dynamic> route) => false,
                                  );
                                },
                                child: WantText(
                                    text: "Login Now",
                                    fontSize: Responsive.getFontSize(15),
                                    fontWeight: AppFontWeight.bold,
                                    textColor: textBlack),
                              ),
                            ],
                          )),
                      SizedBox(
                        height: Responsive.getHeight(20),
                      ),
                    ],
                  ),
                )),
          ),
        ));
  }
}
