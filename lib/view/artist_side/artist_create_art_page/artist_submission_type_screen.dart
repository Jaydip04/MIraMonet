import 'dart:convert';

import 'package:artist/core/utils/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../../config/colors.dart';
import '../../../core/api_service/base_url.dart';
import '../../../core/utils/app_font_weight.dart';
import '../../../core/widgets/custom_text_2.dart';
import '../../../core/widgets/general_button.dart';
import 'artist_upload_art_screens/artist_additional_detail_screen.dart';
import 'artist_upload_art_screens/artist_review_art_screen.dart';

class ArtistSubmissionTypeScreen extends StatefulWidget {
  const ArtistSubmissionTypeScreen({super.key});

  @override
  State<ArtistSubmissionTypeScreen> createState() =>
      _ArtistSubmissionTypeScreenState();
}

class _ArtistSubmissionTypeScreenState
    extends State<ArtistSubmissionTypeScreen> {
  List<dynamic> submissionTypes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSubmissionTypes();
  }

  Future<void> fetchSubmissionTypes() async {
    final url =
        Uri.parse('$serverUrl/get_submisstion_type');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true) {
          setState(() {
            submissionTypes = data['data'];
            isLoading = false;
          });
        }
      }
    } catch (error) {
      print('Error fetching submission types: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0.0,
        automaticallyImplyLeading: false,
        // centerTitle: true,
        title: Text(
          textAlign: TextAlign.start,
          "Submission Type",
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
            ) // Show loader while fetching data
          : SingleChildScrollView(
              child: Column(
                children: submissionTypes.map((submission) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        getNavigationRoute(submission['type']),
                      );
                    },
                    child: Center(
                      child: Container(
                        width: Responsive.getWidth(337),
                        padding: EdgeInsets.all(Responsive.getWidth(12)),
                        decoration: BoxDecoration(
                            color: getBackgroundColor(
                                submission['art_submission_type_id']),
                            borderRadius:
                                BorderRadius.circular(Responsive.getWidth(12))),
                        margin:
                            EdgeInsets.only(bottom: Responsive.getHeight(13)),
                        // width: Responsive.getWidth(337),
                        // padding: EdgeInsets.all(Responsive.getWidth(12)),
                        // decoration: BoxDecoration(
                        //   color:
                        //   borderRadius:
                        //       BorderRadius.circular(Responsive.getWidth(12)),
                        // ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              textAlign: TextAlign.start,
                              submission['type'],
                              style: GoogleFonts.poppins(
                                letterSpacing: 1.5,
                                color: textBlack8,
                                fontSize: Responsive.getFontSize(16),
                                fontWeight: AppFontWeight.bold,
                              ),
                            ),
                            // Text(
                            //   submission['type'],
                            //   style: GoogleFonts.poppins(
                            //     letterSpacing: 1.5,
                            //     color: textBlack8,
                            //     fontSize: Responsive.getFontSize(16),
                            //     fontWeight: AppFontWeight.bold,
                            //   ),
                            // ),
                            SizedBox(height: Responsive.getHeight(8)),
                            Text(
                              textAlign: TextAlign.start,
                              submission['description'],
                              style: GoogleFonts.poppins(
                                  letterSpacing: 1.5,
                                  color: textBlack8,
                                  fontSize: Responsive.getFontSize(14),
                                  fontWeight: AppFontWeight.regular,
                                  height: 2),
                            ),
                            // Text(
                            //   ,
                            //   maxLines: 2,
                            //   overflow: TextOverflow.ellipsis,
                            //   style: GoogleFonts.poppins(
                            //     letterSpacing: 1.5,
                            //     color: textBlack8,
                            //     fontSize: Responsive.getFontSize(14),
                            //     fontWeight: AppFontWeight.regular,
                            //     height: 2,
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
      // SingleChildScrollView(
      //   child: Column(
      //     children: [
      //       SizedBox(
      //         height: Responsive.getHeight(20),
      //       ),
      //       Center(
      //         child: GestureDetector(
      //           onTap: () {
      //             Navigator.pushNamed(
      //               context,
      //               '/Artist/ArtistOnlineUploadArtScreen',
      //             );
      //           },
      //           child: Container(
      //             width: Responsive.getWidth(337),
      //             padding: EdgeInsets.all(Responsive.getWidth(12)),
      //             decoration: BoxDecoration(
      //                 color: Color.fromRGBO(254, 243, 242, 1),
      //                 borderRadius:
      //                     BorderRadius.circular(Responsive.getWidth(12))),
      //             child: Column(
      //               crossAxisAlignment: CrossAxisAlignment.start,
      //               children: [
      //                 Text(
      //                   textAlign: TextAlign.start,
      //                   "Online Shop",
      //                   style: GoogleFonts.poppins(
      //                     letterSpacing: 1.5,
      //                     color: textBlack8,
      //                     fontSize: Responsive.getFontSize(16),
      //                     fontWeight: AppFontWeight.bold,
      //                   ),
      //                 ),
      //                 SizedBox(
      //                   height: Responsive.getHeight(8),
      //                 ),
      //                 Text(
      //                   textAlign: TextAlign.start,
      //                   "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis ",
      //                   style: GoogleFonts.poppins(
      //                       letterSpacing: 1.5,
      //                       color: textBlack8,
      //                       fontSize: Responsive.getFontSize(14),
      //                       fontWeight: AppFontWeight.regular,
      //                       height: 2),
      //                 ),
      //               ],
      //             ),
      //           ),
      //         ),
      //       ),
      //       SizedBox(
      //         height: Responsive.getHeight(13),
      //       ),
      //       Center(
      //         child: GestureDetector(
      //           onTap: () {
      //             Navigator.pushNamed(
      //               context,
      //               '/Artist/ArtistPrivateUploadScrenn',
      //             );
      //           },
      //           child: Container(
      //             width: Responsive.getWidth(337),
      //             padding: EdgeInsets.all(Responsive.getWidth(12)),
      //             decoration: BoxDecoration(
      //                 color: Color.fromRGBO(245, 247, 255, 1),
      //                 borderRadius:
      //                     BorderRadius.circular(Responsive.getWidth(12))),
      //             child: Column(
      //               crossAxisAlignment: CrossAxisAlignment.start,
      //               children: [
      //                 Text(
      //                   textAlign: TextAlign.start,
      //                   "Private Sale",
      //                   style: GoogleFonts.poppins(
      //                     letterSpacing: 1.5,
      //                     color: textBlack8,
      //                     fontSize: Responsive.getFontSize(16),
      //                     fontWeight: AppFontWeight.bold,
      //                   ),
      //                 ),
      //                 SizedBox(
      //                   height: Responsive.getHeight(8),
      //                 ),
      //                 Text(
      //                   textAlign: TextAlign.start,
      //                   "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis ",
      //                   style: GoogleFonts.poppins(
      //                       letterSpacing: 1.5,
      //                       color: textBlack8,
      //                       fontSize: Responsive.getFontSize(14),
      //                       fontWeight: AppFontWeight.regular,
      //                       height: 2),
      //                 ),
      //               ],
      //             ),
      //           ),
      //         ),
      //       ),
      //       SizedBox(
      //         height: Responsive.getHeight(13),
      //       ),
      //       Center(
      //         child: GestureDetector(
      //           onTap: () {
      //             Navigator.pushNamed(
      //               context,
      //               '/Artist/ArtistListExhibitionScreen',
      //             );
      //           },
      //           child: Container(
      //             width: Responsive.getWidth(337),
      //             padding: EdgeInsets.all(Responsive.getWidth(12)),
      //             decoration: BoxDecoration(
      //                 color: Color.fromRGBO(254, 246, 238, 1),
      //                 borderRadius:
      //                     BorderRadius.circular(Responsive.getWidth(12))),
      //             child: Column(
      //               crossAxisAlignment: CrossAxisAlignment.start,
      //               children: [
      //                 Text(
      //                   textAlign: TextAlign.start,
      //                   "Exhibition or Auction",
      //                   style: GoogleFonts.poppins(
      //                     letterSpacing: 1.5,
      //                     color: textBlack8,
      //                     fontSize: Responsive.getFontSize(16),
      //                     fontWeight: AppFontWeight.bold,
      //                   ),
      //                 ),
      //                 SizedBox(
      //                   height: Responsive.getHeight(8),
      //                 ),
      //                 Text(
      //                   textAlign: TextAlign.start,
      //                   "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis ",
      //                   style: GoogleFonts.poppins(
      //                       letterSpacing: 1.5,
      //                       color: textBlack8,
      //                       fontSize: Responsive.getFontSize(14),
      //                       fontWeight: AppFontWeight.regular,
      //                       height: 2),
      //                 ),
      //               ],
      //             ),
      //           ),
      //         ),
      //       ),
      //       SizedBox(
      //         height: Responsive.getHeight(13),
      //       ),
      //       Center(
      //         child: GestureDetector(
      //           onTap: () {
      //             Navigator.pushNamed(
      //               context,
      //               '/Artist/ArtistListExhibitionScreen',
      //             );
      //           },
      //           child: Container(
      //             width: Responsive.getWidth(337),
      //             padding: EdgeInsets.all(Responsive.getWidth(12)),
      //             decoration: BoxDecoration(
      //                 color: Color.fromRGBO(237, 252, 242, 1),
      //                 borderRadius:
      //                     BorderRadius.circular(Responsive.getWidth(12))),
      //             child: Column(
      //               crossAxisAlignment: CrossAxisAlignment.start,
      //               children: [
      //                 Text(
      //                   textAlign: TextAlign.start,
      //                   "Exhibition Space",
      //                   style: GoogleFonts.poppins(
      //                     letterSpacing: 1.5,
      //                     color: textBlack8,
      //                     fontSize: Responsive.getFontSize(16),
      //                     fontWeight: AppFontWeight.bold,
      //                   ),
      //                 ),
      //                 SizedBox(
      //                   height: Responsive.getHeight(8),
      //                 ),
      //                 Text(
      //                   textAlign: TextAlign.start,
      //                   "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis ",
      //                   style: GoogleFonts.poppins(
      //                       letterSpacing: 1.5,
      //                       color: textBlack8,
      //                       fontSize: Responsive.getFontSize(14),
      //                       fontWeight: AppFontWeight.regular,
      //                       height: 2),
      //                 ),
      //               ],
      //             ),
      //           ),
      //         ),
      //       ),
      //       SizedBox(
      //         height: Responsive.getHeight(20),
      //       )
      //     ],
      //   ),
      // ),
    );
  }

  String getNavigationRoute(String type) {
    switch (type) {
      case "Online Shop":
        return '/Artist/ArtistOnlineUploadArtScreen';
      case "Private Sale":
        return '/Artist/ArtistPrivateUploadScrenn';
      case "Exhibition or Auction":
        return '/Artist/ArtistExhibitionOrAuctionScreen';
      case "Exhibition Space":
        return '/Artist/ArtistExhibitionSpaceScreen';
      default:
        return '';
    }
  }

  Color getBackgroundColor(int id) {
    switch (id) {
      case 1:
        return const Color.fromRGBO(254, 243, 242, 1); // Online Shop
      case 2:
        return const Color.fromRGBO(245, 247, 255, 1); // Private Sale
      case 3:
        return const Color.fromRGBO(254, 246, 238, 1); // Exhibition or Auction
      case 4:
        return const Color.fromRGBO(237, 245, 238, 1); // Exhibition Space
      default:
        return Colors.white;
    }
  }
}
