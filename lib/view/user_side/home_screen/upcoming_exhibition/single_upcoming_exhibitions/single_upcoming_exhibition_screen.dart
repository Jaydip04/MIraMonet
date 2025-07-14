import 'dart:async';
import 'dart:convert';

import 'package:artist/config/toast.dart';
import 'package:artist/core/api_service/api_service.dart';
import 'package:artist/view/user_side/home_screen/upcoming_exhibition/single_upcoming_exhibitions/register_payment_screen.dart';
import 'package:artist/view/user_side/home_screen/upcoming_exhibition/single_upcoming_exhibitions/single_auction_art_screen.dart';
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
import '../../../../../config/colors.dart';
import '../../../../../core/api_service/base_url.dart';
import '../../../../../core/models/country_state_city_model.dart';
import '../../../../../core/models/user_side/single_exhibitions_model.dart';
import '../../../../../core/utils/app_font_weight.dart';
import '../../../../../core/utils/responsive.dart';
import '../../../../../core/widgets/app_text_form_field.dart';
import '../../../../../core/widgets/custom_dropdown.dart';
import '../../../../../core/widgets/custom_text_2.dart';
import '../../../../../core/widgets/expandable_text.dart';
import '../../../../../core/widgets/general_button.dart';
import '../../../../artist_side/artist_my_art_page/single_art_screen/artist_review_art_screen.dart';
import '../../../profile_screen/profile_screens/full_screen_image.dart';
import '../../product_detail/single_product/single_product_detail_screen.dart';
import '../../ticket/ticket_screen.dart';

class SingleUpcomingExhibitionScreen extends StatefulWidget {
  final exhibition_unique_id;
  const SingleUpcomingExhibitionScreen(
      {super.key, required this.exhibition_unique_id});

  @override
  State<SingleUpcomingExhibitionScreen> createState() =>
      _SingleUpcomingExhibitionScreenState();
}

