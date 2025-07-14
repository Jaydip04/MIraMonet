import 'package:artist/view/artist_side/artist_home_page/artist_home_screens/story_artist_add_story_screen.dart';
import 'package:artist/view/artist_side/artist_my_art_page/single_art_screen/artist_boost_screen.dart';
import 'package:artist/view/artist_side/artist_my_art_page/single_art_screen/artist_review_art_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../config/colors.dart';
import '../../../../config/toast.dart';
import '../../../../core/api_service/api_service.dart';
import '../../../../core/models/artist_art_model.dart';
import '../../../../core/utils/app_font_weight.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/custom_text_2.dart';

class AllArtForStoryScreen extends StatefulWidget {
  const AllArtForStoryScreen({super.key});

  @override
  State<AllArtForStoryScreen> createState() => _AllArtForStoryScreenState();
}

class _AllArtForStoryScreenState extends State<AllArtForStoryScreen> {
  late Future<List<ArtistArtModel>> futureArtData;
  ApiService apiService = ApiService();
  String selectedFilter = 'All';
  bool isLoading = true;

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
    setState(() {
      futureArtData = apiService.fetchMyArtDataForStory(
        customerUniqueId.toString(),
      );
      isLoading = false;
    });
  }

  Future<Map<String, int>> _getStatusesWithCount() async {
    List<ArtistArtModel> artData = await futureArtData;
    // Create a map to store the count of each status
    Map<String, int> statusCounts = {};

    // Count the occurrences of each status
    for (var art in artData) {
      statusCounts[art.status] = (statusCounts[art.status] ?? 0) + 1;
    }

    return statusCounts;
  }

  Future<Set<String>> _getUniqueStatuses() async {
    List<ArtistArtModel> artData = await futureArtData;
    return artData.map((art) => art.status).toSet();
  }

  List<ArtistArtModel> filterArtData(List<ArtistArtModel> artData) {
    if (selectedFilter == 'All') return artData;
    return artData.where((art) => art.status == selectedFilter).toList();
  }

  bool isLoading2 = false;

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return Scaffold(
      backgroundColor: white,
      body: isLoading
          ? const Center(
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
                      SizedBox(width: Responsive.getWidth(100)),
                      WantText2(
                          text: "My Art",
                          fontSize: Responsive.getFontSize(18),
                          fontWeight: AppFontWeight.medium,
                          textColor: textBlack)
                    ],
                  ),
                ),
                SizedBox(
                  height: Responsive.getHeight(10),
                ),
                FutureBuilder<List<ArtistArtModel>>(
                  future: futureArtData,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
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
                      print("object0 ${snapshot.error}");
                      return SizedBox(
                        width: Responsive.getMainWidth(context),
                        height: Responsive.getHeight(600),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              "assets/box_grey.png",
                              width: Responsive.getWidth(64),
                              height: Responsive.getWidth(64),
                            ),
                            SizedBox(
                              height: Responsive.getHeight(24),
                            ),
                            WantText2(
                                text: "No Art!",
                                fontSize: Responsive.getFontSize(20),
                                fontWeight: AppFontWeight.semiBold,
                                textColor: textBlack11),
                            SizedBox(
                              height: Responsive.getHeight(12),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: Responsive.getWidth(50)),
                              child: Text(
                                textAlign: TextAlign.center,
                                "You don’t have any art at this time.",
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
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      print("object1");
                      return SizedBox(
                        width: Responsive.getMainWidth(context),
                        height: Responsive.getHeight(600),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              "assets/box_grey.png",
                              width: Responsive.getWidth(64),
                              height: Responsive.getWidth(64),
                            ),
                            SizedBox(
                              height: Responsive.getHeight(24),
                            ),
                            WantText2(
                                text: "No Art!",
                                fontSize: Responsive.getFontSize(20),
                                fontWeight: AppFontWeight.semiBold,
                                textColor: textBlack11),
                            SizedBox(
                              height: Responsive.getHeight(12),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: Responsive.getWidth(50)),
                              child: Text(
                                textAlign: TextAlign.center,
                                "You don’t have any art at this time.",
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
                      );
                    }

                    List<ArtistArtModel> artData =
                        filterArtData(snapshot.data!);

                    return artData.length == 0
                        ? Container(
                      width: Responsive.getMainWidth(context),
                      height: Responsive.getHeight(600),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  "assets/box_grey.png",
                                  width: Responsive.getWidth(64),
                                  height: Responsive.getWidth(64),
                                ),
                                SizedBox(
                                  height: Responsive.getHeight(24),
                                ),
                                WantText2(
                                    text: "No Art!",
                                    fontSize: Responsive.getFontSize(20),
                                    fontWeight: AppFontWeight.semiBold,
                                    textColor: textBlack11),
                                SizedBox(
                                  height: Responsive.getHeight(12),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: Responsive.getWidth(50)),
                                  child: Text(
                                    textAlign: TextAlign.center,
                                    "You don’t have any art at this time.",
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
                        : SizedBox(
                            height: Responsive.getHeight(730),
                            child: ListView.builder(
                              shrinkWrap: true,
                              // physics: NeverScrollableScrollPhysics(),
                              itemCount: artData.length,
                              itemBuilder: (context, index) {
                                ArtistArtModel art = artData[index];
                                return Column(
                                  children: [
                                    Container(
                                      margin: EdgeInsets.symmetric(
                                        // vertical: Responsive.getHeight(13),
                                        horizontal: Responsive.getWidth(20),
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        vertical: Responsive.getHeight(10),
                                      ),
                                      decoration: BoxDecoration(
                                        color: white,
                                        borderRadius: BorderRadius.circular(
                                            Responsive.getWidth(8)),
                                      ),
                                      child: Row(
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              art.artImages.length == 0
                                                  ? ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              Responsive
                                                                  .getWidth(4)),
                                                      child: Image.asset(
                                                        "assets/donate.png",
                                                        width:
                                                            Responsive.getWidth(
                                                                84),
                                                        height:
                                                            Responsive.getWidth(
                                                                84),
                                                        fit: BoxFit.contain,
                                                      ),
                                                    )
                                                  : ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              Responsive
                                                                  .getWidth(4)),
                                                      child: Image.network(
                                                        art.artImages[1].image,
                                                        width:
                                                            Responsive.getWidth(
                                                                84),
                                                        height:
                                                            Responsive.getWidth(
                                                                84),
                                                        fit: BoxFit.contain,
                                                      ),
                                                    )
                                            ],
                                          ),
                                          SizedBox(
                                              width: Responsive.getWidth(16)),
                                          Container(
                                            // color: Colors.red,
                                            width: Responsive.getWidth(230),
                                            height: Responsive.getHeight(84),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Container(
                                                      width:
                                                          Responsive.getWidth(
                                                              110),
                                                      child: WantText2(
                                                        text: art.title,
                                                        fontSize: Responsive
                                                            .getFontSize(16),
                                                        fontWeight:
                                                            AppFontWeight
                                                                .medium,
                                                        textColor: textBlack,
                                                      ),
                                                    ),
                                                    art.istroy == false
                                                        ? GestureDetector(
                                                            child: Container(
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                horizontal:
                                                                    Responsive
                                                                        .getWidth(
                                                                            8),
                                                                vertical:
                                                                    Responsive
                                                                        .getHeight(
                                                                            4),
                                                              ),
                                                              decoration:
                                                                  BoxDecoration(
                                                                border: Border.all(
                                                                    width: 1,
                                                                    color:
                                                                        black),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            4),
                                                              ),
                                                              child: Text(
                                                                "Add Story",
                                                                style:
                                                                    GoogleFonts
                                                                        .poppins(
                                                                  letterSpacing:
                                                                      1.5,
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: Responsive
                                                                      .getFontSize(
                                                                          12),
                                                                  fontWeight:
                                                                      AppFontWeight
                                                                          .medium,
                                                                ),
                                                              ),
                                                            ),
                                                            onTap: () {
                                                              Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                      builder: (_) =>
                                                                          StoryArtistAddStoryScreen(
                                                                            artUniqueID:
                                                                                art.artUniqueId,
                                                                          )));
                                                            },
                                                          )
                                                        : SizedBox()
                                                    // _buildStatusTag(art.status,
                                                    //     art.colorCode),
                                                  ],
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                ),
                                                Spacer(),
                                                Text(
                                                  art.paragraph,
                                                  textAlign: TextAlign.start,
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: GoogleFonts.poppins(
                                                    letterSpacing: 1.5,
                                                    color: textBlack8,
                                                    fontSize:
                                                        Responsive.getFontSize(
                                                            10),
                                                    fontWeight:
                                                        AppFontWeight.regular,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    Divider(
                                      color: Color.fromRGBO(243, 243, 243, 1),
                                    )
                                  ],
                                );
                              },
                            ),
                          );
                  },
                ),
              ],
            ),
    );
  }

  Widget _buildFilterOption(String displayText, String status) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = status;
        });
        Navigator.pop(context);
      },
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
                vertical: Responsive.getHeight(14),
                horizontal: Responsive.getHeight(24)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  status,
                  style: GoogleFonts.poppins(
                    letterSpacing: 1.5,
                    fontSize: Responsive.getFontSize(14),
                    fontWeight: AppFontWeight.semiBold,
                    color: selectedFilter == status ? textBlack : textGray18,
                  ),
                ),
                selectedFilter == status
                    ? Image.asset(
                        "assets/radio_1.png",
                        width: Responsive.getWidth(25),
                        height: Responsive.getWidth(25),
                      )
                    : Image.asset(
                        "assets/radio_2.png",
                        width: Responsive.getWidth(25),
                        height: Responsive.getWidth(25),
                      ),
                // selectedFilter == filter
                //     ? Image.asset(
                //   "assets/Vector 25.png",
                //   width: Responsive.getWidth(12),
                //   height: Responsive.getHeight(6),
                // )
                //     : const SizedBox()
              ],
            ),
          ),
          Divider(
            color: Color.fromRGBO(210, 210, 210, 1.0),
          ),
        ],
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
}
