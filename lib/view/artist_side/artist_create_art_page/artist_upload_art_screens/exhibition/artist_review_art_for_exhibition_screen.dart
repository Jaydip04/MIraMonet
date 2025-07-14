import 'dart:async';
import 'package:artist/core/models/upload_art_model/art_review_model.dart';
import 'package:artist/view/artist_side/artist_create_art_page/artist_upload_art_screens/artist_add_story_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../config/colors.dart';
import '../../../../../config/toast.dart';
import '../../../../../core/api_service/api_service.dart';
import '../../../../../core/utils/app_font_weight.dart';
import '../../../../../core/utils/responsive.dart';
import '../../../../../core/widgets/custom_text_2.dart';
import '../../../../../core/widgets/general_button.dart';
import 'artist_exhibition_upload_screen.dart';

class ArtistReviewArtForExhibitionScreen extends StatefulWidget {
  final exhibitionUniqueId;
  final categoryName;
  final categoryId;
  final exhibition_type;
  const ArtistReviewArtForExhibitionScreen(
      {super.key,
      required this.exhibitionUniqueId,
      required this.categoryName,
      required this.exhibition_type,
      required this.categoryId});

  @override
  _ArtistReviewArtForExhibitionScreenState createState() =>
      _ArtistReviewArtForExhibitionScreenState();
}

