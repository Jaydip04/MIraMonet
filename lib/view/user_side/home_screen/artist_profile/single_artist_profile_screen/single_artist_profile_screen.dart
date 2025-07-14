import 'dart:convert';

import 'package:artist/view/user_side/home_screen/product_detail/single_product/single_private_product_detail_screen.dart';
import 'package:artist/view/user_side/home_screen/product_detail/single_product/single_product_detail_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../config/colors.dart';
import '../../../../../core/api_service/api_service.dart';
import '../../../../../core/utils/app_font_weight.dart';
import '../../../../../core/utils/responsive.dart';
import '../../../../../core/widgets/custom_text_2.dart';
import 'package:http/http.dart' as http;

class SingleArtistProfileScreen extends StatefulWidget {
  final String artistUniqueId;

  const SingleArtistProfileScreen({Key? key, required this.artistUniqueId})
      : super(key: key);

  @override
  _SingleArtistProfileScreenState createState() =>
      _SingleArtistProfileScreenState();
}

class _SingleArtistProfileScreenState extends State<SingleArtistProfileScreen> {
  bool isExpanded = false;
  List<String> imagePaths = [
    'assets/gallery_1.png',
    'assets/gallery_2.png',
    'assets/donate.png',
    'assets/gallery_1.png',
    'assets/gallery_2.png',
    'assets/donate.png',
    'assets/gallery_1.png',
    'assets/gallery_2.png',
    'assets/donate.png',
    'assets/gallery_1.png',
    'assets/gallery_2.png',
    'assets/donate.png',
  ];

