import 'package:artist/view/user_side/home_screen/product_detail/single_product/single_private_product_detail_screen.dart';
import 'package:artist/view/user_side/home_screen/product_detail/single_product/single_product_detail_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';

import '../../../../config/colors.dart';
import '../../../../core/api_service/api_service.dart';
import '../../../../core/models/user_side/customer_all_art_model.dart';
import '../../../../core/utils/app_font_weight.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/app_text_form_field.dart';
import '../../../../core/widgets/custom_text_2.dart';

class AllPrivateProductDetails extends StatefulWidget {
  const AllPrivateProductDetails({super.key});

  @override
  State<AllPrivateProductDetails> createState() => _AllPrivateProductDetailsState();
}

class _AllPrivateProductDetailsState extends State<AllPrivateProductDetails> {
  TextEditingController _searchController = TextEditingController();
  late Future<List<CustomerAllArtModel>> artData;
  bool _isSearchVisible = false;
  List<CustomerAllArtModel> _filteredArtItems = [];
  final ApiService apiService = ApiService();
  List<CustomerAllArtModel> _allArtItems = [];

  @override
  void initState() {
    super.initState();
    artData = ApiService().getAllPrivateArt();
    artData.then((data) {
      setState(() {
        _allArtItems = data;
      });
    });
  }
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  bool isshow = false;
  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: Responsive.getWidth(20)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    WantText2(
                        text: "Private Art",
                        fontSize: Responsive.getFontSize(18),
                        fontWeight: AppFontWeight.medium,
                        textColor: textBlack),
                    AnimationConfiguration.synchronized(
                      duration: const Duration(milliseconds: 2000),
                      child: SlideAnimation(
                        curve: Curves.easeInOut,
                        child: FadeInAnimation(
                          duration: const Duration(milliseconds: 1000),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _isSearchVisible =
                                !_isSearchVisible;
                                isshow = false;
                                print(isshow);
                              });
                            },
                            child: Icon(
                              CupertinoIcons.search,
                              size: Responsive.getWidth(24),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_isSearchVisible)
                SizedBox(height: Responsive.getHeight(20)),
              if (_isSearchVisible)
                Padding(
                  padding:
                  EdgeInsets.symmetric(horizontal: Responsive.getWidth(20)),
                  child: AppTextFormField(
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: Responsive.getWidth(12),
                      vertical: Responsive.getHeight(12),
                    ),
                    borderRadius: Responsive.getWidth(15),
                    controller: _searchController,
                    prefixIcon: Icon(CupertinoIcons.search, color: Colors.grey),
                    borderColor: Colors.grey,
                    hintStyle: GoogleFonts.poppins(
                      color: Colors.grey,
                      fontSize: Responsive.getFontSize(16),
                      fontWeight: AppFontWeight.medium,
                    ),
                    textStyle: GoogleFonts.poppins(
                      color: Colors.black,
                      fontSize: Responsive.getFontSize(16),
                      fontWeight: AppFontWeight.medium,
                    ),
                    hintText: "Search",
                    onChanged: (String? query) {
                      _filterArtItems(query);
                      setState(() {
                        isshow = true;
                        print(isshow);
                      });
                    },
                  ),
                ),
              SizedBox(height: Responsive.getHeight(29)),
              SizedBox(
                width: Responsive.getMainWidth(context),
                child: Center(
                  child: Padding(
                    padding:
                    EdgeInsets.symmetric(horizontal: Responsive.getWidth(20)),
                    child: FutureBuilder<List<CustomerAllArtModel>>(
                      future: artData,
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
                        }
                        if (snapshot.hasError) {
                          return SizedBox(
                            height: Responsive.getHeight(600),
                            child: Center(
                              child: WantText2(
                                  text: "No Art available",
                                  fontSize: Responsive.getFontSize(16),
                                  fontWeight: AppFontWeight.regular,
                                  textColor: black),
                            ),
                          );
                        }

                        final artItems = snapshot.data ?? [];
                        final itemsToDisplay =
                        _filteredArtItems.isNotEmpty ? _filteredArtItems : [];

                        return isshow
                            ? itemsToDisplay.length == 0
                            ? WantText2(
                            text: "No result found",
                            fontSize: Responsive.getFontSize(18),
                            fontWeight: AppFontWeight.medium,
                            textColor: black)
                            : StaggeredGridView.countBuilder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: itemsToDisplay.length,
                          mainAxisSpacing: 20,
                          crossAxisSpacing: 20,
                          crossAxisCount: 4,
                          staggeredTileBuilder: (index) =>
                              StaggeredTile.fit(2),
                          itemBuilder: (context, index) {
                            final art = itemsToDisplay[index];

                            return Center(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              SinglePrivateProductDetailScreen(
                                                  artUniqueId: art
                                                      .artUniqueId)));
                                },
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      height: Responsive.getHeight(174),
                                      decoration: BoxDecoration(
                                        borderRadius:
                                        BorderRadius.circular(
                                            Responsive.getWidth(
                                                16)),
                                        // image: DecorationImage(
                                        //   image: NetworkImage(
                                        //       art.artImages[0].image),
                                        //   fit: BoxFit.fill,
                                        // ),
                                      ),
                                      child:
                                      art.artImages.length == 0
                                          ? Container(
                                        height:
                                        Responsive.getHeight(175),
                                        width:
                                        Responsive.getWidth(159),
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
                                                text:
                                                art.title[0],
                                                fontSize: Responsive
                                                    .getFontSize(20),
                                                fontWeight:
                                                AppFontWeight
                                                    .bold,
                                                textColor: black)),
                                      )
                                          : Container(
                                        height:
                                        Responsive.getHeight(175),
                                        width:
                                        Responsive.getWidth(159),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                          BorderRadius.circular(
                                              Responsive.getWidth(
                                                  16)),
                                          image: DecorationImage(
                                            image: NetworkImage(art
                                                .artImages[0]
                                                .image), // Use dynamic image URL
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ),
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
                                            text: art.title,
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
                                            text: art.artistName,
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
                                            text: "Request For Price",
                                            fontSize:
                                            Responsive.getFontSize(
                                                12),
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
                              ),
                            );
                          },
                        )
                            : artItems.length == 0 ? Center(
                          child: WantText2(
                              text: "No Art found",
                              fontSize: Responsive.getFontSize(16),
                              fontWeight: AppFontWeight.regular,
                              textColor: black),
                        ) : StaggeredGridView.countBuilder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: artItems.length,
                          mainAxisSpacing: 20,
                          crossAxisSpacing: 20,
                          crossAxisCount: 4,
                          staggeredTileBuilder: (index) =>
                              StaggeredTile.fit(2),
                          itemBuilder: (context, index) {
                            final art = artItems[index];

                            return Center(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              SinglePrivateProductDetailScreen(
                                                  artUniqueId:
                                                  art.artUniqueId)));
                                },
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      height: Responsive.getHeight(174),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                            Responsive.getWidth(16)),
                                        image: DecorationImage(
                                          image: NetworkImage(
                                              art.artImages[0].image),
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                        height: Responsive.getHeight(6)),
                                    Container(
                                      // height: 59,
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                        MainAxisAlignment.start,
                                        children: [
                                          WantText2(
                                            text: art.title,
                                            fontSize:
                                            Responsive.getFontSize(14),
                                            fontWeight:
                                            AppFontWeight.medium,
                                            textColor: textBlack,
                                            textOverflow:
                                            TextOverflow.ellipsis,
                                          ),
                                          WantText2(
                                            text: art.artistName,
                                            fontSize:
                                            Responsive.getFontSize(11),
                                            fontWeight:
                                            AppFontWeight.regular,
                                            textColor: textBlack,
                                            textOverflow:
                                            TextOverflow.ellipsis,
                                          ),
                                          WantText2(
                                            text: "Request For Price",
                                            fontSize:
                                            Responsive.getFontSize(12),
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
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  void _filterArtItems(String? query) {
    setState(() {
      artData.then((artItems) {
        if (query == null || query.isEmpty) {
          _filteredArtItems = artItems;
        } else {
          _filteredArtItems = artItems
              .where((art) =>
          art.title.toLowerCase().contains(query.toLowerCase()) ||
              art.artistName.toLowerCase().contains(query.toLowerCase()))
              .toList();
        }
      });
    });
  }
}