class _ArtistReviewArtForExhibitionScreenState
    extends State<ArtistReviewArtForExhibitionScreen> {
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

  Future<String?> getArtUniqueId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('artUniqueId');
  }

  late Future<ArtReviewModel> _artDetails;
  bool isClick = true;
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    print(widget.exhibitionUniqueId);
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
    _loadUserData();
    getArtUniqueId().then((artUniqueId) {
      if (artUniqueId != null) {
        setState(() {
          artUniqueID = artUniqueId;
          _artDetails = ApiService().fetchArtDetailsExhibition(artUniqueId);
          isClick = false;
        });
        print("Retrieved Art Unique ID: $artUniqueId");
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

  Future<void> removeArtUniqueId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('artUniqueId');
  }



  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return Scaffold(
      backgroundColor: white,
      body: WillPopScope(
        onWillPop: () async {
          // final shouldPop = await showDeleteDialog(context, artUniqueID);
          bool shouldPop = await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return Dialog(
                backgroundColor: whiteBack,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                insetPadding:
                EdgeInsets.symmetric(horizontal: Responsive.getWidth(14)),
                child: Container(
                  margin: EdgeInsets.all(0),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: Responsive.getWidth(11),
                        vertical: Responsive.getHeight(24),
                      ),
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
                            textColor: textBlack,
                          ),
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
                                  isLoading = true;
                                });
                                ApiService apiService = ApiService();
                                final response =
                                await apiService.cancelArtwork(artUniqueID);
                                // final response =
                                // await ApiService.cancelArtwork(artUniqueID);

                                if (response != null &&
                                    response['status'] == true) {
                                  setState(() {
                                    isLoading = false;
                                  });
                                  removeArtUniqueId();
                                  showToast(message: response['message']);
                                  Navigator.pushNamedAndRemoveUntil(
                                    context,
                                    '/Artist',
                                        (Route<dynamic> route) => false,
                                  );
                                } else {
                                  setState(() {
                                    isLoading = false;
                                  });
                                  showToast(
                                    message: response?['message'] ??
                                        'Failed to cancel artwork.',
                                  );
                                }
                              },
                              child: Container(
                                height: Responsive.getHeight(44),
                                width: Responsive.getWidth(311),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Color.fromRGBO(217, 45, 32, 1.0),
                                  ),
                                  color: Color.fromRGBO(217, 45, 32, 1.0),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: isLoading
                                      ? CircularProgressIndicator(
                                    strokeWidth: 3,
                                    color: Colors.white,
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
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: Responsive.getHeight(12)),
                          Center(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pop(context,
                                    false); // Return `false` to cancel navigation
                              },
                              child: Container(
                                height: Responsive.getHeight(44),
                                width: Responsive.getWidth(311),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Color.fromRGBO(208, 213, 221, 1.0),
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text(
                                    "Cancel",
                                    style: GoogleFonts.urbanist(
                                      textStyle: TextStyle(
                                        fontSize: Responsive.getFontSize(18),
                                        color: Color.fromRGBO(52, 64, 84, 1.0),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );

          return shouldPop ?? false;
        },
        child: SafeArea(
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
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (snapshot.hasData) {
                        ArtReviewModel artDetails = snapshot.data!;
                        return ListView(
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: Responsive.getWidth(16)),
                              child: Row(
                                children: [
                                  GestureDetector(
                                    onTap: () => showDeleteDialog(context, artUniqueID.toString()),
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
                                    width: Responsive.getWidth(85),
                                  ),
                                  WantText2(
                                      text: "Upload Art",
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
                              width: double.infinity,
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
                                  // Painting Name
                                  Text(
                                    textAlign: TextAlign.start,
                                    artDetails.title ?? "",
                                    style: GoogleFonts.poppins(
                                      color: textBlack5,
                                      fontSize: Responsive.getFontSize(24),
                                      fontWeight: AppFontWeight.semiBold,
                                    ),
                                  ),
                                  SizedBox(height: Responsive.getHeight(6)),
                                  Text(
                                    textAlign: TextAlign.start,
                                    artDetails.artistName ?? "",
                                    style: GoogleFonts.poppins(
                                      color: textBlack5,
                                      fontSize: Responsive.getFontSize(14),
                                      fontWeight: AppFontWeight.medium,
                                    ),
                                  ),
                                  // SizedBox(height: Responsive.getHeight(4)),
                                  // ListView.builder(
                                  //     itemCount: artDetails.details.length,
                                  //     shrinkWrap: true,
                                  //     itemBuilder: (context, index) {
                                  //       return Row(
                                  //         mainAxisAlignment:
                                  //             MainAxisAlignment.start,
                                  //         crossAxisAlignment:
                                  //             CrossAxisAlignment.start,
                                  //         children: [
                                  //           Container(
                                  //             width: Responsive.getWidth(35),
                                  //             child: Text(
                                  //               textAlign: TextAlign.start,
                                  //               "${artDetails.details[index].artDataTitle} : ",
                                  //               style: GoogleFonts.poppins(
                                  //                 color: textGray5,
                                  //                 fontSize:
                                  //                     Responsive.getFontSize(14),
                                  //                 fontWeight:
                                  //                     AppFontWeight.semiBold,
                                  //               ),
                                  //             ),
                                  //           ),
                                  //           Container(
                                  //             child: Text(
                                  //               textAlign: TextAlign.start,
                                  //               artDetails
                                  //                   .details[index].description,
                                  //               style: GoogleFonts.poppins(
                                  //                 color: textGray5,
                                  //                 fontSize:
                                  //                     Responsive.getFontSize(12),
                                  //                 fontWeight:
                                  //                     AppFontWeight.semiBold,
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
                                      color: textGray5,
                                      fontSize: Responsive.getFontSize(14),
                                      fontWeight: AppFontWeight.semiBold,
                                    ),
                                  ),
                                  SizedBox(
                                    height: Responsive.getHeight(42),
                                  ),
                                  Row(
                                    children: [
                                      GeneralButton(
                                        Width: Responsive.getWidth(160),
                                        onTap: () => showDeleteDialog(context,
                                            artDetails.artUniqueId.toString()),
                                        label: "Cancel",
                                        isBoarderRadiusLess: true,
                                        isSelected: false,
                                        buttonClick: true,
                                      ),
                                      SizedBox(
                                        width: Responsive.getWidth(20),
                                      ),
                                      GeneralButton(
                                        Width: Responsive.getWidth(160),
                                        onTap: () {
                                          showCongratulationsDialog(
                                              context,
                                              artDetails.isAdd!,
                                              artDetails.isSubmit!,
                                              artDetails.artCount!,
                                              widget.exhibitionUniqueId,
                                              customerUniqueID.toString());
                                        },
                                        label: "Submit",
                                        isBoarderRadiusLess: true,
                                      )
                                    ],
                                  ),
                                  SizedBox(
                                    height: Responsive.getHeight(20),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      } else {
                        return Center(child: Text('No data available'));
                      }
                    },
                  )),
      ),
    );
  }

  void showDeleteDialog(BuildContext context, String artUniqueId) {
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
                          isLoading = true;
                        });
                        ApiService apiService = ApiService();
                        final response =
                        await apiService.cancelArtwork(artUniqueId);
                        // final response =
                        //     await ApiService.cancelArtwork(artUniqueId);

                        if (response != null && response['status'] == true) {
                          setState(() {
                            isLoading = false;
                          });
                          removeArtUniqueId();
                          showToast(message: response['message']);
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/Artist',
                            (Route<dynamic> route) => false,
                          );
                          print("Artwork cancelled successfully.");
                        } else {
                          setState(() {
                            isLoading = false;
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

  void showCongratulationsDialog(
      BuildContext context,
      bool isAdd,
      bool isSubmit,
      String artCount,
      String exhibitionUniqueId,
      String customerUniqueID) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Congratulations(
          categoryName: widget.categoryName,
          categoryId: widget.categoryId,
          artCount: artCount,
          exhibition_type: widget.exhibition_type,
          isSubmit: isSubmit,
          isAdd: isAdd,
          exhibitionUniqueId: exhibitionUniqueId,
          customerUniqueID: customerUniqueID,
        );
      },
    );
  }
}

