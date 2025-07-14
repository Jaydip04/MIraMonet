import 'package:artist/core/api_service/api_service.dart';
import 'package:artist/view/user_side/profile_screen/profile_screens/show_ticket_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../../../config/colors.dart';
import '../../../../config/toast.dart';
import '../../../../core/utils/app_font_weight.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/custom_text_2.dart';
import '../../../../core/widgets/expandable_text.dart';
import '../../artist_create_art_page/artist_upload_art_screens/artist_exhibition_card_screen.dart';
import 'artist_show_exhibition_card_screen.dart';

class ArtistMyTicketScreen extends StatefulWidget {
  @override
  State<ArtistMyTicketScreen> createState() => _ArtistMyTicketScreenState();
}

class _ArtistMyTicketScreenState extends State<ArtistMyTicketScreen> {
  String? customerUniqueID;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

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

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: white,
        body: SafeArea(
          child: FutureBuilder<Map<String, dynamic>>(
            future: ApiService()
                .fetchExhibitionsTicketseller(customerUniqueID.toString()),
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
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        "assets/profile_image/tiket.png",
                        width: Responsive.getWidth(64),
                        height: Responsive.getWidth(64),
                      ),
                      SizedBox(height: Responsive.getHeight(10)),
                      WantText2(
                        text: "No Ticket!",
                        fontSize: Responsive.getFontSize(20),
                        fontWeight: AppFontWeight.semiBold,
                        textColor: textBlack11,
                      ),
                    ],
                  ),
                );
              } else {
                final exhibitions = snapshot.data!;
                return ListView(
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
                                    color: textFieldBorderColor, width: 1.0),
                              ),
                              child: Icon(
                                Icons.arrow_back_ios_new_outlined,
                                size: Responsive.getWidth(19),
                              ),
                            ),
                          ),
                          SizedBox(width: Responsive.getWidth(95)),
                          WantText2(
                            text: "My Ticket",
                            fontSize: Responsive.getFontSize(18),
                            fontWeight: AppFontWeight.medium,
                            textColor: textBlack,
                          ),
                        ],
                      ),
                    ),
                    exhibitions['upcoming_exhibitions'] == null
                        ? Container(
                            height: Responsive.getHeight(600),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  "assets/profile_image/tiket.png",
                                  width: Responsive.getWidth(64),
                                  height: Responsive.getWidth(64),
                                ),
                                SizedBox(height: Responsive.getHeight(10)),
                                WantText2(
                                  text: "No Ticket!",
                                  fontSize: Responsive.getFontSize(20),
                                  fontWeight: AppFontWeight.semiBold,
                                  textColor: textBlack11,
                                ),
                              ],
                            ),
                          )
                        : Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: Responsive.getWidth(16)),
                            height: Responsive.getHeight(55),
                            child: TabBar(
                              indicatorColor: black,
                              indicatorSize: TabBarIndicatorSize.tab,
                              labelColor: Colors.black,
                              labelStyle: GoogleFonts.poppins(
                                  color: black,
                                  fontSize: Responsive.getFontSize(14),
                                  fontWeight: AppFontWeight.medium,
                                  letterSpacing: 1.5),
                              tabs: [
                                Tab(text: "Future Exhibition"),
                                Tab(text: "Past Exhibition"),
                              ],
                            ),
                          ),
                    exhibitions['upcoming_exhibitions'] == null
                        ? SizedBox()
                        : SizedBox(height: Responsive.getHeight(16)),
                    exhibitions['upcoming_exhibitions'] == null
                        ? SizedBox()
                        : Container(
                            height: Responsive.getHeight(660),
                            child: TabBarView(
                              children: [
                                FutureExhibitions(
                                    exhibitions['upcoming_exhibitions']),
                                PastExhibitions(
                                    exhibitions['recent_exhibitions']),
                              ],
                            ),
                          ),
                  ],
                );
              }
            },
          ),
        ),
      ),
    );
  }
}

class FutureExhibitions extends StatelessWidget {
  final List<dynamic> upcomingExhibitions;

  FutureExhibitions(this.upcomingExhibitions);

  @override
  Widget build(BuildContext context) {
    if (upcomingExhibitions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/profile_image/tiket.png",
              width: Responsive.getWidth(64),
              height: Responsive.getWidth(64),
            ),
            SizedBox(height: Responsive.getHeight(24)),
            WantText2(
              text: "No Future Ticket!",
              fontSize: Responsive.getFontSize(20),
              fontWeight: AppFontWeight.semiBold,
              textColor: textBlack11,
            ),
          ],
        ),
      );
    } else {
      return ListView.builder(
        itemCount: upcomingExhibitions.length,
        itemBuilder: (context, index) {
          return EventCard(exhibition: upcomingExhibitions[index]);
        },
      );
    }
  }
}

class PastExhibitions extends StatelessWidget {
  final List<dynamic> recentExhibitions;

