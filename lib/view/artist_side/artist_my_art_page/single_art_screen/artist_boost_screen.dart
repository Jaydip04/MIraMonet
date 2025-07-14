import 'dart:convert';

import 'package:artist/config/colors.dart';
import 'package:artist/core/api_service/api_service.dart';
import 'package:artist/core/utils/responsive.dart';
import 'package:artist/core/widgets/general_button.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../config/toast.dart';
import '../../../../core/utils/app_font_weight.dart';
import '../../../../core/widgets/custom_text_2.dart';
import '../../../../keys.dart';
import 'package:http/http.dart' as http;

import '../../artist_side_bottom_nav_bar.dart';

class ArtistBoostScreen extends StatefulWidget {
  final art_unique_id;
  const ArtistBoostScreen({super.key, required this.art_unique_id});

  @override
  State<ArtistBoostScreen> createState() => _ArtistBoostScreenState();
}

class _ArtistBoostScreenState extends State<ArtistBoostScreen> {
  List<dynamic> ads = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    print("art_unique_id : ${widget.art_unique_id}");
    super.initState();
    _loadUserData();
    fetchAds();
  }

  String? customerUniqueID;
  void _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String customerUniqueId = (prefs.get('customerUniqueId') is String)
        ? prefs.getString('customerUniqueId') ?? ''
        : prefs.getInt('customerUniqueId')?.toString() ?? '';

    print(customerUniqueId.toString());
    setState(() {
      customerUniqueID = customerUniqueId;
    });
  }

  Future<void> fetchAds() async {
    try {
      final response = await ApiService().getAds();
      setState(() {
        ads = response['ads'];
        ads_id = ads[0]['ads_id'].toString();
        selectedPlan = ads[0]['plan_name'].toString();
        selectedPrice = ads[0]['price'].toString();
        selectedDays = ads[0]['days'].toString();
        selectedViews = ads[0]['views'].toString();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  String convertDaysToMonths(int days) {
    if (days < 30) {
      return "$days days";
    } else {
      double months = days / 30;
      int wholeMonths = days ~/ 30;
      int remainingDays = days % 30;

      if (remainingDays == 0) {
        return wholeMonths == 1 ? "$wholeMonths month" : "$wholeMonths months";
      } else {
        return wholeMonths == 1
            ? "$wholeMonths month $remainingDays days"
            : "$wholeMonths months $remainingDays days";
      }
    }
  }

  double amount = 20;
  Map<Stripe, dynamic>? intentPaymentData;
  late String paymentIntentId;
  late String payment_Id;

  late String days;
  late String views;
  late String price;

  Future<void> showPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet().then((onValue) async {
        // paymentIntentId = null;
        print(onValue);

        ApiService()
            .boostSuccessApp(
                paymentId: paymentIntentId.toString(),
                days: days.toString(),
                artUniqueId: widget.art_unique_id.toString(),
                price: price.toString(),
                views: views.toString(),
                customerUniqueId: customerUniqueID.toString())
            .then((onValue) {
          showToast(
            message: "Add Boost",
          );
          // Navigator.pop(context);
          setState(() {
            isClick = false;
          });
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => ArtistSideBottomNavBar(index: 1)),
            (route) => false,
          );
          // Navigator.pushNamedAndRemoveUntil(context, "/Artist/ArtistMyArtScreen", (route) => false,);
        });
        showToast(
          message: "Payment is Success.",
        );
      }).onError((errorMsg, sTrace) {
        setState(() {
          isClick = false;
        });
        if (kDebugMode) {
          setState(() {
            isClick = false;
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
        isClick = false;
      });
      if (kDebugMode) {
        setState(() {
          isClick = false;
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
        isClick = false;
      });
      if (kDebugMode) {
        setState(() {
          isClick = false;
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
        throw Exception('Failed to create payment intent');
      }

      if (kDebugMode) {
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
      if (kDebugMode) {
        print(errorMsg);
      }
      return null;
    }
  }

  Future<void> paymentSheetInitialization(
      String amountToBeCharge, String currency) async {
    setState(() {
      isClick = true;
    });
    try {
      // Fetch payment intent data from the backend
      final intentPaymentData =
          await makeIntentForPayment(amountToBeCharge, currency);

      if (intentPaymentData == null) {
        setState(() {
          isClick = false;
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
          isClick = false;
        });
        print("Error initializing payment sheet: $e");
        // Handle error accordingly
      }

      await showPaymentSheet();
    } catch (errorMsg, s) {
      setState(() {
        isClick = false;
      });
      if (kDebugMode) {
        setState(() {
          isClick = false;
        });
        print(s);
      }
      print(errorMsg.toString());
    }
  }

  String? selectedPlan;
  String? ads_id;
  String? selectedPrice;
  String? selectedDays;
  String? selectedViews;

  bool isClick = false;
  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return Scaffold(
      backgroundColor: white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: Responsive.getWidth(16)),
          child: isLoading
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
              : hasError
                  ? Center(child: Text('Failed to load ads'))
                  : ListView(
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                width: Responsive.getWidth(41),
                                height: Responsive.getHeight(41),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(
                                        Responsive.getWidth(12)),
                                    border: Border.all(
                                        color: textFieldBorderColor,
                                        width: 1.0)),
                                child: Icon(
                                  Icons.arrow_back_ios_new_outlined,
                                  size: Responsive.getWidth(19),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: Responsive.getWidth(80),
                            ),
                            WantText2(
                                text: "Boost Project",
                                fontSize: Responsive.getFontSize(18),
                                fontWeight: AppFontWeight.medium,
                                textColor: textBlack)
                          ],
                        ),
                        SizedBox(
                          height: Responsive.getHeight(14),
                        ),
                        ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: ads.length,
                          itemBuilder: (context, index) {
                            final ad = ads[index];
                            String result = convertDaysToMonths(ad['days']);
                            return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    ads_id = ad['ads_id'].toString();
                                    selectedPlan = ad['plan_name'];
                                    selectedPrice = ad['price'].toString();
                                    selectedDays = ad['days'].toString();
                                    selectedViews = ad['views'].toString();
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8.0),
                                    border: Border.all(
                                      color: ads_id == ad['ads_id'].toString()
                                          ? Color.fromRGBO(224, 224, 224, 1.0)
                                          : Color.fromRGBO(234, 236, 240, 1.0),
                                      width: 1.5,
                                    ),
                                  ),
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  // padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: Responsive.getWidth(16),
                                            vertical: Responsive.getHeight(16)),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    ClipRRect(
                                                      child: Image.network(
                                                        ad['plan_image'],
                                                        fit: BoxFit.cover,
                                                        height:
                                                            Responsive.getWidth(
                                                                28),
                                                        width:
                                                            Responsive.getWidth(
                                                                28),
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              30),
                                                    ),
                                                    SizedBox(
                                                      width:
                                                          Responsive.getWidth(
                                                              16),
                                                    ),
                                                    WantText2(
                                                        text: ad['plan_name'],
                                                        fontSize: Responsive
                                                            .getFontSize(16),
                                                        fontWeight:
                                                            AppFontWeight
                                                                .medium,
                                                        textColor: black)
                                                  ],
                                                ),
                                              ],
                                            ),
                                            ads_id == ad['ads_id'].toString()
                                                ? Icon(Icons.check_circle)
                                                : Icon(
                                                    Icons
                                                        .radio_button_unchecked,
                                                    color: Color.fromRGBO(
                                                        208, 213, 221, 1.0),
                                                  )
                                          ],
                                        ),
                                      ),
                                      Divider(
                                        color:
                                            Color.fromRGBO(224, 224, 224, 1.0),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: Responsive.getWidth(16),
                                            vertical: Responsive.getHeight(16)),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                WantText2(
                                                    text: "\$${ad['price']}",
                                                    fontSize:
                                                        Responsive.getFontSize(
                                                            30),
                                                    fontWeight:
                                                        AppFontWeight.semiBold,
                                                    textColor: Color.fromRGBO(
                                                        52, 64, 84, 1.0)),
                                                SizedBox(
                                                  width: Responsive.getWidth(4),
                                                ),
                                                WantText2(
                                                    text: "/$result",
                                                    fontSize:
                                                        Responsive.getFontSize(
                                                            14),
                                                    fontWeight:
                                                        AppFontWeight.regular,
                                                    textColor: Color.fromRGBO(
                                                        102, 112, 133, 1.0))
                                              ],
                                            ),
                                            WantText2(
                                                text: "${ad['views']} View",
                                                fontSize:
                                                    Responsive.getFontSize(14),
                                                fontWeight:
                                                    AppFontWeight.regular,
                                                textColor: Color.fromRGBO(
                                                    102, 112, 133, 1.0))
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ));
                          },
                        ),
                        SizedBox(
                          height: Responsive.getHeight(20),
                        ),
                        Center(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                price = selectedPrice!;
                                views = selectedViews!;
                                days = selectedDays!;
                              });

                              paymentSheetInitialization(
                                  selectedPrice.toString(), "USD");
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
                                        "Pay \$$selectedPrice",
                                        style: GoogleFonts.poppins(
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
                      ],
                    ),
        ),
      ),
    );
  }
}
// Container(
//   margin:
//       const EdgeInsets.symmetric(vertical: 8.0),
//   padding: const EdgeInsets.all(16.0),
//   decoration: BoxDecoration(
//     color: Colors.white,
//     borderRadius: BorderRadius.circular(8.0),
//     border: Border.all(
//       color: selectedPlan == ad['plan_name']
//           ? Colors.blue
//           : Colors.grey[300]!,
//       width: 1.5,
//     ),
//   ),
//   child: Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       Row(
//         mainAxisAlignment:
//             MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             "${ad['plan_name']}",
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.w600,
//               color: Colors.black,
//             ),
//           ),
//           Text(
//             "\$${ad['price']} per month",
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//               color: Colors.black,
//             ),
//           ),
//         ],
//       ),
//       SizedBox(height: 8.0),
//       Text(
//         "Monthly ${ad['views']} Views",
//         style: TextStyle(
//           fontSize: 14,
//           color: Colors.grey[600],
//         ),
//       ),
//     ],
//   ),
// ),
// ListView.builder(
//   physics: NeverScrollableScrollPhysics(),
//   shrinkWrap: true,
//   itemCount: ads.length,
//   itemBuilder: (context, index) {
//     final ad = ads[index];
//     String result = convertDaysToMonths(ad['days']);
//     return Container(
//       margin: EdgeInsets.symmetric(
//           vertical: Responsive.getHeight(11)),
//       width: Responsive.getWidth(330),
//       padding: EdgeInsets.symmetric(
//           horizontal: Responsive.getWidth(22),
//           vertical: Responsive.getHeight(22)),
//       decoration: BoxDecoration(
//           color: white,
//           boxShadow: [
//             BoxShadow(
//               color: Color.fromRGBO(0, 0, 0, 0.04),
//               spreadRadius: 0,
//               offset: Offset(0, 0),
//               blurRadius: 18,
//             )
//           ],
//           borderRadius: BorderRadius.circular(
//               Responsive.getWidth(4)),
//           border: Border.all(
//               color: Color.fromRGBO(241, 241, 241, 1),
//               width: 1)),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         mainAxisAlignment:
//             MainAxisAlignment.spaceEvenly,
//         children: [
//           Row(
//             mainAxisAlignment:
//                 MainAxisAlignment.spaceBetween,
//             children: [
//               WantText2(
//                   text: "Basic (${ad['views']} View)",
//                   fontSize: Responsive.getFontSize(16),
//                   fontWeight: AppFontWeight.medium,
//                   textColor:
//                       Color.fromRGBO(33, 37, 41, 1)),
//               Row(
//                 children: [
//                   WantText2(
//                       text: "\$${ad['price']}",
//                       fontSize:
//                           Responsive.getFontSize(20),
//                       fontWeight: AppFontWeight.bold,
//                       textColor: Color.fromRGBO(
//                           33, 37, 41, 1)),
//                   WantText2(
//                       text: "/$result",
//                       fontSize:
//                           Responsive.getFontSize(14),
//                       fontWeight: AppFontWeight.regular,
//                       textColor: Color.fromRGBO(
//                           33, 37, 41, 1)),
//                 ],
//               )
//             ],
//           ),
//           SizedBox(
//             height: Responsive.getHeight(5),
//           ),
//           Divider(),
//           SizedBox(
//             height: Responsive.getHeight(10),
//           ),
//           GeneralButton(
//             Width: Responsive.getWidth(285),
//             onTap: () {
//               setState(() {
//                 price = ad['price'].toString();
//                 views = ad['views'].toString();
//                 days = ad['days'].toString();
//               });
//               paymentSheetInitialization(
//                   int.parse(ad['price'].toString())
//                       .round()
//                       .toString(),
//                   "USD");
//             },
//             label: "Choose plan",
//             isBoarderRadiusLess: true,
//           )
//         ],
//       ),
//     );
//   },
// )
