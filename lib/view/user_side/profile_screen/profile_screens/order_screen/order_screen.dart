import 'package:artist/core/utils/responsive.dart';
import 'package:artist/core/widgets/general_button.dart';
import 'package:artist/view/user_side/profile_screen/profile_screens/feedback_screen.dart';
import 'package:artist/view/user_side/profile_screen/profile_screens/order_screen/track_order_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../config/colors.dart';
import '../../../../../core/api_service/api_service.dart';
import '../../../../../core/models/order_response_model.dart';
import '../../../../../core/utils/app_font_weight.dart';
import '../../../../../core/widgets/app_text_form_field.dart';
import '../../../../../core/widgets/custom_text_2.dart';
import '../../../../artist_side/artist_my_art_page/single_art_screen/artist_review_art_screen.dart';

class OrderScreen extends StatefulWidget {
  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  late Future<OrderResponse> futureOrders;

  @override
  void initState() {
    super.initState();
    _loadUserData();
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
      futureOrders = ApiService().fetchOrders(customerUniqueID.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return DefaultTabController(
      length: 7,
      child: Scaffold(
        backgroundColor: white,
        body: SafeArea(
          child: FutureBuilder<OrderResponse>(
            future: futureOrders,
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
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: Responsive.getWidth(16)),
                      child: Row(
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
                                      color: textFieldBorderColor, width: 1.0)),
                              child: Icon(
                                Icons.arrow_back_ios_new_outlined,
                                size: Responsive.getWidth(19),
                              ),
                            ),
                          ),
                          SizedBox(width: Responsive.getWidth(90)),
                          WantText2(
                              text: "My Order",
                              fontSize: Responsive.getFontSize(18),
                              fontWeight: AppFontWeight.medium,
                              textColor: textBlack)
                        ],
                      ),
                    ),
                    SizedBox(
                      height: Responsive.getHeight(250),
                    ),
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
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: Responsive.getWidth(16)),
                      child: Row(
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
                                      color: textFieldBorderColor, width: 1.0)),
                              child: Icon(
                                Icons.arrow_back_ios_new_outlined,
                                size: Responsive.getWidth(19),
                              ),
                            ),
                          ),
                          SizedBox(width: Responsive.getWidth(90)),
                          WantText2(
                              text: "My Order",
                              fontSize: Responsive.getFontSize(18),
                              fontWeight: AppFontWeight.medium,
                              textColor: textBlack)
                        ],
                      ),
                    ),
                    SizedBox(
                      height: Responsive.getHeight(250),
                    ),
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
                    padding: EdgeInsets.symmetric(
                        horizontal: Responsive.getWidth(16)),
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
                                      color: textFieldBorderColor, width: 1.0)),
                              child: Icon(
                                Icons.arrow_back_ios_new_outlined,
                                size: Responsive.getWidth(19),
                              ),
                            ),
                          ),
                          SizedBox(width: Responsive.getWidth(90)),
                          WantText2(
                              text: "My Order",
                              fontSize: Responsive.getFontSize(18),
                              fontWeight: AppFontWeight.medium,
                              textColor: textBlack)
                        ],
                      ),
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
                            Tab(text: "Return Pending"),
                            Tab(text: "Declined"),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: Responsive.getHeight(10),
                      ),
                      Container(
                        height: Responsive.getHeight(660),
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
                              filter: 'Return Pending',
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
      ),
    );
  }
}

class OrdersList extends StatelessWidget {
  final List<OrderData> orders;
  final String filter;
  final String customerUniqueID;

  OrdersList(
      {required this.orders,
      required this.filter,
      required this.customerUniqueID});

