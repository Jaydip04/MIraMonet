import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../config/colors.dart';
import '../../../../core/utils/app_font_weight.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/general_button.dart';
import '../../../../core/widgets/custom_text_2.dart';

class ArtistSingleArtScreen extends StatefulWidget {
  @override
  _ArtistSingleArtScreenState createState() => _ArtistSingleArtScreenState();
}

class _ArtistSingleArtScreenState extends State<ArtistSingleArtScreen> {
  final List<String> _paintingImages = [
    'assets/gallery_2.png',
    'assets/donate.png',
    'assets/gallery_1.png',
    'assets/gallery_2.png',
    'assets/back.png',
    'assets/gallery_1.png',
  ];

  // PageController to control the PageView
  final PageController _pageController = PageController();

  List<Map<String, String>> _additionalDetails = [
    {
      'title': "Edition",
      'description': "2050-2060",
    },
  ];

  int currentStep = 1;

  final List<String> statuses = [
    "Packing",
    "Picked",
    "In Transit",
    "Delivered"
  ];

  final List<String> addresses = [
    "2336 Jack Warren Rd, Delta Junction, Alaska 99737, USA",
    "2417 Tongass Ave #111, Ketchikan, Alaska 99901, USA",
    "16 Rr 2, Ketchikan, Alaska 99901, USA",
    "925 S Chugach St #APT 10, Alaska 99645"
  ];

