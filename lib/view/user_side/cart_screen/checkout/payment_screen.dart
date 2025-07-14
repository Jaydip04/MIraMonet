import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../config/colors.dart';
import '../../../../config/toast.dart';
import '../../../../core/api_service/api_service.dart';
import '../../../../core/models/user_side/cart_model.dart';
import '../../../../core/utils/app_font_weight.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/custom_text_2.dart';
import '../../../../core/widgets/general_button.dart';
import '../../../../keys.dart';
import 'package:http/http.dart' as http;

class PaymentScreen extends StatefulWidget {
  final String deliveryAddressId;
  const PaymentScreen({super.key, required this.deliveryAddressId});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late Future<CartModel> futureArtResponse;
  @override
  void initState() {
    _loadUserData();
    print('Delivery Address ID: ${widget.deliveryAddressId}');
    futureArtResponse = ApiService().fetchCartData(customerUniqueID.toString());
    print("FCM Token$fcmTokenList");
    super.initState();
  }

  @override
  void dispose() {
    _loadUserData();
    onOrderSuccess();
    super.dispose();
  }

  String? customerUniqueID;
  void _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String customerUniqueId = (prefs.get('customerUniqueId') is String)
        ? prefs.getString('customerUniqueId') ?? ''
        : prefs.getInt('customerUniqueId')?.toString() ?? '';

