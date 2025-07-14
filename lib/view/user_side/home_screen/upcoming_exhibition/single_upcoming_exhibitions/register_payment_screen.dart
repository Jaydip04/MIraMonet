import 'dart:convert';

import 'package:artist/config/toast.dart';
import 'package:artist/view/user_side/home_screen/ticket/ticket_screen.dart';
import 'package:artist/view/user_side/profile_screen/profile_screens/my_ticket_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../../config/colors.dart';
import '../../../../../core/api_service/api_service.dart';
import '../../../../../core/utils/app_font_weight.dart';
import '../../../../../core/utils/responsive.dart';
import '../../../../../core/widgets/custom_text_2.dart';
import '../../../../../core/widgets/general_button.dart';
import 'package:http/http.dart' as http;

import '../../../../../keys.dart';

class RegisterPaymentScreen extends StatefulWidget {
  final Map<String, dynamic> response;
  const RegisterPaymentScreen({Key? key, required this.response})
      : super(key: key);

  @override
  State<RegisterPaymentScreen> createState() => _RegisterPaymentScreenState();
}

class _RegisterPaymentScreenState extends State<RegisterPaymentScreen> {
  @override
  void initState() {
    print("Status: ${widget.response['status']}");
    print("Message: ${widget.response['message']}");
    print("Is Paid: ${widget.response['isPaid']}");
    print("Amount: ${widget.response['amount']}");
    print("name: ${widget.response['exhibition_data']["name"]}");
    print("start_date: ${widget.response['exhibition_data']["start_date"]}");
    print("end_date: ${widget.response['exhibition_data']["end_date"]}");
    print("logo: ${widget.response['exhibition_data']["logo"]}");
    print("registration_code: ${widget.response['registration_code']}");
    super.initState();
  }

  final ApiService apiService = ApiService();
  bool isLoading = false;
  bool isCancel = false;

