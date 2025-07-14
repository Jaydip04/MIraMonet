import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:pinput/pinput.dart';
import '../../config/colors.dart';
import 'account_created_screen.dart';

class OTPVerificationScreen extends StatefulWidget {
  final phonenumber;
  const OTPVerificationScreen({super.key, required this.phonenumber});

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final TextEditingController _pinController = TextEditingController();
  // String? otp;
  // String message = "";
  // UserDataShareModel? user;
  // @override
  // void initState() {
  //   super.initState();
  //   _fetchUserData().then((onValue) {
  //     print(widget.phonenumber);
  //     fetchOtp(user!.customerData!.mobile.toString());
  //   });
  //   // print(widget.phonenumber);
  //   // fetchOtp(widget.phonenumber);
  // }
  //
  // Future<void> _fetchUserData() async {
  //   AuthRepo authRepo = AuthRepo();
  //   user = await authRepo.getCustomerFromPreferences();
  //   print("User ID: ${user!.customerId}");
  //   print("User status: ${user!.status}");
  //   print("User status: ${user!.customerData!.mobile}");
  //   setState(() {});
  // }
  //
  // Future<void> fetchOtp(String mobile) async {
  //   // final response = await http.post(
  //   //   Uri.parse('$serverUrl/open_otp?mobile=+91${widget.phonenumber}'),);
  //   final url = Uri.parse('$serverUrl/open_otp');
  //
  //   final Map<String, String> body = {
  //     'mobile': "00${user!.customerData!.mobile.toString()}",
  //   };
  //   final response = await http.post(
  //     url,
  //     headers: {
  //       'Content-Type': 'application/json',
  //     },
  //     body: json.encode(body),
  //   );
  //
  //   if (response.statusCode == 200) {
  //     final jsonResponse = json.decode(response.body);
  //
  //     if (jsonResponse['status'] == true) {
  //       setState(() {
  //         otp = jsonResponse['otp'].toString();
  //         print(otp);
  //         message = jsonResponse['message'];
  //         _pinController.text = otp!;
  //         print(otp);
  //       });
  //       showToast(message: message);
  //     } else {
  //       setState(() {
  //         message = "Failed to retrieve OTP.";
  //       });
  //     }
  //   } else {
  //     setState(() {
  //       message = "Error: ${response.statusCode}";
  //     });
  //   }
  // }
  // Future<Map<String, String>> verifyOtp() async {
  //   final url = Uri.parse('$serverUrl/open_otp_validate');
  //
  //   final Map<String, String> body = {
  //     'mobile': "00${user!.customerData!.mobile}",
  //     'otp': "${otp}",
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
  //       final responseData = json.decode(response.body);
  //
  //       message = responseData['message'] ?? 'No message';
  //       // String couponCodeResponse = responseData['coupon_code'] ?? '';
  //       print("User status: ${user!.customerData!.mobile}");
  //       showToast(message: message);
  //       Navigator.push(
  //           context,
  //           PageTransition(
  //               child: AccountCreatedScreen(),
  //               type: PageTransitionType.rightToLeft));
  //
  //       return {
  //         'message': message,
  //         // 'coupon_code': couponCodeResponse,
  //       };
  //     } else {
  //       setState(() {
  //         message = 'Failed to apply coupon';
  //       });
  //       return {
  //         'message': 'Failed to apply coupon',
  //         'coupon_code': '',
  //       };
  //     }
  //   } catch (error) {
  //     setState(() {
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0.0,
        title: const Text(
          "OTP Verification",
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
        ),
        centerTitle: true,
        leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Padding(
              padding: EdgeInsets.all(10.0),
              child: Icon(Icons.arrow_back_ios_new),
            )),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 50.00,
                    ),
                    const Text(
                      "Enter One Time Password From The Sms We Sent.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Color(0XFFA4A4A4)),
                    ),
                    const SizedBox(height: 50),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Pinput(
                            controller: _pinController,
                            length: 4,
                            onCompleted: (pin) {
                              print('OTP entered: $pin');
                            },
                            defaultPinTheme: PinTheme(
                              width: 60,
                              height: 60,
                              textStyle: const TextStyle(
                                fontSize: 22,
                                color: Colors.black,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            focusedPinTheme: PinTheme(
                              width: 60,
                              height: 60,
                              textStyle: const TextStyle(
                                fontSize: 22,
                                color: Colors.black,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            submittedPinTheme: PinTheme(
                              width: 60,
                              height: 60,
                              textStyle: const TextStyle(
                                fontSize: 22,
                                color: Colors.black,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          // pinWidget(),
                          // pinWidget(),
                          // pinWidget(),
                          // pinWidget(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 50),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don’t Receive The OTP? ",
                          textAlign: TextAlign.center,
                          style:
                          TextStyle(fontSize: 10, color: Color(0XFF7E7D7D)),
                        ),
                        SizedBox(width: 10),
                        GestureDetector(
                          onTap: () {
                            // fetchOtp(widget.phonenumber);
                          },
                          child: Text(
                            "Resend",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12, color: Colors.black),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                // verifyOtp();
              },
              child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  margin: const EdgeInsets.symmetric(
                      horizontal: 100, vertical: 12),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: black,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    "Done",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  )),
            ),
          ],
        ),
      ),
    );
  }

  Widget pinWidget() {
    return Container(
      alignment: Alignment.center,
      height: 50,
      width: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5.0),
        color: const Color(0XFFF2F2F2),
      ),
      child: TextField(
        maxLength: 1,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 20,
        ),
        decoration: InputDecoration(
          counterText: "",
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: BorderSide(
                color: Colors.grey.withOpacity(0.2),
              )),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: const BorderSide(
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
