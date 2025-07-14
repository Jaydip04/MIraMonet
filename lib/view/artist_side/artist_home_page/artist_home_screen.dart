import 'dart:convert';

import 'package:artist/config/colors.dart';
import 'package:artist/core/utils/responsive.dart';
import 'package:artist/view/artist_side/artist_home_page/artist_home_screens/artist_total_order_screen.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/api_service/api_service.dart';
import '../../../core/api_service/base_url.dart';
import '../../../core/models/customer_modell.dart';
import '../../../core/utils/app_font_weight.dart';
import '../../../core/widgets/custom_text_2.dart';
import 'package:http/http.dart' as http;

class ArtistHomeScreen extends StatefulWidget {
  const ArtistHomeScreen({super.key});

  @override
  State<ArtistHomeScreen> createState() => _ArtistHomeScreenState();
}

class CustomDrawer extends StatefulWidget {
  final customer_name;
  final customer_image;
  const CustomDrawer(
      {super.key, required this.customer_image, required this.customer_name});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: white, boxShadow: [
        BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.08),
            blurRadius: 60,
            offset: Offset(34, 0),
            spreadRadius: 0)
      ]),
      // backgroundColor: white,
      width: Responsive.getWidth(265),
      // elevation: 1,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: Responsive.getHeight(10),
            ),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: Responsive.getWidth(34)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(bottom: 20),
                          child: ClipRRect(
                            child: widget.customer_image == null
                                ? SizedBox(
                                    height: Responsive.getWidth(68),
                                    width: Responsive.getWidth(68),
                                    child: CircleAvatar(
                                      backgroundColor: Colors.grey.shade300,
                                      radius: 30,
                                      child: WantText2(
                                          text: widget.customer_name[0],
                                          fontSize: Responsive.getFontSize(20),
                                          fontWeight: AppFontWeight.bold,
                                          textColor: black),
                                    ),
                                  )
                                : Image.network(
                                    widget.customer_image,
                                    fit: BoxFit.cover,
                                    height: Responsive.getWidth(68),
                                    width: Responsive.getWidth(68),
                                  ),
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(bottom: 12),
                          child: WantText2(
                              text: widget.customer_name,
                              fontSize: Responsive.getFontSize(16),
                              fontWeight: AppFontWeight.bold,
                              textColor: black),
                        ),
                        // Text(
                        //   'Sophia Rose',
                        //   style: TextStyle(
                        //     fontSize: 18,
                        //     fontWeight: FontWeight.bold,
                        //   ),
                        // ),
                        WantText2(
                            text: "Artist",
                            fontSize: Responsive.getFontSize(16),
                            fontWeight: AppFontWeight.regular,
                            textColor: black),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: Responsive.getHeight(28),
                  ),
                  Divider(
                    color: Color.fromRGBO(226, 228, 229, 1),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: Responsive.getWidth(34)),
                    child: Column(
                      children: [
                        SizedBox(
                          height: Responsive.getHeight(24),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.asset(
                                "assets/home.png",
                                height: Responsive.getWidth(24),
                                width: Responsive.getWidth(24),
                              ),
                              SizedBox(
                                width: Responsive.getWidth(24),
                              ),
                              WantText2(
                                  text: "Home",
                                  fontSize: Responsive.getFontSize(16),
                                  fontWeight: AppFontWeight.regular,
                                  textColor: black)
                            ],
                          ),
                        ),
                        SizedBox(
                          height: Responsive.getHeight(34),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              "/Artist/ArtistMyEnquiryReplayScreen0",
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.asset(
                                "assets/comments.png",
                                height: Responsive.getWidth(24),
                                width: Responsive.getWidth(24),
                              ),
                              SizedBox(
                                width: Responsive.getWidth(24),
                              ),
                              WantText2(
                                  text: "Art Enquiry",
                                  fontSize: Responsive.getFontSize(16),
                                  fontWeight: AppFontWeight.regular,
                                  textColor: black)
                            ],
                          ),
                        ),
                        SizedBox(
                          height: Responsive.getHeight(34),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              "/Artist/ArtistMyEnquiryReplayScreen1",
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.asset(
                                "assets/comments.png",
                                height: Responsive.getWidth(24),
                                width: Responsive.getWidth(24),
                              ),
                              SizedBox(
                                width: Responsive.getWidth(24),
                              ),
                              WantText2(
                                  text: "Private Sale",
                                  fontSize: Responsive.getFontSize(16),
                                  fontWeight: AppFontWeight.regular,
                                  textColor: black)
                            ],
                          ),
                        ),
                        SizedBox(
                          height: Responsive.getHeight(34),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              "/Artist/ArtistReturnOrderAllChatScreen",
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.asset(
                                "assets/comments.png",
                                height: Responsive.getWidth(24),
                                width: Responsive.getWidth(24),
                              ),
                              SizedBox(
                                width: Responsive.getWidth(24),
                              ),
                              WantText2(
                                  text: "Return Enquiry",
                                  fontSize: Responsive.getFontSize(16),
                                  fontWeight: AppFontWeight.regular,
                                  textColor: black)
                            ],
                          ),
                        ),
                        SizedBox(
                          height: Responsive.getHeight(34),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              "/Artist/AllArtForStoryScreen",
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.asset(
                                "assets/add_story.png",
                                height: Responsive.getWidth(24),
                                width: Responsive.getWidth(24),
                              ),
                              SizedBox(
                                width: Responsive.getWidth(24),
                              ),
                              WantText2(
                                  text: "Art Story",
                                  fontSize: Responsive.getFontSize(16),
                                  fontWeight: AppFontWeight.regular,
                                  textColor: black)
                            ],
                          ),
                        ),
                        SizedBox(
                          height: Responsive.getHeight(34),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              "/Artist/Profile",
                              (route) => false,
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.asset(
                                "assets/user.png",
                                height: Responsive.getWidth(24),
                                width: Responsive.getWidth(24),
                              ),
                              SizedBox(
                                width: Responsive.getWidth(24),
                              ),
                              WantText2(
                                  text: "Profile",
                                  fontSize: Responsive.getFontSize(16),
                                  fontWeight: AppFontWeight.regular,
                                  textColor: black)
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArtistHomeScreenState extends State<ArtistHomeScreen> {
  String? customerUniqueID;
  Future<Map<String, dynamic>>? homeCountsData;
  ArtistDashboardData? dashboardData;
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> fetchDashboardData(String customerUniqueId) async {
    final url = Uri.parse(
        "$serverUrl/artist_dashboard");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"customer_unique_id": customerUniqueId}),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      if (jsonResponse["status"] == true) {
        setState(() {
          orderData = {
            "return_orders": int.tryParse(
                    jsonResponse["data"]["return_orders"].toString()) ??
                0,
            "confirmed_orders": int.tryParse(
                    jsonResponse["data"]["confirmed_orders"].toString()) ??
                0,
            "delivered_orders": int.tryParse(
                    jsonResponse["data"]["delivered_orders"].toString()) ??
                0,
            "cancelled_orders": int.tryParse(
                    jsonResponse["data"]["cancelled_orders"].toString()) ??
                0,
          };
          isLoading = false;
        });
      }
    }
  }

  Map<String, int> orderData = {
    "return_orders": 0,
    "confirmed_orders": 0,
    "delivered_orders": 0,
    "cancelled_orders": 0
  };
  bool isLoading = true;

  void _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String customerUniqueId = (prefs.get('customerUniqueId') is String)
        ? prefs.getString('customerUniqueId') ?? ''
        : prefs.getInt('customerUniqueId')?.toString() ?? '';

    print(customerUniqueId.toString());
    fetchCustomerData(customerUniqueId);
    homeCountsData = ApiService().fetchHomeCounts(customerUniqueId);
    fetchDashboardData(customerUniqueId);
    setState(() {
      customerUniqueID = customerUniqueId;
    });
  }

  List<PieChartSectionData> getChartSections() {
    List<Color> colors = [
      Color(0XFF2ECC71),
      Color(0XFF3498DB),
      Color(0XFFE67E22),
      Color(0XFFE74C3C),
    ];
    final List<String> titles = [
      "Delivered",
      "Confirmed",
      "Cancelled",
      "Returns",
    ];
    final List<String> keys = [
      "delivered_orders",
      "confirmed_orders",
      "cancelled_orders",
      "return_orders",
    ];
    double total = orderData.values.fold(0, (sum, item) => sum + item);
    return List.generate(keys.length, (index) {
      final bool isTouched = index == touchedIndex;
      final double fontSize = isTouched ? 12 : 12;
      final double radius = isTouched ? 80 : 60;
      final int value = orderData[keys[index]] ?? 0;
      double percentage = total == 0 ? 0 : (value / total) * 100;
      return PieChartSectionData(
        color: colors[index],
        value: value == 0 ? 0.1 : value.toDouble(),
        title: isTouched ? "${"${titles[index]} order\n$value"} " : "${percentage.toStringAsFixed(1)}%",
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    });
  }

  void showPopupMenu(BuildContext context, FlTapDownEvent event, String title,
      int value, double percentage) {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    Offset tapPosition =
        event.localPosition; // ✅ Use localPosition from FlTapDownEvent

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        tapPosition.dx,
        tapPosition.dy,
        tapPosition.dx + 40,
        tapPosition.dy + 40,
      ),
      items: [
        PopupMenuItem(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Divider(),
              Text("Orders: $value"),
              Text("Percentage: ${percentage.toStringAsFixed(1)}%"),
            ],
          ),
        ),
      ],
    );
  }

  void fetchCustomerData(String customerUniqueId) async {
    ApiService apiService = ApiService();

    try {
      CustomerData customerData =
          await apiService.getCustomerData(customerUniqueId);
      print("customerData : $customerData");
      _updateControllers(customerData);
    } catch (e) {
      print('Error fetching customer data: $e');
    }
  }

  String? imageUrl;
  String? name;

  void _updateControllers(CustomerData customerData) {
    setState(() {
      imageUrl = customerData.customerProfile;
      name = customerData.name;
    });
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  void _toggleDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  int? touchedIndex;
  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      drawerScrimColor: Colors.transparent,
      drawerDragStartBehavior: DragStartBehavior.start,
      drawerEnableOpenDragGesture: false,
      endDrawerEnableOpenDragGesture: false,
      drawerEdgeDragWidth: 10.0,
      drawer: CustomDrawer(
        customer_image: imageUrl,
        customer_name: name,
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: Responsive.getHeight(16)),
              Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: Responsive.getWidth(16)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        name == null
                            ? Text(
                                textAlign: TextAlign.start,
                                "Hi",
                                style: GoogleFonts.poppins(
                                  letterSpacing: 1.5,
                                  color: textBlack8,
                                  fontSize: Responsive.getFontSize(20),
                                  fontWeight: AppFontWeight.bold,
                                ),
                              )
                            : GestureDetector(
                                onTap: () {
                                  _toggleDrawer();
                                },
                                child: Text(
                                  textAlign: TextAlign.start,
                                  "Hi $name!",
                                  style: GoogleFonts.poppins(
                                    letterSpacing: 1.5,
                                    color: textBlack8,
                                    fontSize: Responsive.getFontSize(20),
                                    fontWeight: AppFontWeight.bold,
                                  ),
                                ),
                              ),
                        Text(
                          "May you always in a good condition",
                          textAlign: TextAlign.start,
                          style: GoogleFonts.poppins(
                            letterSpacing: 1.5,
                            color: const Color.fromRGBO(63, 63, 70, 1),
                            fontSize: Responsive.getFontSize(12),
                            fontWeight: AppFontWeight.medium,
                          ),
                        ),
                      ],
                    ),
                    AnimationConfiguration.synchronized(
                      duration: const Duration(milliseconds: 2000),
                      child: SlideAnimation(
                        curve: Curves.easeInOut,
                        child: FadeInAnimation(
                          duration: const Duration(milliseconds: 1000),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(
                                  context, '/Artist/Notification');
                            },
                            child: Stack(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(6),
                                  width: Responsive.getWidth(32),
                                  height: Responsive.getWidth(32),
                                  decoration: BoxDecoration(
                                    color:
                                        const Color.fromRGBO(249, 250, 251, 1),
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            const Color.fromRGBO(0, 0, 0, 0.05),
                                        spreadRadius: 0,
                                        offset: const Offset(0, 1),
                                        blurRadius: 2,
                                      ),
                                    ],
                                    borderRadius: BorderRadius.circular(
                                        Responsive.getWidth(8)),
                                    border: Border.all(
                                      width: 1,
                                      color:
                                          const Color.fromRGBO(0, 0, 0, 0.05),
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
                                //         textColor: Colors.white,
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
                  ],
                ),
              ),
              SizedBox(height: Responsive.getHeight(21)),
              FutureBuilder<Map<String, dynamic>>(
                future: homeCountsData,
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
                    return Center(child: Text('No data available'));
                  } else if (!snapshot.hasData ||
                      snapshot.data!['status'] != true) {
                    return Center(child: Text('No data available'));
                  }

                  final data = snapshot.data!;
                  final totalArt = data['total_art'];
                  final totalOrder = data['total_order'];
                  final cancelOrder = data['cancel_order'];
                  final bookingRequest = data['booking_request'];

                  return Padding(
                      padding: EdgeInsets.all(Responsive.getWidth(16)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildContainer(
                                "/Artist/ArtistMyArtForHomeScreen",
                                'My Art',
                                totalArt,
                                const Color.fromRGBO(254, 243, 242, 1),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              ArtistTotalOrderScreen(
                                                initialTabIndex: 0,
                                              )));
                                },
                                child: Column(
                                  children: [
                                    Container(
                                      width: Responsive.getWidth(166),
                                      height: Responsive.getHeight(82),
                                      decoration: BoxDecoration(
                                        color: Color.fromRGBO(245, 247, 255, 1),
                                        borderRadius: BorderRadius.circular(
                                            Responsive.getWidth(12)),
                                      ),
                                      padding: EdgeInsets.all(
                                          Responsive.getWidth(12)),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          WantText2(
                                            text: 'Total Order',
                                            fontSize:
                                                Responsive.getFontSize(16),
                                            fontWeight: AppFontWeight.bold,
                                            textColor: const Color.fromRGBO(
                                                24, 24, 27, 1),
                                          ),
                                          SizedBox(
                                              height: Responsive.getHeight(4)),
                                          WantText2(
                                            text: "($totalOrder)",
                                            fontSize:
                                                Responsive.getFontSize(14),
                                            fontWeight: AppFontWeight.regular,
                                            textColor: const Color.fromRGBO(
                                                24, 24, 27, 1),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: Responsive.getHeight(14),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildContainer(
                                "/Artist/ArtistBookingRequestScreen",
                                'Booking Request',
                                bookingRequest,
                                const Color.fromRGBO(254, 246, 238, 1),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              ArtistTotalOrderScreen(
                                                initialTabIndex: 5,
                                              )));
                                },
                                child: Column(
                                  children: [
                                    Container(
                                      width: Responsive.getWidth(166),
                                      height: Responsive.getHeight(82),
                                      decoration: BoxDecoration(
                                        color: Color.fromRGBO(237, 252, 242, 1),
                                        borderRadius: BorderRadius.circular(
                                            Responsive.getWidth(12)),
                                      ),
                                      padding: EdgeInsets.all(
                                          Responsive.getWidth(12)),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          WantText2(
                                            text: 'Cancel Order',
                                            fontSize:
                                                Responsive.getFontSize(16),
                                            fontWeight: AppFontWeight.bold,
                                            textColor: const Color.fromRGBO(
                                                24, 24, 27, 1),
                                          ),
                                          SizedBox(
                                              height: Responsive.getHeight(4)),
                                          WantText2(
                                            text: "($cancelOrder)",
                                            fontSize:
                                                Responsive.getFontSize(14),
                                            fontWeight: AppFontWeight.regular,
                                            textColor: const Color.fromRGBO(
                                                24, 24, 27, 1),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        ],
                      ));
                },
              ),
              SizedBox(
                  height: Responsive.getHeight(270),
                  width: Responsive.getMainWidth(context),
                  child: isLoading
                      ? SizedBox()

                  // PieChart(
                  //         PieChartData(
                  //           sections: getChartSections(),
                  //           pieTouchData: PieTouchData(
                  //             touchCallback: (FlTouchEvent event,
                  //                 PieTouchResponse? pieTouchResponse) {
                  //               if (event is FlTapDownEvent) {
                  //                 // ✅ Only handle tap-down events
                  //                 if (pieTouchResponse == null ||
                  //                     pieTouchResponse.touchedSection ==
                  //                         null) {
                  //                   setState(() {
                  //                     touchedIndex = null;
                  //                   });
                  //                   return;
                  //                 }
                  //
                  //                 setState(() {
                  //                   touchedIndex = pieTouchResponse
                  //                       .touchedSection!
                  //                       .touchedSectionIndex;
                  //                 });
                  //
                  //                 if (touchedIndex != null) {
                  //                   final index = touchedIndex!;
                  //                   final title = [
                  //                     "Delivered",
                  //                     "Confirmed",
                  //                     "Cancelled",
                  //                     "Returns"
                  //                   ][index];
                  //                   final key = [
                  //                     "delivered_orders",
                  //                     "confirmed_orders",
                  //                     "cancelled_orders",
                  //                     "return_orders"
                  //                   ][index];
                  //                   final value = orderData[key] ?? 0;
                  //                   final total = orderData.values
                  //                       .fold(0, (sum, item) => sum + item);
                  //                   final double percentage = total == 0
                  //                       ? 0
                  //                       : (value / total) * 100;
                  //
                  //                   showPopupMenu(context, event, title,
                  //                       value, percentage);
                  //                 }
                  //               }
                  //             },
                  //           ),
                  //         ),
                  //       )
                  : PieChart(
                      PieChartData(
                        sectionsSpace: 0,
                        centerSpaceRadius: 50,
                        sections: getChartSections(),
                        pieTouchData: PieTouchData(
                          touchCallback:
                              (FlTouchEvent event, pieTouchResponse) {
                            setState(() {
                              if (!event.isInterestedForInteractions ||
                                  pieTouchResponse == null ||
                                  pieTouchResponse.touchedSection ==
                                      null) {
                                touchedIndex = -1;
                                return;
                              }
                              touchedIndex = pieTouchResponse
                                  .touchedSection!.touchedSectionIndex;
                            });
                          },
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

  Widget buildLegend(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: Responsive.getWidth(12),
          height: Responsive.getWidth(12),
          color: color,
        ),
        SizedBox(width: Responsive.getWidth(5)),
        Text(
          label,
          style: GoogleFonts.poppins(
            color: black,
            fontSize: Responsive.getFontSize(14),
            fontWeight: AppFontWeight.regular,
          ),
        ),
      ],
    );
  }

  // List<PieChartSectionData> showingSections() {
  //   List<Color> colors = [
  //     Color(0XFF2ECC71),
  //     Color(0XFF3498DB),
  //     Color(0XFFE67E22),
  //     Color(0XFFE74C3C),
  //   ];
  //
  //   List<String> keys = [
  //     "delivered_orders",
  //     "confirmed_orders",
  //     "cancelled_orders",
  //     "return_orders",
  //   ];
  //
  //   return List.generate(keys.length, (index) {
  //     final isTouched = index == touchedIndex;
  //     final double fontSize = isTouched ? 18 : 14;
  //     final double radius = isTouched ? 60 : 50;
  //     final String title = keys[index];
  //     final int value = orderData[title] ?? 0;
  //
  //     return PieChartSectionData(
  //       color: colors[index],
  //       value: value.toDouble(),
  //       title: '$value%',
  //       radius: radius,
  //       titleStyle: TextStyle(
  //         fontSize: fontSize,
  //         fontWeight: FontWeight.bold,
  //         color: Colors.white,
  //       ),
  //     );
  //   });
  // }

  List<PieChartSectionData> showingSections() {
    return List.generate(4, (index) {
      final isTouched = index == touchedIndex;
      final double fontSize = isTouched ? 18 : 14;
      final double radius = isTouched ? 60 : 50;
      final colors = [Colors.blue, Colors.red, Colors.green, Colors.orange];

      return PieChartSectionData(
        color: colors[index],
        value: (index + 1) * 10,
        title: '${(index + 1) * 10}%',
        radius: radius,
        // titleStyle: TextStyle(
        //   fontSize: fontSize,
        //   fontWeight: FontWeight.bold,
        //   color: Colors.white,
        // ),
      );
    });
  }

  Widget _buildContainer(String path, String title, int count, Color? color) {
    return GestureDetector(
      onTap: () {
        if (path.isNotEmpty) {
          Navigator.pushNamed(context, path);
        }
      },
      child: Column(
        children: [
          Container(
            width: Responsive.getWidth(166),
            height: Responsive.getHeight(82),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(Responsive.getWidth(12)),
            ),
            padding: EdgeInsets.all(Responsive.getWidth(12)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                WantText2(
                  text: title,
                  fontSize: Responsive.getFontSize(16),
                  fontWeight: AppFontWeight.bold,
                  textColor: const Color.fromRGBO(24, 24, 27, 1),
                ),
                SizedBox(height: Responsive.getHeight(4)),
                WantText2(
                  text: "(${count.toString()})",
                  fontSize: Responsive.getFontSize(14),
                  fontWeight: AppFontWeight.regular,
                  textColor: const Color.fromRGBO(24, 24, 27, 1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ArtistDashboardData {
  final int returnOrders;
  final int confirmedOrders;
  final int deliveredOrders;
  final int cancelledOrders;

  ArtistDashboardData({
    required this.returnOrders,
    required this.confirmedOrders,
    required this.deliveredOrders,
    required this.cancelledOrders,
  });

  factory ArtistDashboardData.fromJson(Map<String, dynamic> json) {
    return ArtistDashboardData(
      returnOrders: json['return_orders'],
      confirmedOrders: json['confirmed_orders'],
      deliveredOrders: json['delivered_orders'],
      cancelledOrders: json['cancelled_orders'],
    );
  }
}
