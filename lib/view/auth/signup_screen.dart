import 'dart:convert';

import 'package:artist/core/api_service/api_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:pinput/pinput.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/colors.dart';
import '../../core/utils/app_font_weight.dart';
import '../../core/utils/responsive.dart';
import '../../core/widgets/app_text_form_field.dart';
import '../../core/widgets/custom_text.dart';
import '../../core/widgets/general_button.dart';
import '../../core/widgets/password_text_field.dart';
import '../../config/toast.dart';
import 'package:http/http.dart' as http;

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({
    super.key,
  });

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _showPassword = true;
  bool _isShow = false;
  String? _selectedRole;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController artistNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController _pinControllerEmail = TextEditingController();
  final TextEditingController _pinControllerMobile = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final ApiService apiService = ApiService();

  PhoneNumber number = PhoneNumber(isoCode: 'US');
  String phoneNumber = '';
  String countryCode = '';

  bool isPhoneNumberValid = true;
  bool isVisibleEmail = false;
  bool isVisibleMobile = false;

  bool isSend = false;
  bool isVerify = false;
  bool isVerifySuccess = false;
  bool isSendEmail = false;
  bool isVerifyEmail = false;
  bool isVerifySuccessEmail = false;

  bool isLoading = false;

  Future<void> _checkNotificationPermission(BuildContext context) async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Get current notification settings
    NotificationSettings settings = await messaging.getNotificationSettings();

    print("Notification Permission Status: ${settings.authorizationStatus}");

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('✅ User has already granted permission');
      _getToken();
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('🟡 User has provisional permission');
      // _requestPermissionsWithoutNotification(context);
    } else {
      // _requestPermissionsWithoutNotification(context);
      print('❌ User has NOT granted permission');
      // You can show a custom dialog to ask the user to enable notifications
    }
  }

  String? token;
  Future<void> _getToken() async {
    token = await FirebaseMessaging.instance.getToken();
    print('FCM Token: $token');
  }

  void _registerUser() async {
    setState(() {
      isClick = true;
    });

    print(phoneNumber);
    if (nameController.text.isEmpty) {
      showToast(message: "Enter your Name");
      setState(() {
        isClick = false;
      });
    } else if (emailController.text.isEmpty) {
      showToast(message: "Enter your Email");
      setState(() {
        isClick = false;
      });
    } else if (mobileController.text.isEmpty) {
      showToast(message: "Enter your Mobile Number");
      setState(() {
        isClick = false;
      });
    } else if (!isPhoneNumberValid) {
      showToast(message: "Enter a valid Mobile Number");
      setState(() {
        isClick = false;
      });
    } else if (passwordController.text.isEmpty) {
      showToast(message: "Enter your Password");
      setState(() {
        isClick = false;
      });
    } else if (confirmPasswordController.text.isEmpty) {
      showToast(message: "Enter your Password");
      setState(() {
        isClick = false;
      });
    } else if (passwordController.text != confirmPasswordController.text) {
      showToast(message: "Password doesn't match");
      setState(() {
        isClick = false;
      });
    }
    // else if (isVerifySuccess == false) {
    //   showToast(message: "Please Verify Mobile Number");
    // }
    else if (isVerifySuccessEmail == false) {
      showToast(message: "Please Verify Email");
    } else {
      String name = nameController.text.trim();
      String artistName = artistNameController.text.trim();
      String email = emailController.text.trim();
      String password = passwordController.text.trim();
      String mobile = phoneNumber.toString();
      String role = _selectedRole ?? "customer";
      String deviceIP = await getPublicIpAddress();
      print(deviceIP);
      print(number);
      try {
        final response = await apiService.registerUser(
            deviceIP: deviceIP,
            name: name,
            artistName: artistName,
            email: email,
            password: password,
            role: role,
            mobile: mobile,
            token: token.toString());

        if (response['status'] == true) {
          setState(() {
            isClick = false;
          });
          SharedPreferences prefs = await SharedPreferences.getInstance();

          await prefs.setString('name', response['customer']['name']);
          await prefs.setString('email', response['customer']['email']);
          await prefs.setString('mobile', response['customer']['mobile']);
          await prefs.setString('role', response['customer']['role']);
          await prefs.setString('status', response['customer']['status']);
          await prefs.setString(
              'insertedDate', response['customer']['inserted_date']);
          await prefs.setString(
              'insertedTime', response['customer']['inserted_time']);
          await prefs.setInt(
              'customerUniqueId', response['customer']['customer_unique_id']);
          // await prefs.setString('token', response['customer']['token']);

          final UserToken = response['customer']['token'];
          if (UserToken != null && UserToken.isNotEmpty) {
            print("UserToken : ($UserToken)");
            await prefs.setString('UserToken', UserToken);
          }

          if (response['customer']['role'] == "customer") {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/SignUP/User',
              (route) => false,
            );
          } else if (response['customer']['role'] == "seller") {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/SignUP/Artist',
              (route) => false,
            );
          }
        } else if (response['status'] == false) {
          setState(() {
            isClick = false;
          });
          // showToast(message: response['message']);
        } else {
          setState(() {
            isClick = false;
          });
          // showToast(message: response['message']);
        }
      } catch (e) {
        setState(() {
          isClick = false;
        });
        // showToast(message: "Failed to register");
      }
    }
  }

  bool isClick = false;

  Future<String> getPublicIpAddress() async {
    try {
      final response =
          await http.get(Uri.parse('https://api64.ipify.org?format=json'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body)['ip'];
      }
    } catch (e) {
      print("Failed to fetch IP: $e");
    }
    return 'Unknown IP';
  }

  @override
  void initState() {
    super.initState();
    _loadSelectedRole();
    _checkNotificationPermission(context);
  }

  _loadSelectedRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedRole = prefs.getString('selectedRole') ?? 'User';
    });
    print("selectedRole : $_selectedRole");
  }

  @override
  void dispose() {
    nameController.dispose();
    artistNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    mobileController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Center(
          child: Container(
              width: Responsive.getWidth(331),
              child: Form(
                key: _formKey,
                child: ListView(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    SizedBox(
                      height: Responsive.getHeight(78),
                    ),
                    Text(
                      "Hello! Register to get started",
                      style: GoogleFonts.urbanist(
                        color: textBlack,
                        fontSize: Responsive.getFontSize(30),
                        fontWeight: AppFontWeight.bold,
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
                      controller: nameController,
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
                      // onChanged: (p0) {
                      //   _formKey.currentState!.validate();
                      // },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Name cannot be empty';
                        }
                        return null;
                      },
                      hintText: "Enter Full Name",
                    ),
                    _selectedRole == "seller"
                        ? SizedBox(
                            height: Responsive.getHeight(12),
                          )
                        : SizedBox(),
                    _selectedRole == "seller"
                        ? AppTextFormField(
                            fillColor: Color.fromRGBO(247, 248, 249, 1),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: Responsive.getWidth(18),
                                vertical: Responsive.getHeight(18)),
                            borderRadius: Responsive.getWidth(8),
                            controller: artistNameController,
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
                            // onChanged: (p0) {
                            //   _formKey.currentState!.validate();
                            // },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Artist Name cannot be empty';
                              }
                              return null;
                            },
                            hintText: "Enter Artist Name",
                          )
                        : SizedBox(),
                    SizedBox(
                      height: Responsive.getHeight(12),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: isVerifySuccessEmail
                              ? Responsive.getWidth(330)
                              : Responsive.getWidth(252),
                          child: AppTextFormField(
                            suffixIcon: isVerifySuccessEmail
                                ? Icon(
                                    CupertinoIcons.checkmark_seal_fill,
                                    color: Colors.green,
                                  )
                                : SizedBox(),
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
                            // onChanged: (p0) {
                            //   _formKey.currentState!.validate();
                            // },
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
                            hintText: "Enter Email",
                          ),
                        ),
                        isVerifySuccessEmail
                            ? SizedBox()
                            : GestureDetector(
                                onTap: () async {
                                  if (emailController.text.isEmpty) {
                                    showToast(message: "Please Enter Email");
                                  } else {
                                    try {
                                      setState(() {
                                        isSendEmail = true;
                                      });
                                      // await ApiService()
                                      //     .send_otp_email_reg(
                                      //   emailController.text.toString(),
                                      // )
                                      //     .then((onValue) {
                                      //   setState(() {
                                      //     // isVerifySuccessEmail = true;
                                      //     isVisibleEmail = true;
                                      //     isSendEmail = false;
                                      //   });
                                      // });
                                      final response =
                                          await ApiService().send_otp_email_reg(
                                        emailController.text.toString(),
                                      );
                                      if (response['status'] == 'true') {
                                        setState(() {
                                          isVisibleEmail = true;
                                          isSendEmail = false;
                                        });
                                      } else {
                                        setState(() {
                                          isVisibleEmail = false;
                                          isSendEmail = false;
                                        });
                                      }
                                    } catch (e) {
                                      setState(() {
                                        isVerifySuccessEmail = false;
                                        isVisibleEmail = true;
                                        isSendEmail = false;
                                      });
                                      print(e);
                                    }
                                  }
                                  print(
                                      "countryCode : ${emailController.text}");
                                  // setState(() {
                                  //   isVisibleMobile = !isVisibleMobile;
                                  // });
                                },
                                child: Container(
                                  width: Responsive.getWidth(60),
                                  height: Responsive.getHeight(50),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.black),
                                    color: black,
                                    borderRadius: BorderRadius.circular(
                                        Responsive.getWidth(5)),
                                  ),
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        isSendEmail
                                            ? Center(
                                                child: SizedBox(
                                                  height: 20,
                                                  width: 20,
                                                  child:
                                                      CircularProgressIndicator(
                                                    strokeWidth: 3,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              )
                                            : Text(
                                                "Send",
                                                style: GoogleFonts.urbanist(
                                                  textStyle: TextStyle(
                                                    fontSize:
                                                        Responsive.getFontSize(
                                                            16),
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                      ],
                    ),
                    isVisibleEmail
                        ? SizedBox(
                            height: Responsive.getHeight(12),
                          )
                        : Container(),
                    isVisibleEmail
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Pinput(
                                controller: _pinControllerEmail,
                                length: 4,
                                onCompleted: (pin) {
                                  print('OTP entered: $pin');
                                },
                                defaultPinTheme: PinTheme(
                                  width: 60,
                                  height: 45,
                                  textStyle: GoogleFonts.poppins(
                                    color: black,
                                    letterSpacing: 1.5,
                                    fontSize: 18,
                                    fontWeight: FontWeight.normal,
                                  ),
                                  decoration: BoxDecoration(
                                    // color: Color.fromRGBO(247, 248, 249, 1),
                                    border:
                                        Border.all(color: textFieldBorderColor),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                focusedPinTheme: PinTheme(
                                  width: 60,
                                  height: 45,
                                  textStyle: GoogleFonts.poppins(
                                    color: black,
                                    letterSpacing: 1.5,
                                    fontSize: 18,
                                    fontWeight: FontWeight.normal,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    border:
                                        Border.all(color: textFieldBorderColor),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                submittedPinTheme: PinTheme(
                                  width: 60,
                                  height: 45,
                                  textStyle: GoogleFonts.poppins(
                                    color: black,
                                    letterSpacing: 1.5,
                                    fontSize: 18,
                                    fontWeight: FontWeight.normal,
                                  ),
                                  decoration: BoxDecoration(
                                    // color: Color.fromRGBO(247, 248, 249, 1),
                                    border:
                                        Border.all(color: textFieldBorderColor),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () async {
                                  setState(() {
                                    isVerifyEmail =
                                        true; // Show loading indicator
                                  });

                                  try {
                                    final response =
                                        await ApiService().verifyOtpEmailReg(
                                      emailController.text,
                                      _pinControllerEmail.text,
                                    );
                                    if (response['status'] == 'true') {
                                      setState(() {
                                        isVerifySuccessEmail =
                                            true; // Set verification success
                                        isVisibleEmail =
                                            false; // Hide OTP input
                                        isVerifyEmail =
                                            false; // Stop loading indicator
                                      });
                                    } else {
                                      setState(() {
                                        isVerifySuccessEmail =
                                            false; // Mark verification as failed
                                        isVerifyEmail = false;
                                      });
                                    }
                                  } catch (e) {
                                    setState(() {
                                      isVerifySuccessEmail =
                                          false; // Mark verification as failed
                                      isVerifyEmail =
                                          false; // Stop loading indicator
                                    });
                                    showToast(
                                        message:
                                            "Something went wrong. Please try again.");
                                    print(e);
                                  }
                                  // try {
                                  //   String responseMessage = await ApiService().verifyOtpEmailReg(
                                  //     emailController.text,
                                  //     _pinControllerEmail.text,
                                  //   );
                                  //
                                  //   setState(() {
                                  //     isVerifySuccessEmail = true; // Set verification success
                                  //     isVisibleEmail = false; // Hide OTP input
                                  //     isVerifyEmail = false; // Stop loading indicator
                                  //   });
                                  //
                                  //   showToast(message: responseMessage);
                                  // } catch (e) {
                                  //   setState(() {
                                  //     isVerifySuccessEmail = false; // Mark verification as failed
                                  //     isVerifyEmail = false; // Stop loading indicator
                                  //   });
                                  //
                                  //   print(e);
                                  //   showToast(message: 'OTP verification failed. Please try again.');
                                  // }
                                },

                                // onTap: () async {
                                //   setState(() {
                                //     isVerifyEmail = true;
                                //   });
                                //   try {
                                //     await ApiService()
                                //         .verify_otp_email_reg(
                                //             emailController.text,
                                //             _pinControllerEmail.text)
                                //         .then((onValue) {
                                //       setState(() {
                                //         isVerifySuccessEmail = true;
                                //         isVisibleEmail = false;
                                //         isVerifyEmail = false;
                                //       });
                                //     });
                                //   } catch (e) {
                                //     setState(() {
                                //       isVerifySuccessEmail = false;
                                //       isVerifyEmail = false;
                                //     });
                                //     print(e);
                                //   }
                                // },
                                child: Container(
                                  height: Responsive.getHeight(45),
                                  width: Responsive.getWidth(60),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.black),
                                      color: black,
                                      borderRadius: BorderRadius.circular(
                                          Responsive.getWidth(5)),
                                    ),
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          isVerifyEmail
                                              ? Center(
                                                  child: SizedBox(
                                                    height: 20,
                                                    width: 20,
                                                    child:
                                                        CircularProgressIndicator(
                                                      strokeWidth: 3,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                )
                                              : Text(
                                                  "Verify",
                                                  style: GoogleFonts.urbanist(
                                                    textStyle: TextStyle(
                                                      fontSize: Responsive
                                                          .getFontSize(16),
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          )
                        : Container(),
                    SizedBox(
                      height: Responsive.getHeight(12),
                    ),
                    Container(
                      width: Responsive.getWidth(252),
                      padding: EdgeInsets.only(
                        left: Responsive.getWidth(16),
                      ),
                      decoration: BoxDecoration(
                        // color: Color.fromRGBO(247, 248, 249, 1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            width: 1,
                            color:
                                // isPhoneNumberValid
                                //     ?
                                textFieldBorderColor
                            // : Colors.red,
                            ),
                      ),
                      child: InternationalPhoneNumberInput(
                        onInputChanged: (PhoneNumber number) {
                          setState(() {
                            phoneNumber = number.phoneNumber ?? '';
                            countryCode = number.dialCode ?? '';
                          });
                          //   print("Full number: $phoneNumber");
                          //   print("Country code: $countryCode");
                        },
                        onInputValidated: (bool value) {
                          setState(() {
                            isPhoneNumberValid = value;
                          });
                          print(value ? 'Valid' : 'Invalid');
                        },
                        selectorConfig: SelectorConfig(
                          setSelectorButtonAsPrefixIcon: false,
                          useBottomSheetSafeArea: true,
                          leadingPadding: 0,
                          selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                          useEmoji: false,
                          trailingSpace: false,
                        ),
                        ignoreBlank: false,
                        autoValidateMode: AutovalidateMode.disabled,
                        initialValue: number,
                        textFieldController: mobileController,
                        formatInput: false,
                        keyboardType: TextInputType.numberWithOptions(
                            signed: true, decimal: true),
                        inputBorder: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        onSaved: (PhoneNumber number) {
                          String formattedNumber =
                              number.phoneNumber?.replaceFirst('+', '') ?? '';
                          print('On Saved: $formattedNumber');
                        },
                        cursorColor: Colors.black,
                        textStyle: GoogleFonts.poppins(
                          letterSpacing: 1.5,
                          color: black,
                          fontSize: 14.00,
                          fontWeight: FontWeight.normal,
                        ),
                        inputDecoration: InputDecoration(
                          fillColor: white,
                          isDense: true,
                          hintText: 'Enter Phone Number',
                          hintStyle: GoogleFonts.poppins(
                            letterSpacing: 1.5,
                            color: textGray,
                            fontSize: 14.00,
                            fontWeight: FontWeight.normal,
                          ),
                          // fillColor: Color.fromRGBO(247, 248, 249, 1),
                          // filled: true,
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 0, vertical: 5),
                          // suffixIcon: IconButton(
                          //   icon: Icon(
                          //     Icons.clear,
                          //     color: Colors.grey,
                          //   ),
                          //   onPressed: () {
                          //     mobileController.clear();
                          //   },
                          // ),
                          prefixIconConstraints: BoxConstraints(
                            minWidth: 0,
                            minHeight: 0,
                          ),
                          suffixIconConstraints: BoxConstraints(
                            minWidth: 40,
                            minHeight: 40,
                          ),
                          errorMaxLines: 3,
                          counterText: "",
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                            borderSide: BorderSide.none,
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                            borderSide: BorderSide(color: Colors.red, width: 1),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                            borderSide:
                                BorderSide(color: Colors.transparent, width: 1),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                            borderSide:
                                BorderSide(color: Colors.transparent, width: 1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                            borderSide:
                                BorderSide(color: Colors.transparent, width: 1),
                          ),
                        ),
                        // onInputChanged: (PhoneNumber value) {},
                      ),
                    ),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //   crossAxisAlignment: CrossAxisAlignment.start,
                    //   children: [
                    //
                    //     GestureDetector(
                    //       onTap: () async {
                    //         if (countryCode.isEmpty) {
                    //           showToast(message: "Please Select Country");
                    //         } else if (mobileController.text.isEmpty) {
                    //           showToast(message: "Enter Mobile Number");
                    //         } else {
                    //           try {
                    //             setState(() {
                    //               isSend = true;
                    //             });
                    //             await ApiService()
                    //                 .send_otp(
                    //               countryCode.toString(),
                    //               mobileController.text.toString(),
                    //             )
                    //                 .then((onValue) {
                    //               setState(() {
                    //                 isVerifySuccessEmail = true;
                    //                 isVisibleMobile = true;
                    //                 isSend = false;
                    //               });
                    //             });
                    //           } catch (e) {
                    //             setState(() {
                    //               isVerifySuccessEmail = false;
                    //               isVisibleMobile = true;
                    //               isSend = false;
                    //             });
                    //             print(e);
                    //           }
                    //         }
                    //         print("countryCode : $countryCode");
                    //         print("countryCode : ${mobileController.text}");
                    //         // setState(() {
                    //         //   isVisibleMobile = !isVisibleMobile;
                    //         // });
                    //       },
                    //       child: Container(
                    //         height: Responsive.getHeight(45),
                    //         width: Responsive.getWidth(60),
                    //         child: Container(
                    //           decoration: BoxDecoration(
                    //             border: Border.all(color: Colors.black),
                    //             color: black,
                    //             borderRadius: BorderRadius.circular(
                    //                 Responsive.getWidth(5)),
                    //           ),
                    //           child: Center(
                    //             child: Row(
                    //               mainAxisAlignment: MainAxisAlignment.center,
                    //               crossAxisAlignment: CrossAxisAlignment.center,
                    //               children: [
                    //                 isSend
                    //                     ? Center(
                    //                         child: SizedBox(
                    //                           height: 20,
                    //                           width: 20,
                    //                           child: CircularProgressIndicator(
                    //                             strokeWidth: 3,
                    //                             color: Colors.white,
                    //                           ),
                    //                         ),
                    //                       )
                    //                     : Text(
                    //                         "Send",
                    //                         style: GoogleFonts.urbanist(
                    //                           textStyle: TextStyle(
                    //                             fontSize:
                    //                                 Responsive.getFontSize(16),
                    //                             color: Colors.white,
                    //                             fontWeight: FontWeight.bold,
                    //                           ),
                    //                         ),
                    //                       ),
                    //               ],
                    //             ),
                    //           ),
                    //         ),
                    //       ),
                    //     )
                    //   ],
                    // ),
                    // isVisibleMobile
                    //     ? SizedBox(
                    //         height: Responsive.getHeight(12),
                    //       )
                    //     : Container(),
                    // isVisibleMobile
                    //     ? Row(
                    //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //         children: [
                    //           Pinput(
                    //             controller: _pinControllerMobile,
                    //             length: 4,
                    //             onCompleted: (pin) {
                    //               print('OTP entered: $pin');
                    //             },
                    //             defaultPinTheme: PinTheme(
                    //               width: 60,
                    //               height: 45,
                    //               textStyle: GoogleFonts.poppins(
                    //                 color: black,
                    //                 letterSpacing: 1.5,
                    //                 fontSize: 18,
                    //                 fontWeight: FontWeight.normal,
                    //               ),
                    //               decoration: BoxDecoration(
                    //                 // color: Color.fromRGBO(247, 248, 249, 1),
                    //                 border:
                    //                     Border.all(color: textFieldBorderColor),
                    //                 borderRadius: BorderRadius.circular(8),
                    //               ),
                    //             ),
                    //             focusedPinTheme: PinTheme(
                    //               width: 60,
                    //               height: 45,
                    //               textStyle: GoogleFonts.poppins(
                    //                 color: black,
                    //                 letterSpacing: 1.5,
                    //                 fontSize: 18,
                    //                 fontWeight: FontWeight.normal,
                    //               ),
                    //               decoration: BoxDecoration(
                    //                 color: Colors.transparent,
                    //                 border:
                    //                     Border.all(color: textFieldBorderColor),
                    //                 borderRadius: BorderRadius.circular(8),
                    //               ),
                    //             ),
                    //             submittedPinTheme: PinTheme(
                    //               width: 60,
                    //               height: 45,
                    //               textStyle: GoogleFonts.poppins(
                    //                 color: black,
                    //                 letterSpacing: 1.5,
                    //                 fontSize: 18,
                    //                 fontWeight: FontWeight.normal,
                    //               ),
                    //               decoration: BoxDecoration(
                    //                 // color: Color.fromRGBO(247, 248, 249, 1),
                    //                 border:
                    //                     Border.all(color: textFieldBorderColor),
                    //                 borderRadius: BorderRadius.circular(8),
                    //               ),
                    //             ),
                    //           ),
                    //           GestureDetector(
                    //             onTap: () async {
                    //               setState(() {
                    //                 isVerify = true;
                    //               });
                    //               try {
                    //                 await ApiService()
                    //                     .verifyOtp(mobileController.text,
                    //                         _pinControllerMobile.text)
                    //                     .then((onValue) {
                    //                   setState(() {
                    //                     isVerifySuccess = true;
                    //                     isVisibleMobile = false;
                    //                     isVerify = false;
                    //                   });
                    //                 });
                    //               } catch (e) {
                    //                 setState(() {
                    //                   isVerifySuccess = false;
                    //                   isVerify = false;
                    //                 });
                    //                 print(e);
                    //               }
                    //             },
                    //             child: Container(
                    //               height: Responsive.getHeight(45),
                    //               width: Responsive.getWidth(60),
                    //               child: Container(
                    //                 decoration: BoxDecoration(
                    //                   border: Border.all(color: Colors.black),
                    //                   color: black,
                    //                   borderRadius: BorderRadius.circular(
                    //                       Responsive.getWidth(5)),
                    //                 ),
                    //                 child: Center(
                    //                   child: Row(
                    //                     mainAxisAlignment:
                    //                         MainAxisAlignment.center,
                    //                     crossAxisAlignment:
                    //                         CrossAxisAlignment.center,
                    //                     children: [
                    //                       isVerify
                    //                           ? Center(
                    //                               child: SizedBox(
                    //                                 height: 20,
                    //                                 width: 20,
                    //                                 child:
                    //                                     CircularProgressIndicator(
                    //                                   strokeWidth: 3,
                    //                                   color: Colors.white,
                    //                                 ),
                    //                               ),
                    //                             )
                    //                           : Text(
                    //                               "Verify",
                    //                               style: GoogleFonts.urbanist(
                    //                                 textStyle: TextStyle(
                    //                                   fontSize: Responsive
                    //                                       .getFontSize(16),
                    //                                   color: Colors.white,
                    //                                   fontWeight:
                    //                                       FontWeight.bold,
                    //                                 ),
                    //                               ),
                    //                             ),
                    //                     ],
                    //                   ),
                    //                 ),
                    //               ),
                    //             ),
                    //           )
                    //         ],
                    //       )
                    //     : Container(),
                    SizedBox(
                      height: Responsive.getHeight(12),
                    ),
                    PasswordTextField(
                      obscureText: true,
                      fillColor: Color.fromRGBO(247, 248, 249, 1),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: Responsive.getWidth(18),
                        vertical: Responsive.getHeight(18),
                      ),
                      borderRadius: Responsive.getWidth(8),
                      controller: passwordController,
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
                      hintText: "Enter Password",
                      // onChanged: (p0) {
                      //   _formKey.currentState!.validate();
                      // },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password cannot be empty `Test@123`';
                        }
                        final passwordRegex = RegExp(
                            r'^(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{6,}$');
                        if (!passwordRegex.hasMatch(value)) {
                          return 'Your password must be at least 6 characters long\nand include a combination of letters, numbers, and\nspecial characters.';
                        }
                        return null;
                      },
                    ),
                    SizedBox(
                      height: Responsive.getHeight(12),
                    ),
                    PasswordTextField(
                      obscureText: true,
                      fillColor: Color.fromRGBO(247, 248, 249, 1),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: Responsive.getWidth(18),
                        vertical: Responsive.getHeight(18),
                      ),
                      borderRadius: Responsive.getWidth(8),
                      controller: confirmPasswordController,
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
                      hintText: "Enter Confirm password",
                      // onChanged: (p0) {
                      //   _formKey.currentState!.validate();
                      // },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password cannot be empty';
                        }
                        if (value != passwordController.text) {
                          return 'Passwords do not match';
                        }
                        final passwordRegex = RegExp(
                            r'^(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{6,}$');
                        if (!passwordRegex.hasMatch(value)) {
                          return 'Your password must be at least 6 characters long\nand include a combination of letters, numbers, and\nspecial characters.';
                        }
                        return null;
                      },
                    ),
                    SizedBox(
                      height: Responsive.getHeight(30),
                    ),
                    Center(
                      child: GestureDetector(
                        onTap: () async {
                          print("codeNumber : $countryCode");
                          print("mobile : ${mobileController.text.toString()}");
                          print("name : ${nameController.text.toString()}");
                          print("email : ${emailController.text.toString()}");
                          print(
                              "password : ${passwordController.text.toString()}");
                          if (_formKey.currentState!.validate() &&
                              isPhoneNumberValid &&
                              passwordController.text ==
                                  confirmPasswordController.text) {
                            // if (isVerifySuccess == false) {
                            //   showToast(message: "Please Verify Mobile Number");
                            // } else
                            if (isVerifySuccessEmail == false) {
                              showToast(message: "Please Verify Email");
                            } else {
                              _registerUser();
                            }
                            print("Password is valid");
                          } else {
                            showToast(message: "Invalid Details");
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
                                  isClick
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
                                          "REGISTER",
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
                      height: Responsive.getHeight(10),
                    ),
                    Center(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          WantText(
                              text: "Already have an account? ",
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
                      ),
                    ),
                    SizedBox(
                      height: Responsive.getHeight(20),
                    ),
                  ],
                ),
              )),
        ),
      ),
    );
  }
}