  @override
  Widget build(BuildContext context) {
    List<OrderData> filteredOrders = filter == 'All'
        ? orders
        : orders
            .where((order) =>
                order.artDetails.any((art) => art.artOrderStatus == filter))
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
          )
        : ListView.builder(
            itemCount: filteredOrders.length,
            itemBuilder: (context, index) {
              var order = filteredOrders[index];
              return Column(
                children: order.artDetails
                    .where((art) =>
                        art.artOrderStatus == filter || filter == 'All')
                    .map((art) {
                  final String colors = art.colorCode;
                  final String formattedColor =
                      colors.startsWith("#") ? colors.substring(1) : colors;
                  // colorInt =
                  print("Fcm Token : ${art.fcmToken}");
                  return Column(
                    children: [
                      Container(
                        height: Responsive.getHeight(107),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            ArtistSingleArtScreen(
                                              artUniqueID:
                                              art.artUniqueId,
                                            )));
                                // Navigator.pushNamed(
                                //   context,
                                //   '/Artist/ArtistMyArtScreen/ArtistSingleArtScreen',
                                // );
                              },

                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: Image.network(
                                  art.images,
                                  width: Responsive.getWidth(100),
                                  height: double.infinity,
                                  fit: BoxFit.contain,
                                ),
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
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (_) =>
                                                      ArtistSingleArtScreen(
                                                        artUniqueID:
                                                        art.artUniqueId,
                                                      )));
                                          // Navigator.pushNamed(
                                          //   context,
                                          //   '/Artist/ArtistMyArtScreen/ArtistSingleArtScreen',
                                          // );
                                        },
                                        child: Container(
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
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          if (art.artOrderStatus == "Confirmed" ||
                                              art.artOrderStatus == "Return" ||
                                              art.artOrderStatus == "Delivered") {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (_) => TrackOrderScreen(
                                                      fcmToken: art.fcmToken,
                                                      isFeedback: art.isFeedback,
                                                      isReturn: art.isReturn,
                                                      customer_unique_id:
                                                      customerUniqueID,
                                                      artist_unique_id:
                                                      art.artist_unique_id,
                                                      art_unique_id:
                                                      art.artUniqueId.toString(),
                                                    )));
                                          }
                                        },
                                        child: Container(
                                          height: Responsive.getHeight(20),
                                          // width: 68,
                                          padding: EdgeInsets.symmetric(
                                              horizontal: Responsive.getWidth(3)),
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
                                                //             "Confirmed"
                                                //         ? "Ongoing"
                                                //         : art.tracking_status
                                                //     :
                                                //     art.artOrderStatus == "Return"
                                                //         ? art.tracking_status
                                                //         :  art.artOrderStatus ==
                                                //         "Confirmed"
                                                //         ? art.tracking_status
                                                //         : "Ongoing",
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
                                      ),
                                    ],
                                  ),
                                ),
                                Spacer(),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) =>
                                                ArtistSingleArtScreen(
                                                  artUniqueID:
                                                  art.artUniqueId,
                                                )));
                                    // Navigator.pushNamed(
                                    //   context,
                                    //   '/Artist/ArtistMyArtScreen/ArtistSingleArtScreen',
                                    // );
                                  },
                                  child: SizedBox(
                                    width: Responsive.getWidth(235),
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
                                        art.isFeedback == true
                                            ? GestureDetector(
                                                onTap: () {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (_) =>
                                                              FeedbackScreen(
                                                                customerUniqueId:
                                                                    customerUniqueID,
                                                                artUniqueId: art
                                                                    .artUniqueId,
                                                                artistName: art
                                                                    .artistName,
                                                                artName:
                                                                    art.title,
                                                              )));
                                                },
                                                child: Image.asset(
                                                  "assets/feedback.png",
                                                  height: Responsive.getWidth(24),
                                                  width: Responsive.getWidth(24),
                                                ),
                                              )
                                            : SizedBox(),
                                      ],
                                    ),
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
                  );
                }).toList(),
              );
            },
          );
  }

  String getOrderStatus(art) {
    if (art.artOrderStatus == "Confirmed") {
      return art.tracking_status?.isNotEmpty == true
          ? art.tracking_status!
          : "Ongoing";
    } else if (art.artOrderStatus == "Return") {
      return art.tracking_status.isEmpty ? art.artOrderStatus : art.tracking_status;
    } else {
      return art.artOrderStatus;
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'Delivered':
        return Color(0XFF000000);
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
