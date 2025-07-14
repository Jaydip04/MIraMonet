import 'package:artist/core/utils/responsive.dart';
import 'package:artist/core/widgets/custom_text_2.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../config/colors.dart';
import '../../../../core/utils/app_font_weight.dart';
import '../../../../core/api_service/api_service.dart';
import '../../../../core/widgets/expandable_text.dart';
import '../../home_screen/artist_profile/single_artist_profile_screen/single_artist_profile_screen.dart';

class SingleArtistStoryScreen extends StatefulWidget {
  final artistUniqueId;
  const SingleArtistStoryScreen({super.key, required this.artistUniqueId});

  @override
  State<SingleArtistStoryScreen> createState() =>
      _SingleArtistStoryScreenState();
}

class _SingleArtistStoryScreenState extends State<SingleArtistStoryScreen> {
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    print(widget.artistUniqueId);
    _fetchArtDetails();
  }

  ApiService apiService = ApiService();
  Map<String, dynamic>? artDetails;
  Future<void> _fetchArtDetails() async {
    try {
      artDetails = await apiService.getArtDetails(widget.artistUniqueId);
      setState(() {});
    } catch (e) {
      print('Error: $e');
    }
  }

  final List<String> imageUrls = [
    'assets/back.png',
    'assets/artists_stories_back.png',
    'assets/banner.png',
    'assets/back.png',
  ];

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    if (artDetails == null) {
      return Scaffold(
          backgroundColor: white,
          body: Center(
            child: SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: Colors.black,
              ),
            ),
          ));
    }
    return Scaffold(
      backgroundColor: white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: Responsive.getWidth(16)),
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
                      borderRadius:
                          BorderRadius.circular(Responsive.getWidth(12)),
                      border:
                          Border.all(color: textFieldBorderColor, width: 1.0),
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_new_outlined,
                      size: Responsive.getWidth(19),
                    ),
                  ),
                ),
                SizedBox(width: Responsive.getWidth(80)),
                WantText2(
                  text: "Artist Story",
                  fontSize: Responsive.getFontSize(18),
                  fontWeight: AppFontWeight.medium,
                  textColor: textBlack,
                ),
              ],
            ),
            SizedBox(height: Responsive.getHeight(20)),
            Text(
              artDetails!["stories"]["art"]["title"],
              style: GoogleFonts.poppins(
                letterSpacing: 1.5,
                color: textBlack,
                fontSize: Responsive.getFontSize(16),
                fontWeight: AppFontWeight.semiBold,
              ),
            ),
            SizedBox(height: Responsive.getHeight(24)),
            Center(
              child: Container(
                decoration: BoxDecoration(boxShadow: [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.1),
                    spreadRadius: 0,
                    offset: Offset(0, 0),
                    blurRadius: 16,
                  )
                ]),
                width: Responsive.getWidth(328),
                height: Responsive.getHeight(373),
                child: Image.network(
                  artDetails!["stories"]["image"][selectedIndex]["image"],
                  fit: BoxFit.contain,
                ),
              ),
            ),
            SizedBox(height: Responsive.getHeight(37)),
            Center(
              child: Container(
                width: Responsive.getWidth(224),
                height: Responsive.getHeight(64),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: artDetails!["stories"]["image"].length,
                  itemBuilder: (context, index) {
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
                            width: 1,
                          ),
                        ),
                        margin: EdgeInsets.symmetric(horizontal: 8),
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        height: 64,
                        width: 64,
                        child: Image.network(
                          artDetails!["stories"]["image"][index]["image"],
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
            SizedBox(height: Responsive.getHeight(50)),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SingleArtistProfileScreen(
                      artistUniqueId: artDetails!["stories"]["customer"]
                          ["customer_unique_id"],
                    ),
                  ),
                );
              },
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: artDetails!["stories"]["customer"]
                                ["customer_profile"] ==
                            null
                        ? SizedBox(
                            width: Responsive.getWidth(50),
                            height: Responsive.getWidth(50),
                            child: CircleAvatar(
                              backgroundColor: Colors.grey.shade300,
                              radius: 30,
                              child: WantText2(
                                  text: artDetails!["stories"]["customer"]
                                      ["name"][0],
                                  fontSize: Responsive.getFontSize(20),
                                  fontWeight: AppFontWeight.bold,
                                  textColor: black),
                            ),
                          )
                        : Image.network(
                            artDetails!["stories"]["customer"]
                                ["customer_profile"],
                            width: Responsive.getWidth(50),
                            height: Responsive.getWidth(50),
                            fit: BoxFit.fill,
                          ),
                  ),
                  SizedBox(width: 16.0),
                  WantText2(
                    text: artDetails!["stories"]["customer"]["name"],
                    fontSize: Responsive.getFontSize(16),
                    fontWeight: AppFontWeight.semiBold,
                    textColor: Color.fromRGBO(0, 0, 0, 0.6),
                  ),
                ],
              ),
            ),
            SizedBox(height: Responsive.getHeight(21)),
            ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: artDetails!["stories"]["paragraph"].length,
                itemBuilder: (context, index) {
                  return ExpandableText(text: artDetails!["stories"]["paragraph"][index]["paragraph"],maxLines: 5,);
                  //   Text(
                  //   artDetails!["stories"]["paragraph"][index]["paragraph"],
                  //   style: GoogleFonts.poppins(
                  //     letterSpacing: 1.5,
                  //     color: textGray8,
                  //     fontSize: Responsive.getFontSize(12),
                  //     fontWeight: AppFontWeight.regular,
                  //   ),
                  // );
                }),
            SizedBox(height: Responsive.getHeight(24)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                WantText2(
                  text: "Related stories",
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
            SizedBox(height: Responsive.getHeight(12)),
            Container(
              height: Responsive.getHeight(300),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: artDetails!["from_artist"].length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SingleArtistStoryScreen(
                            artistUniqueId: artDetails!["from_artist"][index]
                                ["art"]["art_unique_id"],
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: Responsive.getWidth(170),
                      margin: EdgeInsets.only(right: Responsive.getWidth(9)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: Responsive.getHeight(170),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                Responsive.getWidth(2),
                              ),
                              image: DecorationImage(
                                image: NetworkImage(artDetails!["from_artist"]
                                    [index]["art"]["art_images"][0]["image"]),
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          SizedBox(height: Responsive.getHeight(6)),
                          Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                WantText2(
                                  text: artDetails!["from_artist"][index]["art"]
                                      ["title"],
                                  fontSize: Responsive.getFontSize(12),
                                  fontWeight: AppFontWeight.semiBold,
                                  textColor: textBlack13,
                                  textOverflow: TextOverflow.ellipsis,
                                ),
                                WantText2(
                                  text: artDetails!["from_artist"][index]["art"]
                                      ["artist_name"],
                                  fontSize: Responsive.getFontSize(8),
                                  fontWeight: AppFontWeight.regular,
                                  textColor: textGray14,
                                  textOverflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  artDetails!["from_artist"][index]["paragraph"]
                                      [0]["paragraph"],
                                  maxLines: 5,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(
                                    letterSpacing: 1.5,
                                    color: textGray13,
                                    fontSize: Responsive.getFontSize(10),
                                    fontWeight: AppFontWeight.regular,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ArtItem {
  final String artUniqueId;
  final String title;
  final String artistName;
  final String price;
  final List<ArtImage> artImages;

  ArtItem({
    required this.artUniqueId,
    required this.title,
    required this.artistName,
    required this.price,
    required this.artImages,
  });

  factory ArtItem.fromJson(Map<String, dynamic> json) {
    return ArtItem(
      artUniqueId: json['art_unique_id'],
      title: json['title'],
      artistName: json['artist_name'],
      price: json['price'],
      artImages: (json['art_images'] as List)
          .map((artImageJson) => ArtImage.fromJson(artImageJson))
          .toList(),
    );
  }
}

class ArtImage {
  final String imageUrl;

  ArtImage({
    required this.imageUrl,
  });

  factory ArtImage.fromJson(Map<String, dynamic> json) {
    return ArtImage(
      imageUrl: json['image_url'],
    );
  }
}
