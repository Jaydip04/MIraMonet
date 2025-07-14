import 'dart:async';
import 'dart:convert';

import 'package:artist/config/toast.dart';
import 'package:artist/core/api_service/api_service.dart';
import 'package:artist/view/user_side/home_screen/upcoming_exhibition/single_upcoming_exhibitions/register_payment_screen.dart';
import 'package:artist/view/user_side/profile_screen/profile_screens/full_screen_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:page_transition/page_transition.dart';
import 'package:pinput/pinput.dart';
import 'package:scroll_loop_auto_scroll/scroll_loop_auto_scroll.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../../../config/colors.dart';
import '../../../../core/models/user_side/single_exhibitions_model.dart';
import '../../../../core/utils/app_font_weight.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/app_text_form_field.dart';
import '../../../../core/widgets/custom_text_2.dart';
import '../../../../core/widgets/general_button.dart';
import '../../../../core/widgets/expandable_text.dart';
import '../../../user_side/home_screen/upcoming_exhibition/single_upcoming_exhibitions/single_auction_art_screen.dart';
import '../../artist_my_art_page/single_art_screen/artist_review_art_screen.dart';
import 'artist_exhibition_seat_booking_screen.dart';
import 'artist_register_payment_screen.dart';
import 'exhibition/artist_exhibition_upload_screen.dart';

class ArtistSingleUpcomingExhibitionScreen extends StatefulWidget {

  final exhibition_unique_id;
  final exhibition_type;
  const ArtistSingleUpcomingExhibitionScreen(
      {super.key, required this.exhibition_unique_id,required this.exhibition_type,});

  @override
  State<ArtistSingleUpcomingExhibitionScreen> createState() =>
      _ArtistSingleUpcomingExhibitionScreenState();
}

