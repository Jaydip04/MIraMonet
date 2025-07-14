import 'dart:convert';

import 'package:artist/core/utils/responsive.dart';
import 'package:artist/core/widgets/general_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../config/colors.dart';
import '../../../core/api_service/base_url.dart';
import '../../../core/utils/app_font_weight.dart';
import '../../../core/widgets/app_text_form_field.dart';
import '../../../core/widgets/custom_text_2.dart';
import '../../../config/toast.dart';
import '../../../core/api_service/api_service.dart';
import '../../../core/models/order_response_model.dart';
import '../artist_side_bottom_nav_bar.dart';
import 'artist_track_order_screen.dart';
import 'package:http/http.dart' as http;

class Product {
  final String name;
  final String size;
  final String imageUrl;
  final double price;
  final String status;

  Product({
    required this.name,
    required this.size,
    required this.imageUrl,
    required this.price,
    required this.status,
  });
}

class ArtistOrderScreen extends StatefulWidget {
  @override
  State<ArtistOrderScreen> createState() => _ArtistOrderScreenState();
}

class _ArtistOrderScreenState extends State<ArtistOrderScreen> {
  late Future<OrderResponse> futureOrders;
  String? customerUniqueID;

  void _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String customerUniqueId = (prefs.get('customerUniqueId') is String)
        ? prefs.getString('customerUniqueId') ?? ''
        : prefs.getInt('customerUniqueId')?.toString() ?? '';