  Future<void> registerForExhibitionFree(BuildContext context) async {
    setState(() {
      isLoading = true;
    });
    final response = await apiService.registerForExhibitionForFree(
        widget.response['registration_code'].toString());

    if (response != null) {
      setState(() {
        isLoading = false;
      });
      if (response['status'] == 'true') {
        setState(() {
          isLoading = false;
        });
        showToast(message: response['message']);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                TicketScreen(exhibitionData: response['data']),
          ),
        );
      } else {
        setState(() {
          isLoading = false;
        });
        showToast(message: response['message']);
      }
    } else {
      setState(() {
        isLoading = false;
      });
      showToast(message: "Registration failed. Please try again.");
    }
  }

  Future<void> registerForExhibitionPaid(
      BuildContext context, String payment_id) async {
    setState(() {
      isLoading = true;
    });
    print(
        "registration_code : ${widget.response['registration_code'].toString()}");
    print("payment_id : ${payment_id.toString()}");
    print("amount : ${widget.response['amount'].toString()}");
    final response = await apiService.registerForExhibitionForPaid(
        widget.response['registration_code'].toString(),
        payment_id.toString(),
        widget.response['amount'].toString());

    if (response != null) {
      setState(() {
        isLoading = false;
      });
      if (response['status'] == "true") {
        setState(() {
          isLoading = false;
        });
        showToast(message: response['message']);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                TicketScreen(exhibitionData: response['data']),
          ),
        );
      } else {
        setState(() {
          isLoading = false;
        });
        showToast(message: response['message']);
      }
    } else {
      setState(() {
        isLoading = false;
      });
      showToast(message: "Registration failed. Please try again.");
    }
  }

  Future<void> CancelForExhibition(BuildContext context) async {
    setState(() {
      isCancel = true;
    });
    final response = await apiService
        .cancelForExhibition(widget.response['registration_code'].toString());

    if (response != null) {
      setState(() {
        isCancel = false;
      });
      if (response['status'] == 'true') {
        setState(() {
          isCancel = false;
        });
        showToast(message: response['message']);
        Navigator.pushNamedAndRemoveUntil(
          context,
          "/User",
          (route) => false,
        );
      } else {
        setState(() {
          isCancel = false;
        });
        showToast(message: response['message']);
      }
    } else {
      setState(() {
        isCancel = false;
      });
      showToast(message: "Cancel failed. Please try again.");
    }
  }

  @override
  void dispose() {
    // CancelForExhibition(context);
    super.dispose();
  }

  double amount = 20;
  Map<Stripe, dynamic>? intentPaymentData;
  late String paymentIntentId;
  late String payment_Id;

  Future<void> showPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet().then((onValue) async {
        // paymentIntentId = null;
        print(onValue);

        registerForExhibitionPaid(context, paymentIntentId.toString());
        // ApiService().verifyProfile(
        //   payment_id: payment_Id.toString(),
        //   id: _idController.text.toString(),
        //   frontPhotoFile: _frontPhotoController.text.toString(),
        //   backPhotoFile: _backPhotoController.text.toString(),
        //   ein: _einController.text.toString(),
        //   address: _addressController.text.toString(),
        //   selectedPlanAmount: selectedAmount.toString(),
        //   selectedPlanDuration: selectedDuration.toString(),
        // );
        showToast(
          message: "Payment is Success.",
        );
        setState(() {
          isLoading = false;
        });
      }).onError((errorMsg, sTrace) {
        if (kDebugMode) {
          setState(() {
            isLoading = false;
          });
          showToast(
            message: "Payment is Failed.",
          );
          // Navigator.pushReplacement(
          //   context,
          //   MaterialPageRoute(builder: (context) => OrderFailedScreen()),
          // );
          print(errorMsg.toString() + sTrace.toString());
        }
      });
    } on StripeException catch (error) {
      setState(() {
        isLoading = false;
      });
      if (kDebugMode) {
        setState(() {
          isLoading = false;
        });
        print(error);
      }
      showDialog(
          context: context,
          builder: (c) => AlertDialog(
                content: Text("Cancelled"),
              ));
    } catch (errorMsg) {
      setState(() {
        isLoading = false;
      });
      if (kDebugMode) {
        setState(() {
          isLoading = false;
        });
        print(errorMsg);
      }
      print(errorMsg.toString());
    }
  }

  Future<Map<String, dynamic>?> makeIntentForPayment(
      String amountToBeCharge, String currency) async {
    try {
      Map<String, dynamic> paymentInfo = {
        "amount": (int.parse(amountToBeCharge) * 100).toString(),
        "currency": currency,
        "payment_method_types[]": "card",
      };

      var responseFromStripeAPI = await http.post(
        Uri.parse("https://api.stripe.com/v1/payment_intents"),
        body: paymentInfo,
        headers: {
          "Authorization": "Bearer ${StripeKeys.secretKey}",
          "Content-Type": "application/x-www-form-urlencoded"
        },
      );

      if (responseFromStripeAPI.statusCode != 200) {
        setState(() {
          isLoading = false;
        });
        throw Exception('Failed to create payment intent');
      }

      if (kDebugMode) {
        setState(() {
          isLoading = false;
        });
        print("Response from API: ${responseFromStripeAPI.body}");
      }

      Map<String, dynamic> responseBody =
          jsonDecode(responseFromStripeAPI.body) as Map<String, dynamic>;

      setState(() {
        payment_Id = responseBody["id"].toString();
        paymentIntentId = responseBody["id"].toString();
        // paymentIntentId = responseBody["client_secret"].toString();
      });

      print("Payment Intent ID: $paymentIntentId");
      print("Payment ID: $payment_Id");

      return responseBody;
    } catch (errorMsg) {
      setState(() {
        isLoading = false;
      });
      if (kDebugMode) {
        setState(() {
          isLoading = false;
        });
        print(errorMsg);
      }
      return null;
    }
  }

  Future<void> paymentSheetInitialization(
      String amountToBeCharge, String currency) async {
    setState(() {
      isLoading = true;
    });
    try {
      // Fetch payment intent data from the backend
      final intentPaymentData =
          await makeIntentForPayment(amountToBeCharge, currency);

      if (intentPaymentData == null) {
        setState(() {
          isLoading = false;
        });
        showToast(message: "Failed to process payment. Please try again.");
        throw Exception("Failed to create payment intent");
      }

      // Initialize the payment sheet
      try {
        await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            allowsDelayedPaymentMethods: true,
            paymentIntentClientSecret: intentPaymentData["client_secret"],
            style: ThemeMode.dark,
            merchantDisplayName: "Mira Monet",
          ),
        );
        // Proceed with presenting the payment sheet
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        print("Error initializing payment sheet: $e");
        // Handle error accordingly
      }

      await showPaymentSheet();
    } catch (errorMsg, s) {
      setState(() {
        isLoading = false;
      });
      if (kDebugMode) {
        setState(() {
          isLoading = false;
        });
        print(s);
      }
      print(errorMsg.toString());
    }
  }

  String convertDate(String inputDate) {
    DateTime date = DateTime.parse(inputDate);
    DateTime newDate = DateTime(date.year - 1, date.month - 1, date.day);
    return DateFormat("dd MMM yyyy").format(newDate);
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        backgroundColor: whiteBack,
        body: SafeArea(
          child: Container(
            height: Responsive.getMainHeight(context),
            width: Responsive.getMainWidth(context),
            padding: EdgeInsets.symmetric(horizontal: Responsive.getWidth(16)),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    WantText2(
                        text: "Register",
                        fontSize: Responsive.getFontSize(18),
                        fontWeight: AppFontWeight.medium,
                        textColor: textBlack)
                  ],
                ),
                SizedBox(
                  height: Responsive.getHeight(15),
                ),
                Container(
                  width: Responsive.getWidth(336),
                  padding: EdgeInsets.all(Responsive.getWidth(8)),
                  decoration: BoxDecoration(
                    // boxShadow: [
                    //   BoxShadow(
                    //       color: Color.fromRGBO(0, 0, 0, 0.1),
                    //       blurRadius: 20,
                    //       spreadRadius: 0,
                    //       offset: Offset(0, 5))
                    // ],
                    color: whiteBack,
                    borderRadius:
                        BorderRadius.circular(Responsive.getWidth(15)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        child: Image.network(
                          fit: BoxFit.contain,
                          widget.response['exhibition_data']["logo"],
                          width: Responsive.getWidth(129),
                          height: Responsive.getHeight(129),
                        ),
                        borderRadius:
                            BorderRadius.circular(Responsive.getWidth(10)),
                      ),
                      SizedBox(
                        width: Responsive.getWidth(5),
                      ),
                      Container(
                        width: Responsive.getWidth(180),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            WantText2(
                              text: widget.response['exhibition_data']["name"],
                              fontSize: Responsive.getFontSize(16),
                              fontWeight: AppFontWeight.medium,
                              textColor: textBlack6,
                              textOverflow: TextOverflow.ellipsis,
                            ),
                            WantText2(
                              text:
                                  "Start Date : ${convertDate(widget.response['exhibition_data']["start_date"])}",
                              fontSize: Responsive.getFontSize(14),
                              fontWeight: AppFontWeight.regular,
                              textColor: textGray6,
                              textOverflow: TextOverflow.ellipsis,
                            ),
                            WantText2(
                              text:
                                  "End Date : ${convertDate(widget.response['exhibition_data']["end_date"])}",
                              fontSize: Responsive.getFontSize(14),
                              fontWeight: AppFontWeight.regular,
                              textColor: textGray6,
                              textOverflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(height: Responsive.getHeight(20)),
                Spacer(),
                Container(
                  // width: Responsive.getWidth(336),
                  // decoration: BoxDecoration(
                  //   boxShadow: [
                  //     BoxShadow(
                  //         color: Color.fromRGBO(0, 0, 0, 0.1),
                  //         blurRadius: 20,
                  //         spreadRadius: 0,
                  //         offset: Offset(0, 5))
                  //   ],
                  //   color: whiteBack,
                  //   borderRadius:
                  //       BorderRadius.circular(Responsive.getWidth(20)),
                  // ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: Responsive.getHeight(20),
                      ),
                      Divider(
                        color: Color.fromRGBO(236, 236, 236, 1),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: Responsive.getWidth(22),
                          // vertical: Responsive.getHeight(16)
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                WantText2(
                                    text: "Amount",
                                    fontSize: Responsive.getFontSize(17),
                                    fontWeight: AppFontWeight.medium,
                                    textColor: textBlack),
                                WantText2(
                                    text: widget.response['amount'] == "0"
                                        ? "Free"
                                        : "\$${widget.response['amount']}",
                                    fontSize: Responsive.getFontSize(17),
                                    fontWeight: AppFontWeight.medium,
                                    textColor: textBlack),
                              ],
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(height: Responsive.getHeight(30)),
                Center(
                    child: GestureDetector(
                  onTap: () {
                    if (widget.response['isPaid'] == 0) {
                      print("${widget.response['registration_code']}");
                      registerForExhibitionFree(context);
                    } else {
                      // ApiService().registerForExhibition(widget.response['registration_code'].toString(),widget.response['amount'].toString());
                      paymentSheetInitialization(
                         widget.response['amount'].toString(),
                          "USD");
                    }
                  },
                  child: Container(
                    height: Responsive.getHeight(50),
                    width: Responsive.getWidth(335),
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
                                    "REGISTER",
                                    style: GoogleFonts.poppins(
                                      textStyle: TextStyle(
                                        letterSpacing: 1.5,
                                        fontSize: Responsive.getFontSize(16),
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )),
                SizedBox(
                  height: Responsive.getHeight(16),
                ),
                Center(
                    child: GestureDetector(
                  onTap: () {
                    CancelForExhibition(context);
                  },
                  child: Container(
                    height: Responsive.getHeight(50),
                    width: Responsive.getWidth(335),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        // color: black,
                        borderRadius:
                            BorderRadius.circular(Responsive.getWidth(8)),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            isCancel
                                ? Center(
                                    child: SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 3,
                                        color: Colors.black,
                                      ),
                                    ),
                                  )
                                : Text(
                                    "CANCEL",
                                    style: GoogleFonts.poppins(
                                      textStyle: TextStyle(
                                        letterSpacing: 1.5,
                                        fontSize: Responsive.getFontSize(16),
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )),
                SizedBox(
                  height: Responsive.getHeight(16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void showCongratulationsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Congratulations();
      },
    );
  }
}

class Congratulations extends StatefulWidget {
  @override
  _CongratulationsState createState() => _CongratulationsState();
}

class _CongratulationsState extends State<Congratulations> {
  final TextEditingController _pinController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return Dialog(
      backgroundColor: whiteBack,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: EdgeInsets.symmetric(horizontal: Responsive.getWidth(14)),
      child: Container(
        margin: EdgeInsets.all(0),
        // height: Responsive.getHeight(422),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: Responsive.getWidth(11),
                vertical: Responsive.getHeight(11)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  "assets/check.png",
                  height: Responsive.getWidth(78),
                  width: Responsive.getWidth(78),
                ),
                SizedBox(height: Responsive.getHeight(12)),
                WantText2(
                    text: "Successfully Order",
                    fontSize: Responsive.getFontSize(20),
                    fontWeight: AppFontWeight.semiBold,
                    textColor: textBlack),
                SizedBox(height: Responsive.getHeight(8)),
                WantText2(
                    text: "Your Art has been\nSuccessfully Order .",
                    fontSize: Responsive.getFontSize(16),
                    fontWeight: AppFontWeight.regular,
                    textColor: Color.fromRGBO(128, 128, 128, 1)),
                SizedBox(height: Responsive.getHeight(24)),
                Center(
                  child: GeneralButton(
                    Width: Responsive.getWidth(293),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/User/Cart/SelectAddressScreen/OrderConfirmationPage',
                      );
                      // Navigator.pop(context);
                    },
                    label: "Thanks",
                    isBoarderRadiusLess: true,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