  @override
  void initState() {
    super.initState();
    Timer.periodic(Duration(seconds: 3), (Timer timer) {
      if (_pageController.hasClients) {
        if (_pageController.page!.toInt() < _paintingImages.length - 1) {
          _pageController.nextPage(
            duration: Duration(milliseconds: 1000),
            curve: Curves.easeInOut,
          );
        } else {
          _pageController.jumpToPage(0);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return Scaffold(
      backgroundColor: white,
      body: SafeArea(
        child: ListView(
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
                    width: Responsive.getWidth(105),
                  ),
                  WantText2(
                      text: "My Art",
                      fontSize: Responsive.getFontSize(18),
                      fontWeight: AppFontWeight.medium,
                      textColor: textBlack)
                ],
              ),
            ),
            SizedBox(
              height: Responsive.getHeight(22),
            ),
            Container(
              width: double.infinity,
              height: Responsive.getHeight(326),
              margin: EdgeInsets.symmetric(horizontal: Responsive.getWidth(16)),
              decoration: BoxDecoration(boxShadow: [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.1),
                  spreadRadius: 0,
                  offset: Offset(4, 4),
                  blurRadius: 16,
                )
              ]),
              child: Center(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _paintingImages.length,
                  itemBuilder: (context, index) {
                    return Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(_paintingImages[index]),
                          fit: BoxFit.contain,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            SizedBox(
              height: Responsive.getHeight(17),
            ),
            Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: Responsive.getWidth(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Painting Name
                  Row(
                    children: [
                      Container(
                        child: Text(
                          textAlign: TextAlign.start,
                          "Wallowing Breeze",
                          style: GoogleFonts.poppins(
                            letterSpacing: 1.5,
                            color: textBlack5,
                            fontSize: Responsive.getFontSize(24),
                            fontWeight: AppFontWeight.semiBold,
                          ),
                        ),
                        width: Responsive.getWidth(290),
                      ),
                      Container(
                        child: Center(
                          child: Text(
                            textAlign: TextAlign.start,
                            "Sold",
                            style: GoogleFonts.poppins(
                              letterSpacing: 1.5,
                              color: white,
                              fontSize: Responsive.getFontSize(10),
                              fontWeight: AppFontWeight.regular,
                            ),
                          ),
                        ),
                        decoration: BoxDecoration(
                            color: Color.fromRGBO(41, 186, 56, 1),
                            borderRadius: BorderRadius.circular(4)),
                        height: Responsive.getHeight(20),
                        width: Responsive.getWidth(53),
                      ),
                    ],
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  ),
                  SizedBox(height: Responsive.getHeight(6)),
                  Text(
                    textAlign: TextAlign.start,
                    "Hettie Richards",
                    style: GoogleFonts.poppins(
                      letterSpacing: 1.5,
                      color: textBlack5,
                      fontSize: Responsive.getFontSize(14),
                      fontWeight: AppFontWeight.medium,
                    ),
                  ),
                  SizedBox(height: Responsive.getHeight(4)),
                  Text(
                    textAlign: TextAlign.start,
                    "Oil on canvas, 2008",
                    style: GoogleFonts.poppins(
                      letterSpacing: 1.5,
                      color: textGray5,
                      fontSize: Responsive.getFontSize(14),
                      fontWeight: AppFontWeight.semiBold,
                    ),
                  ),
                  Text(
                    textAlign: TextAlign.start,
                    "Gallery wrap canvas",
                    style: GoogleFonts.poppins(
                      letterSpacing: 1.5,
                      color: textGray5,
                      fontSize: Responsive.getFontSize(14),
                      fontWeight: AppFontWeight.semiBold,
                    ),
                  ),
                  Text(
                    textAlign: TextAlign.start,
                    "26 in × 23 in",
                    style: GoogleFonts.poppins(
                      color: textGray5,
                      fontSize: Responsive.getFontSize(14),
                      fontWeight: AppFontWeight.semiBold,
                    ),
                  ),
                  SizedBox(height: Responsive.getHeight(8)),
                  Text(
                    textAlign: TextAlign.start,
                    "Dynamic and elusive abstraction and texture. Plays between the lines of chaos and serenity. Perfect fit for modern and contemporary styled interiors.",
                    style: GoogleFonts.poppins(
                      color: textGray5,
                      fontSize: Responsive.getFontSize(14),
                      fontWeight: AppFontWeight.semiBold,
                    ),
                  ),
                  SizedBox(height: Responsive.getHeight(21)),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsetsDirectional.symmetric(
                  horizontal: Responsive.getWidth(16)),
              child: WantText2(
                  text: "Additional Detail",
                  fontSize: Responsive.getFontSize(16),
                  fontWeight: AppFontWeight.regular,
                  textColor: textBlack),
            ),
            SizedBox(height: Responsive.getHeight(10)),
            Container(
              margin: EdgeInsetsDirectional.symmetric(
                  horizontal: Responsive.getWidth(16)),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(10),
              ),
              child: SingleChildScrollView(
                child: DataTable(
                  dataRowHeight: Responsive.getHeight(50),
                  columnSpacing: 0,
                  columns: [
                    DataColumn(
                      label: Container(
                        child: WantText2(
                          text: "Title",
                          fontSize: Responsive.getFontSize(13),
                          fontWeight: AppFontWeight.regular,
                          textColor: textBlack11,
                        ),
                        width: Responsive.getWidth(78),
                      ),
                    ),
                    DataColumn(
                      label: Container(
                        height: Responsive.getHeight(57),
                        child: Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(color: Colors.grey),
                              height: Responsive.getHeight(57),
                              width: 1,
                            ),
                          ],
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Container(
                        child: WantText2(
                          text: "Description",
                          fontSize: Responsive.getFontSize(13),
                          fontWeight: AppFontWeight.regular,
                          textColor: textBlack11,
                        ),
                        width: Responsive.getWidth(196),
                      ),
                    ),
                  ],
                  rows: _additionalDetails.map((detail) {
                    return DataRow(cells: [
                      // Title Column
                      DataCell(Container(
                        child: WantText2(
                          text: detail['title']!,
                          fontSize: Responsive.getFontSize(10),
                          fontWeight: AppFontWeight.regular,
                          textColor: textBlack11,
                        ),
                        width: Responsive.getWidth(78),
                        alignment: Alignment.centerLeft,
                      )),

                      // Vertical Divider
                      DataCell(Container(
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          border: Border(
                            left: BorderSide(color: Colors.grey, width: 1.0),
                          ),
                        ),
                        width: 1,
                      )),

                      // Description Column
                      DataCell(Container(
                        child: Text(
                          detail['description']!,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.start,
                          style: GoogleFonts.poppins(
                            color: textBlack11,
                            fontSize: Responsive.getFontSize(10),
                            fontWeight: AppFontWeight.regular,
                          ),
                        ),
                        width: Responsive.getWidth(196),
                        height: Responsive.getHeight(50),
                        alignment: Alignment.centerLeft,
                      )),
                    ]);
                  }).toList(),
                ),
              ),
            ),
            SizedBox(height: Responsive.getHeight(32)),
            Padding(
              padding: EdgeInsetsDirectional.symmetric(
                  horizontal: Responsive.getWidth(16)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  WantText2(
                      text: "Order ID: 33546",
                      fontSize: Responsive.getFontSize(14),
                      fontWeight: AppFontWeight.semiBold,
                      textColor: Color.fromRGBO(52, 64, 84, 1)),
                  WantText2(
                      text: "Feb 16, 2022",
                      fontSize: Responsive.getFontSize(14),
                      fontWeight: AppFontWeight.semiBold,
                      textColor: Color.fromRGBO(52, 64, 84, 1)),
                ],
              ),
            ),
            SizedBox(height: Responsive.getHeight(32)),
            Padding(
              padding: EdgeInsetsDirectional.symmetric(
                  horizontal: Responsive.getWidth(16)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  WantText2(
                      text: "Order Status",
                      fontSize: Responsive.getFontSize(20),
                      fontWeight: AppFontWeight.semiBold,
                      textColor: Color.fromRGBO(26, 26, 26, 1)),
                  WantText2(
                      text: "",
                      fontSize: Responsive.getFontSize(14),
                      fontWeight: AppFontWeight.semiBold,
                      textColor: Color.fromRGBO(52, 64, 84, 1)),
                ],
              ),
            ),
            SizedBox(height: Responsive.getHeight(16)),
            Padding(
              padding: EdgeInsetsDirectional.symmetric(
                  horizontal: Responsive.getWidth(16)),
              child: Divider(
                color: Color.fromRGBO(230, 230, 230, 1),
              ),
            ),
            SizedBox(height: Responsive.getHeight(16)),
            Padding(
              padding: EdgeInsetsDirectional.symmetric(
                  horizontal: Responsive.getWidth(16)),
              child: Column(
                children: [
                  for (int i = 0; i < statuses.length; i++) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Status Circle
                        Column(
                          children: [
                            i <= currentStep
                                ? Image.asset(
                                    "assets/artist/status.png",
                                    width: Responsive.getWidth(20),
                                    height: Responsive.getWidth(20),
                                  )
                                : Image.asset(
                                    "assets/artist/status_empty.png",
                                    width: Responsive.getWidth(20),
                                    height: Responsive.getWidth(20),
                                  ),
                            if (i != statuses.length - 1)
                              Container(
                                width: 5,
                                height: 50,
                                child: i <= currentStep
                                    ? Image.asset(
                                        "assets/artist/line_black.png",
                                        height: Responsive.getWidth(50),
                                        fit: BoxFit.contain,
                                      )
                                    : Image.asset(
                                        "assets/artist/line_gray.png",
                                        height: Responsive.getWidth(50),
                                        fit: BoxFit.contain,
                                      ),
                                // color: i < currentStep ? Colors.green : Colors.grey,
                              ),
                          ],
                        ),
                        // const SizedBox(width: 16),
                        // Status Details
                        Flexible(
                          child: Padding(
                            padding:
                                EdgeInsets.only(left: Responsive.getWidth(8)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  textAlign: TextAlign.start,
                                  statuses[i],
                                  style: GoogleFonts.poppins(
                                    color: Color.fromRGBO(26, 26, 26, 1),
                                    fontSize: Responsive.getFontSize(16),
                                    fontWeight: AppFontWeight.semiBold,
                                  ),
                                ),
                                Text(
                                  textAlign: TextAlign.start,
                                  addresses[i],
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(
                                    color: Color.fromRGBO(128, 128, 128, 1),
                                    fontSize: Responsive.getFontSize(14),
                                    fontWeight: AppFontWeight.regular,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                ],
              ),
            ),
            SizedBox(height: Responsive.getHeight(16)),
            Padding(
              padding: EdgeInsetsDirectional.symmetric(
                  horizontal: Responsive.getWidth(16)),
              child: Divider(
                color: Color.fromRGBO(230, 230, 230, 1),
              ),
            ),
            SizedBox(height: Responsive.getHeight(16)),
            Padding(
              padding: EdgeInsetsDirectional.symmetric(
                  horizontal: Responsive.getWidth(16)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      Row(
                        children: [
                          ClipRRect(
                            child: Image.asset(
                              "assets/donate.png",
                              height: Responsive.getWidth(48),
                              width: Responsive.getWidth(48),
                              fit: BoxFit.contain,
                            ),
                            borderRadius:
                                BorderRadius.circular(Responsive.getWidth(80)),
                          ),
                          SizedBox(
                            width: Responsive.getWidth(12),
                          ),
                          Container(
                            width: Responsive.getWidth(221),
                            child: Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                        width: Responsive.getWidth(221),
                                        child: WantText2(
                                            text:
                                                "Jacob Jones",
                                            fontSize:
                                                Responsive.getFontSize(16),
                                            fontWeight: AppFontWeight.semiBold,
                                            textColor: textBlack11)),
                                    WantText2(
                                        text: "Delivery Guy",
                                        fontSize: Responsive.getFontSize(14),
                                        fontWeight: AppFontWeight.regular,
                                        textColor:
                                            Color.fromRGBO(128, 128, 128, 1))
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                      width: Responsive.getWidth(48),
                      height: Responsive.getWidth(48),
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: Color.fromRGBO(230, 230, 230, 1)),
                      child: Image.asset(
                        "assets/artist/call.png",
                        height: Responsive.getWidth(24),
                        width: Responsive.getWidth(24),
                      ))
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
