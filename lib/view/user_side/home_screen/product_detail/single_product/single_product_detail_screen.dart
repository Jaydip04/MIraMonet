import 'package:artist/core/api_service/api_service.dart';
import 'package:artist/core/utils/responsive.dart';
import 'package:artist/core/widgets/custom_text_3.dart';
import 'package:artist/core/widgets/general_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../config/colors.dart';
import '../../../../../config/toast.dart';
import '../../../../../core/models/user_side/single_art_model.dart';
import '../../../../../core/utils/app_font_weight.dart';
import '../../../../../core/widgets/app_text_form_field.dart';
import '../../../../../core/widgets/custom_text_2.dart';
import '../../artist_profile/single_artist_profile_screen/single_artist_profile_screen.dart';

class ArtItemArguments {
  final String artUniqueId;

  ArtItemArguments(this.artUniqueId);
}

class SingleProductDetailScreen extends StatefulWidget {
  final artUniqueId;
  final art_status;
  const SingleProductDetailScreen(
      {super.key, required this.artUniqueId, this.art_status});

  @override
  State<SingleProductDetailScreen> createState() =>
      _SingleProductDetailScreenState();
}

class _SingleProductDetailScreenState extends State<SingleProductDetailScreen> {
  int selectedIndex = 0;
  final List<String> imageUrls = [
    'assets/back.png',
    'assets/artists_stories_back.png',
    'assets/banner.png',
    'assets/back.png',
  ];

  late SingleArtModel artDetails;
  bool isLoading = true;

  // Method to fetch art details
  Future<void> fetchArtDetails() async {
    try {
      var response = await ApiService().fetchSingleArtDetails(
        widget.artUniqueId,
      );

      print("response : $response");
      if (response != null) {
        setState(() {
          artDetails = response;
          isLoading = false;
          print("isWishlist : ${artDetails.art.isWishlist}");
        });
      }
    } catch (error) {
      // Handle error if any
      print('Error fetching art details: $error');
    }
  }

  @override
  void initState() {
    super.initState();
    _checkLoginStatus().then((onValue) {
      if (isLoggedIn) {
        print("object");
        _loadUserData();
      } else {
        print("object0");
        fetchArtDetails();
      }
    });
    // _loadUserData();
  }

