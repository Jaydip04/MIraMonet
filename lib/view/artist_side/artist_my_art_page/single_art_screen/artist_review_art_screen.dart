import 'dart:async';
import 'package:artist/core/models/upload_art_model/art_review_model.dart';
import 'package:artist/view/artist_side/artist_create_art_page/artist_upload_art_screens/artist_add_story_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../config/colors.dart';
import '../../../../config/toast.dart';
import '../../../../core/api_service/api_service.dart';
import '../../../../core/utils/app_font_weight.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/general_button.dart';
import '../../../../core/widgets/custom_text_2.dart';

class ArtistSingleArtScreen extends StatefulWidget {
  final String artUniqueID;

  ArtistSingleArtScreen({required this.artUniqueID});

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

  final PageController _pageController = PageController();
  var artUniqueID;

  late Future<ArtReviewModel> _artDetails;
  bool isClick = true;
  bool isLoading = false;
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
    if (widget.artUniqueID != null) {
      setState(() {
        artUniqueID = widget.artUniqueID;
        _artDetails = ApiService().fetchArtDetails(widget.artUniqueID);
        isClick = false;
      });
      print("Retrieved Art Unique ID: ${widget.artUniqueID}");
    }
  }

  Future<void> removeArtUniqueId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('artUniqueId');
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return Scaffold(
      backgroundColor: white,
      body: SafeArea(
          child: isClick
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
              : FutureBuilder<ArtReviewModel>(
                  future: _artDetails,
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
                      return Center(
                          child: WantText2(
                              text: "No Art Details available",
                              fontSize: Responsive.getFontSize(16),
                              fontWeight: AppFontWeight.regular,
                              textColor: black));
                    } else if (snapshot.hasData) {
                      print(snapshot.hasData);
                      ArtReviewModel artDetails = snapshot.data!;
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
                                            color: textFieldBorderColor,
                                            width: 1.0)),
                                    child: Icon(
                                      Icons.arrow_back_ios_new_outlined,
                                      size: Responsive.getWidth(19),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: Responsive.getWidth(100),
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
                          artDetails.images!.length == 0 ? SizedBox() : Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: Responsive.getWidth(16)),
                            width: Responsive.getWidth(328),
                            height: Responsive.getHeight(400),
                            child: Center(
                              child: PageView.builder(
                                controller: _pageController,
                                itemCount: artDetails.images!.length,
                                itemBuilder: (context, index) {
                                  return Container(
                                    width: double.infinity,
                                    height: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                          Responsive.getWidth(10)),
                                      image: DecorationImage(
                                        image: NetworkImage(
                                            artDetails.images![index]),
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
                            padding: EdgeInsets.symmetric(
                                horizontal: Responsive.getWidth(16)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(),
                                    // Container(
                                    //   child: Text(
                                    //     textAlign: TextAlign.center,
                                    //     artDetails.status,
                                    //     style: GoogleFonts.poppins(
                                    //       letterSpacing: 1.5,
                                    //       color: white,
                                    //       fontSize: Responsive.getFontSize(10),
                                    //       fontWeight: AppFontWeight.regular,
                                    //     ),
                                    //   ),
                                    //   padding: EdgeInsets.symmetric(horizontal: Responsive.getWidth(10),vertical: Responsive.getHeight(5)),
                                    //   decoration: BoxDecoration(
                                    //     color:getStatusColor(artDetails.status),
                                    //     borderRadius: BorderRadius.circular(Responsive.getWidth(4))
                                    //   ),
                                    // )
                                    _buildStatusTag(artDetails.status ?? "",
                                        artDetails.colorCode!),
                                  ],
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                ),
                                Text(
                                  textAlign: TextAlign.start,
                                  artDetails.title ?? "",
                                  style: GoogleFonts.poppins(
                                    letterSpacing: 1.5,
                                    color: textBlack5,
                                    fontSize: Responsive.getFontSize(24),
                                    fontWeight: AppFontWeight.semiBold,
                                  ),
                                ),
                                SizedBox(height: Responsive.getHeight(6)),
                                Text(
                                  textAlign: TextAlign.start,
                                  "Artist Name : ${artDetails.artistName}",
                                  style: GoogleFonts.poppins(
                                    letterSpacing: 1.5,
                                    color: textBlack5,
                                    fontSize: Responsive.getFontSize(14),
                                    fontWeight: AppFontWeight.medium,
                                  ),
                                ),
                                SizedBox(
                                  height: Responsive.getWidth(9),
                                ),
                                Text(
                                  textAlign: TextAlign.start,
                                  "\$${artDetails.price}",
                                  style: GoogleFonts.poppins(
                                    letterSpacing: 1.5,
                                    color: textBlack,
                                    fontSize: Responsive.getFontSize(20),
                                    fontWeight: AppFontWeight.bold,
                                  ),
                                ),
                                SizedBox(
                                  height: Responsive.getWidth(9),
                                ),
                                Text(
                                    textAlign: TextAlign.start,
                                    "Edition : ${artDetails.edition}",
                                    style: GoogleFonts.poppins(
                                      letterSpacing: 1.5,
                                      color: textGray5,
                                      fontSize: Responsive.getFontSize(12),
                                      fontWeight: AppFontWeight.semiBold,
                                    )),
                                Text(
                                    textAlign: TextAlign.start,
                                    "Since : ${artDetails.since}",
                                    style: GoogleFonts.poppins(
                                      letterSpacing: 1.5,
                                      color: textGray5,
                                      fontSize: Responsive.getFontSize(12),
                                      fontWeight: AppFontWeight.semiBold,
                                    )),
                                Text(
                                    textAlign: TextAlign.start,
                                    "Sold With Frame : ${artDetails.frame}",
                                    style: GoogleFonts.poppins(
                                      color: textGray5,
                                      fontSize: Responsive.getFontSize(12),
                                      fontWeight: AppFontWeight.semiBold,
                                    )),
                                // SizedBox(height: Responsive.getHeight(4)),
                                // ListView.builder(
                                //     itemCount: artDetails.details.length,
                                //     shrinkWrap: true,
                                //     itemBuilder: (context, index) {
                                //       return Row(
                                //         mainAxisAlignment: MainAxisAlignment.start,
                                //         crossAxisAlignment: CrossAxisAlignment.start,
                                //         children: [
                                //           Container(
                                //             child: Text(
                                //               textAlign: TextAlign.start,
                                //               artDetails.details[index].description,
                                //               style: GoogleFonts.poppins(
                                //                 color: textGray5,
                                //                 fontSize: Responsive.getFontSize(12),
                                //                 fontWeight: AppFontWeight.semiBold,
                                //               ),
                                //             ),
                                //             width: Responsive.getWidth(305),
                                //           ),
                                //         ],
                                //       );
                                //     }),
                                SizedBox(height: Responsive.getHeight(15)),
                                Text(
                                  textAlign: TextAlign.start,
                                  artDetails.paragraph ?? "",
                                  style: GoogleFonts.poppins(
                                    letterSpacing: 1.5,
                                    color: textGray5,
                                    fontSize: Responsive.getFontSize(14),
                                    fontWeight: AppFontWeight.semiBold,
                                  ),
                                ),
                                SizedBox(
                                  height: Responsive.getHeight(21),
                                ),
                                artDetails.details!.length == 0 ?SizedBox() :Text(
                                  textAlign: TextAlign.start,
                                  "Additional Detail",
                                  style: GoogleFonts.poppins(
                                    letterSpacing: 1.5,
                                    color: textBlack,
                                    fontSize: Responsive.getFontSize(16),
                                    fontWeight: AppFontWeight.regular,
                                  ),
                                ),
                                artDetails.details!.length == 0 ? SizedBox():SizedBox(
                                  height: Responsive.getHeight(10),
                                ),
                              ],
                            ),
                          ),
                          artDetails.details!.length == 0
                              ? SizedBox()
                              : Container(
                                  margin: EdgeInsets.symmetric(
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
                                              fontSize:
                                                  Responsive.getFontSize(13),
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
                                                  decoration: BoxDecoration(
                                                      color: Colors.grey),
                                                  height:
                                                      Responsive.getHeight(50),
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
                                              fontSize:
                                                  Responsive.getFontSize(13),
                                              fontWeight: AppFontWeight.regular,
                                              textColor: textBlack11,
                                            ),
                                            width: Responsive.getWidth(196),
                                          ),
                                        ),
                                      ],
                                      rows: artDetails.details!.map((detail) {
                                        return DataRow(cells: [
                                          // Title Column
                                          DataCell(Container(
                                            child: WantText2(
                                              text: detail.artDataTitle ?? "",
                                              fontSize:
                                                  Responsive.getFontSize(10),
                                              fontWeight: AppFontWeight.regular,
                                              textColor: textBlack11,
                                            ),
                                            width: Responsive.getWidth(75),
                                            alignment: Alignment.centerLeft,
                                          )),

                                          // Vertical Divider
                                          DataCell(Container(
                                            decoration: BoxDecoration(
                                              color: Colors.grey,
                                              border: Border(
                                                left: BorderSide(
                                                    color: Colors.grey,
                                                    width: 1.0),
                                              ),
                                            ),
                                            width: 1,
                                          )),

                                          // Description Column
                                          DataCell(Container(
                                            child: Text(
                                              detail.description ?? "",
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.start,
                                              style: GoogleFonts.poppins(
                                                letterSpacing: 1.5,
                                                color: textBlack11,
                                                fontSize:
                                                    Responsive.getFontSize(10),
                                                fontWeight:
                                                    AppFontWeight.regular,
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
                          SizedBox(
                            height: Responsive.getHeight(10),
                          ),
                        ],
                      );
                    } else {
                      return Center(child: Text('No data available'));
                    }
                  },
                )),
    );
  }
}

Widget _buildStatusTag(String status, String colorCode) {
  final String colors = colorCode;
  final String formattedColor =
      colors.startsWith("#") ? colors.substring(1) : colors;
  Color bgColor = getStatusColor(status);

  return Container(
    padding: EdgeInsets.symmetric(
      horizontal: Responsive.getWidth(8),
      vertical: Responsive.getHeight(4),
    ),
    decoration: BoxDecoration(
      color: Color(0xFF000000 | int.parse(formattedColor, radix: 16)),
      borderRadius: BorderRadius.circular(4),
    ),
    child: Text(
      status,
      style: GoogleFonts.poppins(
        letterSpacing: 1.5,
        color: Colors.white,
        fontSize: Responsive.getFontSize(12),
        fontWeight: AppFontWeight.medium,
      ),
    ),
  );
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