    print(customerUniqueId.toString());
    setState(() {
      customerUniqueID = customerUniqueId;
      futureOrders = ApiService().fetchSellerOrders(customerUniqueID!);
    });
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return DefaultTabController(
      length: 6, // Updated to 6
      child: Scaffold(
        backgroundColor: white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          scrolledUnderElevation: 0.0,
          automaticallyImplyLeading: false,
          // centerTitle: true,
          centerTitle: false,
          title: Text(
            textAlign: TextAlign.start,
            "My Order",
            style: GoogleFonts.poppins(
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
                          '/Artist/Notification',
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
                                  borderRadius: BorderRadius.circular(
                                      Responsive.getWidth(8)),
                                  border: Border.all(
                                    width: 1,
                                    color: Color.fromRGBO(0, 0, 0, 0.05),
                                  ),
                                ),
                                child: Image.asset(
                                  "assets/bell_blank.png",
                                  width: Responsive.getWidth(24),
                                  height: Responsive.getHeight(24),
                                )),
                            // Positioned(
                            //   top: 0,
                            //   right: 0,
                            //   child: Container(
                            //     width: 15,
                            //     height: 15,
                            //     decoration: BoxDecoration(
                            //         color: Colors.red,
                            //         borderRadius: BorderRadius.circular(30)),
                            //     child: Center(
                            //         child: WantText2(
                            //             text: "1",
                            //             fontSize: Responsive.getWidth(10),
                            //             fontWeight: AppFontWeight.bold,
                            //             textColor: white)),
                            //   ),
                            // )
                          ],
                        ),
                      )),
                ),
              ),
            ),
          ],
        ),
        body: FutureBuilder<OrderResponse>(
          future: ApiService().fetchSellerOrders(customerUniqueID.toString()),
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
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        "assets/box_grey.png",
                        width: Responsive.getWidth(64),
                        height: Responsive.getWidth(64),
                      ),
                      SizedBox(height: Responsive.getHeight(24)),
                      WantText2(
                          text: "No Orders!",
                          fontSize: Responsive.getFontSize(20),
                          fontWeight: AppFontWeight.semiBold,
                          textColor: textBlack11),
                      SizedBox(height: Responsive.getHeight(12)),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: Responsive.getWidth(50)),
                        child: Text(
                          textAlign: TextAlign.center,
                          "You don’t have any orders at this time.",
                          style: GoogleFonts.poppins(
                            letterSpacing: 1.5,
                            color: Color.fromRGBO(128, 128, 128, 1),
                            fontSize: Responsive.getFontSize(16),
                            fontWeight: AppFontWeight.regular,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            } else if (!snapshot.hasData || !snapshot.data!.status) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        "assets/box_grey.png",
                        width: Responsive.getWidth(64),
                        height: Responsive.getWidth(64),
                      ),
                      SizedBox(height: Responsive.getHeight(24)),
                      WantText2(
                          text: "No Orders!",
                          fontSize: Responsive.getFontSize(20),
                          fontWeight: AppFontWeight.semiBold,
                          textColor: textBlack11),
                      SizedBox(height: Responsive.getHeight(12)),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: Responsive.getWidth(50)),
                        child: Text(
                          textAlign: TextAlign.center,
                          "You don’t have any orders at this time.",
                          style: GoogleFonts.poppins(
                            letterSpacing: 1.5,
                            color: Color.fromRGBO(128, 128, 128, 1),
                            fontSize: Responsive.getFontSize(16),
                            fontWeight: AppFontWeight.regular,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            } else {
              return SafeArea(
                child: ListView(
                  padding:
                      EdgeInsets.symmetric(horizontal: Responsive.getWidth(16)),
                  children: [
                    // Row(
                    //   children: [
                    //     GestureDetector(
                    //       onTap: () => Navigator.pop(context),
                    //       child: Container(
                    //         width: Responsive.getWidth(41),
                    //         height: Responsive.getHeight(41),
                    //         decoration: BoxDecoration(
                    //             color: Colors.white,
                    //             borderRadius: BorderRadius.circular(
                    //                 Responsive.getWidth(12)),
                    //             border: Border.all(
                    //                 color: textFieldBorderColor, width: 1.0)),
                    //         child: Icon(
                    //           Icons.arrow_back_ios_new_outlined,
                    //           size: Responsive.getWidth(19),
                    //         ),
                    //       ),
                    //     ),
                    //     SizedBox(width: Responsive.getWidth(90)),
                    //     WantText2(
                    //         text: "My Order",
                    //         fontSize: Responsive.getFontSize(18),
                    //         fontWeight: AppFontWeight.medium,
                    //         textColor: textBlack)
                    //   ],
                    // ),

                    Container(
                      height: Responsive.getHeight(55),
                      child: TabBar(
                        dividerColor: Color.fromRGBO(
                          238,
                          239,
                          242,
                          1,
                        ),
                        isScrollable: true,
                        tabAlignment: TabAlignment.start,
                        labelColor: Colors.black,
                        dividerHeight: 0.4,
                        indicatorColor: black,
                        labelStyle: GoogleFonts.poppins(
                            color: black,
                            fontSize: Responsive.getFontSize(14),
                            fontWeight: AppFontWeight.medium,
                            letterSpacing: 1.5),
                        tabs: [
                          Tab(text: "All Orders"),
                          Tab(text: "Pending"),
                          Tab(text: "Ongoing"),
                          Tab(text: "Delivered"),
                          Tab(text: "Return"),
                          Tab(text: "Declined"),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: Responsive.getHeight(10),
                    ),
                    Container(
                      height: Responsive.getHeight(610),
                      child: TabBarView(
                        children: [
                          OrdersList(
                            orders: snapshot.data!.orderAllData,
                            filter: 'All',
                            customerUniqueID: customerUniqueID.toString(),
                          ),
                          OrdersList(
                            orders: snapshot.data!.orderAllData,
                            filter: 'Pending',
                            customerUniqueID: customerUniqueID.toString(),
                          ),
                          OrdersList(
                            orders: snapshot.data!.orderAllData,
                            filter: 'Confirmed',
                            customerUniqueID: customerUniqueID.toString(),
                          ),
                          OrdersList(
                            orders: snapshot.data!.orderAllData,
                            filter: 'Delivered',
                            customerUniqueID: customerUniqueID.toString(),
                          ),
                          OrdersList(
                            orders: snapshot.data!.orderAllData,
                            filter: 'Return',
                            customerUniqueID: customerUniqueID.toString(),
                          ),
                          OrdersList(
                            orders: snapshot.data!.orderAllData,
                            filter: 'Declined',
                            customerUniqueID: customerUniqueID.toString(),
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
      ),
    );
  }
}

class OrdersList extends StatefulWidget {
  final List<OrderData> orders;
  final String filter;
  final String customerUniqueID;

  OrdersList(
      {required this.orders,
      required this.filter,
      required this.customerUniqueID});

  @override
  State<OrdersList> createState() => _OrdersListState();
}

class _OrdersListState extends State<OrdersList> {
  @override
  void initState() {
    super.initState();
    fetchTrackingStatuses();
  }

  List<String> _trackingStatuses = [];

  Future<void> fetchTrackingStatuses() async {
    final Map<String, dynamic> body = {
      "type": "delivery",
    };
    try {
      final response = await http.post(
        Uri.parse('$serverUrl/tracking_status'),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(body),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true) {
          setState(() {
            _trackingStatuses = List<String>.from(
              data['data'].map((item) => item['tracking_status']),
            );
          });
          print(_trackingStatuses);
        } else {
          // showToast(message: "Failed to fetch statuses");
        }
      } else {
        // showToast(message: "Error: ${response.statusCode}");
      }
    } catch (e) {
      // showToast(message: "Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filter orders based on the `art_order_status` of each `art_details`
    List<OrderData> filteredOrders = widget.filter == 'All'
        ? widget.orders
        : widget.orders
            .where((order) => order.artDetails
                .any((art) => art.artOrderStatus == widget.filter))
            .toList();

    return filteredOrders.isEmpty
        ? Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/box_grey.png",
                  width: Responsive.getWidth(64),
                  height: Responsive.getWidth(64),
                ),
                SizedBox(height: Responsive.getHeight(24)),
                WantText2(
                    text: "No Orders!",
                    fontSize: Responsive.getFontSize(20),
                    fontWeight: AppFontWeight.semiBold,
                    textColor: textBlack11),
                SizedBox(height: Responsive.getHeight(12)),
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: Responsive.getWidth(50)),
                  child: Text(
                    textAlign: TextAlign.center,
                    "You don’t have any ongoing orders at this time.",
                    style: GoogleFonts.poppins(
                      letterSpacing: 1.5,
                      color: Color.fromRGBO(128, 128, 128, 1),
                      fontSize: Responsive.getFontSize(16),
                      fontWeight: AppFontWeight.regular,
                    ),
                  ),
                ),
              ],
            ),
          )
        : ListView.builder(
            itemCount: filteredOrders.length,
            itemBuilder: (context, index) {
              var order = filteredOrders[index];
              return Column(
                children: order.artDetails
                    .where((art) =>
                        art.artOrderStatus == widget.filter ||
                        widget.filter == 'All')
                    .map((art) {
                  final String colors = art.colorCode;
                  final String formattedColor =
                      colors.startsWith("#") ? colors.substring(1) : colors;
                  print("FcmToken : ${art.fcmToken}");
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => ArtistTrackOrderScreen(
                                    art_unique_id: art.artUniqueId,
                                  )));
                    },
                    child: Column(
                      children: [
                        Container(
                          height: Responsive.getHeight(107),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: Image.network(
                                  art.images,
                                  width: Responsive.getWidth(100),
                                  height: double.infinity,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              SizedBox(width: 6),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: Responsive.getWidth(230),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: Responsive.getWidth(140),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                art.title,
                                                overflow: TextOverflow.ellipsis,
                                                style: GoogleFonts.poppins(
                                                    color: black,
                                                    fontSize:
                                                        Responsive.getFontSize(
                                                            14),
                                                    fontWeight:
                                                        AppFontWeight.medium,
                                                    letterSpacing: 1.5),
                                              ),
                                              Text(
                                                overflow: TextOverflow.ellipsis,
                                                art.artistName,
                                                style: GoogleFonts.poppins(
                                                    color: Color.fromRGBO(
                                                        128, 128, 128, 1),
                                                    fontSize:
                                                        Responsive.getFontSize(
                                                            12),
                                                    fontWeight:
                                                        AppFontWeight.regular,
                                                    letterSpacing: 1.5),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          height: Responsive.getHeight(20),
                                          padding: EdgeInsets.symmetric(
                                              horizontal:
                                                  Responsive.getWidth(3)),
                                          decoration: BoxDecoration(
                                            color: Color(0xFF000000 |
                                                int.parse(formattedColor,
                                                    radix: 16)),
                                            // getStatusColor(
                                            //     art.artOrderStatus),
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: SizedBox(
                                            width: Responsive.getWidth(80),
                                            child: Center(
                                              child: Text(
                                                overflow: TextOverflow.ellipsis,
                                                getOrderStatus(art),
                                                // art.tracking_status.isEmpty
                                                //     ? art.artOrderStatus ==
                                                //     "Confirmed"
                                                //     ? "Ongoing"
                                                //     : art.tracking_status
                                                //     :
                                                // art.artOrderStatus == "Return"
                                                //     ? art.tracking_status
                                                //     :  art.artOrderStatus ==
                                                //     "Confirmed"
                                                //     ? art.tracking_status
                                                //     : art.artOrderStatus,
                                                style: GoogleFonts.poppins(
                                                    color: white,
                                                    fontSize:
                                                        Responsive.getFontSize(
                                                            10),
                                                    fontWeight:
                                                        AppFontWeight.medium,
                                                    letterSpacing: 1.5),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Spacer(),
                                  SizedBox(
                                    width: Responsive.getWidth(230),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "\$${art.price}",
                                          style: GoogleFonts.poppins(
                                              color: black,
                                              fontSize:
                                                  Responsive.getFontSize(16),
                                              fontWeight: AppFontWeight.bold,
                                              letterSpacing: 1.5),
                                          // TextStyle(
                                          //     fontSize: 16,
                                          //     fontWeight: FontWeight.bold,
                                          //     color: Colors.black),
                                        ),
                                        art.artOrderStatus == "Confirmed"
                                            ? art.isTrack == false
                                                ? GestureDetector(
                                                    onTap: () {
                                                      showRegisterDialog(art
                                                          .artUniqueId
                                                          .toString(),art.fcmToken.toString());
                                                    },
                                                    child: Image.asset(
                                                      "assets/status.png",
                                                      width: 22,
                                                      height: 22,
                                                    ),
                                                  )
                                                : GestureDetector(
                                                    onTap: () {
                                                      showAddTrackingRegisterDialog(
                                                          context,
                                                          widget
                                                              .customerUniqueID,
                                                          art.order_unique_id!
                                                              .toString(),
                                                          art.artUniqueId,art.fcmToken.toString());
                                                    },
                                                    child: Image.asset(
                                                      "assets/track_details.png",
                                                      width: 24,
                                                      height: 24,
                                                    ),
                                                  )
                                            : SizedBox()
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: Responsive.getHeight(8),
                        ),
                        Divider(
                          color: Color.fromRGBO(243, 243, 243, 1),
                        ),
                        SizedBox(
                          height: Responsive.getHeight(8),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          );
  }

  final _formKey = GlobalKey<FormState>();
  TextEditingController _trackIdController = TextEditingController();
  TextEditingController _trackLineController = TextEditingController();
  TextEditingController _companyNameController = TextEditingController();

  bool isClick = false;
  @override
  void dispose() {
    _trackIdController.dispose();
    _trackLineController.dispose();
    _companyNameController.dispose();
    super.dispose();
  }

  void showAddTrackingRegisterDialog(
    BuildContext context,
    String customer_unique_id,
    String order_unique_id,
    String art_unique_id,
    String fcmToken,
  ) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: whiteBack,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          insetPadding:
              EdgeInsets.symmetric(horizontal: Responsive.getWidth(14)),
          child: Container(
            margin: EdgeInsets.all(0), // Remove all margins
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: Responsive.getWidth(11),
                    vertical: Responsive.getHeight(11)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: 1,
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Icon(
                            CupertinoIcons.multiply_circle,
                            color: Colors.grey,
                          ),
                        )
                      ],
                    ),
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          WantText2(
                              text: "Track Info",
                              fontSize: Responsive.getFontSize(16),
                              fontWeight: AppFontWeight.bold,
                              textColor: textBlack9),
                          SizedBox(
                            height: Responsive.getHeight(10),
                          ),
                          Row(
                            children: [
                              WantText2(
                                  text: "Track ID",
                                  fontSize: Responsive.getFontSize(12),
                                  fontWeight: AppFontWeight.medium,
                                  textColor: textBlack9),
                              WantText2(
                                  text: "*",
                                  fontSize: Responsive.getFontSize(12),
                                  fontWeight: AppFontWeight.medium,
                                  textColor: Color.fromRGBO(246, 0, 0, 1.0)),
                            ],
                          ),
                          SizedBox(
                            height: Responsive.getHeight(5),
                          ),
                          AppTextFormField(
                            fillColor: Color.fromRGBO(247, 248, 249, 1),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: Responsive.getWidth(18),
                                vertical: Responsive.getHeight(14)),
                            borderRadius: Responsive.getWidth(8),
                            controller: _trackIdController,
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
                            hintText: "Enter Track ID",
                          ),
                          SizedBox(
                            height: Responsive.getHeight(15),
                          ),
                          Row(
                            children: [
                              WantText2(
                                  text: "Track Link",
                                  fontSize: Responsive.getFontSize(12),
                                  fontWeight: AppFontWeight.medium,
                                  textColor: textBlack9),
                              WantText2(
                                  text: "*",
                                  fontSize: Responsive.getFontSize(12),
                                  fontWeight: AppFontWeight.medium,
                                  textColor: Color.fromRGBO(246, 0, 0, 1.0)),
                            ],
                          ),
                          SizedBox(
                            height: Responsive.getHeight(5),
                          ),
                          AppTextFormField(
                            fillColor: Color.fromRGBO(247, 248, 249, 1),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: Responsive.getWidth(18),
                                vertical: Responsive.getHeight(14)),
                            borderRadius: Responsive.getWidth(8),
                            controller: _trackLineController,
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
                            hintText: "Enter Track Link",
                          ),
                          SizedBox(
                            height: Responsive.getHeight(15),
                          ),
                          Row(
                            children: [
                              WantText2(
                                  text: "Company Name",
                                  fontSize: Responsive.getFontSize(12),
                                  fontWeight: AppFontWeight.medium,
                                  textColor: textBlack9),
                              WantText2(
                                  text: "*",
                                  fontSize: Responsive.getFontSize(12),
                                  fontWeight: AppFontWeight.medium,
                                  textColor: Color.fromRGBO(246, 0, 0, 1.0)),
                            ],
                          ),
                          SizedBox(
                            height: Responsive.getHeight(5),
                          ),
                          AppTextFormField(
                            fillColor: Color.fromRGBO(247, 248, 249, 1),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: Responsive.getWidth(18),
                                vertical: Responsive.getHeight(14)),
                            borderRadius: Responsive.getWidth(8),
                            controller: _companyNameController,
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
                            hintText: "Enter Company Name",
                          ),
                          SizedBox(
                            height: Responsive.getHeight(20),
                          ),
                          Align(
                            alignment: Alignment.center,
                            child: GestureDetector(
                              onTap: () async {
                                if (_trackIdController.text.isEmpty) {
                                  showToast(message: "Enter Track ID");
                                } else if (_trackLineController.text.isEmpty) {
                                  showToast(message: "Enter Track Link");
                                } else if (_companyNameController
                                    .text.isEmpty) {
                                  showToast(message: "Enter Company Name");
                                } else {
                                  setState(() {
                                    isClick = true;
                                  });
                                  ApiService()
                                      .addTrackingSystem(
                                          customer_unique_id,
                                          order_unique_id,
                                          art_unique_id,
                                          _trackIdController.text.toString(),
                                          _trackLineController.text.toString(),
                                          _companyNameController.text
                                              .toString(),fcmToken)
                                      .then((onValue) {
                                    Navigator.pushNamedAndRemoveUntil(
                                      context,
                                      "/Artist/order",
                                      arguments: 3,
                                      (route) => false,
                                    );
                                    setState(() {
                                      isClick = false;
                                    });
                                  });
                                }
                              },
                              child: Container(
                                height: Responsive.getHeight(45),
                                width: Responsive.getMainWidth(context),
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
                                        isClick
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
                                                "ACCEPT",
                                                style: GoogleFonts.poppins(
                                                  letterSpacing: 1.5,
                                                  textStyle: TextStyle(
                                                    fontSize:
                                                        Responsive.getFontSize(
                                                            18),
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
                  ],
                ),
              ),
            ),
          ),
        );
        //   RegisterDialog(
        //   artUniqueId: art_unique_id,
        //   customerUniqueId: customer_unique_id,
        //   orderUniqueId: order_unique_id,
        //   FCMToken: FCMToken,
        // );
      },
    );
  }

  String getOrderStatus(art) {
    if (art.artOrderStatus == "Confirmed") {
      return art.tracking_status?.isNotEmpty == true
          ? art.tracking_status!
          : "Ongoing";
    } else if (art.artOrderStatus == "Return") {
      return art.tracking_status.isEmpty
          ? art.artOrderStatus
          : art.tracking_status;
    } else {
      return art.artOrderStatus;
    }
  }

  // final _formKey = GlobalKey<FormState>();

  String? _selectedframe;

  bool _isDropdownOpen = false;
  void showRegisterDialog(String artUniqueId,String fcmToken) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: whiteBack,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          insetPadding: EdgeInsets.symmetric(horizontal: Responsive.getWidth(14)),
          child: StatefulBuilder(
            builder: (context, setState) {
              return Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.getWidth(11),
                  vertical: Responsive.getHeight(11),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Close Button
                      Align(
                        alignment: Alignment.topRight,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Icon(
                            CupertinoIcons.multiply_circle,
                            color: Colors.grey,
                          ),
                        ),
                      ),

                      // Title
                      WantText2(
                        text: "Order Status",
                        fontSize: Responsive.getFontSize(18),
                        fontWeight: AppFontWeight.bold,
                        textColor: textBlack9,
                      ),

                      SizedBox(height: Responsive.getHeight(10)),

                      // Order Status Dropdown
                      FormField<String>(
                        validator: (value) {
                          if (_selectedframe == null || _selectedframe!.isEmpty) {
                            return 'Please select a status';
                          }
                          return null;
                        },
                        builder: (FormFieldState<String> state) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              WantText2(
                                text: "Select Order Status",
                                fontSize: Responsive.getFontSize(12),
                                fontWeight: AppFontWeight.medium,
                                textColor: textBlack9,
                              ),
                              SizedBox(height: Responsive.getHeight(5)),

                              // Dropdown Field
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _isDropdownOpen = !_isDropdownOpen;
                                  });
                                },
                                child: InputDecorator(
                                  decoration: _inputDecoration(state, 'Select'),
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      WantText2(
                                        text: _selectedframe ?? "Select",
                                        fontSize: Responsive.getFontSize(14),
                                        fontWeight: _selectedframe == null
                                            ? AppFontWeight.regular
                                            : AppFontWeight.medium,
                                        textColor: _selectedframe == null
                                            ? Color.fromRGBO(131, 145, 161, 1.0)
                                            : textBlack11,
                                      ),
                                      Icon(
                                        Icons.keyboard_arrow_down_outlined,
                                        color: Color.fromRGBO(131, 131, 131, 1),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // Show Dropdown List when `_isDropdownOpen` is true
                              if (_isDropdownOpen)
                                Material(
                                  elevation: 4,
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    width: double.infinity,
                                    color: Colors.white,
                                    // margin: EdgeInsets.only(top: 5),
                                    // decoration: BoxDecoration(
                                    //   border: Border.all(color: Colors.grey.shade300),
                                    //   borderRadius: BorderRadius.circular(8),
                                    //   color: Colors.white,
                                    // ),
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: _trackingStatuses.length,
                                      itemBuilder: (context, index) {
                                        return ListTile(
                                          title: WantText2(
                                            text: _trackingStatuses[index],
                                            fontSize: Responsive.getFontSize(14),
                                            fontWeight: AppFontWeight.medium,
                                            textColor: textBlack11,
                                          ),
                                          onTap: () {
                                            setState(() {
                                              _selectedframe = _trackingStatuses[index];
                                              _isDropdownOpen = false; // Close dropdown
                                            });
                                            state.didChange(_selectedframe);
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),

                      SizedBox(height: Responsive.getHeight(20)),

                      // Submit Button
                      Align(
                        alignment: Alignment.center,
                        child: GestureDetector(
                          onTap: () async {
                            if (_selectedframe != null) {
                              // API Call
                              ApiService()
                                  .updateSellerStatus(artUniqueId, _selectedframe.toString(),fcmToken)
                                  .then((_) {
                                Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  "/Artist/order",
                                  arguments: 3,
                                      (route) => false,
                                );
                              });
                            } else {
                              showToast(message: 'Select Status');
                            }
                          },
                          child: Container(
                            height: Responsive.getHeight(45),
                            width: Responsive.getMainWidth(context),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black),
                              color: black,
                              borderRadius: BorderRadius.circular(
                                  Responsive.getWidth(8)),
                            ),
                            child: Center(
                              child: Text(
                                "UPDATE",
                                style: GoogleFonts.poppins(
                                  fontSize: Responsive.getFontSize(18),
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  // void showRegisterDialog(
  //   String art_unique_id,
  // ) {
  //   showDialog(
  //     barrierDismissible: false,
  //     context: context,
  //     builder: (BuildContext context) {
  //       return Dialog(
  //         backgroundColor: whiteBack,
  //         shape:
  //             RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  //         insetPadding:
  //             EdgeInsets.symmetric(horizontal: Responsive.getWidth(14)),
  //         child: Container(
  //           margin: EdgeInsets.all(0), // Remove all margins
  //           child: SingleChildScrollView(
  //             child: Padding(
  //               padding: EdgeInsets.symmetric(
  //                   horizontal: Responsive.getWidth(11),
  //                   vertical: Responsive.getHeight(11)),
  //               child: Column(
  //                 mainAxisSize: MainAxisSize.min,
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   Row(
  //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                     children: [
  //                       SizedBox(
  //                         width: 1,
  //                       ),
  //                       GestureDetector(
  //                         onTap: () => Navigator.pop(context),
  //                         child: Icon(
  //                           CupertinoIcons.multiply_circle,
  //                           color: Colors.grey,
  //                         ),
  //                       )
  //                     ],
  //                   ),
  //                   Form(
  //                     key: _formKey,
  //                     child: Column(
  //                       crossAxisAlignment: CrossAxisAlignment.start,
  //                       children: [
  //                         WantText2(
  //                             text: "Order Status",
  //                             fontSize: Responsive.getFontSize(18),
  //                             fontWeight: AppFontWeight.bold,
  //                             textColor: textBlack9),
  //                         // SizedBox(
  //                         //   height: Responsive.getHeight(10),
  //                         // ),
  //                         // WantText2(
  //                         //     text: "Select Order Status",
  //                         //     fontSize: Responsive.getFontSize(12),
  //                         //     fontWeight: AppFontWeight.medium,
  //                         //     textColor: textBlack9),
  //                         // SizedBox(
  //                         //   height: Responsive.getHeight(5),
  //                         // ),
  //                         FormField<String>(
  //                           validator: (value) {
  //                             if (_selectedframe == null ||
  //                                 _selectedframe!.isEmpty ||
  //                                 _selectedframe == 'Select') {
  //                               return 'Please select a status';
  //                             }
  //                             return null;
  //                           },
  //                           builder: (FormFieldState<String> state) {
  //                             return Column(
  //                               crossAxisAlignment: CrossAxisAlignment.start,
  //                               children: [
  //                                 SizedBox(height: Responsive.getHeight(15)),
  //                                 WantText2(
  //                                     text: "Select Order Status",
  //                                     fontSize: Responsive.getFontSize(12),
  //                                     fontWeight: AppFontWeight.medium,
  //                                     textColor: textBlack9),
  //                                 SizedBox(height: Responsive.getHeight(5)),
  //                                 GestureDetector(
  //                                   onTap: () {
  //                                     setState(() {
  //                                       _isDropdownOpen = !_isDropdownOpen;
  //                                     });
  //                                   },
  //                                   child: InputDecorator(
  //                                     decoration:
  //                                         _inputDecoration(state, 'Select'),
  //                                     child: Row(
  //                                       mainAxisAlignment:
  //                                           MainAxisAlignment.spaceBetween,
  //                                       crossAxisAlignment:
  //                                           CrossAxisAlignment.center,
  //                                       children: [
  //                                         WantText2(
  //                                           text: _selectedframe ?? "Select",
  //                                           fontSize:
  //                                               Responsive.getFontSize(14),
  //                                           fontWeight: _selectedframe == null
  //                                               ? AppFontWeight.regular
  //                                               : AppFontWeight.medium,
  //                                           textColor: _selectedframe == null
  //                                               ? Color.fromRGBO(
  //                                                   131, 145, 161, 1.0)
  //                                               : textBlack11,
  //                                         ),
  //                                         Icon(
  //                                           Icons.keyboard_arrow_down_outlined,
  //                                           color: Color.fromRGBO(
  //                                               131, 131, 131, 1),
  //                                           // size: Responsive.getWidth(28),
  //                                         ),
  //                                         // Icon(Icons.keyboard_arrow_down_outlined),
  //                                       ],
  //                                     ),
  //                                   ),
  //                                 ),
  //                                 // Show dropdown only if it's open
  //                                 if (_isDropdownOpen)
  //                                   Positioned(
  //                                     // left: (MediaQuery.of(context).size.width - 250) / 2, // Center the dropdown
  //                                     top: Responsive.getHeight(45),
  //                                     child: Material(
  //                                       elevation: 4,
  //                                       borderRadius: BorderRadius.circular(8),
  //                                       child: Container(
  //                                         width: double.infinity,
  //                                         color: Colors.white,
  //                                         child: ListView(
  //                                           shrinkWrap: true,
  //                                           children: _trackingStatuses
  //                                               .map((String status) {
  //                                             return ListTile(
  //                                               title: WantText2(
  //                                                   text: status,
  //                                                   fontSize:
  //                                                       Responsive.getFontSize(
  //                                                           14),
  //                                                   fontWeight:
  //                                                       AppFontWeight.medium,
  //                                                   textColor: textBlack11),
  //                                               // Text(title),
  //                                               onTap: () {
  //                                                 state.didChange(status);
  //                                                 setState(() {
  //                                                   _selectedframe = status;
  //                                                 }); // Update form field value
  //                                                 setState(() {
  //                                                   _isDropdownOpen =
  //                                                       false; // Close dropdown after selection
  //                                                 });
  //                                               },
  //                                             );
  //                                           }).toList(),
  //                                         ),
  //                                       ),
  //                                     ),
  //                                   ),
  //                               ],
  //                             );
  //                           },
  //                         ),
  //                         // FormField<String>(
  //                         //   validator: (value) {
  //                         //     if (_selectedframe == null ||
  //                         //         _selectedframe!.isEmpty) {
  //                         //       return 'Please select a status';
  //                         //     }
  //                         //     return null;
  //                         //   },
  //                         //   builder: (FormFieldState<String> state) {
  //                         //     return Column(
  //                         //       crossAxisAlignment: CrossAxisAlignment.start,
  //                         //       children: [
  //                         //         InputDecorator(
  //                         //           decoration: InputDecoration(
  //                         //             isDense: true,
  //                         //             hintText: 'Select',
  //                         //             hintStyle: GoogleFonts.poppins(
  //                         //               letterSpacing: 1.5,
  //                         //               color: textGray,
  //                         //               fontSize: 14.0,
  //                         //               fontWeight: FontWeight.normal,
  //                         //             ),
  //                         //             contentPadding:
  //                         //                 EdgeInsets.fromLTRB(16, 15, 16, 15),
  //                         //             errorText: state.errorText,
  //                         //             border: OutlineInputBorder(
  //                         //               borderRadius: BorderRadius.all(
  //                         //                   Radius.circular(10)),
  //                         //               borderSide: BorderSide(
  //                         //                   color: textFieldBorderColor,
  //                         //                   width: 1),
  //                         //             ),
  //                         //           ),
  //                         //           child: DropdownButtonHideUnderline(
  //                         //             child: DropdownButton<String>(
  //                         //               dropdownColor: white,
  //                         //               hint: Text("Select"),
  //                         //               icon: Icon(
  //                         //                 Icons.keyboard_arrow_down_outlined,
  //                         //                 color:
  //                         //                     Color.fromRGBO(131, 131, 131, 1),
  //                         //               ),
  //                         //               value: _selectedframe,
  //                         //               isDense: true,
  //                         //               onChanged: (value) {
  //                         //                 state.didChange(value);
  //                         //                 setState(() {
  //                         //                   _selectedframe = value;
  //                         //                 });
  //                         //               },
  //                         //               items: _trackingStatuses
  //                         //                   .map((String status) {
  //                         //                 return DropdownMenuItem<String>(
  //                         //                   value: status,
  //                         //                   child: Text(
  //                         //                     status,
  //                         //                     style: GoogleFonts.poppins(
  //                         //                       fontSize:
  //                         //                           Responsive.getFontSize(16),
  //                         //                       fontWeight:
  //                         //                           AppFontWeight.medium,
  //                         //                     ),
  //                         //                   ),
  //                         //                 );
  //                         //               }).toList(),
  //                         //               borderRadius: BorderRadius.circular(20),
  //                         //             ),
  //                         //           ),
  //                         //         ),
  //                         //       ],
  //                         //     );
  //                         //   },
  //                         // ),
  //                         SizedBox(
  //                           height: Responsive.getHeight(20),
  //                         ),
  //                         Align(
  //                           alignment: Alignment.center,
  //                           child: GestureDetector(
  //                             onTap: () async {
  //                               if (_formKey.currentState!.validate()) {
  //                                 // showToast(
  //                                 //     message:
  //                                 //         "Selected status: $_selectedframe");
  //                                 ApiService()
  //                                     .updateSellerStatus(art_unique_id,
  //                                         _selectedframe.toString())
  //                                     .then((onValue) {
  //                                   Navigator.pushNamedAndRemoveUntil(
  //                                     context,
  //                                     "/Artist/order",
  //                                     arguments: 3,
  //                                     (route) => false,
  //                                   );
  //                                 });
  //                               } else {
  //                                 showToast(message: 'Select Status');
  //                               }
  //                             },
  //                             child: Container(
  //                               height: Responsive.getHeight(45),
  //                               width: Responsive.getMainWidth(context),
  //                               child: Container(
  //                                 decoration: BoxDecoration(
  //                                   border: Border.all(color: Colors.black),
  //                                   color: black,
  //                                   borderRadius: BorderRadius.circular(
  //                                       Responsive.getWidth(8)),
  //                                 ),
  //                                 child: Center(
  //                                   child: Row(
  //                                     mainAxisAlignment:
  //                                         MainAxisAlignment.center,
  //                                     crossAxisAlignment:
  //                                         CrossAxisAlignment.center,
  //                                     children: [
  //                                       Text(
  //                                         "UPDATE",
  //                                         style: GoogleFonts.poppins(
  //                                           letterSpacing: 1.5,
  //                                           textStyle: TextStyle(
  //                                             fontSize:
  //                                                 Responsive.getFontSize(18),
  //                                             color: Colors.white,
  //                                             fontWeight: FontWeight.w500,
  //                                           ),
  //                                         ),
  //                                       ),
  //                                     ],
  //                                   ),
  //                                 ),
  //                               ),
  //                             ),
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

  InputDecoration _inputDecoration(
      FormFieldState<String> state, String hintText) {
    return InputDecoration(
      isDense: true,
      hintText: hintText,
      hintStyle: GoogleFonts.poppins(
        letterSpacing: 1.5,
        color: Color.fromRGBO(131, 145, 161, 1.0),
        fontSize: 14.0,
        fontWeight: FontWeight.normal,
      ),
      contentPadding: EdgeInsets.fromLTRB(16, 15, 10, 15),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide.none,
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide(color: textFieldBorderColor, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide(color: textFieldBorderColor, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide(color: textFieldBorderColor, width: 1),
      ),
      errorText: state.errorText, // Show error message
    );
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'Delivered':
        return Color(0XFF29BA38);
      case 'Confirmed':
        return Color(0XFF0400D9);
      case 'Pending':
        return Color(0XFFD9B500);
      case 'Return':
        return Color(0XFF1900D9);
      case 'Declined':
        return Color(0XFFFF2F2F);
      default:
        return Colors.grey;
    }
  }
}