  bool isLoggedIn = false;
  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isLoggedIn = prefs.getString('UserToken') != null;
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
      fetchArtDetails();
    });
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
          : Padding(
        padding:
        EdgeInsets.symmetric(horizontal: Responsive.getWidth(16)),
        child: ListView(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                WantText2(
                    text: "Product Detail",
                    fontSize: Responsive.getFontSize(18),
                    fontWeight: AppFontWeight.medium,
                    textColor: textBlack),
                widget.art_status == "Sold"
                    ? SizedBox(
                  width: Responsive.getWidth(24),
                )
                    : AnimationConfiguration.synchronized(
                  duration: const Duration(milliseconds: 2000),
                  child: SlideAnimation(
                    curve: Curves.easeInOut,
                    child: FadeInAnimation(
                      duration: const Duration(milliseconds: 1000),
                      child: GestureDetector(
                        onTap: () async {
                          if (isLoggedIn) {
                            print(
                                "customer_unique_id : ${customerUniqueID}");
                            print(
                                "art_unique_id : ${widget.artUniqueId}");
                            await ApiService()
                                .addToWishlist(
                                customerUniqueID.toString(),
                                widget.artUniqueId.toString())
                                .then((onValue) {
                              fetchArtDetails();
                            });
                          } else {
                            showLoginDialogForwishlist(context);
                            // showToast(message: "First Login");
                          }
                          // setState(() {});
                        },
                        child: artDetails.art.isWishlist
                            ? Image.asset(
                          "assets/wishlist_red.png",
                          width: Responsive.getWidth(24),
                          height: Responsive.getHeight(24),
                        )
                            : Image.asset(
                          "assets/wishlist.png",
                          width: Responsive.getWidth(24),
                          height: Responsive.getHeight(24),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: Responsive.getHeight(20),
            ),
            Center(
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.1),
                      spreadRadius: 0,
                      offset: Offset(0, 0),
                      blurRadius: 16,
                    )
                  ],
                  borderRadius:
                  BorderRadius.circular(Responsive.getWidth(10)),
                ),
                width: Responsive.getWidth(328),
                height: Responsive.getHeight(373),
                child: ClipRRect(
                  borderRadius:
                  BorderRadius.circular(Responsive.getWidth(10)),
                  child: Image.network(
                    artDetails.art.artImages[selectedIndex].image
                        .toString(),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: Responsive.getHeight(37),
            ),
            Center(
              child: Container(
                width: Responsive.getWidth(224),
                height: Responsive.getHeight(64),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: artDetails.art.artImages.length,
                  itemBuilder: (context, index) {
                    print(artDetails.art.fcmToken);
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedIndex = index;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: selectedIndex == index
                                  ? containerBorderColor
                                  : Colors.transparent,
                              width: 1),
                        ),
                        margin: EdgeInsets.symmetric(horizontal: 8),
                        padding: EdgeInsets.symmetric(
                            horizontal: 8, vertical: 8),
                        height: 64,
                        width: 64,
                        child: Image.network(
                          artDetails.art.artImages[index].image
                              .toString(),
                          color: selectedIndex == index
                              ? null
                              : Colors.black.withOpacity(0.7),
                          colorBlendMode: BlendMode.color,
                          fit: BoxFit.contain,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                WantText2(
                  text: artDetails.art.title,
                  fontSize: Responsive.getFontSize(24),
                  fontWeight: AppFontWeight.bold,
                  textColor: textBlack5,
                  textOverflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: Responsive.getHeight(6.0)),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SingleArtistProfileScreen(
                          artistUniqueId: artDetails.art.artistId,
                        ),
                      ),
                    );
                  },
                  child: WantText2(
                    text: artDetails.art.artistName,
                    fontSize: Responsive.getFontSize(14),
                    fontWeight: AppFontWeight.medium,
                    textColor: textBlack5,
                    textOverflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(height: Responsive.getHeight(9.0)),
                WantText3(
                    text: "\$${artDetails.art.price}",
                    fontSize: Responsive.getFontSize(20),
                    fontWeight: AppFontWeight.bold,
                    textColor: textBlack5),
                SizedBox(height: Responsive.getHeight(9.0)),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: Responsive.getFontSize(13),
                      color: textGray5,
                    ),
                    SizedBox(
                      width: Responsive.getWidth(2),
                    ),
                    Flexible(
                      child: WantText3(
                        text:
                        "${artDetails.art.pickupAddress} ${artDetails.art.city} ${artDetails.art.state} ${artDetails.art.country} ${artDetails.art.pincode}",
                        fontSize: Responsive.getFontSize(11),
                        fontWeight: AppFontWeight.regular,
                        textColor: textGray5,
                        textOverflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: Responsive.getHeight(9.0)),
                WantText2(
                  text: "Free Return available",
                  fontSize: Responsive.getFontSize(10),
                  fontWeight: AppFontWeight.medium,
                  textColor: textBlack5,
                  textOverflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: Responsive.getHeight(9.0)),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(
                        ClipboardData(text: artDetails.art.artUniqueId));
                    showToast(message: "Art ID copied to clipboard!");
                  },
                  child: WantText2(
                    text: "Art ID: ${artDetails.art.artUniqueId}",
                    fontSize: Responsive.getFontSize(12),
                    fontWeight: AppFontWeight.semiBold,
                    textColor: textBlack5,
                    textOverflow: TextOverflow.ellipsis,
                  ),
                ),
                // SizedBox(height: Responsive.getHeight(10.0)),
                // Row(
                //   children: [
                //     Image.asset(
                //       "assets/box.png",
                //       width: 13,
                //       height: 13,
                //     ),
                //     SizedBox(
                //       width: Responsive.getWidth(2),
                //     ),
                //     WantText3(
                //       text: "Estimated shipping: 3 - 7 days after order.",
                //       fontSize: Responsive.getFontSize(11),
                //       fontWeight: AppFontWeight.regular,
                //       textColor: textGray5,
                //       textOverflow: TextOverflow.ellipsis,
                //     ),
                //   ],
                // ),
                SizedBox(height: Responsive.getHeight(9.0)),
                ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: artDetails.art.artAdditionalDetails.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.only(
                            bottom: Responsive.getWidth(5)),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              "${artDetails.art.artAdditionalDetails[index].artData.artDataTitle} : ",
                              style: GoogleFonts.poppins(
                                letterSpacing: 1.5,
                                color: textGray5,
                                fontSize: Responsive.getFontSize(13),
                                fontWeight: AppFontWeight.semiBold,
                              ),
                            ),
                            SizedBox(
                              width: Responsive.getWidth(5),
                            ),
                            Flexible(
                              child: Text(
                                overflow: TextOverflow.ellipsis,
                                maxLines: 3,
                                artDetails.art.artAdditionalDetails[index]
                                    .description,
                                style: GoogleFonts.poppins(
                                  letterSpacing: 1.5,
                                  color: textGray5,
                                  fontSize: Responsive.getFontSize(10),
                                  fontWeight: AppFontWeight.regular,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                SizedBox(height: Responsive.getHeight(8.0)),
                Text(
                  artDetails.art.paragraph,
                  style: GoogleFonts.poppins(
                    color: textGray5,
                    fontSize: Responsive.getFontSize(13),
                    fontWeight: AppFontWeight.semiBold,
                  ),
                ),
                SizedBox(height: Responsive.getHeight(10.0)),
                Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GeneralButton(
                          Width: Responsive.getWidth(165),
                          onTap: () async {
                            if (isLoggedIn) {
                              if (artDetails.art.status == "Sold") {
                                showToast(message: "The art is already sold");
                              } else {
                                print(
                                    "customer_unique_id : ${customerUniqueID}");
                                print(
                                    "art_unique_id : ${widget.artUniqueId}");
                                await ApiService().addToCart(
                                    customerUniqueID.toString(),
                                    widget.artUniqueId.toString());
                              }
                            } else {
                              showLoginDialogForCart(context);
                              // showToast(message: "First Login");
                            }
                          },
                          label: artDetails.art.status == "Sold"
                              ? artDetails.art.status
                              : "Add to Cart",
                          isBoarderRadiusLess: true,
                          isSelected: true,
                          buttonClick: false,
                        ),
                        GeneralButton(
                          Width: Responsive.getWidth(165),
                          onTap: () async {
                            if (isLoggedIn) {
                              showRegisterDialog(
                                  context,
                                  artDetails.art.artUniqueId,
                                  artDetails.art.artistId,
                                  artDetails.art.fcmToken!);
                            } else {
                              showLoginDialogForEnquiry(context);
                              // showToast(message: "First Login");
                            }

                            // print("customer_unique_id : ${customerUniqueID}");
                            // print("art_unique_id : ${widget.artUniqueId}");
                            // await ApiService().addToCart(
                            //     customerUniqueID.toString(),
                            //     widget.artUniqueId.toString());
                          },
                          label: "Enquiry",
                          isBoarderRadiusLess: true,
                          isSelected: false,
                          buttonClick: true,
                        ),
                      ],
                    )),
                SizedBox(height: Responsive.getHeight(16)),
                artDetails.categoryArtData == 0
                    ? Container()
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    WantText2(
                      text: "POPULAR ART WORK",
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
                artDetails.categoryArtData == 0
                    ? Container()
                    : SizedBox(height: Responsive.getHeight(11)),
                artDetails.categoryArtData == 0
                    ? Container()
                    : Container(
                  // padding: EdgeInsets.only(left: Responsive.getWidth(16)),
                  height: Responsive.getHeight(185),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: artDetails.categoryArtData.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      SingleProductDetailScreen(
                                          artUniqueId: artDetails
                                              .categoryArtData[
                                          index]
                                              .artUniqueId)));
                        },
                        child: Container(
                          width: Responsive.getWidth(140),
                          height: Responsive.getHeight(178),
                          margin: EdgeInsets.only(
                              right: Responsive.getWidth(12)),
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: Responsive.getWidth(140),
                                height: Responsive.getHeight(140),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  borderRadius:
                                  BorderRadius.circular(
                                      Responsive.getWidth(4)),
                                  // image: DecorationImage(
                                  //     image: NetworkImage(
                                  //         ),
                                  //     fit: BoxFit.fill)
                                ),
                                child: artDetails
                                    .categoryArtData[index]
                                    .artImages
                                    .length ==
                                    0
                                    ? Center(
                                  child: WantText2(
                                      text: artDetails
                                          .categoryArtData[
                                      index]
                                          .title[0],
                                      fontSize: Responsive
                                          .getFontSize(20),
                                      fontWeight:
                                      AppFontWeight.bold,
                                      textColor: black),
                                )
                                    : ClipRRect(
                                  borderRadius:
                                  BorderRadius.circular(
                                      4),
                                  child: Image.network(
                                    artDetails
                                        .categoryArtData[
                                    index]
                                        .artImages
                                        .first
                                        .image,
                                    fit: BoxFit.contain,
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
                                      text: artDetails
                                          .categoryArtData[index]
                                          .title,
                                      fontSize:
                                      Responsive.getFontSize(
                                          10),
                                      fontWeight:
                                      AppFontWeight.bold,
                                      textColor: textBlack),
                                  SizedBox(
                                    height: Responsive.getHeight(2),
                                  ),
                                  WantText2(
                                      text:
                                      "\$${artDetails.categoryArtData[index].price}",
                                      fontSize:
                                      Responsive.getFontSize(8),
                                      fontWeight:
                                      AppFontWeight.regular,
                                      textColor: textGray7)
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    WantText2(
                      text: "MORE FROM ARTIST",
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
                SizedBox(height: Responsive.getHeight(11)),
                Container(
                  // padding: EdgeInsets.only(left: Responsive.getWidth(16)),
                  height: Responsive.getHeight(185),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: artDetails.fromArtist.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      SingleProductDetailScreen(
                                          artUniqueId: artDetails
                                              .fromArtist[index]
                                              .artUniqueId)));
                        },
                        child: Container(
                          width: Responsive.getWidth(140),
                          height: Responsive.getHeight(178),
                          margin: EdgeInsets.only(
                              right: Responsive.getWidth(12)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: Responsive.getWidth(140),
                                height: Responsive.getHeight(140),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                      Responsive.getWidth(4)),
                                  color: Colors.grey.shade300,
                                  // borderRadius:
                                  // BorderRadius.circular(
                                  //     Responsive.getWidth(4)),
                                  // image: DecorationImage(
                                  //     image: NetworkImage(artDetails
                                  //         .fromArtist[index]
                                  //         .artImages
                                  //         .first
                                  //         .image),
                                  //     fit: BoxFit.fill)
                                ),
                                child: artDetails.fromArtist[index]
                                    .artImages ==
                                    0
                                    ? Center(
                                  child: WantText2(
                                      text: artDetails
                                          .fromArtist[index]
                                          .title[0],
                                      fontSize:
                                      Responsive.getFontSize(
                                          20),
                                      fontWeight:
                                      AppFontWeight.bold,
                                      textColor: black),
                                )
                                    : ClipRRect(
                                  borderRadius:
                                  BorderRadius.circular(4),
                                  child: Image.network(
                                    artDetails.fromArtist[index]
                                        .artImages.first.image,
                                    fit: BoxFit.contain,
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
                                      text: artDetails
                                          .fromArtist[index].title,
                                      fontSize:
                                      Responsive.getFontSize(10),
                                      fontWeight: AppFontWeight.bold,
                                      textColor: textBlack),
                                  SizedBox(
                                    height: Responsive.getHeight(2),
                                  ),
                                  WantText2(
                                      text:
                                      "\$${artDetails.fromArtist[index].price}",
                                      fontSize: Responsive.getFontSize(8),
                                      fontWeight: AppFontWeight.regular,
                                      textColor: textGray7)
                                ],
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void showLoginDialogForwishlist(
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
                      "You want to add this Product in wishlist then Log in First.",
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

  void showLoginDialogForEnquiry(
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
                      "You want to enquiry on this Product then Log in First.",
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

  void showLoginDialogForCart(
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
                      "You want to Add to cart this Product then Log in First. ",
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

  void showRegisterDialog(BuildContext context, String artUniqueId,
      String artist_unique_id, String fcmToken) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return RegisterDialog(
          fcmToken: fcmToken,
          artUniqueId: artUniqueId.toString(),
          customerUniqueID: customerUniqueID.toString(),
          artist_unique_id: artist_unique_id.toString(),
        );
      },
    );
  }
}

