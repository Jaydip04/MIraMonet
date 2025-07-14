import 'package:artist/core/utils/app_font_weight.dart';
import 'package:artist/core/widgets/app_text_form_field.dart';
import 'package:artist/core/widgets/custom_text.dart';
import 'package:artist/core/widgets/general_button.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/colors.dart';
import '../../core/utils/responsive.dart';
import '../../core/widgets/password_text_field.dart';
import '../../config/toast.dart';
import '../../core/api_service/api_service.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final ApiService apiService = ApiService();
  bool isClick = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _checkNotificationPermission(context);
    super.initState();
  }

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

  void _loginUser() async {
    setState(() {
      isClick = true;
    });
    if (emailController.text.isEmpty) {
      showToast(message: "Enter your Email");
      setState(() {
        isClick = false;
      });
    } else if (passwordController.text.isEmpty) {
      showToast(message: "Enter your password");
      setState(() {
        isClick = false;
      });
    } else {
      String email = emailController.text.trim();
      String password = passwordController.text.trim();
      try {
        final response = await apiService.loginUser(
          email: email,
          password: password,
          token: token.toString(),
        );
        if (response['status'] == true && response['customer'] != null) {
          setState(() {
            isClick = false;
          });
          final customer = response['customer'];
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('name', customer['name'] ?? '');
          await prefs.setString('email', customer['email'] ?? '');
          await prefs.setString('mobile', customer['mobile'] ?? '');
          await prefs.setString('role', customer['role'] ?? '');
          await prefs.setString('status', customer['status'] ?? '');
          await prefs.setString('insertedDate', customer['inserted_date'] ?? '');
          await prefs.setString('insertedTime', customer['inserted_time'] ?? '');
          await prefs.setString('customerUniqueId', customer['customer_unique_id'] ?? '');

          final UserToken = customer['token'];
          if (UserToken != null && UserToken.isNotEmpty) {
            print("UserToken : ($UserToken)");
            await prefs.setString('UserToken', UserToken);
          }
          // SharedPreferences prefs = await SharedPreferences.getInstance();
          //
          // await prefs.setString('name', response['customer']['name'] ?? '');
          // await prefs.setString('email', response['customer']['email'] ?? '');
          // await prefs.setString('mobile', response['customer']['mobile'] ?? '');
          // await prefs.setString('role', response['customer']['role'] ?? '');
          // await prefs.setString('status', response['customer']['status'] ?? '');
          // await prefs.setString(
          //     'insertedDate', response['customer']['inserted_date'] ?? '');
          // await prefs.setString(
          //     'insertedTime', response['customer']['inserted_time'] ?? '');
          // await prefs.setString('customerUniqueId',
          //     response['customer']['customer_unique_id'] ?? '');
          // await prefs.setString('token', response['customer']['token'] ?? '');


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
          // if (response['customer']['role'] == "customer") {
          //   Navigator.pushNamedAndRemoveUntil(
          //     context,
          //     '/home',  // Customer's home screen
          //         (route) => false,
          //   );
          // } else if (response['customer']['role'] == "seller") {
          //   Navigator.pushNamedAndRemoveUntil(
          //     context,
          //     '/seller_home',  // Seller's home screen
          //         (route) => false,
          //   );
          // }
        } else {
          // Show error message if login failed
          setState(() {
            isClick = false;
          });
          // showToast(message: response['message']);
        }
      } catch (e) {
        setState(() {
          isClick = false;
        });
        // Handle any errors during the API call
        // showToast(message: e.toString());
      }
    }
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
            height: Responsive.getMainHeight(context),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: Responsive.getHeight(78)),
                  Text(
                    "Welcome back! Glad to see you, Again!",
                    style: GoogleFonts.urbanist(
                      color: textBlack,
                      fontSize: Responsive.getFontSize(30),
                      fontWeight: AppFontWeight.bold,
                    ),
                  ),
                  SizedBox(height: Responsive.getHeight(35)),
                  AppTextFormField(
                    fillColor: Color.fromRGBO(247, 248, 249, 1),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: Responsive.getWidth(18),
                      vertical: Responsive.getHeight(18),
                    ),
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
                    hintText: "Enter your email",
                  ),
                  SizedBox(height: Responsive.getHeight(15)),
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
                    hintText: "Enter your password",
                    // onChanged: (p0) {
                    //   _formKey.currentState!.validate();
                    // },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password cannot be empty';
                      }
                      final passwordRegex = RegExp(
                          r'^(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{6,}$');
                      if (!passwordRegex.hasMatch(value)) {
                        return 'Your password must be at least 6 characters long\nand include a combination of letters, numbers, and\nspecial characters.';
                      }
                      return null; // Return null if validation passes
                    },
                  ),
                  SizedBox(height: Responsive.getHeight(15)),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/SignIn/ForgotPassword');
                    },
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: WantText(
                        text: "Forgot Password?",
                        fontSize: Responsive.getFontSize(14),
                        fontWeight: AppFontWeight.semiBold,
                        textColor: textGray2,
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ),
                  SizedBox(height: Responsive.getHeight(30)),
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          _loginUser();
                          print("Password is valid");
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
                                        "LOGIN",
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
                    // GeneralButton(
                    //   Width: Responsive.getWidth(331),
                    //   onTap: () {
                    //     _loginUser();
                    //     // String client = "customer";
                    //     // if (client == "seller") {
                    //     //   Navigator.pushNamedAndRemoveUntil(
                    //     //     context,
                    //     //     '/SignIn/Artist',
                    //     //         (Route<dynamic> route) => false,
                    //     //   );
                    //     // } else if (client == "customer") {
                    //     //   Navigator.pushNamedAndRemoveUntil(
                    //     //     context,
                    //     //     '/SignIn/User',
                    //     //         (Route<dynamic> route) => false,
                    //     //   );
                    //     // } else {
                    //     //   Navigator.pushNamedAndRemoveUntil(
                    //     //     context,
                    //     //     '/ChooseRole',
                    //     //         (Route<dynamic> route) => false,
                    //     //   );
                    //     // }
                    //   },
                    //   label: "Login",
                    //   isBoarderRadiusLess: true,
                    // ),
                  ),
                  // SizedBox(
                  //   height: Responsive.getHeight(35),
                  // ),
                  // Row(
                  //   crossAxisAlignment: CrossAxisAlignment.center,
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: [
                  //     Container(
                  //       height: Responsive.getHeight(1),
                  //       width: Responsive.getWidth(103),
                  //       color: Color.fromRGBO(232, 236, 244, 1),
                  //     ),
                  //     WantText(
                  //         text: "Or Register with",
                  //         fontSize: Responsive.getFontSize(14),
                  //         fontWeight: AppFontWeight.semiBold,
                  //         textColor: textGray2),
                  //     Container(
                  //       height: Responsive.getHeight(1),
                  //       width: Responsive.getWidth(103),
                  //       color: Color.fromRGBO(232, 236, 244, 1),
                  //     ),
                  //   ],
                  // ),
                  // SizedBox(
                  //   height: Responsive.getHeight(22),
                  // ),
                  // Row(
                  //   crossAxisAlignment: CrossAxisAlignment.center,
                  //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  //   children: [
                  //     Container(
                  //         width: Responsive.getWidth(105),
                  //         height: Responsive.getHeight(56),
                  //         padding: EdgeInsets.symmetric(
                  //             vertical: Responsive.getHeight(16)),
                  //         decoration: BoxDecoration(
                  //             color: Colors.white,
                  //             borderRadius: BorderRadius.circular(
                  //                 Responsive.getWidth(8)),
                  //             border: Border.all(
                  //                 color: textFieldBorderColor, width: 1.0)),
                  //         child: Image.asset(
                  //           "assets/facebook_ic.png",
                  //           height: Responsive.getHeight(20),
                  //           width: Responsive.getWidth(20),
                  //         )),
                  //     GestureDetector(
                  //       onTap: (){
                  //         fetchGoogleLoginCallback();
                  //       },
                  //       child: Container(
                  //           width: Responsive.getWidth(105),
                  //           height: Responsive.getHeight(56),
                  //           padding: EdgeInsets.symmetric(
                  //               vertical: Responsive.getHeight(16)),
                  //           decoration: BoxDecoration(
                  //               color: Colors.white,
                  //               borderRadius: BorderRadius.circular(
                  //                   Responsive.getWidth(8)),
                  //               border: Border.all(
                  //                   color: textFieldBorderColor, width: 1.0)),
                  //           child: Image.asset(
                  //             "assets/google_ic.png",
                  //             height: Responsive.getHeight(20),
                  //             width: Responsive.getWidth(20),
                  //           )),
                  //     ),
                  //     Container(
                  //         width: Responsive.getWidth(105),
                  //         height: Responsive.getHeight(56),
                  //         padding: EdgeInsets.symmetric(
                  //             vertical: Responsive.getHeight(16)),
                  //         decoration: BoxDecoration(
                  //             color: Colors.white,
                  //             borderRadius: BorderRadius.circular(
                  //                 Responsive.getWidth(8)),
                  //             border: Border.all(
                  //                 color: textFieldBorderColor, width: 1.0)),
                  //         child: Image.asset(
                  //           "assets/apple_ic.png",
                  //           height: Responsive.getHeight(20),
                  //           width: Responsive.getWidth(20),
                  //         )),
                  //   ],
                  // ),
                  // SizedBox(
                  //   height: Responsive.getHeight(20),
                  // ),
                  Spacer(),
                  Center(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        WantText(
                          text: "Don’t have an account?",
                          fontSize: Responsive.getFontSize(15),
                          fontWeight: AppFontWeight.medium,
                          textColor: buttonBlack,
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/ChooseRole',
                              (Route<dynamic> route) => false,
                            );
                          },
                          child: WantText(
                            text: " Register Now",
                            fontSize: Responsive.getFontSize(15),
                            fontWeight: AppFontWeight.bold,
                            textColor: textBlack,
                          ),
                        ),
                      ],
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

  // String responseMessage = '';
  // void fetchGoogleLoginCallback() async {
  //   const callbackUrl = 'https://myapp.com/callback';
  //   try {
  //     final response = await apiService.getGoogleLoginCallback(callbackUrl);
  //     setState(() {
  //       responseMessage = response['message'];
  //     });
  //   } catch (e) {
  //     setState(() {
  //       responseMessage = e.toString();
  //     });
  //   }
  // }
}
