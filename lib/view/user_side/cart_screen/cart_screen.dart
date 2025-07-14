import 'package:artist/config/toast.dart';
import 'package:artist/core/api_service/api_service.dart';
import 'package:artist/core/widgets/general_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../config/colors.dart';
import '../../../core/models/user_side/cart_model.dart';
import '../../../core/utils/app_font_weight.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/custom_text_2.dart';
import '../notification/notification_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late Future<CartModel> futureArtResponse;
  @override
  void initState() {
    _loadUserData();
    futureArtResponse = ApiService().fetchCartData(customerUniqueID.toString());
    super.initState();
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

  @override
  void dispose() {
    _loadUserData();
    super.dispose();
  }

  void _refreshCart() {
    setState(() {
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
        showToast(message: "Stock available");
        setState(() {
          isLoading = false;
        });
        Navigator.pushNamed(context, '/User/Cart/SelectAddressScreen');
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
      // Handle error
      print('Failed to check quantity: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        scrolledUnderElevation: 0.0,
        automaticallyImplyLeading: false,
        centerTitle: false,
        title: Text(
          "Cart",
          textAlign: TextAlign.start,
          style: GoogleFonts.poppins(
            letterSpacing: 1.5,
            color: textBlack8,
            fontSize: Responsive.getFontSize(20),
            fontWeight: AppFontWeight.bold,
          ),
        ),
        actions: [
          AnimationConfiguration.synchronized(
            duration: const Duration(milliseconds: 2000),
            child: SlideAnimation(
              curve: Curves.easeInOut,
              child: FadeInAnimation(
                duration: const Duration(milliseconds: 1000),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/User/Notification',
                    );
                  },
                  child: Padding(
                    padding: EdgeInsets.only(right: 16),
                    child: Stack(
                      children: [
                        Container(
                          padding: EdgeInsets.all(6),
                          width: Responsive.getWidth(32),
                          height: Responsive.getWidth(32),
                          decoration: BoxDecoration(
                            color: Color.fromRGBO(249, 250, 251, 1),
                            boxShadow: [
                              BoxShadow(
                                color: Color.fromRGBO(0, 0, 0, 0.05),
                                spreadRadius: 0,
                                offset: Offset(0, 1),
                                blurRadius: 2,
                              ),
                            ],
                            borderRadius:
                                BorderRadius.circular(Responsive.getWidth(8)),
                            border: Border.all(
                              width: 1,
                              color: Color.fromRGBO(0, 0, 0, 0.05),
                            ),
                          ),
                          child: Image.asset(
                            "assets/bell_blank.png",
                            width: Responsive.getWidth(24),
                            height: Responsive.getHeight(24),
                          ),
                        ),
                        // Positioned(
                        //   top: 0,
                        //   right: 0,
                        //   child: Container(
                        //     width: 15,
                        //     height: 15,
                        //     decoration: BoxDecoration(
                        //       color: Colors.red,
                        //       borderRadius: BorderRadius.circular(30),
                        //     ),
                        //     child: Center(
                        //       child: WantText2(
                        //         text: "1",
                        //         fontSize: Responsive.getWidth(10),
                        //         fontWeight: AppFontWeight.bold,
                        //         textColor: white,
                        //       ),
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
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
                  print(snapshot.error);
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
                    height: Responsive.getHeight(650),
                    child: Column(
                      children: [
                        Container(
                          height: Responsive.getHeight(430),
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: snapshot.data!.data.length,
                            itemBuilder: (context, index) {
                              final art = snapshot.data!.data[index];
                              bool isOutOfStock =
                                  outOfStockArtCartIds.contains(art.artCartId);
                              return Container(
                                margin: EdgeInsets.only(
                                  right: Responsive.getWidth(7),
                                  left: Responsive.getWidth(7),
                                  top: Responsive.getHeight(10),
                                ),
                                padding: EdgeInsets.symmetric(
                                    vertical: isOutOfStock ? 10 : 0),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(
                                      width: 2,
                                      color: isOutOfStock
                                          ? Colors.red
                                          : Colors.transparent,
                                    )),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                              Responsive.getWidth(8)),
                                          child: Image.network(
                                            art.artImages.isNotEmpty
                                                ? art.artImages.first.image
                                                : 'assets/donate.png',
                                            fit: BoxFit.contain,
                                            height: Responsive.getHeight(80),
                                            width: Responsive.getWidth(80),
                                          ),
                                        ),
                                        SizedBox(
                                            width: Responsive.getWidth(16)),
                                        Container(
                                          width: Responsive.getWidth(239),

                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                art.title,
                                                style: GoogleFonts.poppins(
                                                    color: Colors.black,
                                                    fontSize:
                                                        Responsive.getFontSize(
                                                            16),
                                                    fontWeight: AppFontWeight.semiBold,
                                                    letterSpacing: 1.5),
                                                // TextStyle(
                                                //   fontSize:
                                                //       Responsive.getFontSize(
                                                //           16),
                                                //   fontWeight: FontWeight.w500,
                                                //   color: Colors.black,
                                                // ),
                                              ),
                                              Text(
                                                art.artistName,
                                                style: GoogleFonts.poppins(
                                                    color: Colors.grey,
                                                    fontSize:
                                                        Responsive.getFontSize(
                                                            14),
                                                    fontWeight: FontWeight.w400,
                                                    letterSpacing: 1.5),
                                                // TextStyle(
                                                //   fontSize:
                                                //       Responsive.getFontSize(
                                                //           16),
                                                //   fontWeight: FontWeight.w400,
                                                //   color: Colors.grey,
                                                // ),
                                              ),
                                              SizedBox(height: Responsive.getHeight(12),),
                                              Text(
                                                '\$${art.price}',
                                                style: GoogleFonts.poppins(
                                                    color: Colors.black,
                                                    fontSize:
                                                        Responsive.getFontSize(
                                                            18),
                                                    fontWeight: FontWeight.bold,
                                                    letterSpacing: 1.5),
                                                // TextStyle(
                                                //   fontSize:
                                                //       Responsive.getFontSize(
                                                //           16),
                                                //   fontWeight: FontWeight.bold,
                                                //   color: Colors.black,
                                                // ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        GestureDetector(
                                          child: Image.asset(
                                            "assets/delete.png",
                                            width: Responsive.getWidth(18),
                                            height: Responsive.getHeight(18),
                                            fit: BoxFit.cover,
                                          ),
                                          onTap: () async {
                                            print(
                                                "artCartId : ${art.artCartId}");
                                            await ApiService()
                                                .deleteCartItem(
                                              art.artCartId.toString(),
                                            )
                                                .then((onValue) {
                                              _refreshCart();
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                    Divider(
                                      color: Color.fromRGBO(224, 224, 229, 1.0),
                                    )
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        Spacer(),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: Responsive.getWidth(24)),
                          child: Column(
                            children: [
                              Image.asset("assets/line.png",),
                              SizedBox(height: Responsive.getHeight(24),),
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
                              Center(
                                child: GestureDetector(
                                  onTap: () {
                                    _goToCheckout();
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
                                                    "GO TO CHECKOUT",
                                                    style: GoogleFonts.poppins(
                                                      textStyle: TextStyle(
                                                        letterSpacing: 1.5,
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
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