class RegisterDialog extends StatefulWidget {
  final String artUniqueId;
  final String fcmToken;
  final String customerUniqueID;
  final String artist_unique_id;

  const RegisterDialog(
      {Key? key,
        required this.artUniqueId,
        required this.fcmToken,
        required this.customerUniqueID,
        required this.artist_unique_id})
      : super(key: key);

  @override
  _RegisterDialogState createState() => _RegisterDialogState();
}

class _RegisterDialogState extends State<RegisterDialog> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  // final TextEditingController mobileController = TextEditingController();
  final TextEditingController messageController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    // mobileController.dispose();
    messageController.dispose();
    super.dispose();
  }

  void registerCustomer() async {
    if (_formKey.currentState!.validate()) {
      if (nameController.text.isEmpty) {
        showToast(message: "Enter Name");
      } else if (emailController.text.isEmpty) {
        showToast(message: "Enter Email");
      }
      // else if (mobileController.text.isEmpty) {
      //   showToast(message: "Enter Mobile");
      // }
      else if (messageController.text.isEmpty) {
        showToast(message: "Enter message");
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
          final response = await ApiService().addSaleEnquiry(
            name: nameController.text.toString(),
            email: emailController.text.toString(),
            artist_unique_id: widget.artist_unique_id.toString(),
            fcmToken: widget.fcmToken.toString(),
            // mobile: mobileController.text.toString(),
            artUniqueId: widget.artUniqueId.toString(),
            message: messageController.text.toString(),
            customerUniqueId: widget.customerUniqueID.toString(),
          );
          print(response);
          if (response['status'] == true) {
            showToast(message: "Art Enquiry Send Successfully.");
          } else {
            showToast(message: response['message']);
          }
          Navigator.pop(context);
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
  Widget build(BuildContext context) {
    Responsive.init(context);
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
                WantText2(
                    text: "Art Enquiry",
                    fontSize: Responsive.getFontSize(18),
                    fontWeight: AppFontWeight.medium,
                    textColor: textBlack),
                SizedBox(height: Responsive.getHeight(10)),
                WantText2(
                    textAlign: TextAlign.center,
                    text:
                    "Thank you for your interest. Please fill out the below form,\nand our specialist will follow up with you shortly.",
                    fontSize: Responsive.getFontSize(8),
                    fontWeight: AppFontWeight.medium,
                    textColor: textBlack10),
                SizedBox(height: 10),
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          WantText2(
                              text: "Name",
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
                        hintText: "Enter your Name",
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
                      AppTextFormField(
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
                            r'^[a-z0-9][a-z0-9._%+-]*@[a-z0-9.-]+\.[a-z]{2,}$',
                            caseSensitive: false,
                          );
                          if (!emailRegex.hasMatch(value)) {
                            return 'Email is not valid';
                          }
                          return null;
                        },
                        hintText: "Enter Your Email",
                      ),
                      SizedBox(
                        height: Responsive.getHeight(15),
                      ),
                      // WantText2(
                      //     text: "Contact Number ",
                      //     fontSize: Responsive.getFontSize(10),
                      //     fontWeight: AppFontWeight.medium,
                      //     textColor: textBlack9),
                      // SizedBox(
                      //   height: Responsive.getHeight(5),
                      // ),
                      // AppTextFormField(
                      //   fillColor: Color.fromRGBO(247, 248, 249, 1),
                      //   contentPadding: EdgeInsets.symmetric(
                      //       horizontal: Responsive.getWidth(18),
                      //       vertical: Responsive.getHeight(14)),
                      //   borderRadius: Responsive.getWidth(8),
                      //   controller: mobileController,
                      //   borderColor: textFieldBorderColor,
                      //   hintStyle: GoogleFonts.urbanist(
                      //     color: textGray,
                      //     fontSize: Responsive.getFontSize(15),
                      //     fontWeight: AppFontWeight.medium,
                      //   ),
                      //   textStyle: GoogleFonts.urbanist(
                      //     color: textBlack,
                      //     fontSize: Responsive.getFontSize(15),
                      //     fontWeight: AppFontWeight.medium,
                      //   ),
                      //   onChanged: (p0) {
                      //     _formKey.currentState!.validate();
                      //   },
                      //   validator: (value) {
                      //     if (value == null || value.isEmpty) {
                      //       return 'Contact number cannot be empty';
                      //     }
                      //     return null;
                      //   },
                      //   hintText: "Contact number",
                      // ),
                      // SizedBox(
                      //   height: Responsive.getHeight(15),
                      // ),
                      Row(
                        children: [
                          WantText2(
                              text: "Message",
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
                        maxLines: 4,
                        fillColor: Color.fromRGBO(247, 248, 249, 1),
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: Responsive.getWidth(18),
                            vertical: Responsive.getHeight(14)),
                        borderRadius: Responsive.getWidth(8),
                        controller: messageController,
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
                            return 'Message cannot be empty';
                          }
                          return null;
                        },
                        hintText: "Enter Message",
                      ),
                      SizedBox(
                        height: Responsive.getHeight(28),
                      ),
                      Center(
                        child: GestureDetector(
                          onTap: registerCustomer,
                          child: Container(
                            height: Responsive.getHeight(45),
                            width: Responsive.getWidth(315),
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
                                      "ENQUIRY",
                                      style: GoogleFonts.poppins(
                                        letterSpacing: 1.5,
                                        textStyle: TextStyle(
                                          fontSize:
                                          Responsive.getFontSize(16),
                                          color: Colors.white,
                                          fontWeight:
                                          AppFontWeight.semiBold,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
