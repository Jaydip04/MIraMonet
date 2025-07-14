import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../config/colors.dart';
import '../../../core/api_service/api_service.dart';
import '../../../core/models/category_model.dart';
import '../../../core/models/user_side/customer_all_art_model.dart';
import '../../../core/utils/app_font_weight.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/app_text_form_field.dart';
import '../../../core/widgets/custom_text_2.dart';
import '../home_screen/all_category/all_category_screen.dart';
import '../home_screen/all_category/single_category/single_category_screen.dart';
import '../home_screen/product_detail/single_product/single_product_detail_screen.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  TextEditingController _searchController = TextEditingController();
  late Future<List<CustomerAllArtModel>> artData;
  bool _isSearchVisible = false; // Track the visibility of the search bar
  List<CustomerAllArtModel> _filteredArtItems = [];
  List<CustomerAllArtModel> _allArtItems = [];
  final ApiService apiService = ApiService();
  late Future<List<Category>> _categoriesFuture;
  @override
  void initState() {
    super.initState();
    artData = ApiService().getAllArt();
    artData.then((data) {
      setState(() {
        _allArtItems = data;
      });
    });
    _categoriesFuture = ApiService().fetchCategories();
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        scrolledUnderElevation: 0.0,
        automaticallyImplyLeading: false,
        // centerTitle: true,
        centerTitle: false,
        title: Text(
          textAlign: TextAlign.start,
          "Shop",
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
                    setState(() {
                      _isSearchVisible = !_isSearchVisible;
                      isshow = false;
                      print(isshow);
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 24),
                    child: Icon(
                      CupertinoIcons.search,
                      size: Responsive.getWidth(24),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
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
            if (_isSearchVisible) SizedBox(height: Responsive.getHeight(29)),
            // CategoryList
            FutureBuilder<List<Category>>(
              future: _categoriesFuture,
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
                  return Center(
                      child: WantText2(
                          text: "No categories available",
                          fontSize: Responsive.getFontSize(16),
                          fontWeight: AppFontWeight.regular,
                          textColor: black));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                      child: WantText2(
                          text: "No categories available",
                          fontSize: Responsive.getFontSize(16),
                          fontWeight: AppFontWeight.regular,
                          textColor: black));
                } else {
                  final categories = snapshot.data!;
                  return Container(
                    margin: EdgeInsets.only(left: Responsive.getWidth(18)),
                    height: Responsive.getHeight(100),
                    child: Row(
                      children: [
                        Container(
                          width: Responsive.getWidth(290),
                          child: ListView.builder(
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount:
                                categories.length > 4 ? 4 : categories.length,
                            itemBuilder: (context, index) {
                              final category = categories[index];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => SingleCategoryScreen(
                                              Category_id:
                                                  categories[index].categoryId,
                                              Category_name: categories[index]
                                                  .categoryName,
                                            )),
                                  );
                                },
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: Responsive.getWidth(50),
                                      height: Responsive.getWidth(70),
                                      margin: EdgeInsets.only(right: 25),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: Responsive.getWidth(48),
                                            height: Responsive.getWidth(48),
                                            // padding: EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Color.fromRGBO(
                                                  233, 255, 248, 1),
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                              child: Image.network(
                                                category.categoryIcon,
                                                fit: BoxFit.fill,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                              height: Responsive.getHeight(4)),
                                          WantText2(
                                            text: category.categoryName,
                                            fontSize:
                                                Responsive.getFontSize(12),
                                            fontWeight: AppFontWeight.regular,
                                            textColor: Colors.black,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        categories.length > 4
                            ? GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AllCategoryScreen(
                                          categories: categories),
                                    ),
                                  );
                                },
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: Responsive.getWidth(60),
                                      height: Responsive.getWidth(70),
                                      // margin: EdgeInsets.only(right: 12),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: Responsive.getWidth(48),
                                            height: Responsive.getWidth(48),
                                            decoration: BoxDecoration(
                                              color: Color.fromRGBO(
                                                  233, 255, 248, 1),
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                            ),
                                            child: Center(
                                              child: Image.asset(
                                                "assets/all.png",
                                                height: Responsive.getWidth(24),
                                                width: Responsive.getWidth(24),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                              height: Responsive.getHeight(4)),
                                          WantText2(
                                            text: "All",
                                            fontSize:
                                                Responsive.getFontSize(12),
                                            fontWeight: AppFontWeight.regular,
                                            textColor: Colors.black,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Container(),
                      ],
                    ),
                  );
                }
              },
            ),
            SizedBox(height: Responsive.getHeight(20)),
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
                          height: Responsive.getHeight(500),
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
                                                      SingleProductDetailScreen(
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
                                                image: DecorationImage(
                                                  image: NetworkImage(
                                                      art.artImages[0].image),
                                                  fit: BoxFit.contain,
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
                                                    text: "\$${art.price}",
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
                                      ),
                                    );
                                  },
                                )
                          : StaggeredGridView.countBuilder(
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
                                                  SingleProductDetailScreen(
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
                                            // image: DecorationImage(
                                            //   image: NetworkImage(
                                            //       .artImages[0].image),
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
                                                text: "\$${art.price}",
                                                fontSize:
                                                    Responsive.getFontSize(14),
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
                  art.artistName.toLowerCase().contains(query.toLowerCase()) ||
                  art.price.toLowerCase().contains(query.toLowerCase()))
              .toList();
        }
      });
    });
  }
}