  PastExhibitions(this.recentExhibitions);

  @override
  Widget build(BuildContext context) {
    if (recentExhibitions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/profile_image/tiket.png",
              width: Responsive.getWidth(64),
              height: Responsive.getWidth(64),
            ),
            SizedBox(height: Responsive.getHeight(10)),
            WantText2(
              text: "No Past Ticket!",
              fontSize: Responsive.getFontSize(20),
              fontWeight: AppFontWeight.semiBold,
              textColor: textBlack11,
            ),
          ],
        ),
      );
    } else {
      return ListView.builder(
        itemCount: recentExhibitions.length,
        itemBuilder: (context, index) {
          return EventCard(exhibition: recentExhibitions[index]);
        },
      );
    }
  }
}

class EventCard extends StatefulWidget {
  final Map<String, dynamic> exhibition;

  EventCard({required this.exhibition});

  @override
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
  final ApiService apiService = ApiService();
  bool isLoading = false;
  Future<void> registerForExhibition(BuildContext context) async {
    setState(() {
      isLoading = true;
    });
    final response = await apiService.registerTicketSeller(
        widget.exhibition['registration_code'].toString());

    if (response != null) {
      setState(() {
        isLoading = false;
      });
      if (response['status'] == 'true') {
        setState(() {
          isLoading = false;
        });
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ArtistShowExhibitionCardScreen(
                exhibitionData: response['data']),
          ),
        );
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } else {
      setState(() {
        isLoading = false;
      });
      showToast(message: "Registration failed. Please try again.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // width: 341,
      margin: EdgeInsets.symmetric(
          vertical: Responsive.getHeight(9),
          horizontal: Responsive.getWidth(16)),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(Responsive.getWidth(10)),
          boxShadow: [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.04),
              blurRadius: 50,
              spreadRadius: 0,
              offset: Offset(0, 10),
            ),
          ],
          border:
              Border.all(color: Color.fromRGBO(218, 218, 218, 1), width: 1)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(Responsive.getWidth(10)),
                topRight: Radius.circular(Responsive.getWidth(10))),
            child: Image.network(
              widget.exhibition['logo'],
              height: 163,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(height: Responsive.getHeight(10)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: Responsive.getWidth(9)),
            child: Text(
              widget.exhibition['name'].toString().toUpperCase(),
              style: GoogleFonts.poppins(
                  letterSpacing: 1.5,
                  fontSize: Responsive.getFontSize(16),
                  fontWeight: AppFontWeight.medium,
                  color: textBlack),
            ),
          ),
          SizedBox(height: Responsive.getHeight(1)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: Responsive.getWidth(9)),
            child:
                // ExpandableText(text: widget.exhibition['description'],maxLines: 2,),
                Text(
              widget.exhibition['description'],
                  maxLines: 2,
              style: GoogleFonts.poppins(
                  letterSpacing: 1.5,
                  fontSize: Responsive.getFontSize(10),
                  color: Color.fromRGBO(174, 174, 174, 1),
                  fontWeight: AppFontWeight.regular),
            ),
          ),
          SizedBox(height: Responsive.getHeight(4)),
          // Padding(
          //   padding: EdgeInsets.symmetric(horizontal: Responsive.getWidth(9)),
          //   child: Text(
          //     'Date & Time',
          //     style: GoogleFonts.poppins(
          //         letterSpacing: 1.5,
          //         fontSize: Responsive.getFontSize(10),
          //         color: Color.fromRGBO(174, 174, 174, 1),
          //         fontWeight: AppFontWeight.medium),
          //   ),
          // ),
          // SizedBox(height: Responsive.getHeight(1)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: Responsive.getWidth(9)),
            child: Text(
              "Start Date : ${widget.exhibition['start_date']}",
              style: GoogleFonts.poppins(
                  letterSpacing: 1.5,
                  fontSize: Responsive.getFontSize(12),
                  color: textBlack,
                  fontWeight: AppFontWeight.medium),
            ),
          ),
          SizedBox(height: Responsive.getHeight(18)),
          Image.asset("assets/line_2.png"),
          SizedBox(height: Responsive.getHeight(21)),
          GestureDetector(
            onTap: () {
              registerForExhibition(context);
            },
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
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Show Your Ticket',
                        style: GoogleFonts.poppins(
                            letterSpacing: 1.5,
                            fontSize: Responsive.getFontSize(14),
                            color: textBlack,
                            fontWeight: AppFontWeight.regular),
                      ),
                      SizedBox(
                        width: Responsive.getWidth(10),
                      ),
                      Image.asset(
                        "assets/profile_image/tiket.png",
                        height: Responsive.getWidth(26),
                        width: Responsive.getWidth(26),
                      )
                    ],
                  ),
          ),
          SizedBox(height: Responsive.getHeight(21)),
        ],
      ),
    );
  }
}
