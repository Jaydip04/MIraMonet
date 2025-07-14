import 'package:artist/view/user_side/home_screen/product_detail/single_product/single_product_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../config/colors.dart';
import '../../../core/api_service/api_service.dart';
import '../../../core/utils/app_font_weight.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/custom_text_2.dart';

class searchArt {
  final int artId;
  final String artUniqueId;
  final String title;
  final String artistName;
  final String image;
  final String categoryName;
  final int categoryId;
  final String price;

  searchArt({
    required this.artId,
    required this.artUniqueId,
    required this.title,
    required this.artistName,
    required this.image,
    required this.categoryName,
    required this.categoryId,
    required this.price,
  });

  factory searchArt.fromJson(Map<String, dynamic> json) {
    return searchArt(
      artId: json['art_id'],
      artUniqueId: json['art_unique_id'],
      title: json['title'],
      artistName: json['artist_name'],
      image: json['image'],
      categoryName: json['category_name'],
      categoryId: json['category_id'],
      price: json['price'],
    );
  }
}

class SearchScreen extends StatefulWidget {
  final String search_query;
  const SearchScreen({super.key, required this.search_query});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late Future<List<searchArt>> _searchResults;

  @override
  void initState() {
    super.initState();
    _searchResults = ApiService().fetchSearchArtData(
        widget.search_query); // Fetch data when screen loads
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: white,
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: Responsive.getWidth(16)),
          child: ListView(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
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
                          border: Border.all(
                              color: textFieldBorderColor, width: 1.0)),
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
                      text: "Search",
                      fontSize: Responsive.getFontSize(18),
                      fontWeight: AppFontWeight.medium,
                      textColor: textBlack)
                ],
              ),
              SizedBox(
                height: Responsive.getHeight(16),
              ),
              FutureBuilder<List<searchArt>>(
                future: _searchResults,
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
                    return Center(child: Text('No results found.'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No results found.'));
                  } else {
                    final itemsToDisplay = snapshot.data!;

                    return StaggeredGridView.countBuilder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: itemsToDisplay.length,
                      mainAxisSpacing: 20,
                      crossAxisSpacing: 20,
                      crossAxisCount: 4,
                      staggeredTileBuilder: (index) => StaggeredTile.fit(2),
                      itemBuilder: (context, index) {
                        final art = itemsToDisplay[index];

                        return Center(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => SingleProductDetailScreen(
                                      artUniqueId: art.artUniqueId),
                                ),
                              );
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: Responsive.getHeight(174),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                        Responsive.getWidth(16)),
                                    image: DecorationImage(
                                      image: NetworkImage(art.image),
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                                SizedBox(height: Responsive.getHeight(6)),
                                Container(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      WantText2(
                                        text: art.title,
                                        fontSize: Responsive.getFontSize(14),
                                        fontWeight: AppFontWeight.medium,
                                        textColor: textBlack,
                                        textOverflow: TextOverflow.ellipsis,
                                      ),
                                      WantText2(
                                        text: art.artistName,
                                        fontSize: Responsive.getFontSize(11),
                                        fontWeight: AppFontWeight.regular,
                                        textColor: textBlack,
                                        textOverflow: TextOverflow.ellipsis,
                                      ),
                                      WantText2(
                                        text: "\$${art.price}",
                                        fontSize: Responsive.getFontSize(14),
                                        fontWeight: AppFontWeight.medium,
                                        textColor: textBlack,
                                        textOverflow: TextOverflow.ellipsis,
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
                  }
                },
              ),
            ],
          ),
        ));
  }
}