    setState(() {
      customerUniqueID = customerUniqueId;
      futureArtResponse =
          ApiService().fetchCartData(customerUniqueID.toString());
    });
  }

  List<int> outOfStockArtCartIds = [];
  bool isLoading = false;
  void _goToCheckout() async {
    setState(() {
      isLoading = true;
    });
    try {
      final result =
          await ApiService().checkQuantity(customerUniqueID.toString());
      if (result['status']) {
        setState(() {
          isLoading = false;
        });
          paymentSheetInitialization(
            total.toString(), "USD");
        showToast(message: "Stock available");
      } else {
        setState(() {
          isLoading = false;
        });
        showToast(message: "Out Of Stock Product\n Please Remove It From Cart");
        for (var product in result['out_of_stock_products']) {
          outOfStockArtCartIds.add(product['art_cart_id']);
        }
        setState(() {
          outOfStockArtCartIds = outOfStockArtCartIds;
        });
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      print('Failed to check quantity: $error');
    }
  }

  double amount = 20;
  Map<Stripe, dynamic>? intentPaymentData;
  late String paymentIntentId;
  late String payment_Id;

  Future<void> showPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet().then((onValue) async {
        print(onValue);

        ApiService()
            .callOrderSuccessApi(paymentIntentId.toString(), total.toString(),
                widget.deliveryAddressId.toString(), fcmTokenList)
            .then((onValue) {
          showCongratulationsDialog(context);
          onOrderSuccess();
        });

        showToast(
          message: "Payment is Success.",
        );
        setState(() {
          isLoading = false;
        });
      }).onError((errorMsg, sTrace) {
        setState(() {
          isLoading = false;
        });
        if (kDebugMode) {
          setState(() {
            isLoading = false;
          });
          onOrderSuccess();
          showToast(
            message: "Payment is Failed.",
          );

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
      final intentPaymentData =
          await makeIntentForPayment(amountToBeCharge, currency);

      if (intentPaymentData == null) {
        setState(() {
          isLoading = false;
        });
        showToast(message: "Failed to process payment. Please try again.");
        throw Exception("Failed to create payment intent");
      }

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

  late String total;
  late String FCMToken;
  List<String> fcmTokenList = [];

  void onOrderSuccess() {
    fcmTokenList.clear();

    print("FCM Token list cleared: $fcmTokenList");
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return Scaffold(
      backgroundColor: whiteBack,
      body: SafeArea(
        child: Container(
          height: Responsive.getMainHeight(context),
          width: Responsive.getMainWidth(context),
          padding: EdgeInsets.symmetric(horizontal: Responsive.getWidth(16)),
          child: Column(
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
                          borderRadius:
                              BorderRadius.circular(Responsive.getWidth(12)),
                          border: Border.all(
                              color: textFieldBorderColor, width: 1.0)),
                      child: Icon(
                        Icons.arrow_back_ios_new_outlined,
                        size: Responsive.getWidth(19),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: Responsive.getWidth(90),
                  ),
                  WantText2(
                      text: "Review",
                      fontSize: Responsive.getFontSize(18),
                      fontWeight: AppFontWeight.medium,
                      textColor: textBlack)
                ],
              ),
              SizedBox(height: Responsive.getHeight(10)),
              FutureBuilder<CartModel>(
                future: futureArtResponse,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: Colors.black,
                        ),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Container(
                      width: Responsive.getMainWidth(context),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            "assets/bottom_navigation_bar_icon/cart_grey.png",
                            width: Responsive.getWidth(64),
                            height: Responsive.getWidth(64),
                          ),
                          SizedBox(
                            height: Responsive.getHeight(24),
                          ),
                          WantText2(
                              text: "No Cart Item!",
                              fontSize: Responsive.getFontSize(20),
                              fontWeight: AppFontWeight.semiBold,
                              textColor: textGray17),
                        ],
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.data.isEmpty) {
                    return Container(
                      height: Responsive.getHeight(600),
                      width: Responsive.getMainWidth(context),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            "assets/bottom_navigation_bar_icon/cart_grey.png",
                            width: Responsive.getWidth(64),
                            height: Responsive.getWidth(64),
                          ),
                          SizedBox(
                            height: Responsive.getHeight(24),
                          ),
                          WantText2(
                              text: "No Cart Item!",
                              fontSize: Responsive.getFontSize(20),
                              fontWeight: AppFontWeight.semiBold,
                              textColor: textGray17),
                        ],
                      ),
                    );
                  } else {
                    return Container(
                      // height: Responsive.getHeight(700),
                      child: Column(
                        children: [
                          Container(
                            height: Responsive.getHeight(500),
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: snapshot.data!.data.length,
                              itemBuilder: (context, index) {
                                final art = snapshot.data!.data[index];
                                print(art.artist_fcm_token);
                                // if (art.artist_fcm_token != null
                                //     // && !fcmTokenList.contains(art.artist_fcm_token)
                                // ) {
                                //   fcmTokenList.add("${art.artist_fcm_token}");
                                // }
                                if (art.artist_fcm_token != null
                                    && !fcmTokenList.contains(art.artist_fcm_token)
                                    ) {
                                  fcmTokenList.add(art.artist_fcm_token);
                                }
                                print("FCM Token List : $fcmTokenList");
                                bool isOutOfStock = outOfStockArtCartIds
                                    .contains(art.artCartId);
                                return Column(
                                  children: [
                                    Container(
                                      // width: Responsive.getWidth(336),
                                      margin: EdgeInsets.symmetric(vertical: 5),
                                      // padding: EdgeInsets.all(/
                                      decoration: BoxDecoration(
                                        // boxShadow: [
                                        //   BoxShadow(
                                        //       color: Color.fromRGBO(0, 0, 0, 0.1),
                                        //       blurRadius: 20,
                                        //       spreadRadius: 0,
                                        //       offset: Offset(0, 5))
                                        // ],
                                        color: whiteBack,
                                        border: Border.all(
                                            width: 1,
                                            color: isOutOfStock
                                                ? Colors.red
                                                : Colors.transparent),
                                        borderRadius: BorderRadius.circular(
                                            Responsive.getWidth(15)),
                                      ),
                                      child: Row(
                                        children: [
                                          ClipRRect(
                                            child: Image.network(
                                              art.artImages.first.image,
                                              width: 75,
                                              height: 80,
                                              fit: BoxFit.contain,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                                Responsive.getWidth(10)),
                                          ),
                                          SizedBox(
                                            width: Responsive.getWidth(17),
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                child: WantText2(
                                                  text: art.title,
                                                  fontSize:
                                                      Responsive.getFontSize(16),
                                                  fontWeight:
                                                      AppFontWeight.medium,
                                                  textColor: textBlack6,
                                                  textOverflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                width: Responsive.getWidth(250),
                                              ),
                                              WantText2(
                                                text: art.artistName,
                                                fontSize:
                                                    Responsive.getFontSize(16),
                                                fontWeight:
                                                    AppFontWeight.regular,
                                                textColor: textGray6,
                                                textOverflow:
                                                    TextOverflow.ellipsis,
                                              ),
                                              WantText2(
                                                text: '\$${art.price}',
                                                fontSize:
                                                    Responsive.getFontSize(16),
                                                fontWeight:
                                                    AppFontWeight.regular,
                                                textColor: textGray6,
                                                textOverflow:
                                                    TextOverflow.ellipsis,
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                    Divider(
                                      color: Color.fromRGBO(238, 238, 238, 1),
                                    )
                                  ],
                                );
                              },
                            ),
                          ),
                          SizedBox(
                            height: Responsive.getHeight(20),
                          ),
                          Divider(
                            color: Color.fromRGBO(236, 236, 236, 1),
                          ),
                          Column(
                            children: [
                              Container(
                                // width: Responsive.getWidth(336),
                                decoration: BoxDecoration(
                                  // boxShadow: [
                                  //   BoxShadow(
                                  //       color: Color.fromRGBO(0, 0, 0, 0.1),
                                  //       blurRadius: 20,
                                  //       spreadRadius: 0,
                                  //       offset: Offset(0, 5))
                                  // ],
                                  color: whiteBack,
                                  borderRadius: BorderRadius.circular(
                                      Responsive.getWidth(20)),
                                ),
                                child: Column(
                                  children: [
                                    // Padding(
                                    //   padding: EdgeInsets.symmetric(
                                    //       horizontal: Responsive.getWidth(22),
                                    //       vertical: Responsive.getHeight(16)),
                                    //   child: Column(
                                    //     children: [
                                    //       Row(
                                    //         mainAxisAlignment:
                                    //             MainAxisAlignment.spaceBetween,
                                    //         children: [
                                    //           WantText2(
                                    //               text: "Total",
                                    //               fontSize:
                                    //                   Responsive.getFontSize(
                                    //                       17),
                                    //               fontWeight:
                                    //                   AppFontWeight.medium,
                                    //               textColor: textBlack),
                                    //           WantText2(
                                    //               text:
                                    //                   "\$${snapshot.data!.payableamout.toString()}",
                                    //               fontSize:
                                    //                   Responsive.getFontSize(
                                    //                       17),
                                    //               fontWeight:
                                    //                   AppFontWeight.medium,
                                    //               textColor: textBlack),
                                    //         ],
                                    //       ),
                                    //     ],
                                    //   ),
                                    // )
                                    Column(
                                      children: [
                                        // Image.asset("assets/line.png",),
                                        // SizedBox(height: Responsive.getHeight(24),),
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                          children: [
                                            WantText2(
                                              text: "Art price",
                                              fontSize: Responsive.getFontSize(16),
                                              fontWeight: AppFontWeight.regular,
                                              textColor: textBlack11,
                                            ),
                                            WantText2(
                                              text:
                                              "\$${snapshot.data!.total.toString()}",
                                              fontSize: Responsive.getFontSize(16),
                                              fontWeight: AppFontWeight.bold,
                                              textColor: textBlack14,
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                          children: [
                                            WantText2(
                                              text: "Tax (${snapshot.data!.tax_per.toString()}%)",
                                              fontSize: Responsive.getFontSize(16),
                                              fontWeight: AppFontWeight.regular,
                                              textColor: textBlack11,
                                            ),
                                            WantText2(
                                              text:
                                              "\$${snapshot.data!.totalTax.toString()}",
                                              fontSize: Responsive.getFontSize(16),
                                              fontWeight: AppFontWeight.bold,
                                              textColor: textBlack14,
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                          children: [
                                            WantText2(
                                              text: "Service fee (${snapshot.data!.service_per.toString()}%)",
                                              fontSize: Responsive.getFontSize(16),
                                              fontWeight: AppFontWeight.regular,
                                              textColor: textBlack11,
                                            ),
                                            WantText2(
                                              text:
                                              "\$${snapshot.data!.totalServiceFee.toString()}",
                                              fontSize: Responsive.getFontSize(16),
                                              fontWeight: AppFontWeight.bold,
                                              textColor: textBlack14,
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                          children: [
                                            WantText2(
                                              text: "Buyer Premium (${snapshot.data!.buyer_premium.toString()}%)",
                                              fontSize: Responsive.getFontSize(16),
                                              fontWeight: AppFontWeight.regular,
                                              textColor: textBlack11,
                                            ),
                                            WantText2(
                                              text:
                                              "\$${snapshot.data!.buyer_premiumAmountFee.toString()}",
                                              fontSize: Responsive.getFontSize(16),
                                              fontWeight: AppFontWeight.bold,
                                              textColor: textBlack14,
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                          children: [
                                            WantText2(
                                              text: "Total",
                                              fontSize: Responsive.getFontSize(16),
                                              fontWeight: AppFontWeight.regular,
                                              textColor: textBlack11,
                                            ),
                                            WantText2(
                                              text:
                                              "\$${snapshot.data!.payableamout.toString()}",
                                              fontSize: Responsive.getFontSize(16),
                                              fontWeight: AppFontWeight.bold,
                                              textColor: textBlack14,
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: Responsive.getHeight(15),
                                        ),
                                        // Center(
                                        //   child: GestureDetector(
                                        //     onTap: () {
                                        //       _goToCheckout();
                                        //     },
                                        //     child: Container(
                                        //       height: Responsive.getHeight(45),
                                        //       width: Responsive.getWidth(341),
                                        //       child: Container(
                                        //         decoration: BoxDecoration(
                                        //           border: Border.all(color: Colors.black),
                                        //           color: black,
                                        //           borderRadius: BorderRadius.circular(
                                        //               Responsive.getWidth(8)),
                                        //         ),
                                        //         child: Center(
                                        //           child: Row(
                                        //             mainAxisAlignment:
                                        //             MainAxisAlignment.center,
                                        //             crossAxisAlignment:
                                        //             CrossAxisAlignment.center,
                                        //             children: [
                                        //               isLoading
                                        //                   ? Center(
                                        //                 child: SizedBox(
                                        //                   height: 20,
                                        //                   width: 20,
                                        //                   child:
                                        //                   CircularProgressIndicator(
                                        //                     strokeWidth: 3,
                                        //                     color: Colors.white,
                                        //                   ),
                                        //                 ),
                                        //               )
                                        //                   : Text(
                                        //                 "GO TO CHECKOUT",
                                        //                 style: GoogleFonts.poppins(
                                        //                   textStyle: TextStyle(
                                        //                     letterSpacing: 1.5,
                                        //                     fontSize: Responsive
                                        //                         .getFontSize(18),
                                        //                     color: Colors.white,
                                        //                     fontWeight:
                                        //                     FontWeight.w500,
                                        //                   ),
                                        //                 ),
                                        //               ),
                                        //             ],
                                        //           ),
                                        //         ),
                                        //       ),
                                        //     ),
                                        //   ),
                                        // ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              // SizedBox(
                              //   height: Responsive.getHeight(15),
                              // ),
                              Center(
                                child: GestureDetector(
                                  onTap: () {
                                    _goToCheckout();
                                    setState(() {
                                      total = snapshot.data!.payableamout.toString();
                                    });
                                  },
                                  child: Container(
                                    height: Responsive.getHeight(45),
                                    width: Responsive.getWidth(341),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.black),
                                        color: black,
                                        borderRadius: BorderRadius.circular(
                                            Responsive.getWidth(8)),
                                      ),
                                      child: Center(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            isLoading
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
                                                    "CONTINUE",
                                                    style: GoogleFonts.poppins(
                                                      letterSpacing: 1.5,
                                                      textStyle: TextStyle(
                                                        fontSize: Responsive
                                                            .getFontSize(18),
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w500,
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
                        ],
                      ),
                    );
                  }
                },
              ),

              // SizedBox(height: Responsive.getHeight(20)),
              // Spacer(),

              // SizedBox(height: Responsive.getHeight(15)),
              // Center(
              //     child: GeneralButton(
              //   Width: Responsive.getWidth(335),
              //   onTap: () {
              //     showCongratulationsDialog(context);
              //   },
              //   label: "Confirm",
              //   icon: Icons.arrow_forward,
              //   isIconShow: true,
              //   isBoarderRadiusLess: true,
              //   isSelected: true,
              //   buttonClick: false,
              // ))
            ],
          ),
        ),
      ),
    );
  }

  void showCongratulationsDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
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
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        "/User",
                        (route) => false,
                      );
                      // Navigator.pushNamed(
                      //   context,
                      //   '/User/Cart/SelectAddressScreen/OrderConfirmationPage',
                      // );
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