  Map<String, dynamic>? artistData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchArtistData();
  }

  Future<void> fetchArtistData() async {
    print("artistUniqueId : ${widget.artistUniqueId}");
    try {
      setState(() {
        isLoading = true;
      });

      ApiService apiService = ApiService();
      print(widget.artistUniqueId);
      final data = await apiService.fetchSingleArtistData(
          widget.artistUniqueId, "customer");

      setState(() {
        artistData = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching artist data: $e');
    }
  }

  String text =
      'Visual design is a field that combines art and technology. It helps to convey messages visually and can be applied in various forms such as advertising, web design, and multimedia production. Visual designers focus on the aesthetic aspects of designs to create visually appealing and functional products and experiences. Through the use of typography, color, imagery, and layout, visual designers aim to enhance the user experience and effectively communicate messages.';

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
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
              ) // Show loader
            : SafeArea(
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: Responsive.getWidth(16)),
                  child: ListView(
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
                          SizedBox(
                            width: Responsive.getWidth(80),
                          ),
                          WantText2(
                              text: "Artist Profile",
                              fontSize: Responsive.getFontSize(18),
                              fontWeight: AppFontWeight.medium,
                              textColor: textBlack)
                        ],
                      ),
                      SizedBox(height: Responsive.getHeight(27)),
                      artistData?["artdata"] == null
                          ? Container(
                              width: Responsive.getMainWidth(context),
                              height: Responsive.getHeight(700),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    "assets/profile.png",
                                    width: Responsive.getWidth(64),
                                    height: Responsive.getWidth(64),
                                  ),
                                  SizedBox(
                                    height: Responsive.getHeight(24),
                                  ),
                                  WantText2(
                                    text: "No Details",
                                    fontSize: Responsive.getFontSize(20),
                                    fontWeight: AppFontWeight.semiBold,
                                    textColor: textBlack11,
                                  ),
                                ],
                              ),
                            )
                          : Column(
                              children: [
                                Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(30),
                                      child: artistData!["artistData"]
                                                  ["artist_profile"] ==
                                              null
                                          ? CircleAvatar(
                                              radius: 25,
                                              backgroundColor:
                                                  Colors.grey.shade300,
                                              child: Text(
                                                '${artistData!["artistData"]["artist_name"].toUpperCase()}',
                                                style: TextStyle(
                                                    fontSize: 24,
                                                    color: black,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            )
                                          : CircleAvatar(
                                              radius: 25,
                                              backgroundColor:
                                                  Colors.grey.shade300,
                                              child: Image.network(
                                                artistData!["artistData"]
                                                    ["artist_profile"],
                                                width: Responsive.getWidth(50),
                                                height: Responsive.getWidth(50),
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                    ),
                                    SizedBox(width: 16.0),
                                    WantText2(
                                        text: artistData!["artistData"]
                                            ["artist_name"],
                                        fontSize: Responsive.getFontSize(16),
                                        fontWeight: AppFontWeight.semiBold,
                                        textColor: Color.fromRGBO(0, 0, 0, 0.6))
                                  ],
                                ),
                                SizedBox(height: Responsive.getHeight(16)),
                                artistData!["artistData"]["introduction"] ==
                                        null
                                    ? SizedBox()
                                    : Container(
                                        child: Stack(
                                          children: [
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                vertical:
                                                    Responsive.getWidth(8),
                                              ),
                                              child: Container(
                                                width: double.infinity,
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                      width: 1,
                                                      color: Color.fromRGBO(
                                                          0, 0, 0, 0.25)),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          Responsive.getWidth(
                                                              10)),
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Padding(
                                                        padding: EdgeInsets.only(
                                                            top: Responsive
                                                                .getHeight(14),
                                                            right: Responsive
                                                                .getWidth(12),
                                                            left: Responsive
                                                                .getWidth(12)),
                                                        child: WantText2(
                                                            text:
                                                                "About Artist",
                                                            fontSize: Responsive
                                                                .getFontSize(
                                                                    12),
                                                            fontWeight:
                                                                AppFontWeight
                                                                    .bold,
                                                            textColor:
                                                                textBlack)),
                                                    artistData!["artistData"][
                                                                "introduction"] ==
                                                            null
                                                        ? SizedBox()
                                                        : SizedBox(height: 8.0),
                                                    artistData!["artistData"][
                                                                "introduction"] ==
                                                            null
                                                        ? SizedBox()
                                                        : Padding(
                                                            padding: EdgeInsets.only(
                                                                bottom: Responsive
                                                                    .getHeight(
                                                                        24),
                                                                right: Responsive
                                                                    .getWidth(
                                                                        12),
                                                                left: Responsive
                                                                    .getWidth(
                                                                        12)),
                                                            child:
                                                                AnimatedCrossFade(
                                                              firstChild: Text(
                                                                maxLines: 3,
                                                                textAlign:
                                                                    TextAlign
                                                                        .start,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                artistData![
                                                                        "artistData"]
                                                                    [
                                                                    "introduction"],
                                                                style:
                                                                    GoogleFonts
                                                                        .poppins(
                                                                  letterSpacing:
                                                                      1.5,
                                                                  color:
                                                                      textBlack,
                                                                  fontSize: Responsive
                                                                      .getFontSize(
                                                                          10),
                                                                  fontWeight:
                                                                      AppFontWeight
                                                                          .regular,
                                                                ),
                                                              ),
                                                              secondChild: Text(
                                                                textAlign:
                                                                    TextAlign
                                                                        .start,
                                                                artistData![
                                                                        "artistData"]
                                                                    [
                                                                    "introduction"],
                                                                style:
                                                                    GoogleFonts
                                                                        .poppins(
                                                                  letterSpacing:
                                                                      1.5,
                                                                  color:
                                                                      textBlack,
                                                                  fontSize: Responsive
                                                                      .getFontSize(
                                                                          10),
                                                                  fontWeight:
                                                                      AppFontWeight
                                                                          .regular,
                                                                ),
                                                              ),
                                                              crossFadeState: isExpanded
                                                                  ? CrossFadeState
                                                                      .showSecond
                                                                  : CrossFadeState
                                                                      .showFirst,
                                                              duration: Duration(
                                                                  milliseconds:
                                                                      2000),
                                                            ),
                                                          ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              bottom: isExpanded
                                                  ? screenHeight * 0.0
                                                  : screenHeight * 0.0,
                                              left: 0,
                                              right: 0,
                                              child: Align(
                                                alignment: Alignment.center,
                                                child: GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      isExpanded = !isExpanded;
                                                    });
                                                  },
                                                  child: Container(
                                                    height:
                                                        screenHeight * 0.0375,
                                                    width: screenWidth * 0.325,
                                                    decoration: BoxDecoration(
                                                      color: Colors.black,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              screenWidth *
                                                                  0.25),
                                                    ),
                                                    child: Center(
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          Icon(
                                                            isExpanded
                                                                ? Icons
                                                                    .keyboard_arrow_up
                                                                : Icons
                                                                    .keyboard_arrow_down,
                                                            color: Colors.white,
                                                          ),
                                                          SizedBox(
                                                              width:
                                                                  screenWidth *
                                                                      0.015),
                                                          Text(
                                                            isExpanded
                                                                ? "See less"
                                                                : "Read More",
                                                            style: GoogleFonts
                                                                .poppins(
                                                              textStyle:
                                                                  TextStyle(
                                                                letterSpacing:
                                                                    1.5,
                                                                fontSize:
                                                                    screenWidth *
                                                                        0.03,
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
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
                                SizedBox(height: 16.0),
                                artistData!["artistData"]["introduction"] ==
                                        null
                                    ? SizedBox()
                                    : Text(
                                        '${artistData!["artdata"][0]["artist_name"]}\'s Artwork',
                                        style: GoogleFonts.poppins(
                                          textStyle: TextStyle(
                                            letterSpacing: 1.5,
                                            fontSize:
                                                Responsive.getFontSize(20),
                                            color: black,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                SizedBox(height: 8.0),
                                Container(
                                  alignment: Alignment.center,
                                  child: StaggeredGridView.countBuilder(
                                    staggeredTileBuilder: (index) =>
                                        StaggeredTile.fit(2),
                                    shrinkWrap: true,
                                    mainAxisSpacing: 20,
                                    crossAxisSpacing: 20,
                                    physics: NeverScrollableScrollPhysics(),
                                    crossAxisCount: 4,
                                    itemCount: artistData!["artdata"]
                                        .length, // Total number of items
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return GestureDetector(
                                        onTap: () {
                                          print(
                                              "artistUniqueId : ${artistData!["artdata"][index]["art_unique_id"]}");
                                          if (artistData!["artdata"][index]
                                                  ["art_type"] ==
                                              "Online") {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    SingleProductDetailScreen(
                                                  art_status:
                                                      artistData!["artdata"]
                                                              [index]["status"]
                                                          .toString(),
                                                  artUniqueId:
                                                      artistData!["artdata"]
                                                                  [index]
                                                              ["art_unique_id"]
                                                          .toString(),
                                                ),
                                              ),
                                            );
                                          } else if (artistData!["artdata"]
                                                  [index]["art_type"] ==
                                              "Private") {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    SinglePrivateProductDetailScreen(
                                                  artUniqueId:
                                                      artistData!["artdata"]
                                                                  [index]
                                                              ["art_unique_id"]
                                                          .toString(),
                                                ),
                                              ),
                                            );
                                          } else {
                                            // Navigator.push(
                                            //   context,
                                            //   MaterialPageRoute(
                                            //     builder: (_) =>
                                            //         SingleProductDetailScreen(
                                            //           artUniqueId:
                                            //           artistData!["artdata"]
                                            //           [index]
                                            //           ["art_unique_id"]
                                            //               .toString(),
                                            //         ),
                                            //   ),
                                            // );
                                          }
                                        },
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Stack(
                                              children: [
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          16.0),
                                                  child: artistData!["artdata"]
                                                                  [index]
                                                              ["artImages"]
                                                          .isEmpty
                                                      ? Container(
                                                    height: Responsive
                                                        .getHeight(175),
                                                    width: Responsive
                                                        .getWidth(160),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors
                                                                .grey.shade300,
                                                          ),
                                                          child: Center(
                                                            child: Text(
                                                              '${artistData!["artdata"][index]["title"].toUpperCase()}',
                                                              style: TextStyle(
                                                                  fontSize: 24,
                                                                  color: black,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                          ),
                                                        )
                                                      : Image.network(
                                                          height: Responsive
                                                              .getHeight(175),
                                                          width: Responsive
                                                              .getWidth(160),
                                                          artistData!["artdata"]
                                                                      [index]
                                                                  ["artImages"]
                                                              [1]["image"],
                                                          fit: BoxFit.contain,
                                                        ),
                                                ),
                                                artistData!["artdata"][index]
                                                            ["status"] ==
                                                        "Sold"
                                                    ? Positioned(
                                                        child: Container(
                                                          // height: Responsive.getHeight(20),
                                                          // width: 68,
                                                          padding: EdgeInsets.symmetric(
                                                              horizontal:
                                                                  Responsive
                                                                      .getWidth(
                                                                          16),
                                                              vertical:
                                                                  Responsive
                                                                      .getWidth(
                                                                          3)),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: black,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        4),
                                                          ),
                                                          child: SizedBox(
                                                            // width: Responsive.getWidth(80),
                                                            child: Center(
                                                              child: Text(
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                artistData!["artdata"]
                                                                        [index]
                                                                    ["status"],
                                                                style: GoogleFonts.poppins(
                                                                    color:
                                                                        white,
                                                                    fontSize: Responsive
                                                                        .getFontSize(
                                                                            10),
                                                                    fontWeight:
                                                                        AppFontWeight
                                                                            .medium,
                                                                    letterSpacing:
                                                                        1.5),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        top: 10,
                                                        left: 10,
                                                      )
                                                    : SizedBox(),
                                              ],
                                            ),
                                            SizedBox(
                                                height:
                                                    Responsive.getHeight(6)),
                                            Container(
                                              // height: 59,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  WantText2(
                                                    text: artistData!["artdata"]
                                                        [index]["title"],
                                                    fontSize:
                                                        Responsive.getFontSize(
                                                            14),
                                                    fontWeight:
                                                        AppFontWeight.medium,
                                                    textColor: textBlack,
                                                    textOverflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  WantText2(
                                                    text: artistData!["artdata"]
                                                        [index]["artist_name"],
                                                    fontSize:
                                                        Responsive.getFontSize(
                                                            11),
                                                    fontWeight:
                                                        AppFontWeight.regular,
                                                    textColor: textBlack,
                                                    textOverflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  WantText2(
                                                    text:
                                                        "\$${artistData!["artdata"][index]["price"]}",
                                                    fontSize:
                                                        Responsive.getFontSize(
                                                            14),
                                                    fontWeight:
                                                        AppFontWeight.medium,
                                                    textColor: textBlack,
                                                    textOverflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                    // staggeredTileBuilder: (int index) {
                                    //   if (index % 5 == 0) {
                                    //     return const StaggeredTile.count(2, 2);
                                    //   } else if (index % 5 == 1 ||
                                    //       index % 5 == 2) {
                                    //     return const StaggeredTile.count(2, 1);
                                    //   } else if (index % 5 == 3 ||
                                    //       index % 5 == 4) {
                                    //     return const StaggeredTile.count(4, 1);
                                    //   } else {
                                    //     return const StaggeredTile.count(2, 1);
                                    //   }
                                    // },
                                    // mainAxisSpacing: 8.0,
                                    // crossAxisSpacing: 8.0,
                                  ),
                                ),
                              ],
                            )

                      // GridView.count(
                      //   crossAxisCount: 2,
                      //   shrinkWrap: true,
                      //   physics: NeverScrollableScrollPhysics(),
                      //   crossAxisSpacing: 8.0,
                      //   mainAxisSpacing: 8.0,
                      //   children: List.generate(6, (index) {
                      //     return Image.network(
                      //       'https://via.placeholder.com/150', // Replace with artwork images URLs
                      //       fit: BoxFit.cover,
                      //     );
                      //   }),
                      // ),
                    ],
                  ),
                ),
              ));
  }
}

Color getStatusColor(String status) {
  switch (status) {
    case 'Sold':
      return Color(0XFF29BA38);
    case 'Declined':
      return Color(0XFFFF2828);
    case 'Approved':
      return Color(0XFF0A00B0);
    case 'Pending':
      return Color(0XFFDABD00);
    default:
      return Colors.grey;
  }
}