class Congratulations extends StatefulWidget {
  final isAdd;
  final exhibition_type;
  final isSubmit;
  final artCount;
  final exhibitionUniqueId;
  final customerUniqueID;
  final categoryName;
  final categoryId;
  const Congratulations({
    super.key,
    required this.exhibition_type,
    required this.isAdd,
    required this.isSubmit,
    required this.artCount,
    required this.categoryName,
    required this.categoryId,
    required this.exhibitionUniqueId,
    required this.customerUniqueID,
  });

  @override
  _CongratulationsState createState() => _CongratulationsState();
}

class _CongratulationsState extends State<Congratulations> {
  final TextEditingController _pinController = TextEditingController();

  Future<void> removeArtUniqueId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('artUniqueId');
  }

  @override
  void initState() {
    super.initState();
  }
  // String? message;

  void submitExhibitionData() async {
    ApiService apiService = ApiService();

    final response = await apiService.submitExhibition(
      customerUniqueId: widget.customerUniqueID,
      exhibitionUniqueId: widget.exhibitionUniqueId,
    );

    print(response);
    if (response['status'] == "true") {
      removeArtUniqueId().then((onValue) {
        showCongratulationsDialog(response['message']);
        // Navigator.pushNamedAndRemoveUntil(
        //   context,
        //   '/Artist',
        //   (Route<dynamic> route) => false,
        // );
      });
      // setState(() {
      //   message = response['message'];
      // });

      // showToast(message: response['message']);
      print('Success: ${response['message']}');
    } else {
      print('Failed: ${response['message']}');
    }
  }

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
                // Image.asset(
                //   "assets/check.png",
                //   height: Responsive.getWidth(78),
                //   width: Responsive.getWidth(78),
                // ),
                // SizedBox(height: Responsive.getHeight(12)),
                WantText2(
                    text: "${widget.artCount}/5",
                    fontSize: Responsive.getFontSize(20),
                    fontWeight: AppFontWeight.semiBold,
                    textColor: textBlack),
                SizedBox(height: Responsive.getHeight(8)),
                WantText2(
                    text: "Your Art has been added.",
                    fontSize: Responsive.getFontSize(16),
                    fontWeight: AppFontWeight.regular,
                    textColor: Color.fromRGBO(128, 128, 128, 1)),
                SizedBox(height: Responsive.getHeight(24)),
                widget.isAdd == true
                    ? Center(
                        child: GeneralButton(
                          Width: Responsive.getWidth(293),
                          onTap: () {
                            removeArtUniqueId().then((onValue) {
                              print("${widget.exhibitionUniqueId}");
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          ArtistExhibitionUploadScreen(
                                            exhibition_type: widget.exhibition_type,
                                            categoryId: widget.categoryId,
                                            categoryName: widget.categoryName,
                                            exhibitionUniqueId:
                                                widget.exhibitionUniqueId,
                                          )));
                            });
                          },
                          label: "Add More",
                          isBoarderRadiusLess: true,
                          buttonClick: true,
                          isSelected: false,
                        ),
                      )
                    : SizedBox(),
                SizedBox(height: Responsive.getHeight(8)),
                widget.isSubmit == true
                    ? Center(
                        child: GeneralButton(
                          Width: Responsive.getWidth(293),
                          onTap: () {
                            // showCongratulationsDialog(
                            //     'We will revert within 72 hours. We will revert within 72 hours.');
                            submitExhibitionData();
                          },
                          label: "Submit",
                          isBoarderRadiusLess: true,
                        ),
                      )
                    : SizedBox(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void showCongratulationsDialog(String message) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return Congratulations2(
          message: message,
        );
      },
    );
  }
}