class _ArtistSingleUpcomingExhibitionScreenState
    extends State<ArtistSingleUpcomingExhibitionScreen> {
  Map<String, dynamic>? exhibitionDetails;
  bool isLoading = true;
  late ScrollController _scrollController;
  late Timer _timer;
  double _scrollPosition = 0.0;

  late ScrollController _scrollController2;
  late Timer _timer2;
  double _scrollPosition2 = 0.0;
  @override
  void initState() {
    super.initState();
    fetchDetails();
    _loadUserData();
    _scrollController = ScrollController();
    _timer = Timer.periodic(Duration(seconds: 2), (timer) {
      if (_scrollController.hasClients) {
        _scrollPosition += 50;
        if (_scrollPosition >= _scrollController.position.maxScrollExtent) {
          _scrollPosition = 0.0;
        }
        _scrollController.animateTo(
          _scrollPosition,
          duration: Duration(seconds: 1),
          curve: Curves.easeInOut,
        );
      }
    });
    _scrollController2 = ScrollController();
    _timer2 = Timer.periodic(Duration(seconds: 2), (timer) {
      if (_scrollController2.hasClients) {
        _scrollPosition2 += 50;
        if (_scrollPosition2 >= _scrollController2.position.maxScrollExtent) {
          _scrollPosition2 = 0.0;
        }
        _scrollController2.animateTo(
          _scrollPosition2,
          duration: Duration(seconds: 1),
          curve: Curves.easeInOut,
        );
      }
    });
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

  int? exhibitionId;
  String? exhibitionUniqueId;
  String? exhibitionName;
  int? isArtApproved;
  int? isBooth;
  bool? isAdd;
  bool? isFull;
  bool? isRegister;

  void fetchDetails() async {
    try {
      final details = await ApiService()
          .fetchExhibitionDetailsSeller(widget.exhibition_unique_id);

      setState(() {
        exhibitionDetails = details;

        // Store values in separate variables
        exhibitionId = exhibitionDetails!['exhibition']['exhibition_id'];
        exhibitionUniqueId =
            exhibitionDetails!['exhibition']['exhibition_unique_id'];
        exhibitionName = exhibitionDetails!['exhibition']['name'];
        isArtApproved = exhibitionDetails!['exhibition']['isArtApproved'];
        isBooth = exhibitionDetails!['exhibition']['is_booth'];
        isAdd = exhibitionDetails!['exhibition']['isAdd'];
        isFull = exhibitionDetails!['exhibition']['isFull'];
        isRegister = exhibitionDetails!['exhibition']['isRegister'];
        //
        isLoading = false;

        // Print the stored values
        print("Exhibition ID: $exhibitionId");
        print("Exhibition Unique ID: $exhibitionUniqueId");
        print("Exhibition Name: $exhibitionName");
        print("isArtApproved: $isArtApproved");
        print("isBooth: $isBooth");
        print("isAdd: $isAdd");
        print("isFull: $isFull");
        print("isRegister: $isRegister");
      });
    } catch (e) {
      print("Error fetching details: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  // void fetchDetails() async {
  //   try {
  //     final details = await ApiService()
  //         .fetchExhibitionDetailsSeller(widget.exhibition_unique_id);
  //     setState(() {
  //       exhibitionDetails = details;
  //       // print(exhibitionDetails);
  //       print(exhibitionDetails!['isArtApproved']);
  //       print(exhibitionDetails!['is_booth']);
  //       print(exhibitionDetails!['isAdd']);
  //       print(exhibitionDetails!['isFull']);
  //       print(exhibitionDetails!['isRegister']);
  //       isLoading = false;
  //     });
  //   } catch (e) {
  //     print(e);
  //     setState(() {
  //       isLoading = false;
  //     });
  //   }
  // }

  bool _isChecked = true;
  String convertDate(String inputDate) {
    DateTime date = DateTime.parse(inputDate);
    DateTime newDate = DateTime(date.year - 1, date.month - 1, date.day);
    return DateFormat("MMM dd, yyyy").format(newDate);
  }

  bool showAll = false;

  @override
  Widget build(BuildContext context) {
    int itemCount =
        showAll ? exhibitionDetails!['exhibition']["termData"].length : 2;
    Responsive.init(context);
    return Scaffold(
      backgroundColor: white,
      body: isLoading
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
          : ListView(
              children: [
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: Responsive.getWidth(16)),
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
                      SizedBox(
                        width: Responsive.getWidth(35),
                      ),
                      WantText2(
                          text: "Upcoming Exhibition",
                          fontSize: Responsive.getFontSize(18),
                          fontWeight: AppFontWeight.medium,
                          textColor: textBlack)
                    ],
                  ),
                ),
                Container(
                  width: Responsive.getWidth(343),
                  height: Responsive.getWidth(343),
                  margin: EdgeInsets.symmetric(
                      horizontal: Responsive.getWidth(16),
                      vertical: Responsive.getHeight(16)),
                  child: Image.network(
                    exhibitionDetails!['exhibition']["banner"],
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: Responsive.getWidth(16)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exhibitionDetails!['exhibition']["name"]
                            .toString()
                            .toUpperCase(),
                        style: GoogleFonts.poppins(
                          letterSpacing: 1.5,
                          color: textBlack4,
                          fontSize: Responsive.getFontSize(20),
                          fontWeight: AppFontWeight.medium,
                        ),
                      ),
                      ExpandableText(
                        text: exhibitionDetails!['exhibition']["description"],
                        maxLines: 3,
                      ),
                      // Text(
                      //   exhibitionDetails!['exhibition']["description"],
                      //   style: GoogleFonts.poppins(
                      //     letterSpacing: 1.5,
                      //     color: textBlack4,
                      //     fontSize: Responsive.getFontSize(16),
                      //     fontWeight: AppFontWeight.regular,
                      //   ),
                      // ),
                      SizedBox(height: Responsive.getHeight(5)),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: Responsive.getWidth(16),
                            color: textGray9,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Container(
                            width: Responsive.getWidth(310),
                            child: Text(
                              textAlign: TextAlign.start,
                              "${exhibitionDetails!['exhibition']["address1"]}, ${exhibitionDetails!['exhibition']["city"]["name_of_city"]}, ${exhibitionDetails!['exhibition']["state"]["state_subdivision_name"]}, ${exhibitionDetails!['exhibition']["country"]["country_name"]}",
                              style: GoogleFonts.poppins(
                                  color: textGray9,
                                  fontSize: Responsive.getFontSize(14),
                                  fontWeight: AppFontWeight.regular,
                                  letterSpacing: 1.5),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: Responsive.getHeight(5)),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_month,
                            size: Responsive.getWidth(16),
                            color: textGray9,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Container(
                            width: Responsive.getWidth(310),
                            child: WantText2(
                              text:
                                  "${convertDate(exhibitionDetails!['exhibition']["start_date"])} - ${convertDate(exhibitionDetails!['exhibition']["end_date"])}",
                              fontSize: Responsive.getFontSize(14),
                              fontWeight: AppFontWeight.regular,
                              textColor: textGray9,
                              // textOverflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: Responsive.getHeight(5)),
                      Row(
                        children: [
                          Image.asset(
                            "assets/exhibition_theme.png",
                            height: 16,
                            width: 16,
                          ),
                          // Icon(
                          //   ,
                          //   size: Responsive.getWidth(16),
                          //   color: textGray9,
                          // ),
                          SizedBox(
                            width: 10,
                          ),
                          Container(
                            width: Responsive.getWidth(310),
                            child: WantText2(
                              text:
                                  "Exhibition Theme : ${exhibitionDetails!["exhibition"]["theme"]}",
                              fontSize: Responsive.getFontSize(14),
                              fontWeight: AppFontWeight.regular,
                              textColor: textGray9,
                              // textOverflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: Responsive.getHeight(5)),
                      Row(
                        children: [
                          Icon(
                            Icons.category_outlined,
                            size: Responsive.getWidth(16),
                            color: textGray9,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Container(
                            width: Responsive.getWidth(310),
                            child: WantText2(
                              text:
                                  "Exhibition Category : ${exhibitionDetails!["exhibition"]["category"]["category_name"]}",
                              fontSize: Responsive.getFontSize(14),
                              fontWeight: AppFontWeight.regular,
                              textColor: textGray9,
                              // textOverflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: Responsive.getHeight(11)),
                exhibitionDetails!["exhibition"]["exhibition_art"].length == 0
                    ? Container()
                    : Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: Responsive.getWidth(16)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            WantText2(
                              text: "Auction Art",
                              fontSize: Responsive.getFontSize(20),
                              fontWeight: AppFontWeight.medium,
                              textColor: Colors.black,
                            ),
                            WantText2(
                              text: "",
                              fontSize: Responsive.getFontSize(12),
                              fontWeight: AppFontWeight.medium,
                              textColor: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                exhibitionDetails!["exhibition"]["exhibition_art"].length == 0
                    ? Container()
                    : SizedBox(height: Responsive.getHeight(11)),
                exhibitionDetails!["exhibition"]["exhibition_art"].length == 0
                    ? Container()
                    : Container(
                  padding: EdgeInsets.only(left: Responsive.getWidth(16)),
                  height: Responsive.getHeight(200),
                  child: ScrollLoopAutoScroll(
                    scrollDirection: Axis.horizontal,
                    delay: Duration(seconds: 0),
                    duration: Duration(seconds: 120),
                    gap: 10, // Space between items
                    reverseScroll: false, // Scrolls in one direction
                    enableScrollInput: false, // Disable manual scrolling
                    child: Row(
                      children: List.generate(
                        exhibitionDetails!["exhibition"]["exhibition_art"]
                            .length,
                            (index) {
                          var artDetails =
                          exhibitionDetails!["exhibition"]
                          ["exhibition_art"][index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => SingleAuctionArtScreen(
                                    artUniqueID:
                                    artDetails["art_unique_id"],
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              width: Responsive.getWidth(140),
                              height: Responsive.getHeight(200),
                              margin: EdgeInsets.only(
                                  right: Responsive.getWidth(10)),
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: Responsive.getWidth(140),
                                    height: Responsive.getHeight(140),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                          Responsive.getWidth(4)),
                                      image: DecorationImage(
                                        image: NetworkImage(
                                            artDetails["exhibition_art_image"][1]
                                            ["image"]),
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                      height: Responsive.getHeight(6)),
                                  Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                    MainAxisAlignment.center,
                                    children: [
                                      WantText2(
                                        text: artDetails["title"],
                                        fontSize:
                                        Responsive.getFontSize(10),
                                        fontWeight: AppFontWeight.bold,
                                        textColor: textBlack,
                                      ),
                                      SizedBox(
                                          height:
                                          Responsive.getHeight(2)),
                                      WantText2(
                                        text: artDetails["artist_name"],
                                        fontSize:
                                        Responsive.getFontSize(8),
                                        fontWeight: AppFontWeight.regular,
                                        textColor: textGray7,
                                      ),
                                      SizedBox(
                                          height:
                                          Responsive.getHeight(2)),
                                      WantText2(
                                        text: 'Bid Price : \$${artDetails["price"]}',
                                        fontSize:
                                        Responsive.getFontSize(8),
                                        fontWeight:
                                        AppFontWeight.semiBold,
                                        textColor: black,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  // child: ListView.builder(
                  //   controller: _scrollController,
                  //   scrollDirection: Axis.horizontal,
                  //   itemCount: exhibitionDetails!["exhibition"]
                  //           ["exhibition_art"]
                  //       .length,
                  //   itemBuilder: (context, index) {
                  //     return GestureDetector(
                  //       onTap: () {
                  //         Navigator.push(
                  //             context,
                  //             MaterialPageRoute(
                  //                 builder: (_) => ArtistSingleArtScreen(
                  //                     artUniqueID:
                  //                         exhibitionDetails!["exhibition"]
                  //                                     ["exhibition_art"]
                  //                                 [index]["art"]
                  //                             ["art_unique_id"])));
                  //       },
                  //       child: Container(
                  //         width: Responsive.getWidth(140),
                  //         height: Responsive.getHeight(200),
                  //         margin: EdgeInsets.only(
                  //             right: Responsive.getWidth(10)),
                  //         child: Column(
                  //           crossAxisAlignment: CrossAxisAlignment.start,
                  //           children: [
                  //             Container(
                  //               width: Responsive.getWidth(140),
                  //               height: Responsive.getHeight(140),
                  //               decoration: BoxDecoration(
                  //                   borderRadius: BorderRadius.circular(
                  //                       Responsive.getWidth(4)),
                  //                   image: DecorationImage(
                  //                       image: NetworkImage(
                  //                           exhibitionDetails![
                  //                                           "exhibition"]
                  //                                       ["exhibition_art"]
                  //                                   [index]["art"][
                  //                               "art_images"][1]["image"]),
                  //                       fit: BoxFit.fill)),
                  //             ),
                  //             SizedBox(
                  //               height: Responsive.getHeight(6),
                  //             ),
                  //             Column(
                  //               crossAxisAlignment:
                  //                   CrossAxisAlignment.start,
                  //               mainAxisAlignment:
                  //                   MainAxisAlignment.center,
                  //               children: [
                  //                 WantText2(
                  //                     text:
                  //                         exhibitionDetails!["exhibition"]
                  //                                 ["exhibition_art"]
                  //                             [index]["art"]["title"],
                  //                     fontSize:
                  //                         Responsive.getFontSize(10),
                  //                     fontWeight: AppFontWeight.bold,
                  //                     textColor: textBlack),
                  //                 SizedBox(
                  //                   height: Responsive.getHeight(2),
                  //                 ),
                  //                 WantText2(
                  //                     text:
                  //                         exhibitionDetails!["exhibition"]
                  //                                     ["exhibition_art"]
                  //                                 [index]["art"]
                  //                             ["artist_name"],
                  //                     fontSize: Responsive.getFontSize(8),
                  //                     fontWeight: AppFontWeight.regular,
                  //                     textColor: textGray7),
                  //                 SizedBox(
                  //                   height: Responsive.getHeight(2),
                  //                 ),
                  //                 WantText2(
                  //                     text:
                  //                         '\$${exhibitionDetails!["exhibition"]["exhibition_art"][index]["art"]["price"]}',
                  //                     fontSize:
                  //                         Responsive.getFontSize(12),
                  //                     fontWeight: AppFontWeight.semiBold,
                  //                     textColor: black)
                  //               ],
                  //             )
                  //           ],
                  //         ),
                  //       ),
                  //     );
                  //   },
                  // ),
                ),
                exhibitionDetails!["exhibition"]["exhibition_guests"].length ==
                        0
                    ? Container()
                    : SizedBox(height: Responsive.getHeight(15)),
                exhibitionDetails!["exhibition"]["exhibition_guests"].length ==
                        0
                    ? Container()
                    : Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: Responsive.getWidth(16)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            WantText2(
                              text: "Chief Guests",
                              fontSize: Responsive.getFontSize(20),
                              fontWeight: AppFontWeight.medium,
                              textColor: Colors.black,
                            ),
                            WantText2(
                              text: "",
                              fontSize: Responsive.getFontSize(12),
                              fontWeight: AppFontWeight.medium,
                              textColor: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                exhibitionDetails!["exhibition"]["exhibition_guests"].length ==
                        0
                    ? Container()
                    : SizedBox(height: Responsive.getHeight(11)),
                exhibitionDetails!["exhibition"]["exhibition_guests"].length ==
                        0
                    ? Container()
                    : Container(
                        padding: EdgeInsets.only(left: Responsive.getWidth(16)),
                        // height: Responsive.getHeight(100),
                        child: StaggeredGridView.countBuilder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: exhibitionDetails!["exhibition"]
                                  ["exhibition_guests"]
                              .length,
                          mainAxisSpacing: 20,
                          crossAxisSpacing: 20,
                          crossAxisCount: 3,
                          staggeredTileBuilder: (index) => StaggeredTile.fit(1),
                          itemBuilder: (context, index) {
                            // final item = exhibition[index];
                            return GestureDetector(
                              onTap: () {
                                showChiefGuestsDialog(
                                    exhibitionDetails!["exhibition"]
                                        ["exhibition_guests"][index]["photo"],
                                    exhibitionDetails!["exhibition"]
                                        ["exhibition_guests"][index]["name"],
                                    exhibitionDetails!["exhibition"]
                                        ["exhibition_guests"][index]["message"],
                                    exhibitionDetails!["exhibition"]
                                            ["exhibition_guests"][index]
                                        ["position"]);
                                // Navigator.push(
                                //     context,
                                //     MaterialPageRoute(
                                //         builder: (_) => FullScreenImage(
                                //             image: exhibitionDetails![
                                //             "exhibition_guests"]
                                //             [index]["photo"])));
                              },
                              child: Container(
                                width: Responsive.getWidth(60),
                                height: Responsive.getWidth(90),
                                margin: EdgeInsets.only(
                                    right: Responsive.getWidth(18)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: Responsive.getWidth(60),
                                      height: Responsive.getWidth(60),
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                              Responsive.getWidth(30)),
                                          image: DecorationImage(
                                              image: NetworkImage(
                                                  exhibitionDetails![
                                                              "exhibition"]
                                                          ["exhibition_guests"]
                                                      [index]["photo"]),
                                              fit: BoxFit.cover)),
                                    ),
                                    SizedBox(
                                      height: Responsive.getHeight(6),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        WantText2(
                                            text:
                                                exhibitionDetails!["exhibition"]
                                                        ["exhibition_guests"]
                                                    [index]["name"],
                                            fontSize:
                                                Responsive.getFontSize(14),
                                            fontWeight: AppFontWeight.regular,
                                            textColor: textGray8),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                exhibitionDetails!["exhibition"]["exhibition_gallery"].length ==
                        0
                    ? Container()
                    : SizedBox(height: Responsive.getHeight(15)),
                exhibitionDetails!["exhibition"]["exhibition_gallery"].length ==
                        0
                    ? Container()
                    : Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: Responsive.getWidth(16)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            WantText2(
                              text: "Gallery",
                              fontSize: Responsive.getFontSize(20),
                              fontWeight: AppFontWeight.medium,
                              textColor: Colors.black,
                            ),
                            WantText2(
                              text: "",
                              fontSize: Responsive.getFontSize(12),
                              fontWeight: AppFontWeight.medium,
                              textColor: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                exhibitionDetails!["exhibition"]["exhibition_gallery"].length ==
                        0
                    ? Container()
                    : SizedBox(height: Responsive.getHeight(11)),
                exhibitionDetails!["exhibition"]["exhibition_gallery"].length ==
                        0
                    ? Container()
                    : Container(
                  padding: EdgeInsets.only(left: Responsive.getWidth(16)),
                  height: Responsive.getHeight(178),
                  child: ScrollLoopAutoScroll(
                    scrollDirection: Axis.horizontal,
                    delay: Duration(seconds: 0),
                    duration: Duration(seconds: 120),
                    gap: 18,
                    reverseScroll: false, // Scrolls left to right
                    enableScrollInput: false, // Disables manual scroll
                    child: Row(
                      children: List.generate(
                        exhibitionDetails!["exhibition"]
                        ["exhibition_gallery"]
                            .length,
                            (index) {
                          var galleryItem =
                          exhibitionDetails!["exhibition"]
                          ["exhibition_gallery"][index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => FullScreenImage(
                                      image: galleryItem["link"]),
                                ),
                              );
                            },
                            child: Container(
                              width: Responsive.getWidth(140),
                              height: Responsive.getHeight(178),
                              margin: EdgeInsets.only(
                                  right: Responsive.getWidth(18)),
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width: Responsive.getWidth(140),
                                    height: Responsive.getHeight(140),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                          Responsive.getWidth(4)),
                                      image: DecorationImage(
                                        image: NetworkImage(
                                            galleryItem["link"]),
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                      height: Responsive.getHeight(6)),
                                  WantText2(
                                    text: galleryItem["tagline"],
                                    fontSize: Responsive.getFontSize(14),
                                    fontWeight: AppFontWeight.regular,
                                    textColor: textGray8,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(height: Responsive.getHeight(7)),
                exhibitionDetails!["exhibition"]["exhibition_sponsor"].length ==
                        0
                    ? Container()
                    : SizedBox(height: Responsive.getHeight(15)),
                exhibitionDetails!["exhibition"]["exhibition_sponsor"].length ==
                        0
                    ? Container()
                    : Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: Responsive.getWidth(16)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            WantText2(
                              text: "Exhibition Sponcer's",
                              fontSize: Responsive.getFontSize(20),
                              fontWeight: AppFontWeight.medium,
                              textColor: Colors.black,
                            ),
                            WantText2(
                              text: "",
                              fontSize: Responsive.getFontSize(12),
                              fontWeight: AppFontWeight.medium,
                              textColor: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                exhibitionDetails!["exhibition"]["exhibition_sponsor"].length ==
                        0
                    ? Container()
                    : SizedBox(height: Responsive.getHeight(11)),
                exhibitionDetails!["exhibition"]["exhibition_sponsor"].length ==
                        0
                    ? Container()
                    : Container(
                        padding: EdgeInsets.only(left: Responsive.getWidth(16)),
                        // height: Responsive.getHeight(100),
                        child: StaggeredGridView.countBuilder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: exhibitionDetails!["exhibition"]
                                  ["exhibition_sponsor"]
                              .length,
                          mainAxisSpacing: 20,
                          crossAxisSpacing: 20,
                          crossAxisCount: 3,
                          staggeredTileBuilder: (index) => StaggeredTile.fit(1),
                          itemBuilder: (context, index) {
                            // final item = exhibition[index];
                            return GestureDetector(
                              onTap: () {},
                              child: Container(
                                width: Responsive.getWidth(60),
                                height: Responsive.getWidth(90),
                                margin: EdgeInsets.only(
                                    right: Responsive.getWidth(18)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: Responsive.getWidth(60),
                                      height: Responsive.getWidth(60),
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                              Responsive.getWidth(30)),
                                          image: DecorationImage(
                                              image: NetworkImage(
                                                  exhibitionDetails![
                                                              "exhibition"]
                                                          ["exhibition_sponsor"]
                                                      [index]["logo"]),
                                              fit: BoxFit.fill)),
                                    ),
                                    SizedBox(
                                      height: Responsive.getHeight(6),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        WantText2(
                                            text:
                                                exhibitionDetails!["exhibition"]
                                                        ["exhibition_sponsor"]
                                                    [index]["title"],
                                            fontSize:
                                                Responsive.getFontSize(14),
                                            fontWeight: AppFontWeight.regular,
                                            textColor: textGray8),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                SizedBox(height: Responsive.getHeight(16)),
                exhibitionDetails!['exhibition']["termData"].length ==0 ? SizedBox() : Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: Responsive.getHeight(16)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [

                      SizedBox(
                        child: Text(
                          "Artistry Submission & Display Guidelines",
                          style: GoogleFonts.poppins(
                              fontSize: Responsive.getFontSize(16),
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5),
                        ),
                        width: Responsive.getWidth(210),
                      ),
                      if (exhibitionDetails!['exhibition']["termData"].length > 2)
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              showAll = !showAll;
                            });
                          },
                          child: WantText2(
                              text: showAll ? "See Less" : "See All",
                              fontSize: Responsive.getFontSize(14),
                              fontWeight: AppFontWeight.regular,
                              textColor: black),
                        ),
                    ],
                  ),
                ),
                exhibitionDetails!['exhibition']["termData"].length ==0 ? SizedBox() : SizedBox(height: Responsive.getHeight(8)),
                exhibitionDetails!['exhibition']["termData"].length ==0 ? SizedBox() : ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: itemCount,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 5, horizontal: Responsive.getHeight(16)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              // width: 15,
                              // height: 10,
                              // decoration: BoxDecoration(
                              //   color: Colors.black.withOpacity(0.6),
                              //   borderRadius: BorderRadius.circular(15),
                              // ),
                              child: WantText2(
                                  text: "${index + 1}.",
                                  fontSize: Responsive.getFontSize(16),
                                  fontWeight: FontWeight.bold,
                                  textColor: black),
                            ),
                            SizedBox(width: 10),
                            Flexible(
                              child: Text(
                                exhibitionDetails!['exhibition']["termData"]
                                    [index]['para'],
                                style: GoogleFonts.poppins(
                                    fontSize: Responsive.getFontSize(16),
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: 1.5),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                // TextButton(
                //   onPressed: () {
                //     setState(() {
                //       showAll = !showAll; // Toggle state
                //     });
                //   },
                //   child: Text(
                //     showAll ? "See Less" : "See All",
                //     style: GoogleFonts.poppins(
                //       fontSize: 16,
                //       fontWeight: FontWeight.bold,
                //       color: Colors.blue, // Change color as needed
                //     ),
                //   ),
                // ),
                SizedBox(height: Responsive.getHeight(7)),
                Padding(
                  padding: EdgeInsets.only(left: Responsive.getWidth(16)),
                  child: TermsCheckbox(exhibitionUniqueId.toString()),
                ),
                SizedBox(height: Responsive.getHeight(16)),
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: Responsive.getWidth(16)),
                  child: Column(
                    children: [
                      isArtApproved == 1
                          ? Row(
                              children: [
                                GeneralButton(
                                  Width: Responsive.getWidth(340),
                                  onTap: () {
                                    print("${exhibitionUniqueId}");
                                    isBooth == 0
                                        ? isRegister == false
                                            ? showCongratulationsDialog()
                                            : showRegisterDialog(context,
                                                exhibitionUniqueId.toString())
                                        : isRegister == false
                                            ? showCongratulationsDialog()
                                            : Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (_) =>
                                                        ArtistExhibitionSeatBookingScreen(
                                                          exhibitionUniqueId:
                                                              exhibitionUniqueId
                                                                  .toString(),
                                                        )));
                                  },
                                  label: isBooth == 0
                                      ? "REGISTER NOW"
                                      : "REGISTER NOW",
                                  isBoarderRadiusLess: true,
                                ),
                              ],
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                            )
                          : isAdd == true
                              ? GeneralButton(
                                  Width: Responsive.getWidth(360),
                                  onTap: () {
                                    if (isFull == true) {
                                      showCongratulationsDialog();
                                    } else {
                                      print("${exhibitionUniqueId}");
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) =>
                                                  ArtistExhibitionUploadScreen(
                                                    exhibition_type: widget.exhibition_type,
                                                    categoryName:
                                                        exhibitionDetails![
                                                                    "exhibition"]
                                                                ["category"]
                                                            ["category_name"],
                                                    categoryId:
                                                        exhibitionDetails![
                                                                    "exhibition"]
                                                                ["category"]
                                                            ["category_id"],
                                                    exhibitionUniqueId:
                                                        exhibitionUniqueId,
                                                  )));
                                    }
                                  },
                                  label: "REGISTER NOW",
                                  isBoarderRadiusLess: true,
                                )
                              : SizedBox(),
                    ],
                  ),
                ),
                SizedBox(
                  height: Responsive.getHeight(20),
                ),
              ],
            ),
    );
  }

  void showRegisterDialog(BuildContext context, String exhibition_unique_id) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return RegisterDialog(
          exhibitionUniqueId: exhibition_unique_id.toString(),
          customerUniqueID: customerUniqueID.toString(),
        );
      },
    );
  }

  void showCongratulationsDialog() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return Congratulations();
      },
    );
  }

  void showChiefGuestsDialog(
      String image, String name, String message, String position) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return ChiefGuests(
            Image: image, Message: message, name: name, position: position);
      },
    );
  }

  Widget TermsCheckbox(String exhibitionUniqueId) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _isChecked = !_isChecked;
            });
          },
          child: Container(
            width: Responsive.getWidth(20),
            height: Responsive.getWidth(20),
            decoration: BoxDecoration(
                color: _isChecked ? black : Colors.transparent,
                borderRadius: BorderRadius.circular(Responsive.getWidth(4)),
                border: Border.all(color: Color.fromRGBO(0, 0, 0, 1))),
            child: _isChecked
                ? Center(
                    child: Icon(
                    Icons.check,
                    color: white,
                    size: 16,
                  ))
                : Container(),
          ),
        ),
        SizedBox(
          width: 5,
        ),
        Flexible(
          child: GestureDetector(
            onTap: () {
              _fetchAndShowTerms(context, exhibitionUniqueId);
            },
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'I have read and agree to the ',
                    style: GoogleFonts.poppins(
                      letterSpacing: 1.5,
                      color: Color.fromRGBO(27, 43, 65, 0.72),
                      fontSize: Responsive.getFontSize(10),
                      fontWeight: AppFontWeight.medium,
                    ),
                  ),
                  TextSpan(
                    text: 'Terms of Service',
                    style: GoogleFonts.poppins(
                      letterSpacing: 1.5,
                      color: Color.fromRGBO(0, 0, 0, 1),
                      fontSize: Responsive.getFontSize(10),
                      decoration: TextDecoration.underline,
                      fontWeight: AppFontWeight.medium,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _fetchAndShowTerms(
      BuildContext context, String exhibitionUniqueId) async {
    try {
      final termsData = await ApiService()
          .getTermsConditionsForExhibition(exhibitionUniqueId);
      _showTermsDialog(context, termsData);
    } catch (error) {
      print('Error fetching terms and conditions: $error');
    }
  }

  void _showTermsDialog(BuildContext context, Map<String, dynamic> termsData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          insetPadding: EdgeInsets.symmetric(horizontal: 14),
          child: Container(
            margin: EdgeInsets.all(0),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
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
                  for (var term in termsData['terms'])
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          term['heading'],
                          style: GoogleFonts.poppins(
                              fontSize: Responsive.getFontSize(18),
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5),
                        ),
                        for (var para in term['conditions_paras'])
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.6),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                SizedBox(width: 10),
                                Flexible(
                                  child: Text(
                                    para['para'],
                                    style: GoogleFonts.poppins(
                                        fontSize: Responsive.getFontSize(14),
                                        fontWeight: FontWeight.w400,
                                        letterSpacing: 1.5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // void showRegisterDialog(BuildContext context, String exhibition_unique_id) {
  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (BuildContext context) {
  //       return RegisterDialog(
  //         exhibitionUniqueId: exhibition_unique_id.toString(),
  //         customerUniqueID: customerUniqueID.toString(),
  //       );
  //     },
  //   );
  // }
}

// exhibitionDetails!['isArtApproved'] == 1
//     ? GeneralButton(
//       Width: Responsive.getWidth(340),
//       onTap: () {
//         print(
//             "${exhibitionDetails!['exhibition_unique_id']}");
//
//         exhibitionDetails!['exhibition_unique_id'] == 0
//             ? exhibitionDetails!['isRegister'] == false
//                 ? showCongratulationsDialog()
//                 : showRegisterDialog(
//                     context,
//                     exhibitionDetails![
//                         'exhibition_unique_id'])
//             : exhibitionDetails!['isRegister'] == false
//                 ? showCongratulationsDialog()
//                 : Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                         builder: (_) =>
//                             ArtistExhibitionSeatBookingScreen(
//                               exhibitionUniqueId:
//                                   exhibitionDetails![
//                                       'exhibition_unique_id'],
//                             )));
//       },
//       label: exhibitionDetails!['is_booth'] == 0
//           ? "Booking"
//           : "Select Seat",
//       isBoarderRadiusLess: true,
//     )
//     : exhibitionDetails!['isAdd'] == true
//         ? GeneralButton(
//             Width: Responsive.getWidth(360),
//             onTap: () {
//               if (exhibitionDetails!['isFull'] == true) {
//                 showCongratulationsDialog();
//               } else {
//                 print(
//                     "${exhibitionDetails!['exhibition_unique_id']}");
//                 Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                         builder: (_) =>
//                             ArtistExhibitionUploadScreen(
//                               exhibitionUniqueId:
//                                   exhibitionDetails![
//                                       'exhibition_unique_id'],
//                             )));
//               }
//             },
//             label: "Register Now",
//             isBoarderRadiusLess: true,
//           )
//         : SizedBox(),

class ChiefGuests extends StatefulWidget {
  final Image;
  final Message;
  final name;
  final position;
  const ChiefGuests(
      {super.key,
      required this.Image,
      required this.name,
      required this.position,
      required this.Message});

  @override
  _ChiefGuestsState createState() => _ChiefGuestsState();
}

class _ChiefGuestsState extends State<ChiefGuests> {
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
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: Responsive.getWidth(11),
                vertical: Responsive.getHeight(10)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              // mainAxisSize: MainAxisSize.min,
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
                Row(
                  children: [
                    Container(
                      width: Responsive.getWidth(60),
                      height: Responsive.getWidth(60),
                      decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(Responsive.getWidth(30)),
                          image: DecorationImage(
                              image: NetworkImage(widget.Image),
                              fit: BoxFit.cover)),
                    ),
                    SizedBox(
                      width: Responsive.getWidth(10),
                    ),
                    SizedBox(
                      width: Responsive.getWidth(240),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            widget.name,
                            style: GoogleFonts.poppins(
                                color: Colors.black,
                                fontSize: Responsive.getFontSize(14),
                                fontWeight: AppFontWeight.bold,
                                letterSpacing: 1.5),
                          ),
                          SizedBox(
                            height: Responsive.getHeight(2),
                          ),
                          Text(
                            widget.position,
                            style: GoogleFonts.poppins(
                                color: Colors.black,
                                fontSize: Responsive.getFontSize(12),
                                fontWeight: AppFontWeight.regular,
                                letterSpacing: 1.5),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: Responsive.getHeight(10),
                ),
                Text(
                  textAlign: TextAlign.start,
                  widget.Message,
                  style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontSize: Responsive.getFontSize(12),
                      fontWeight: AppFontWeight.regular,
                      letterSpacing: 1.5),
                ),
                // SizedBox(height: Responsive.getHeight(24)),
                // WantText2(
                //     text: "Art submission is now closed.",
                //     fontSize: Responsive.getFontSize(16),
                //     fontWeight: AppFontWeight.semiBold,
                //     textColor: black),
                // SizedBox(height: Responsive.getHeight(24)),
                // Center(
                //   child: GeneralButton(
                //     Width: Responsive.getWidth(293),
                //     onTap: () {
                //       Navigator.pop(context);
                //     },
                //     label: "Close",
                //     isBoarderRadiusLess: true,
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
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
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: Responsive.getWidth(11),
                vertical: Responsive.getHeight(24)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // SizedBox(height: Responsive.getHeight(24)),
                WantText2(
                    text: "Art submission is now closed.",
                    fontSize: Responsive.getFontSize(16),
                    fontWeight: AppFontWeight.semiBold,
                    textColor: black),
                SizedBox(height: Responsive.getHeight(24)),
                Center(
                  child: GeneralButton(
                    Width: Responsive.getWidth(293),
                    onTap: () {
                      Navigator.pop(context);
                    },
                    label: "Close",
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

class RegisterDialog extends StatefulWidget {
  final String exhibitionUniqueId;
  final String customerUniqueID;

  const RegisterDialog(
      {Key? key,
      required this.exhibitionUniqueId,
      required this.customerUniqueID})
      : super(key: key);

  @override
  _RegisterDialogState createState() => _RegisterDialogState();
}

class _RegisterDialogState extends State<RegisterDialog> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController _pinControllerMobile = TextEditingController();
  final TextEditingController _ArtistNameControllerMobile =
      TextEditingController();
  final TextEditingController _profileLinkControllerMobile =
      TextEditingController();
  final TextEditingController _socialLinkControllerMobile =
      TextEditingController();
  bool isVisibleMobile = false;
  PhoneNumber number = PhoneNumber(isoCode: 'US');
  String phoneNumber = '';
  String countryCode = '';
  bool isPhoneNumberValid = true;
  bool isSend = false;
  bool isVerify = false;
  bool isVerifySuccess = false;
  bool isLoading = false;

  void registerCustomer() async {
    if (_formKey.currentState!.validate()) {
      if (nameController.text.isEmpty) {
        showToast(message: "Enter Full Name");
      } else if (emailController.text.isEmpty) {
        showToast(message: "Enter Email");
      } else if (mobileController.text.isEmpty) {
        showToast(message: "Enter Mobile");
      } else if (addressController.text.isEmpty) {
        showToast(message: "Enter Address");
      } else if (_ArtistNameControllerMobile.text.isEmpty) {
        showToast(message: "Enter Artist Name");
      } else if (_profileLinkControllerMobile.text.isEmpty) {
        showToast(message: "Enter Profile Link");
      } else if (_socialLinkControllerMobile.text.isEmpty) {
        showToast(message: "Enter Social Media Link");
      } else if (isVerifySuccess == false) {
        showToast(message: "Please Verify Email");
      } else {
        setState(() {
          isLoading = true;
        });
        try {
          // await ApiService().registerCustomerExhibitions(
          //   name: nameController.text,
          //   email: emailController.text,
          //   mobile: mobileController.text,
          //   exhibitionUniqueId: widget.exhibitionUniqueId,
          //   address: addressController.text,
          //   customerUniqueId: widget.customerUniqueID,
          // ).then((onValue) {
          //   Navigator.pushReplacement(
          //     context,
          //     MaterialPageRoute(
          //       builder: (_) => RegisterPaymentScreen(),
          //     ),
          //   );
          // });
          final response = await ApiService().registerSellerExhibitions(
            name: nameController.text,
            email: emailController.text,
            mobile: mobileController.text,
            exhibitionUniqueId: widget.exhibitionUniqueId,
            address: addressController.text,
            artist_name: _ArtistNameControllerMobile.text.toString(),
            portfolio_link: _profileLinkControllerMobile.text.toString(),
            social_link: _socialLinkControllerMobile.text.toString(),
            customerUniqueId: widget.customerUniqueID,
          );
          // role: "seller",
          showToast(message: response['message']);
          if (response['status'] == "false") {
            showToast(message: response['message']);
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => ArtistRegisterPaymentScreen(response: response),
              ),
            );
          }
        } catch (e) {
          print(e);
        } finally {
          setState(() {
            isLoading = false;
          });
        }
      }
    }
  }

  @override
  void initState() {
    getExhibitionPercentage();
    super.initState();
  }

  String? percentage;
  void getExhibitionPercentage() async {
    ApiService apiService = ApiService();

    percentage =
        await apiService.fetchExhibitionPercentage(widget.exhibitionUniqueId);

    if (percentage != null) {
      print('Exhibition percentage: $percentage%');
      // Trigger UI rebuild to reflect percentage
      setState(() {});
    } else {
      print('Failed to fetch exhibition percentage.');
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    print(widget.exhibitionUniqueId);
    print(widget.customerUniqueID);
    return Dialog(
      backgroundColor: whiteBack,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: EdgeInsets.symmetric(horizontal: Responsive.getWidth(14)),
      child: Container(
        margin: EdgeInsets.all(0), // Remove all margins
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: Responsive.getWidth(11),
                vertical: Responsive.getHeight(11)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: 1,
                        ),
                        WantText2(
                            text: "Register Now",
                            fontSize: Responsive.getFontSize(18),
                            fontWeight: AppFontWeight.medium,
                            textColor: textBlack),
                        GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Icon(
                              CupertinoIcons.multiply_circle,
                              color: textGray,
                            ))
                      ],
                    ),
                    SizedBox(height: Responsive.getHeight(10)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: 1,
                        ),
                        WantText2(
                            text: "Fill the information carefully",
                            fontSize: Responsive.getFontSize(8),
                            fontWeight: AppFontWeight.medium,
                            textColor: textBlack10),
                        Icon(
                          CupertinoIcons.multiply_circle,
                          color: Colors.transparent,
                        )
                      ],
                    ),
                    SizedBox(height: 10),
                  ],
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          WantText2(
                              text: "Full Name",
                              fontSize: Responsive.getFontSize(10),
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
                        controller: nameController,
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
                            return 'Name cannot be empty';
                          }
                          return null;
                        },
                        hintText: "Enter Full Name",
                      ),
                      SizedBox(
                        height: Responsive.getHeight(15),
                      ),
                      Row(
                        children: [
                          WantText2(
                              text: "Email",
                              fontSize: Responsive.getFontSize(10),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width:  isVerifySuccess
                                ? Responsive.getWidth(324)
                                : Responsive.getWidth(252),
                            child: AppTextFormField(
                              suffixIcon: isVerifySuccess
                                  ? Icon(
                                CupertinoIcons.checkmark_seal_fill,
                                color: Colors.green,
                              )
                                  : SizedBox(),
                              fillColor: Color.fromRGBO(247, 248, 249, 1),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: Responsive.getWidth(18),
                                  vertical: Responsive.getHeight(14)),
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
                                  r'^[a-z][a-zA-Z0-9._%+-]*@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                                );
                                if (!emailRegex.hasMatch(value)) {
                                  return 'Email is not valid';
                                }
                                return null;
                              },
                              hintText: "Enter Email",
                            ),
                          ),
                          isVerifySuccess
                              ? SizedBox()
                              : GestureDetector(
                            onTap: () async {
                              if (emailController.text.isEmpty) {
                                showToast(message: "Enter Email");
                              } else {
                                try {
                                  setState(() {
                                    isSend = true;
                                  });
                                  // await ApiService()
                                  //     .sendOTPexhibitionReg(
                                  //   emailController.text.toString(),
                                  //   // mobileController.text.toString(),
                                  //   widget.exhibitionUniqueId.toString()
                                  // )
                                  final response =
                                  await ApiService().sendOTPexhibitionReg(
                                    emailController.text.toString(),
                                    widget.exhibitionUniqueId.toString(),
                                  );
                                  if (response['status'] == 'true') {
                                    setState(() {
                                      isVisibleMobile = true;
                                      isSend = false;
                                    });
                                  } else {
                                    setState(() {
                                      isVisibleMobile = false;
                                      isSend = false;
                                    });
                                  }
                                  //     .then((onValue) {
                                  //   setState(() {
                                  //     isVisibleMobile = true;
                                  //     isSend = false;
                                  //   });
                                  // });
                                } catch (e) {
                                  setState(() {
                                    isVisibleMobile = true;
                                    isSend = false;
                                  });
                                  print(e);
                                }
                              }
                              // print("countryCode : $countryCode");
                              // print("countryCode : ${mobileController.text}");
                              // print(
                              //     "exhibition_unique_id : ${widget.exhibitionUniqueId}");
                            },
                            child: Container(
                              height: Responsive.getHeight(45),
                              width: Responsive.getWidth(60),
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black),
                                  color: black,
                                  borderRadius: BorderRadius.circular(
                                      Responsive.getWidth(5)),
                                ),
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                    CrossAxisAlignment.center,
                                    children: [
                                      isSend
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
                                        "SEND",
                                        style: GoogleFonts.poppins(
                                          textStyle: TextStyle(
                                            letterSpacing: 1.5,
                                            fontSize:
                                            Responsive.getFontSize(
                                                16),
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
                          )
                        ],
                      ),
                      isVisibleMobile
                          ? SizedBox(
                        height: Responsive.getHeight(12),
                      )
                          : Container(),
                      isVisibleMobile
                          ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Pinput(
                            controller: _pinControllerMobile,
                            length: 4,
                            onCompleted: (pin) {
                              print('OTP entered: $pin');
                            },
                            defaultPinTheme: PinTheme(
                              width: 60,
                              height: 45,
                              textStyle: GoogleFonts.poppins(
                                color: black,
                                letterSpacing: 1.5,
                                fontSize: 18,
                                fontWeight: FontWeight.normal,
                              ),
                              decoration: BoxDecoration(
                                // color: Color.fromRGBO(247, 248, 249, 1),
                                border: Border.all(
                                    color: textFieldBorderColor),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            focusedPinTheme: PinTheme(
                              width: 60,
                              height: 45,
                              textStyle: GoogleFonts.poppins(
                                color: black,
                                letterSpacing: 1.5,
                                fontSize: 18,
                                fontWeight: FontWeight.normal,
                              ),
                              decoration: BoxDecoration(
                                // color: Colors.transparent,
                                border: Border.all(
                                    color: textFieldBorderColor),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            submittedPinTheme: PinTheme(
                              width: 60,
                              height: 45,
                              textStyle: GoogleFonts.poppins(
                                color: black,
                                letterSpacing: 1.5,
                                fontSize: 18,
                                fontWeight: FontWeight.normal,
                              ),
                              decoration: BoxDecoration(
                                // color: Color.fromRGBO(247, 248, 249, 1),
                                border: Border.all(
                                    color: textFieldBorderColor),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              setState(() {
                                isVerify = true;
                              });
                              try {
                                final response = await ApiService().verifyOtpEmail(
                                  emailController.text,
                                  _pinControllerMobile.text,
                                );

                                if (response['status'] == 'true') {
                                  setState(() {
                                    isVerifySuccess = true; // Set verification success
                                    isVisibleMobile = false; // Hide OTP input
                                    isVerify = false; // Stop loading indicator
                                  });
                                } else {
                                  setState(() {
                                    isVerifySuccess = false; // Mark verification as failed
                                    isVerify = false;
                                  });
                                  showToast(message: response['message']); // Show error message
                                }
                              } catch (e) {
                                setState(() {
                                  isVerifySuccess = false; // Mark verification as failed
                                  isVerify = false; // Stop loading indicator
                                });
                                showToast(message: "Something went wrong. Please try again.");
                                print(e);
                              }

                              // try {
                              //   await ApiService()
                              //       .verifyOtpEmail(emailController.text,
                              //           _pinControllerMobile.text)
                              //       .then((onValue) {
                              //     setState(() {
                              //       isVerifySuccess = true;
                              //       isVisibleMobile = false;
                              //       isVerify = false;
                              //     });
                              //   });
                              // } catch (e) {
                              //   setState(() {
                              //     isVerifySuccess = false;
                              //     isVerify = false;
                              //   });
                              //   print(e);
                              // }
                            },
                            child: Container(
                              height: Responsive.getHeight(45),
                              width: Responsive.getWidth(60),
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black),
                                  color: black,
                                  borderRadius: BorderRadius.circular(
                                      Responsive.getWidth(5)),
                                ),
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.center,
                                    crossAxisAlignment:
                                    CrossAxisAlignment.center,
                                    children: [
                                      isVerify
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
                                        "VERIFY",
                                        style: GoogleFonts.poppins(
                                          letterSpacing: 1.5,
                                          textStyle: TextStyle(
                                            fontSize: Responsive
                                                .getFontSize(14),
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
                          )
                        ],
                      )
                          : Container(),
                      SizedBox(
                        height: Responsive.getHeight(15),
                      ),
                      Row(
                        children: [
                          WantText2(
                              text: "Mobile Number",
                              fontSize: Responsive.getFontSize(10),
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
                      Container(
                        // width: Responsive.getWidth(252),
                        padding: EdgeInsets.only(
                          left: Responsive.getWidth(16),
                        ),
                        decoration: BoxDecoration(
                          // color: Color.fromRGBO(247, 248, 249, 1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              width: 1,
                              color:
                                  // isPhoneNumberValid
                                  //     ?
                                  textFieldBorderColor
                              // : Colors.red,
                              ),
                        ),
                        child: InternationalPhoneNumberInput(
                          onInputChanged: (PhoneNumber number) {
                            setState(() {
                              phoneNumber = number.phoneNumber ?? '';
                              countryCode = number.dialCode ?? '';
                            });
                            print("Full number: $phoneNumber");
                            print("Country code: $countryCode");
                          },
                          onInputValidated: (bool value) {
                            setState(() {
                              isPhoneNumberValid = value;
                            });
                            print(value ? 'Valid' : 'Invalid');
                          },
                          selectorConfig: SelectorConfig(
                            setSelectorButtonAsPrefixIcon: false,
                            useBottomSheetSafeArea: true,
                            leadingPadding: 0,
                            selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                            useEmoji: false,
                            trailingSpace: false,
                          ),
                          ignoreBlank: false,
                          autoValidateMode: AutovalidateMode.disabled,
                          initialValue: number,
                          textFieldController: mobileController,
                          formatInput: false,
                          textStyle: GoogleFonts.poppins(
                            letterSpacing: 1.5,
                            color: textBlack,
                            fontSize: 14.00,
                            fontWeight: FontWeight.normal,
                          ),
                          keyboardType: TextInputType.numberWithOptions(
                              signed: true, decimal: true),
                          inputBorder: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          onSaved: (PhoneNumber number) {
                            String formattedNumber =
                                number.phoneNumber?.replaceFirst('+', '') ?? '';
                            print('On Saved: $formattedNumber');
                          },
                          cursorColor: Colors.black,
                          inputDecoration: InputDecoration(
                            isDense: true,
                            hintText: 'Enter phone number',
                            hintStyle: GoogleFonts.poppins(
                              letterSpacing: 1.5,
                              color: textGray,
                              fontSize: 14.00,
                              fontWeight: FontWeight.normal,
                            ),
                            // fillColor: Color.fromRGBO(247, 248, 249, 1),
                            // filled: true,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 0, vertical: 10),
                            // suffixIcon: IconButton(
                            //   icon: Icon(
                            //     Icons.clear,
                            //     color: Colors.grey,
                            //   ),
                            //   onPressed: () {
                            //     mobileController.clear();
                            //   },
                            // ),
                            prefixIconConstraints: BoxConstraints(
                              minWidth: 0,
                              minHeight: 0,
                            ),
                            suffixIconConstraints: BoxConstraints(
                              minWidth: 40,
                              minHeight: 40,
                            ),
                            errorMaxLines: 3,
                            counterText: "",
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5)),
                              borderSide: BorderSide.none,
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5)),
                              borderSide:
                                  BorderSide(color: Colors.red, width: 1),
                            ),
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5)),
                              borderSide: BorderSide(
                                  color: Colors.transparent, width: 1),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5)),
                              borderSide: BorderSide(
                                  color: Colors.transparent, width: 1),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5)),
                              borderSide: BorderSide(
                                  color: Colors.transparent, width: 1),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: Responsive.getHeight(15),
                      ),
                      Row(
                        children: [
                          WantText2(
                              text: "Artist Name",
                              fontSize: Responsive.getFontSize(10),
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
                        controller: _ArtistNameControllerMobile,
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
                            return 'Artist Name cannot be empty';
                          }
                          return null;
                        },
                        hintText: "Enter Artist Name",
                      ),
                      SizedBox(
                        height: Responsive.getHeight(15),
                      ),
                      Row(
                        children: [
                          WantText2(
                              text: "Portfolio Link",
                              fontSize: Responsive.getFontSize(10),
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
                        controller: _profileLinkControllerMobile,
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
                            return 'Portfolio Link cannot be empty';
                          }
                          return null;
                        },
                        hintText: "Enter Portfolio Link",
                      ),
                      SizedBox(
                        height: Responsive.getHeight(15),
                      ),
                      Row(
                        children: [
                          WantText2(
                              text: "Social media Link",
                              fontSize: Responsive.getFontSize(10),
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
                        controller: _socialLinkControllerMobile,
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
                            return 'Social media Link cannot be empty';
                          }
                          return null;
                        },
                        hintText: "Enter Social media Link",
                      ),
                      SizedBox(
                        height: Responsive.getHeight(15),
                      ),
                      Row(
                        children: [
                          WantText2(
                              text: "Current Address",
                              fontSize: Responsive.getFontSize(10),
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
                        controller: addressController,
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
                            return 'Current Address cannot be empty';
                          }
                          return null;
                        },
                        hintText: "Enter Address",
                      ),
                      SizedBox(
                        height: Responsive.getHeight(15),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.check_box,
                            color: black,
                            size: Responsive.getWidth(20),
                          ),
                          SizedBox(
                            width: Responsive.getWidth(5),
                          ),
                          SizedBox(
                            width: Responsive.getWidth(300),
                            child: Text(
                              "A ${percentage == null ? 0 : percentage}% commission will be deducted from each artwork sold at the exhibition",
                              maxLines: 2,
                              style: GoogleFonts.poppins(
                                  color: black,
                                  fontSize: Responsive.getFontSize(8),
                                  fontWeight: AppFontWeight.semiBold,
                                  letterSpacing: 1.5),
                            ),
                          ),
                          // WantText2(text: "A 21% commission will be deducted from each artwork sold at the exhibition", fontSize: Responsive.getFontSize(8), fontWeight: AppFontWeight.semiBold, textColor: black)
                        ],
                      ),
                      SizedBox(
                        height: Responsive.getHeight(20),
                      ),
                      Center(
                          child: GestureDetector(
                        onTap: registerCustomer,
                        child: Container(
                          height: Responsive.getHeight(45),
                          width: Responsive.getWidth(335),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black),
                              color: black,
                              borderRadius:
                                  BorderRadius.circular(Responsive.getWidth(5)),
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
                                          "NEXT",
                                          style: GoogleFonts.poppins(
                                            letterSpacing: 1.5,
                                            textStyle: TextStyle(
                                              fontSize:
                                                  Responsive.getFontSize(16),
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
                    ],
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
    contentPadding: EdgeInsets.fromLTRB(16, 15, 16, 15),
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

String _getPurpose(String? value) {
  switch (value) {
    case "Private Viewing":
      return "private";
    case "Auction Art":
      return "auction";
    case "Exhibition Registration":
    default:
      return "visitor";
  }
}