class _SingleUpcomingExhibitionScreenState
    extends State<SingleUpcomingExhibitionScreen> {
  Map<String, dynamic>? exhibitionDetails;
  bool isLoading = true;
  late ScrollController _scrollController;
  late Timer _timer;
  double _scrollPosition = 0.0;

  late ScrollController _scrollController2;
  late Timer _timer2;
  double _scrollPosition2 = 0.0;
  bool isLoggedIn = false;
  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isLoggedIn = prefs.getString('UserToken') != null;
    });
  }

  @override
  void initState() {
    super.initState();
    // _checkLoginStatus();
    print(widget.exhibition_unique_id);
    _checkLoginStatus().then((onValue) {
      if (isLoggedIn) {
        print("object");
        _loadUserData();
      } else {
        print("object0");
      }
    });
    fetchDetails();

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

  void fetchDetails() async {
    try {
      final details = await ApiService()
          .fetchExhibitionDetails(widget.exhibition_unique_id);
      setState(() {
        exhibitionDetails = details;
        isLoading = false;
      });
    } catch (e) {
      print(e);
      setState(() {
        isLoading = false;
      });
    }
  }

  String convertDate(String inputDate) {
    DateTime date = DateTime.parse(inputDate);
    DateTime newDate = DateTime(date.year, date.month, date.day);
    return DateFormat("MMM dd, yyyy").format(newDate);
  }

  @override
  Widget build(BuildContext context) {
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
                    exhibitionDetails!["exhibition"]["banner"],
                    fit: BoxFit.contain,
                  ),
                ),
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: Responsive.getWidth(16)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exhibitionDetails!["exhibition"]["name"]
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
                      //   exhibitionDetails!["exhibition"]["description"],
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
                              "${exhibitionDetails!["exhibition"]["address1"]}, ${exhibitionDetails!["exhibition"]["city"]["name_of_city"]}, ${exhibitionDetails!["exhibition"]["state"]["state_subdivision_name"]}, ${exhibitionDetails!["exhibition"]["country"]["country_name"]}",
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
                                  "${convertDate(exhibitionDetails!["exhibition"]["start_date"])} - ${convertDate(exhibitionDetails!["exhibition"]["end_date"])}",
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
                      SizedBox(height: Responsive.getHeight(5)),
                      Text(
                        "\$${
                          exhibitionDetails!["exhibition"]["amount"]
                              .toString()
                              .toUpperCase()
                        }",
                        style: GoogleFonts.poppins(
                          letterSpacing: 1.5,
                          color: textBlack4,
                          fontSize: Responsive.getFontSize(20),
                          fontWeight: AppFontWeight.medium,
                        ),
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
                        height: Responsive.getHeight(210),
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
                                    // height: Responsive.getHeight(200),
                                    margin: EdgeInsets.only(
                                        right: Responsive.getWidth(10)),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        artDetails["exhibition_art_image"]
                                                    .length ==
                                                0
                                            ? Container(
                                                width: Responsive.getWidth(140),
                                                height:
                                                    Responsive.getHeight(140),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey.shade100,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          Responsive.getWidth(
                                                              4)),
                                                ),
                                                child: Center(
                                                  child: WantText2(
                                                      text: artDetails["title"]
                                                              [0]
                                                          .toString()
                                                          .toUpperCase(),
                                                      fontSize: Responsive
                                                          .getFontSize(20),
                                                      fontWeight:
                                                          AppFontWeight.bold,
                                                      textColor: black),
                                                ))
                                            : Container(
                                                width: Responsive.getWidth(140),
                                                height:
                                                    Responsive.getHeight(140),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          Responsive.getWidth(
                                                              4)),
                                                  image: DecorationImage(
                                                    image: NetworkImage(artDetails[
                                                            "exhibition_art_image"]
                                                        [0]["image"]),
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
                                            SizedBox(
                                              width: Responsive.getWidth(140),
                                              child: WantText2(
                                                textOverflow: TextOverflow.fade,
                                                text:
                                                    'Estimate Range : \$${artDetails["price"]}',
                                                fontSize:
                                                    Responsive.getFontSize(8),
                                                fontWeight:
                                                    AppFontWeight.semiBold,
                                                textColor: black,
                                              ),
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
                exhibitionDetails!["upcomingExhibitions"].length == 0
                    ? SizedBox()
                    : Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: Responsive.getWidth(16)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            WantText2(
                              text: "Upcoming Exhibitions",
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
                exhibitionDetails!["upcomingExhibitions"].length == 0
                    ? SizedBox()
                    : SizedBox(height: Responsive.getHeight(8)),
                exhibitionDetails!["upcomingExhibitions"].length == 0
                    ? SizedBox()
                    : Container(
                        padding: EdgeInsets.only(left: Responsive.getWidth(16)),
                        height: Responsive.getHeight(196),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount:
                              exhibitionDetails!["upcomingExhibitions"].length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            SingleUpcomingExhibitionScreen(
                                              exhibition_unique_id:
                                                  exhibitionDetails![
                                                              "upcomingExhibitions"]
                                                          [index]
                                                      ["exhibition_unique_id"],
                                            )));
                                // Navigator.pushNamed(
                                //     context, "/User/SingleUpcomingExhibitionScreen");
                              },
                              child: Container(
                                width: Responsive.getWidth(120),
                                height: Responsive.getHeight(196),
                                margin: EdgeInsets.only(
                                    right: Responsive.getWidth(10)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: Responsive.getWidth(120),
                                      height: Responsive.getHeight(150),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                            Responsive.getWidth(5)),
                                        // image: DecorationImage(
                                        //     image: NetworkImage(
                                        //         exhibitionDetails![
                                        //                 "upcomingExhibitions"]
                                        //             [index]["logo"]),
                                        //     fit: BoxFit.fill)
                                      ),
                                      child: exhibitionDetails![
                                                      "upcomingExhibitions"]
                                                  [index]["logo"] ==
                                              null
                                          ? Container(
                                              height: Responsive.getHeight(175),
                                              width: Responsive.getWidth(159),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        Responsive.getWidth(
                                                            16)),
                                                color: Colors.grey.shade300,
                                                // image: DecorationImage(
                                                //   image: NetworkImage(artItem
                                                //       .artImages[0]
                                                //       .image), // Use dynamic image URL
                                                //   fit: BoxFit.fill,
                                                // ),
                                              ),
                                              child: Center(
                                                  child: WantText2(
                                                      text: exhibitionDetails![
                                                              "upcomingExhibitions"]
                                                          [index]["name"][0],
                                                      fontSize: Responsive
                                                          .getFontSize(20),
                                                      fontWeight:
                                                          AppFontWeight.bold,
                                                      textColor: black)),
                                            )
                                          : Container(
                                              height: Responsive.getHeight(175),
                                              width: Responsive.getWidth(159),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        Responsive.getWidth(
                                                            16)),
                                                image: DecorationImage(
                                                  image: NetworkImage(
                                                      exhibitionDetails![
                                                                  "upcomingExhibitions"]
                                                              [index][
                                                          "logo"]), // Use dynamic image URL
                                                  fit: BoxFit.contain,
                                                ),
                                              ),
                                            ),
                                    ),
                                    SizedBox(
                                      height: Responsive.getHeight(6),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        WantText2(
                                            text: exhibitionDetails![
                                                    "upcomingExhibitions"]
                                                [index]["name"],
                                            fontSize:
                                                Responsive.getFontSize(10),
                                            fontWeight: AppFontWeight.bold,
                                            textColor: textBlack),
                                        SizedBox(
                                          height: Responsive.getHeight(3),
                                        ),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.location_on_outlined,
                                              size: Responsive.getWidth(10),
                                            ),
                                            SizedBox(
                                              width: Responsive.getWidth(2),
                                            ),
                                            Flexible(
                                              child: WantText2(
                                                  text:
                                                      "${exhibitionDetails!["upcomingExhibitions"][index]["address1"]}, ${exhibitionDetails!["upcomingExhibitions"][index]["city"]["name_of_city"]}, ${exhibitionDetails!["upcomingExhibitions"][index]["state"]["state_subdivision_name"]}, ${exhibitionDetails!["upcomingExhibitions"][index]["country"]["country_name"]}",
                                                  fontSize:
                                                      Responsive.getFontSize(8),
                                                  fontWeight:
                                                      AppFontWeight.regular,
                                                  textColor: textGray7),
                                            ),
                                          ],
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                SizedBox(height: Responsive.getHeight(8)),
                Center(
                  child: GeneralButton(
                    Width: Responsive.getWidth(335),
                    onTap: () {
                      if (isLoggedIn) {
                        if (exhibitionDetails!["exhibition"]["isFull"] ==
                            true) {
                          showToast(message: "Exhibition is Full");
                        } else {
                          showRegisterDialog(
                              context,
                              exhibitionDetails!["exhibition"]
                                  ["exhibition_unique_id"]);
                        }
                      } else {
                        showLoginDialogForExhibition(context);
                        // showToast(message: "First Login");
                      }
                    },
                    label: "Register Now",
                    isBoarderRadiusLess: true,
                  ),
                ),
                SizedBox(
                  height: Responsive.getHeight(20),
                ),
              ],
            ),
    );
  }

  void showLoginDialogForExhibition(
    BuildContext context,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: whiteBack,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          insetPadding:
              EdgeInsets.symmetric(horizontal: Responsive.getWidth(14)),
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
                    Image.asset(
                      "assets/login.png",
                      height: Responsive.getWidth(35),
                      width: Responsive.getWidth(35),
                    ),
                    SizedBox(height: Responsive.getHeight(12)),
                    WantText2(
                        text: "Log In to your Account",
                        fontSize: Responsive.getFontSize(20),
                        fontWeight: AppFontWeight.semiBold,
                        textColor: textBlack),
                    SizedBox(height: Responsive.getHeight(8)),
                    Text(
                      textAlign: TextAlign.center,
                      "You want to Register in this Exhibition then Log in First.",
                      style: GoogleFonts.poppins(
                        letterSpacing: 1.5,
                        color: Color.fromRGBO(128, 128, 128, 1),
                        fontSize: Responsive.getFontSize(14),
                        fontWeight: AppFontWeight.regular,
                      ),
                    ),
                    SizedBox(height: Responsive.getHeight(24)),
                    Center(
                        child: GestureDetector(
                      onTap: () {
                        print("Click");
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/SignIn',
                          (Route<dynamic> route) => false,
                        );
                        // deleteAccount(customerUniqueID.toString());
                        // _logout(context);
                      },
                      child: Container(
                        height: Responsive.getHeight(44),
                        width: Responsive.getWidth(311),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: black,
                            ),
                            color: black,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "Log in",
                                  style: GoogleFonts.poppins(
                                    letterSpacing: 1.5,
                                    textStyle: TextStyle(
                                      fontSize: Responsive.getFontSize(18),
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
                    )),
                    SizedBox(height: Responsive.getHeight(12)),
                    Center(
                        child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        height: Responsive.getHeight(44),
                        width: Responsive.getWidth(311),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Color.fromRGBO(208, 213, 221, 1.0),
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "Cancel",
                                  style: GoogleFonts.urbanist(
                                    textStyle: TextStyle(
                                      fontSize: Responsive.getFontSize(18),
                                      color: Color.fromRGBO(52, 64, 84, 1.0),
                                      fontWeight: FontWeight.w500,
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
            ),
          ),
        );
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

  void showRegisterDialog(BuildContext context, String exhibition_unique_id) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return RegisterDialog(
          exhibitionUniqueId: exhibition_unique_id.toString(),
          customerUniqueID: customerUniqueID.toString(),
        );
      },
    );
  }
}

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
                      width: Responsive.getHeight(10),
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
  final TextEditingController zipController = TextEditingController();
  final TextEditingController _pinControllerMobile = TextEditingController();
  TextEditingController _countryController = TextEditingController();
  TextEditingController _cityController = TextEditingController();
  TextEditingController _stateController = TextEditingController();
  bool isVisibleMobile = false;
  PhoneNumber number = PhoneNumber(isoCode: 'US');
  String phoneNumber = '';
  String countryCode = '';
  bool isPhoneNumberValid = true;
  bool isSend = false;
  bool isVerify = false;
  bool isVerifySuccess = false;
  bool isLoading = false;
  String? _selectedPurpose;
  String? _selectedDate;
  String? _selectedSlot;
  String? _selectedSlotPrice;
  String? exhibition_time_slot_id;
  final List<String> _frame = [
    "Private Viewing",
    "Auction Art",
    "Exhibition Registration"
  ];
  List<String> _dateOptions = [];
  List<Map<String, dynamic>> _slots = [];

  List<Country> allCountries = [];
  List<Country> filteredCountries = [];
  List<StateModel> allStates = [];
  List<StateModel> filteredStates = [];
  List<City> allCities = [];
  List<City> filteredCities = [];

  bool isCountryDropdownVisible = false;
  bool isStateDropdownVisible = false;
  bool isCityDropdownVisible = false;

  Country? selectedCountry;
  StateModel? selectedState;
  City? selectedCity;
  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    mobileController.dispose();
    addressController.dispose();
    _pinControllerMobile.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    fetchCountries();
  }

  Future<void> fetchExhibitionDates(
      String exhibitionUniqueId, String type) async {
    try {
      final response = await http.post(
        Uri.parse('$serverUrl/get_exhibition_date'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'exhibition_unique_id': exhibitionUniqueId,
          'type': type,
        }),
      );

      print(response.body);
      print(response.statusCode);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == true) {
          setState(() {
            _dateOptions = List<String>.from(
              responseData['data'].map((dateData) => dateData['date']),
            );
          });
          print(_dateOptions);
        } else {
          final responseData = jsonDecode(response.body);
          showToast(message: responseData['message']);
        }
      } else {
        print('Failed to fetch dates: ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred while fetching dates: $e');
    }
  }

  Future<void> fetchExhibitionSlots(
      String exhibitionUniqueId, String type, String date) async {
    // Make the API call
    try {
      final response = await http.post(
        Uri.parse('$serverUrl/get_exhibition_slot'),
        body: {
          'exhibition_unique_id': exhibitionUniqueId,
          'type': type,
          'date': date,
        },
      );

      if (response.statusCode == 200) {
        // Parse the response
        final data = json.decode(response.body);
        if (data['status'] == true) {
          final slots = List<Map<String, dynamic>>.from(data['data']);
          setState(() {
            _slots = slots;
          });
        } else {}
      } else {}
    } catch (error) {
      print("Error fetching slots: $error");
    }
  }

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
      } else if (_countryController.text.isEmpty) {
        showToast(message: "Select Country");
      } else if (_stateController.text.isEmpty) {
        showToast(message: "Select State");
      } else if (_cityController.text.isEmpty) {
        showToast(message: "Select City");
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
          String purpose = _getPurpose(_selectedPurpose);
          final response = await ApiService().registerCustomerExhibitionsnew(
              name: nameController.text,
              email: emailController.text,
              mobile: phoneNumber.toString(),
              exhibitionUniqueId: widget.exhibitionUniqueId,
              address: addressController.text,
              country: selectedCountry!.id.toString(),
              state: selectedState!.id.toString(),
              city: selectedCity!.id.toString(),
              zip: zipController.text.toString(),
              role: "customer",
              customerUniqueId: widget.customerUniqueID,
              date: _selectedDate!,
              exhibition_time_slot_id: exhibition_time_slot_id!,
              purpose_booking: _selectedPurpose!,
              type: purpose,
              amount: _selectedSlotPrice.toString());
          showToast(message: response['message']);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => RegisterPaymentScreen(response: response),
            ),
          );
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

  String convertDate(String? inputDate) {
    DateTime date = DateTime.parse(inputDate!);
    DateTime newDate = DateTime(date.year - 1, date.month - 1, date.day);
    return DateFormat("MMM dd, yyyy").format(newDate);
  }

  bool _isDropdownOpen = false;
  bool _isDropdownOpen2 = false;
  bool _isDropdownOpen3 = false;

  Future<void> fetchCountries() async {
    try {
      final countries = await ApiService.getCountries();
      setState(() {
        allCountries = countries;
        filteredCountries = countries;
        print("Countries fetched: ${allCountries.length}");
      });
    } catch (e) {
      print("Failed to fetch countries: $e");
      // Optionally, show an error message to the user
    }
  }

  Future<void> fetchStates(int countryId) async {
    try {
      final states = await ApiService.getStates(countryId);
      setState(() {
        allStates = states;
        filteredStates = states;
        print("States fetched: ${allStates.length}");
      });
    } catch (e) {
      print("Failed to fetch states: $e");
      // Optionally, show an error message to the user
    }
  }

  Future<void> fetchCities(int stateId) async {
    try {
      final cities = await ApiService.getCities(stateId);
      setState(() {
        allCities = cities;
        filteredCities = cities;
        print("Cities fetched: ${allCities.length}");
      });
    } catch (e) {
      print("Failed to fetch cities: $e");
      // Optionally, show an error message to the user
    }
  }

  void filterCountries(String query) {
    setState(() {
      filteredCountries = allCountries
          .where((country) =>
              country.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
      print("Filtered countries: ${filteredCountries.length}");
    });
  }

  void filterStates(String query) {
    setState(() {
      filteredStates = allStates
          .where(
              (state) => state.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
      print("Filtered states: ${filteredStates.length}");
    });
  }

  void filterCities(String query) {
    setState(() {
      filteredCities = allCities
          .where(
              (city) => city.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
      print("Filtered cities: ${filteredCities.length}");
    });
  }

  void selectCountry(Country country) {
    setState(() {
      selectedCountry = country;
      _countryController.text = country.name;
      isCountryDropdownVisible = false;
      _stateController.clear();
      _cityController.clear();
      allStates.clear();
      allCities.clear();
      fetchStates(country.id);
    });
  }

  void selectState(StateModel state) {
    setState(() {
      selectedState = state;
      _stateController.text = state.name;
      isStateDropdownVisible = false;
      _cityController.clear();
      allCities.clear();
      fetchCities(state.id);
    });
  }

  void selectCity(City city) {
    setState(() {
      selectedCity = city;
      _cityController.text = city.name;
      isCityDropdownVisible = false;
    });
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
                              text: "Enter Full Name",
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
                              text: "Email Address",
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
                            width: isVerifySuccess
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
                                        final response = await ApiService()
                                            .sendOTPexhibitionReg(
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
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
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
                                                        fontSize: Responsive
                                                            .getFontSize(16),
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
                                      final response =
                                          await ApiService().verifyOtpEmail(
                                        emailController.text,
                                        _pinControllerMobile.text,
                                      );

                                      if (response['status'] == 'true') {
                                        setState(() {
                                          isVerifySuccess =
                                              true; // Set verification success
                                          isVisibleMobile =
                                              false; // Hide OTP input
                                          isVerify =
                                              false; // Stop loading indicator
                                        });
                                      } else {
                                        setState(() {
                                          isVerifySuccess =
                                              false; // Mark verification as failed
                                          isVerify = false;
                                        });
                                        showToast(
                                            message: response[
                                                'message']); // Show error message
                                      }
                                    } catch (e) {
                                      setState(() {
                                        isVerifySuccess =
                                            false; // Mark verification as failed
                                        isVerify =
                                            false; // Stop loading indicator
                                      });
                                      showToast(
                                          message:
                                              "Something went wrong. Please try again.");
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
                          textStyle: GoogleFonts.poppins(
                            letterSpacing: 1.5,
                            color: black,
                            fontSize: 14.00,
                            fontWeight: FontWeight.w500,
                          ),
                          inputDecoration: InputDecoration(
                            isDense: true,
                            hintText: 'Enter mobile number',
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
                            return 'Email cannot be empty';
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
                          WantText2(
                              text: "Country of Origin",
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
                      buildTextField(
                        hintText: "Select Country",
                        controller: _countryController,
                        isVisible: isCountryDropdownVisible,
                        filteredItems: filteredCountries,
                        onChanged: filterCountries,
                        onTap: (country) => selectCountry(country),
                        setVisible: (visible) {
                          setState(() {
                            isCountryDropdownVisible = visible;
                          });
                        },
                      ),
                      SizedBox(
                        height: Responsive.getHeight(15),
                      ),
                      Row(
                        children: [
                          WantText2(
                              text: "State",
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
                      buildTextField(
                        hintText: "Select State",
                        controller: _stateController,
                        isVisible: isStateDropdownVisible,
                        filteredItems: filteredStates,
                        onChanged: filterStates,
                        onTap: (state) => selectState(state),
                        setVisible: (visible) {
                          setState(() {
                            isStateDropdownVisible = visible;
                          });
                        },
                      ),
                      SizedBox(
                        height: Responsive.getHeight(15),
                      ),
                      Row(
                        children: [
                          WantText2(
                              text: "City",
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
                      buildTextField(
                        hintText: "Select City",
                        controller: _cityController,
                        isVisible: isCityDropdownVisible,
                        filteredItems: filteredCities,
                        onChanged: filterCities,
                        onTap: (city) => selectCity(city),
                        setVisible: (visible) {
                          setState(() {
                            isCityDropdownVisible = visible;
                          });
                        },
                      ),
                      SizedBox(
                        height: Responsive.getHeight(15),
                      ),
                      Row(
                        children: [
                          WantText2(
                              text: "Zip Code",
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
                        controller: zipController,
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
                            return 'Zip cannot be empty';
                          }
                          return null;
                        },
                        hintText: "Enter Zip Code",
                      ),
                      FormField<String>(
                        validator: (value) {
                          if (_selectedPurpose == null ||
                              _selectedPurpose!.isEmpty ||
                              _selectedPurpose == 'Select') {
                            return 'Please select a purpose of booking';
                          }
                          return null;
                        },
                        builder: (FormFieldState<String> state) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: Responsive.getHeight(15)),
                              Row(
                                children: [
                                  WantText2(
                                    text: "Purpose of Booking",
                                    fontSize: Responsive.getFontSize(10),
                                    fontWeight: AppFontWeight.medium,
                                    textColor: textBlack9,
                                  ),
                                  WantText2(
                                      text: "*",
                                      fontSize: Responsive.getFontSize(12),
                                      fontWeight: AppFontWeight.medium,
                                      textColor:
                                          Color.fromRGBO(246, 0, 0, 1.0)),
                                ],
                              ),
                              SizedBox(height: Responsive.getHeight(5)),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      WantText2(
                                        text: _selectedPurpose ??
                                            "Select Purpose of Booking",
                                        fontSize: Responsive.getFontSize(14),
                                        fontWeight: _selectedPurpose == null
                                            ? AppFontWeight.regular
                                            : AppFontWeight.medium,
                                        textColor: _selectedPurpose == null
                                            ? Color.fromRGBO(131, 145, 161, 1.0)
                                            : textBlack11,
                                      ),
                                      Icon(
                                        Icons.keyboard_arrow_down_outlined,
                                        color: Color.fromRGBO(131, 131, 131, 1),
                                        // size: Responsive.getWidth(28),
                                      ),
                                      // Icon(Icons.keyboard_arrow_down_outlined),
                                    ],
                                  ),
                                ),
                              ),
                              // Show dropdown only if it's open
                              if (_isDropdownOpen)
                                Material(
                                  elevation: 4,
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    width: double.infinity,
                                    color: Colors.white,
                                    child: ListView(
                                      shrinkWrap: true,
                                      children: _frame.map((String title) {
                                        return ListTile(
                                          title: WantText2(
                                              text: title,
                                              fontSize:
                                                  Responsive.getFontSize(14),
                                              fontWeight: AppFontWeight.medium,
                                              textColor: textBlack11),
                                          // Text(title),
                                          onTap: () {
                                            setState(() {
                                              _selectedPurpose = title;
                                              String purpose =
                                                  _getPurpose(title);
                                              fetchExhibitionDates(
                                                  widget.exhibitionUniqueId,
                                                  purpose);
                                            });
                                            setState(() {
                                              _selectedDate = null;
                                              _selectedSlot = null;
                                              _selectedSlotPrice = null;
                                              exhibition_time_slot_id = null;
                                            });
                                            state.didChange(
                                                title); // Update form field value
                                            setState(() {
                                              _isDropdownOpen =
                                                  false; // Close dropdown after selection
                                            });
                                          },
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                      FormField<String>(
                        validator: (value) {
                          if (_selectedDate == null ||
                              _selectedDate!.isEmpty ||
                              _selectedDate == 'Select') {
                            return 'Please select a date';
                          }
                          return null;
                        },
                        builder: (FormFieldState<String> state) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: Responsive.getHeight(15)),
                              Row(
                                children: [
                                  WantText2(
                                    text: "Date",
                                    fontSize: Responsive.getFontSize(10),
                                    fontWeight: AppFontWeight.medium,
                                    textColor: textBlack9,
                                  ),
                                  WantText2(
                                      text: "*",
                                      fontSize: Responsive.getFontSize(12),
                                      fontWeight: AppFontWeight.medium,
                                      textColor:
                                          Color.fromRGBO(246, 0, 0, 1.0)),
                                ],
                              ),
                              SizedBox(height: Responsive.getHeight(5)),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _isDropdownOpen2 = !_isDropdownOpen2;
                                  });
                                },
                                child: InputDecorator(
                                  decoration: _inputDecoration(state, 'Select'),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      WantText2(
                                        text: _selectedDate == null
                                            ? "Select Date"
                                            : convertDate(_selectedDate),
                                        fontSize: Responsive.getFontSize(14),
                                        fontWeight: _selectedDate == null
                                            ? AppFontWeight.regular
                                            : AppFontWeight.medium,
                                        textColor: _selectedDate == null
                                            ? Color.fromRGBO(131, 145, 161, 1.0)
                                            : textBlack11,
                                      ),
                                      Icon(
                                        Icons.keyboard_arrow_down_outlined,
                                        color: Color.fromRGBO(131, 131, 131, 1),
                                        // size: Responsive.getWidth(28),
                                      ),
                                      // Icon(Icons.keyboard_arrow_down_outlined),
                                    ],
                                  ),
                                ),
                              ),
                              // Show dropdown only if it's open
                              if (_isDropdownOpen2)
                                Material(
                                  elevation: 4,
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    width: double.infinity,
                                    color: Colors.white,
                                    child: ListView(
                                      shrinkWrap: true,
                                      children:
                                          _dateOptions.map((String title) {
                                        return ListTile(
                                          title: WantText2(
                                              text: convertDate(title),
                                              fontSize:
                                                  Responsive.getFontSize(14),
                                              fontWeight: AppFontWeight.medium,
                                              textColor: textBlack11),
                                          onTap: () {
                                            setState(() {
                                              _selectedDate = title;
                                              // String purpose =
                                              //     _getPurpose(title);
                                              String purpose =
                                                  _getPurpose(_selectedPurpose);
                                              fetchExhibitionSlots(
                                                  widget.exhibitionUniqueId,
                                                  purpose,
                                                  _selectedDate!);
                                              // fetchExhibitionDates(
                                              //     widget.exhibitionUniqueId,
                                              //     purpose);
                                            });
                                            setState(() {
                                              _selectedSlot = null;
                                              _selectedSlotPrice = null;
                                              exhibition_time_slot_id = null;
                                            });
                                            state.didChange(
                                                title); // Update form field value
                                            setState(() {
                                              _isDropdownOpen2 =
                                                  false; // Close dropdown after selection
                                            });
                                          },
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                      FormField<String>(
                        validator: (value) {
                          if (_selectedSlot == null ||
                              _selectedSlot!.isEmpty ||
                              _selectedSlot == 'Select') {
                            return 'Please select a slot';
                          }
                          return null;
                        },
                        builder: (FormFieldState<String> state) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: Responsive.getHeight(15)),
                              Row(
                                children: [
                                  WantText2(
                                    text: "Slot",
                                    fontSize: Responsive.getFontSize(10),
                                    fontWeight: AppFontWeight.medium,
                                    textColor: textBlack9,
                                  ),
                                  WantText2(
                                      text: "*",
                                      fontSize: Responsive.getFontSize(12),
                                      fontWeight: AppFontWeight.medium,
                                      textColor:
                                          Color.fromRGBO(246, 0, 0, 1.0)),
                                ],
                              ),
                              SizedBox(height: Responsive.getHeight(5)),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _isDropdownOpen3 = !_isDropdownOpen3;
                                  });
                                },
                                child: InputDecorator(
                                  decoration: _inputDecoration(state, 'Select'),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      WantText2(
                                        text: _selectedSlot ?? "Select Slot",
                                        fontSize: Responsive.getFontSize(14),
                                        fontWeight: _selectedSlot == null
                                            ? AppFontWeight.regular
                                            : AppFontWeight.medium,
                                        textColor: _selectedSlot == null
                                            ? Color.fromRGBO(131, 145, 161, 1.0)
                                            : textBlack11,
                                      ),
                                      Icon(
                                        Icons.keyboard_arrow_down_outlined,
                                        color: Color.fromRGBO(131, 131, 131, 1),
                                        // size: Responsive.getWidth(24),
                                      ),
                                      // Icon(Icons.keyboard_arrow_down_outlined),
                                    ],
                                  ),
                                ),
                              ),
                              // Show dropdown only if it's open
                              if (_isDropdownOpen3)
                                Material(
                                  elevation: 4,
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    width: double.infinity,
                                    color: Colors.white,
                                    child: ListView(
                                      shrinkWrap: true,
                                      children: _slots.map((slot) {
                                        return ListTile(
                                          title: WantText2(
                                              text: slot['slot_name'],
                                              fontSize:
                                                  Responsive.getFontSize(14),
                                              fontWeight: AppFontWeight.medium,
                                              textColor: textBlack11),
                                          // Text(slot['slot_name']),
                                          onTap: () {
                                            setState(() {
                                              _selectedSlot = slot['slot_name'];
                                              final selectedSlot =
                                                  _slots.firstWhere((slot) =>
                                                      slot['slot_name'] ==
                                                      slot['slot_name']);
                                              _selectedSlotPrice =
                                                  selectedSlot['amount'];
                                              exhibition_time_slot_id =
                                                  selectedSlot[
                                                          'exhibition_time_slot_id']
                                                      .toString();
                                              _isDropdownOpen3 = false;
                                            });

                                            state.didChange(slot[
                                                'slot_name']); // Update form field value
                                          },
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                      SizedBox(
                        height: Responsive.getHeight(16),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          WantText2(
                              text: "Exhibition Fee",
                              fontSize: Responsive.getFontSize(14),
                              fontWeight: AppFontWeight.bold,
                              textColor: black),
                          WantText2(
                              text:
                                  "${_selectedSlotPrice == "0" ? "Free" : "\$${_selectedSlotPrice ?? '0'}" ?? '0'}",
                              fontSize: Responsive.getFontSize(14),
                              fontWeight: AppFontWeight.bold,
                              textColor: black)
                        ],
                      ),
                      SizedBox(
                        height: Responsive.getHeight(13),
                      ),
                      TermsCheckbox(),
                      SizedBox(
                        height: Responsive.getHeight(16),
                      ),
                      Center(
                          child: GestureDetector(
                        onTap: () {
                          if (_formKey.currentState!.validate()) {
                            if (_isChecked) {
                              registerCustomer();
                            } else {
                              showToast(message: "Check Terms of Service");
                            }
                          } else {
                            showToast(message: "Form is not valid");
                          }
                        },
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

  Widget buildTextField<T>({
    required TextEditingController controller,
    required bool isVisible,
    required String hintText,
    required List<T> filteredItems,
    required Function(String) onChanged,
    required Function(T) onTap,
    required Function(bool) setVisible,
  }) {
    return Column(
      children: [
        AppTextFormField(
          contentPadding: EdgeInsets.symmetric(
            horizontal: Responsive.getWidth(18),
            vertical: Responsive.getHeight(18),
          ),
          borderRadius: Responsive.getWidth(8),
          controller: controller,
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
          onChanged: (newValue) {
            // _formKey.currentState!.validate();
            onChanged(newValue ?? ''); // Ensure newValue is non-nullable
            setVisible(true);
          },
          suffixIcon: GestureDetector(
            onTap: () {
              setVisible(true);
            },
            child: Icon(
              size: 24,
              Icons.keyboard_arrow_down_outlined,
              color: Color.fromRGBO(131, 131, 131, 1),
              // size: Responsive.getWidth(28),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '$hintText cannot be empty';
            }
            return null;
          },
          hintText: hintText,
        ),
        if (isVisible)
          Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              color: white,
              height: Responsive.getHeight(150),
              // decoration: BoxDecoration(
              //   border: Border.all(color: Colors.black.withOpacity(0.5)),
              //   borderRadius: BorderRadius.circular(8),
              //   color: Colors.white,
              // ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: filteredItems.length,
                itemBuilder: (context, index) {
                  final item = filteredItems[index];
                  return ListTile(
                    title: Text(
                      item is Country
                          ? item.name
                          : item is StateModel
                              ? item.name
                              : (item as City).name,
                      style: GoogleFonts.poppins(letterSpacing: 1.5),
                    ),
                    onTap: () => onTap(item),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }

  bool _isChecked = false;
  Widget TermsCheckbox() {
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
              _fetchAndShowTerms(context);
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

  void _fetchAndShowTerms(BuildContext context) async {
    try {
      final termsData = await ApiService().getTermsConditions("Exhibition");
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
                                    para['paragraph'],
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

  void showVerificationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return VerifyDialog();
      },
    );
  }
}

class VerifyDialog extends StatefulWidget {
  @override
  _VerifyDialogState createState() => _VerifyDialogState();
}

class _VerifyDialogState extends State<VerifyDialog> {
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
        height: Responsive.getHeight(422),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: Responsive.getWidth(11),
                vertical: Responsive.getHeight(11)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                WantText2(
                    text: "Register Now",
                    fontSize: Responsive.getFontSize(20),
                    fontWeight: AppFontWeight.medium,
                    textColor: textBlack),
                SizedBox(height: Responsive.getHeight(18)),
                WantText2(
                    text: "Enter verification code",
                    fontSize: Responsive.getFontSize(12),
                    fontWeight: AppFontWeight.medium,
                    textColor: textBlack10),
                SizedBox(height: 16),
                Align(
                  alignment: Alignment.center,
                  child: Pinput(
                    controller: _pinController,
                    length: 4,
                    onCompleted: (pin) {
                      print('OTP entered: $pin');
                    },
                    defaultPinTheme: PinTheme(
                      width: 60,
                      height: 60,
                      margin: EdgeInsets.symmetric(
                          horizontal: Responsive.getWidth(10)),
                      textStyle: GoogleFonts.urbanist(
                        color: textBlack,
                        fontSize: Responsive.getFontSize(22),
                        fontWeight: AppFontWeight.bold,
                      ),
                      decoration: BoxDecoration(
                        border:
                            Border.all(color: textFieldBorderColor, width: 1.0),
                        color: whitefill,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    focusedPinTheme: PinTheme(
                      width: 60,
                      height: 60,
                      margin: EdgeInsets.symmetric(
                          horizontal: Responsive.getWidth(10)),
                      textStyle: GoogleFonts.urbanist(
                        color: textBlack,
                        fontSize: Responsive.getFontSize(22),
                        fontWeight: AppFontWeight.bold,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: textFieldBorderColor2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    submittedPinTheme: PinTheme(
                      width: 60,
                      height: 60,
                      margin: EdgeInsets.symmetric(
                          horizontal: Responsive.getWidth(10)),
                      textStyle: GoogleFonts.urbanist(
                        color: textBlack,
                        fontSize: Responsive.getFontSize(22),
                        fontWeight: AppFontWeight.bold,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: textFieldBorderColor2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 23),
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: Responsive.getWidth(50)),
                  child: Text(
                    textAlign: TextAlign.center,
                    "A verification code has been sent to your mobile number and email",
                    style: GoogleFonts.poppins(
                      color: textGray10,
                      fontSize: Responsive.getFontSize(10),
                      fontWeight: AppFontWeight.regular,
                    ),
                  ),
                ),
                SizedBox(height: 120),
                Center(
                  child: GeneralButton(
                    Width: Responsive.getWidth(275),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(
                        context,
                        '/User/SingleUpcomingExhibitionScreen/TicketScreen',
                      );
                    },
                    label: "Verify",
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