class Congratulations2 extends StatefulWidget {
  final message;
  const Congratulations2({super.key, required this.message});

  @override
  _CongratulationsState2 createState() => _CongratulationsState2();
}

class _CongratulationsState2 extends State<Congratulations2> {
  final TextEditingController _pinController = TextEditingController();

  // Future<void> removeArtUniqueId() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   await prefs.remove('artUniqueId');
  // }

  @override
  void initState() {
    super.initState();
    print(widget.message);
  }

  // void submitExhibitionData() async {
  //   ApiService apiService = ApiService();
  //
  //   final response = await apiService.submitExhibition(
  //     customerUniqueId: widget.customerUniqueID,
  //     exhibitionUniqueId: widget.exhibitionUniqueId,
  //   );
  //
  //   print(response);
  //   if (response['status'] == "true") {
  //     removeArtUniqueId().then((onValue) {
  //       Navigator.pushNamedAndRemoveUntil(
  //         context,
  //         '/Artist',
  //         (Route<dynamic> route) => false,
  //       );
  //     });
  //     showToast(message: response['message']);
  //     print('Success: ${response['message']}');
  //   } else {
  //     print('Failed: ${response['message']}');
  //   }
  // }

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
                Image.asset(
                  "assets/check.png",
                  height: Responsive.getWidth(78),
                  width: Responsive.getWidth(78),
                ),
                SizedBox(height: Responsive.getHeight(12)),
                WantText2(
                    text: " Request sent",
                    fontSize: Responsive.getFontSize(20),
                    fontWeight: AppFontWeight.semiBold,
                    textColor: textBlack),
                SizedBox(height: Responsive.getHeight(8)),
                Text(
                  textAlign: TextAlign.center,
                  widget.message,
                  style: GoogleFonts.poppins(
                      color: Color.fromRGBO(128, 128, 128, 1),
                      fontSize: Responsive.getFontSize(16),
                      fontWeight: AppFontWeight.regular,
                      letterSpacing: 1.5),
                ),
                // WantText2(
                //     text: widget.message,
                //     fontSize: Responsive.getFontSize(16),
                //     fontWeight: AppFontWeight.regular,
                //     textColor: Color.fromRGBO(128, 128, 128, 1)),
                SizedBox(height: Responsive.getHeight(24)),
                // widget.isAdd == true
                //     ? Center(
                //         child: GeneralButton(
                //           Width: Responsive.getWidth(293),
                //           onTap: () {
                //             removeArtUniqueId().then((onValue) {
                //               print("${widget.exhibitionUniqueId}");
                //               Navigator.push(
                //                   context,
                //                   MaterialPageRoute(
                //                       builder: (_) =>
                //                           ArtistExhibitionUploadScreen(
                //                             categoryId: widget.categoryId,
                //                             categoryName: widget.categoryName,
                //                             exhibitionUniqueId:
                //                                 widget.exhibitionUniqueId,
                //                           )));
                //             });
                //           },
                //           label: "Add More ?",
                //           isBoarderRadiusLess: true,
                //           buttonClick: true,
                //           isSelected: false,
                //         ),
                //       )
                //     : SizedBox(),
                SizedBox(height: Responsive.getHeight(8)),
                Center(
                  child: GeneralButton(
                    Width: Responsive.getWidth(293),
                    onTap: () {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/Artist',
                        (Route<dynamic> route) => false,
                      );
                      // submitExhibitionData();
                    },
                    label: "Home",
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
