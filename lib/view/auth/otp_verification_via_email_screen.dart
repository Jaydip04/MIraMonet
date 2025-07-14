import 'dart:convert';

import 'package:artist/view/auth/reset_password.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:pinput/pinput.dart';
import 'package:http/http.dart' as http;

import '../../config/colors.dart';
import '../../core/utils/app_font_weight.dart';
import '../../core/utils/responsive.dart';
import '../../core/widgets/custom_text.dart';
import '../../core/widgets/general_button.dart';
import '../../config/toast.dart';
import '../../core/api_service/api_service.dart';

class OtpVerificationViaEmailScreen extends StatefulWidget {
  final email;
  const OtpVerificationViaEmailScreen({super.key, required this.email});

  @override
  State<OtpVerificationViaEmailScreen> createState() =>
      _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OtpVerificationViaEmailScreen> {
  final TextEditingController _pinController = TextEditingController();
  String? otp;
  String message = "";
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    print(widget.email);
    // fetchOtp(widget.email);
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  // final String baseUrl = "$serverUrl";
  // Future<void> fetchOtp(String email) async {
  //   setState(() {
  //     isLoading = true;
  //   });
  //   try {
  //     final url = Uri.parse('$baseUrl/passwordsendotp');
  //     final Map<String, String> body = {"email": email, "type": "customer"};
  //     final response = await http.post(
  //       url,
  //       headers: {
  //         'Content-Type': 'application/json',
  //       },
  //       body: json.encode(body),
  //     );
  //
  //     print('Response status: ${response.statusCode}');
  //     print('Response body: ${response.body}');
  //
  //     if (response.statusCode == 200) {
  //       setState(() {
  //         isLoading = false;
  //       });
  //       final jsonResponse = json.decode(response.body);
  //
  //       if (jsonResponse['status'] == true) {
  //         setState(() {
  //           otp = jsonResponse['otp'].toString();
  //           print(otp);
  //           message = jsonResponse['message'];
  //           _pinController.text = otp!;
  //           print(otp);
  //           isLoading = false;
  //         });
  //         showToast(message: message);
  //       } else {
  //         setState(() {
  //           isLoading = false;
  //           message = "Failed to retrieve OTP.";
  //         });
  //       }
  //     } else {
  //       setState(() {
  //         isLoading = false;
  //         message = "Error: ${response.statusCode}";
  //       });
  //     }
  //   } catch (e) {
  //     print('Exception caught: $e');
  //     setState(() {
  //       isLoading = false;
  //       message = "An error occurred: $e";
  //     });
  //   }
  // }
  //
  // Future<Map<String, String>> verifyOtp() async {
  //   setState(() {
  //     isLoading = true;
  //   });
  //   final url = Uri.parse('$baseUrl/passwordverifyotp');
  //
  //   final Map<String, String> body = {
  //     'email': widget.email,
  //     "type": "customer",
  //     'otp': "${otp}"
  //   };
  //
  //   try {
  //     final response = await http.post(
  //       url,
  //       headers: {
  //         'Content-Type': 'application/json',
  //       },
  //       body: json.encode(body),
  //     );
  //
  //     if (response.statusCode == 200) {
  //       setState(() {
  //         isLoading = false;
  //       });
  //       final responseData = json.decode(response.body);
  //
  //       message = responseData['message'] ?? 'No message';
  //       showToast(message: message);
  //       Navigator.push(
  //           context,
  //           PageTransition(
  //               child: ResetPassword(
  //                 email: widget.email,
  //               ),
  //               type: PageTransitionType.rightToLeft));
  //
  //       return {
  //         'message': message,
  //         // 'coupon_code': couponCodeResponse,
  //       };
  //     } else {
  //       setState(() {
  //         isLoading = true;
  //         message = 'Failed to apply coupon';
  //       });
  //       return {
  //         'message': 'Failed to apply coupon',
  //         'coupon_code': '',
  //       };
  //     }
  //   } catch (error) {
  //     setState(() {
  //       isLoading = true;
  //       message = error.toString();
  //     });
  //     print('Error sending data: $error');
  //     return {
  //       'message': 'An error occurred',
  //       'coupon_code': '',
  //     };
  //   }
  // }

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
                      "OTP Verification",
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
                      "Enter the verification code we just sent on your email address.",
                      style: GoogleFonts.urbanist(
                        color: textGray,
                        fontSize: Responsive.getFontSize(16),
                        fontWeight: AppFontWeight.medium,
                      ),
                    ),
                    SizedBox(
                      height: Responsive.getHeight(32),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Pinput(
                        controller: _pinController,
                        length: 4,
                        onCompleted: (pin) {
                          print('OTP entered: $pin');
                        },
                        defaultPinTheme: PinTheme(
                          width: 70,
                          height: 60,
                          textStyle: GoogleFonts.urbanist(
                            color: textBlack,
                            fontSize: Responsive.getFontSize(22),
                            fontWeight: AppFontWeight.bold,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: textFieldBorderColor, width: 1.0),
                            color: whitefill,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        focusedPinTheme: PinTheme(
                          width: 70,
                          height: 60,
                          textStyle: GoogleFonts.urbanist(
                            color: textBlack,
                            fontSize: Responsive.getFontSize(22),
                            fontWeight: AppFontWeight.bold,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: textFieldBorderColor2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        submittedPinTheme: PinTheme(
                          width: 70,
                          height: 60,
                          textStyle: GoogleFonts.urbanist(
                            color: textBlack,
                            fontSize: Responsive.getFontSize(22),
                            fontWeight: AppFontWeight.bold,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: textFieldBorderColor2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: Responsive.getHeight(38),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: GestureDetector(
                        onTap: () async {
                          setState(() {
                            isLoading = true;
                          });
                          await ApiService()
                              .verifyOtp_email(
                                  widget.email, _pinController.text)
                              .then((onValue) {

                            setState(() {
                              isLoading = false;
                            });
                            Navigator.pushReplacement(
                                context,
                                PageTransition(
                                    child: ResetPassword(
                                      email: widget.email,
                                    ),
                                    type: PageTransitionType.rightToLeft));
                          });
                          // verifyOtp();
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
                                          "VERIFY",
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
                    // GeneralButton(
                    //   Width: Responsive.getWidth(331),
                    //   onTap: () {
                    //     Navigator.pushReplacement(
                    //         context,
                    //         PageTransition(
                    //             child: ResetPassword(email: widget.email),
                    //             type: PageTransitionType.rightToLeft));
                    //   },
                    //   label: "Verify",
                    //   isBoarderRadiusLess: true,
                    // )),
                    Spacer(),
                    Align(
                        alignment: Alignment.center,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            WantText(
                                text: "Didn’t received code? ",
                                fontSize: Responsive.getFontSize(15),
                                fontWeight: AppFontWeight.medium,
                                textColor: buttonBlack),
                            GestureDetector(
                              onTap: () async {
                                // fetchOtp(widget.email);
                                await ApiService().send_otp_email(
                                  widget.email.toString(),
                                );
                              },
                              child: WantText(
                                  text: "Resend",
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
                )),
          ),
        ));
  }
}
