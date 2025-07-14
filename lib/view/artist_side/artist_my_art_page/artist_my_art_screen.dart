import 'package:artist/view/artist_side/artist_my_art_page/single_art_screen/artist_boost_screen.dart';
import 'package:artist/view/artist_side/artist_my_art_page/single_art_screen/artist_review_art_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../config/colors.dart';
import '../../../config/toast.dart';
import '../../../core/api_service/api_service.dart';
import '../../../core/models/artist_art_model.dart';
import '../../../core/utils/app_font_weight.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/custom_text_2.dart';

class ArtistMyArtScreen extends StatefulWidget {
  const ArtistMyArtScreen({super.key});

  @override
  State<ArtistMyArtScreen> createState() => _ArtistMyArtScreenState();
}

class _ArtistMyArtScreenState extends State<ArtistMyArtScreen> {
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
      futureArtData =
          apiService.fetchMyArtData(customerUniqueId.toString(), "seller");
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
  Future<bool?> showDeleteDialog(BuildContext context, String artUniqueId) {
    return showDialog(
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
                      "assets/dialog_delete.png",
                      height: Responsive.getWidth(78),
                      width: Responsive.getWidth(78),
                    ),
                    SizedBox(height: Responsive.getHeight(12)),
                    WantText2(
                        text: "Delete Art",
                        fontSize: Responsive.getFontSize(20),
                        fontWeight: AppFontWeight.semiBold,
                        textColor: textBlack),
                    SizedBox(height: Responsive.getHeight(8)),
                    Text(
                      textAlign: TextAlign.center,
                      "Are you sure you want to delete this Art?\nThis action cannot be undone.",
                      style: GoogleFonts.poppins(
                        color: Color.fromRGBO(128, 128, 128, 1),
                        fontSize: Responsive.getFontSize(14),
                        fontWeight: AppFontWeight.regular,
                      ),
                    ),
                    SizedBox(height: Responsive.getHeight(24)),
                    Center(
                        child: GestureDetector(
                      onTap: () async {
                        setState(() {
                          isLoading2 = true;
                        });
                        ApiService apiService = ApiService();
                        final response =
                        await apiService.cancelArtwork(artUniqueId);
                        // final response =
                        //     await ApiService.cancelArtwork(artUniqueId);

                        if (response != null && response['status'] == true) {
                          setState(() {
                            isLoading2 = false;
                          });
                          showToast(message: response['message']);
                          _loadUserData();
                          Navigator.pop(context);
                          print("Artwork cancelled successfully.");
                        } else {
                          setState(() {
                            isLoading2 = false;
                          });
                          showToast(
                              message: response?['message'] ??
                                  'Failed to cancel artwork.');
                          print("Failed to cancel artwork.");
                        }
                      },
                      child: Container(
                        height: Responsive.getHeight(44),
                        width: Responsive.getWidth(311),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Color.fromRGBO(217, 45, 32, 1.0),
                            ),
                            color: Color.fromRGBO(217, 45, 32, 1.0),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                isLoading2
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
                                        "Delete",
                                        style: GoogleFonts.urbanist(
                                          textStyle: TextStyle(
                                            fontSize:
                                                Responsive.getFontSize(18),
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
        title: Text(
          "My Art",
          textAlign: TextAlign.start,
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
                  onTap: _showFilterBottomSheet,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          width: Responsive.getWidth(32),
                          height: Responsive.getWidth(32),
                          decoration: BoxDecoration(
                            color: const Color.fromRGBO(249, 250, 251, 1),
                            boxShadow: [
                              BoxShadow(
                                color: const Color.fromRGBO(0, 0, 0, 0.05),
                                spreadRadius: 0,
                                offset: const Offset(0, 1),
                                blurRadius: 2,
                              ),
                            ],
                            borderRadius:
                                BorderRadius.circular(Responsive.getWidth(8)),
                            border: Border.all(
                              width: 1,
                              color: const Color.fromRGBO(0, 0, 0, 0.05),
                            ),
                          ),
                          child: Image.asset(
                            "assets/filter.png",
                            width: Responsive.getWidth(24),
                            height: Responsive.getHeight(24),
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
          : FutureBuilder<List<ArtistArtModel>>(
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
                  return Container(
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

                List<ArtistArtModel> artData = filterArtData(snapshot.data!);

                return artData.length == 0
                    ? SizedBox(
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
                    : ListView.builder(
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
                                  // horizontal: Responsive.getWidth(16),
                                ),
                                // width: Responsive.getWidth(332),
                                decoration: BoxDecoration(
                                  color: white,
                                  borderRadius: BorderRadius.circular(
                                      Responsive.getWidth(8)),
                                  // boxShadow: [
                                  //   BoxShadow(
                                  //     color: const Color.fromRGBO(0, 0, 0, 0.1),
                                  //     blurRadius: 4,
                                  //     offset: const Offset(0, 4),
                                  //     spreadRadius: 0,
                                  //   )
                                  // ],
                                ),
                                child: Row(
                                  children: [
                                    Column(
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
                                          child: art.artImages.length == 0
                                              ? ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          Responsive.getWidth(
                                                              4)),
                                                  child: Image.asset(
                                                    "assets/donate.png",
                                                    width:
                                                        Responsive.getWidth(84),
                                                    height:
                                                        Responsive.getWidth(84),
                                                    fit: BoxFit.cover,
                                                  ),
                                                )
                                              : ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          Responsive.getWidth(
                                                              4)),
                                                  child: Image.network(
                                                    art.artImages[1].image,
                                                    width:
                                                        Responsive.getWidth(84),
                                                    height:
                                                        Responsive.getWidth(84),
                                                    fit: BoxFit.contain,
                                                  ),
                                                ),
                                        )
                                      ],
                                    ),
                                    SizedBox(width: Responsive.getWidth(16)),
                                    Container(
                                      // color: Colors.red,
                                      width: Responsive.getWidth(230),
                                      height: Responsive.getHeight(100),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (_) =>
                                                              ArtistSingleArtScreen(
                                                                artUniqueID: art
                                                                    .artUniqueId,
                                                              )));
                                                },
                                                child: Container(
                                                  width:
                                                      Responsive.getWidth(140),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      WantText2(
                                                        text: art.title,
                                                        fontSize:
                                                            Responsive.getFontSize(
                                                                16),
                                                        fontWeight:
                                                            AppFontWeight.medium,
                                                        textColor: textBlack,
                                                      ),
                                                      WantText2(
                                                        text: art.art_submission_type,
                                                        fontSize:
                                                        Responsive.getFontSize(
                                                            10),
                                                        fontWeight:
                                                        AppFontWeight.medium,
                                                        textColor: textBlack,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              _buildStatusTag(
                                                  art.status, art.colorCode),
                                            ],
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
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
                                            },
                                            child: Text(
                                              art.paragraph,
                                              textAlign: TextAlign.start,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.poppins(
                                                letterSpacing: 1.5,
                                                color: textBlack8,
                                                fontSize:
                                                    Responsive.getFontSize(10),
                                                fontWeight:
                                                    AppFontWeight.regular,
                                              ),
                                            ),
                                          ),
                                          art.status == "Approved"
                                              ? art.is_boost == false
                                                  ? Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        SizedBox(),
                                                        GestureDetector(
                                                          onTap: () {
                                                            Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder: (_) =>
                                                                        ArtistBoostScreen(
                                                                            art_unique_id:
                                                                                art.artUniqueId)));
                                                          },
                                                          child: Image.asset(
                                                            "assets/boost.png",
                                                            width: Responsive
                                                                .getWidth(80),
                                                            height: Responsive
                                                                .getWidth(16),
                                                          ),
                                                        )
                                                      ],
                                                    )
                                                  : SizedBox()
                                              : SizedBox(),
                                          art.status == "Declined"
                                              ? Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    SizedBox(),
                                                    GestureDetector(
                                                      child: Image.asset(
                                                        "assets/delete.png",
                                                        width:
                                                            Responsive.getWidth(
                                                                18),
                                                        height:
                                                            Responsive.getWidth(
                                                                18),
                                                      ),
                                                      onTap: () async {
                                                        showDeleteDialog(
                                                            context,
                                                            art.artUniqueId
                                                                .toString());
                                                      },
                                                    ),
                                                  ],
                                                )
                                              : SizedBox()
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
                      );
              },
            ),
    );
  }

  void _showFilterDialog() async {
    Map<String, int> statusCounts = await _getStatusesWithCount();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: whiteBack,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          insetPadding:
              EdgeInsets.symmetric(horizontal: Responsive.getWidth(14)),
          child: Container(
            margin: EdgeInsets.all(0),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    WantText2(
                      text: "Filter",
                      fontSize: Responsive.getFontSize(16),
                      fontWeight: AppFontWeight.bold,
                      textColor: const Color.fromRGBO(37, 43, 66, 1),
                    ),
                    SizedBox(height: Responsive.getHeight(13)),
                    Column(
                      children: ['All', ...statusCounts.keys].map((status) {
                        // Show the count for statuses
                        String displayText = status;
                        if (statusCounts.containsKey(status)) {
                          displayText = '$status (${statusCounts[status]})';
                        }
                        return _buildFilterOption(displayText, status);
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showFilterBottomSheet() async {
    Map<String, int> statusCounts = await _getStatusesWithCount();

    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(Responsive.getWidth(15)),
              topRight: Radius.circular(Responsive.getWidth(15)))),
      builder: (BuildContext context) {
        return Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: Responsive.getHeight(5),
              ),
              ...['All', ...statusCounts.keys].map((status) {
                // Show the count for statuses
                String displayText = status;
                if (statusCounts.containsKey(status)) {
                  displayText = '$status (${statusCounts[status]})';
                }
                return _buildFilterOption(displayText, status);
              }).toList(),
            ],
          ),
        );
      },
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
      width: Responsive.getWidth(90),
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.getWidth(8),
        vertical: Responsive.getHeight(4),
      ),
      decoration: BoxDecoration(
        color: Color(0xFF000000 | int.parse(formattedColor, radix: 16)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Text(
          status,
          style: GoogleFonts.poppins(
            letterSpacing: 1.5,
            color: Colors.white,
            fontSize: Responsive.getFontSize(12),
            fontWeight: AppFontWeight.medium,
          ),
        ),
      ),
    );
  }
}
