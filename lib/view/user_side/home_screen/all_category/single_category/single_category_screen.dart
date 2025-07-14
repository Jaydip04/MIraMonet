import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:screenshot/screenshot.dart';
import 'package:http/http.dart' as http;
import '../../../../../config/colors.dart';
import '../../../../../core/api_service/api_service.dart';
import '../../../../../core/api_service/base_url.dart';
import '../../../../../core/models/upload_art_model/category_select_model.dart';
import '../../../../../core/models/user_side/customer_all_art_model.dart';
import '../../../../../core/utils/app_font_weight.dart';
import '../../../../../core/utils/responsive.dart';
import '../../../../../core/widgets/custom_text_2.dart';
import '../../product_detail/single_product/single_product_detail_screen.dart';

class SingleCategoryScreen extends StatefulWidget {
  final Category_id;
  final Category_name;
  const SingleCategoryScreen(
      {super.key, required this.Category_id, required this.Category_name});

  @override
  State<SingleCategoryScreen> createState() => _SingleCategoryScreenState();
}

// class _SingleCategoryScreenState extends State<SingleCategoryScreen> {
//   late Future<List<CustomerAllArtModel>> artData;
//   final ApiService apiService = ApiService();
//   List<SubCategory> subCategories = [];
//   String selectedSubCategoryId = ""; // Track selected subcategory
//
//   @override
//   void initState() {
//     super.initState();
//     print("Category Id: ${widget.Category_id}");
//     fetchSubCategories(widget.Category_id.toString());
//     artData = fetchCategoryProducts(widget.Category_id.toString()); // Initially fetch category products
//   }
//
//   /// Fetch Subcategories for the given Category
//   Future<void> fetchSubCategories(String categoryId) async {
//     final url = Uri.parse("$serverUrl/subCategories");
//
//     try {
//       final response = await http.post(
//         url,
//         body: jsonEncode({"category_id": categoryId}),
//         headers: {"Content-Type": "application/json"},
//       );
//
//       if (response.statusCode == 200) {
//         Map<String, dynamic> data = jsonDecode(response.body);
//         if (data['status']) {
//           setState(() {
//             subCategories = (data['sub_categories_array'] as List)
//                 .map((json) => SubCategory.fromJson(json))
//                 .toList();
//           });
//         }
//       } else {
//         print("Failed to load subcategories");
//       }
//     } catch (e) {
//       print("Error: $e");
//     }
//   }
//
//   /// Fetch Products by Subcategory ID
//   Future<List<CustomerAllArtModel>> fetchCategoryProducts(String subCategoryId) async {
//     final url = Uri.parse("$serverUrl/get_sub_category_product");
//
//     try {
//       final response = await http.post(
//         url,
//         body: jsonEncode({"sub_category_1_id": subCategoryId}),
//         headers: {"Content-Type": "application/json"},
//       );
//
//       if (response.statusCode == 200) {
//         Map<String, dynamic> data = jsonDecode(response.body);
//         if (data['status']) {
//           return (data['artdata'] as List)
//               .map((json) => CustomerAllArtModel.fromJson(json))
//               .toList();
//         }
//       }
//     } catch (e) {
//       print("Error: $e");
//     }
//     return [];
//   }
//
//     Color getRandomBackgroundColor() {
//     final Random random = Random();
//     int red = 200 + random.nextInt(56);   // 200 - 255 (light pastel shades)
//     int green = 200 + random.nextInt(56);
//     int blue = 200 + random.nextInt(56);
//     return Color.fromRGBO(red, green, blue, 1); // Full opacity
//   }
//
//   Color getContrastTextColor(Color backgroundColor) {
//     // Compute luminance (brightness of color)
//     double luminance = (0.299 * backgroundColor.red +
//         0.587 * backgroundColor.green +
//         0.114 * backgroundColor.blue) / 255;
//
//     return luminance > 0.6 ? Colors.black : Colors.white;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     Responsive.init(context);
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: ListView(
//         children: [
//           FutureBuilder<List<CustomerAllArtModel>>(
//             future: artData,
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return _buildLoadingState();
//               }
//               if (snapshot.hasError || snapshot.data!.isEmpty) {
//                 return _buildNoProductsState();
//               }
//
//               final artItems = snapshot.data ?? [];
//
//               return SafeArea(
//                 child: SingleChildScrollView(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       _buildHeader(),
//                       SizedBox(height: Responsive.getHeight(16)),
//
//                       // 🔹 Subcategory List (Clickable)
//                       Padding(
//                         padding: EdgeInsets.symmetric(horizontal: Responsive.getWidth(20)),
//                         child: SizedBox(
//                           height: Responsive.getHeight(72),
//                           child: ListView.builder(
//                             shrinkWrap: true,
//                             scrollDirection: Axis.horizontal,
//                             itemCount: subCategories.length,
//                             itemBuilder: (context, index) {
//                               final category = subCategories[index];
//                               final isSelected = selectedSubCategoryId == category.subCategoryId;
//                               final bgColor = isSelected ? Colors.blue : getRandomBackgroundColor();
//                               final textColor = getContrastTextColor(bgColor);
//
//                               return GestureDetector(
//                                 onTap: () {
//                                   setState(() {
//                                     selectedSubCategoryId = category.subCategoryId.toString();
//                                     artData = fetchCategoryProducts(category.subCategoryId.toString()); // Fetch new products
//                                   });
//                                 },
//                                 child: Column(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     Container(
//                                       width: Responsive.getWidth(50),
//                                       height: Responsive.getWidth(70),
//                                       margin: EdgeInsets.only(right: index == subCategories.length - 1 ? 0 : 25),
//                                       child: Column(
//                                         crossAxisAlignment: CrossAxisAlignment.center,
//                                         mainAxisAlignment: MainAxisAlignment.center,
//                                         children: [
//                                           Container(
//                                             width: Responsive.getWidth(48),
//                                             height: Responsive.getWidth(48),
//                                             decoration: BoxDecoration(
//                                               color: bgColor.withOpacity(0.5),
//                                               borderRadius: BorderRadius.circular(30),
//                                               border: isSelected ? Border.all(color: Colors.blue, width: 2) : null,
//                                             ),
//                                             child: ClipRRect(
//                                               borderRadius: BorderRadius.circular(30),
//                                               child: Center(
//                                                 child: WantText2(
//                                                   text: category.subCategoryName[0],
//                                                   fontSize: Responsive.getFontSize(20),
//                                                   fontWeight: AppFontWeight.bold,
//                                                   textColor: textColor,
//                                                 ),
//                                               ),
//                                             ),
//                                           ),
//                                           SizedBox(height: Responsive.getHeight(4)),
//                                           WantText2(
//                                             text: category.subCategoryName,
//                                             fontSize: Responsive.getFontSize(12),
//                                             fontWeight: AppFontWeight.regular,
//                                             textColor: isSelected ? Colors.blue : Colors.black,
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               );
//                             },
//                           ),
//                         ),
//                       ),
//
//                       SizedBox(height: Responsive.getHeight(16)),
//
//                       // 🔹 Product Grid Based on Selected Subcategory
//                       _buildProductGrid(artItems),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
//
//   /// 📌 **Loading State**
//   Widget _buildLoadingState() {
//     return SizedBox(
//       height: Responsive.getMainHeight(context),
//       width: Responsive.getMainWidth(context),
//       child: Center(child: CircularProgressIndicator(color: Colors.black)),
//     );
//   }
//
//   /// 📌 **No Products State**
//   Widget _buildNoProductsState() {
//     return Column(
//       children: [
//         SizedBox(height: Responsive.getHeight(250)),
//         Image.asset("assets/category.png", width: Responsive.getWidth(64), height: Responsive.getWidth(64)),
//         SizedBox(height: Responsive.getHeight(24)),
//         WantText2(
//           text: "No Category Item!",
//           fontSize: Responsive.getFontSize(20),
//           fontWeight: AppFontWeight.semiBold,
//           textColor: textGray17,
//         ),
//       ],
//     );
//   }
//
//   /// 📌 **Header with Category Name**
//   Widget _buildHeader() {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: Responsive.getWidth(20)),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           GestureDetector(
//             onTap: () => Navigator.pop(context),
//             child: Container(
//               width: Responsive.getWidth(41),
//               height: Responsive.getHeight(41),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(color: textFieldBorderColor, width: 1.0),
//               ),
//               child: Icon(Icons.arrow_back_ios_new_outlined, size: Responsive.getWidth(19)),
//             ),
//           ),
//           Flexible(
//             child: Center(
//               child: WantText2(
//                 text: widget.Category_name,
//                 fontSize: Responsive.getFontSize(18),
//                 fontWeight: AppFontWeight.medium,
//                 textColor: textBlack,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   /// 📌 **Product Grid**
//   Widget _buildProductGrid(List<CustomerAllArtModel> artItems) {
//     return StaggeredGridView.countBuilder(
//       physics: NeverScrollableScrollPhysics(),
//       shrinkWrap: true,
//       itemCount: artItems.length,
//       mainAxisSpacing: 20,
//       crossAxisSpacing: 20,
//       crossAxisCount: 4,
//       staggeredTileBuilder: (index) => StaggeredTile.fit(2),
//       itemBuilder: (context, index) {
//         final art = artItems[index];
//         return GestureDetector(
//           onTap: () {
//             Navigator.push(context, MaterialPageRoute(
//               builder: (_) => SingleProductDetailScreen(artUniqueId: art.artUniqueId),
//             ));
//           },
//           child: Image.network(art.artImages[0].image, fit: BoxFit.fill),
//         );
//       },
//     );
//   }
// }

class _SingleCategoryScreenState extends State<SingleCategoryScreen> {
  late Future<List<CustomerAllArtModel>> artData;
  final ApiService apiService = ApiService();
  List<SubCategory> subCategories = [];
  String selectedSubCategoryId = "";
  @override
  void initState() {
    super.initState();
    print("category Id : ${widget.Category_id.toString()}");
    fetchSubCategories(widget.Category_id.toString());
    artData = ApiService().fetchCategoryProducts(widget.Category_id.toString());
  }

  Future<void> fetchSubCategories(String categoryId) async {
    final url = Uri.parse("$serverUrl/subCategories");

    try {
      final response = await http.post(
        url,
        body: jsonEncode({"category_id": categoryId}),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        if (data['status']) {
          setState(() {
            subCategories = (data['sub_categories_array'] as List)
                .map((json) => SubCategory.fromJson(json))
                .toList();
          });
        }
      } else {
        print("Failed to load subcategories");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<List<CustomerAllArtModel>> fetchCategoryProducts(
      String subCategoryId) async {
    final url =
        Uri.parse("$serverUrl/get_sub_category_product");

    try {
      final response = await http.post(
        url,
        body: jsonEncode({"sub_category_1_id": subCategoryId}),
        headers: {"Content-Type": "application/json"},
      );

      print(response.body);
      if (response.statusCode == 200) {
        print(response.body);
        Map<String, dynamic> data = jsonDecode(response.body);
        if (data['status']) {
          return (data['artdata'] as List)
              .map((json) => CustomerAllArtModel.fromJson(json))
              .toList();
        }
      }
    } catch (e) {
      print("Error: $e");
    }
    return [];
  }

  Color getRandomBackgroundColor() {
    final Random random = Random();
    int red = 200 + random.nextInt(56); // 200 - 255 (light pastel shades)
    int green = 200 + random.nextInt(56);
    int blue = 200 + random.nextInt(56);
    return Color.fromRGBO(red, green, blue, 1); // Full opacity
  }

  Color getContrastTextColor(Color backgroundColor) {
    // Compute luminance (brightness of color)
    double luminance = (0.299 * backgroundColor.red +
            0.587 * backgroundColor.green +
            0.114 * backgroundColor.blue) /
        255;

    return luminance > 0.6 ? Colors.black : Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        children: [
          FutureBuilder<List<CustomerAllArtModel>>(
            future: artData,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SizedBox(
                  height: Responsive.getMainHeight(context),
                  width: Responsive.getMainWidth(context),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
              if (snapshot.hasError) {
                return SafeArea(
                  child: SizedBox(
                    height: Responsive.getMainHeight(context),
                    width: Responsive.getMainWidth(context),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      // mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: Responsive.getWidth(20)),
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
                              Flexible(
                                child: Center(
                                  child: WantText2(
                                      text: widget.Category_name,
                                      fontSize: Responsive.getFontSize(18),
                                      fontWeight: AppFontWeight.medium,
                                      textColor: textBlack),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: Responsive.getHeight(16)),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: Responsive.getWidth(20)),
                          child: SizedBox(
                            height: Responsive.getHeight(100),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: ListView.builder(
                                  shrinkWrap: true,
                                  scrollDirection: Axis.horizontal,
                                  itemCount: subCategories.length,
                                  itemBuilder: (context, index) {
                                    final category = subCategories[index];
                                    final bgColor = getRandomBackgroundColor();
                                    final isSelected = selectedSubCategoryId ==
                                        category.subCategoryId;
                                    final textColor =
                                        getContrastTextColor(bgColor);
                                    return Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            print(
                                                "SubCategoryId: ${category.subCategoryId.toString()}");
                                            setState(() {
                                              selectedSubCategoryId = category
                                                  .subCategoryId
                                                  .toString();
                                              artData = fetchCategoryProducts(
                                                  category.subCategoryId
                                                      .toString()); // Fetch new products
                                            });
                                          },
                                          child: Container(
                                            width: Responsive.getWidth(50),
                                            height: Responsive.getWidth(70),
                                            margin: EdgeInsets.only(
                                                right: index ==
                                                        subCategories.length - 1
                                                    ? 0
                                                    : 25),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Container(
                                                  width:
                                                      Responsive.getWidth(48),
                                                  height:
                                                      Responsive.getWidth(48),
                                                  // padding: EdgeInsets.all(8),
                                                  decoration: BoxDecoration(
                                                    color: bgColor
                                                        .withOpacity(0.5),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                  ),
                                                  child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              30),
                                                      child: Center(
                                                        child: WantText2(
                                                            text: category
                                                                    .subCategoryName[
                                                                0],
                                                            fontSize: Responsive
                                                                .getFontSize(
                                                                    20),
                                                            fontWeight:
                                                                AppFontWeight
                                                                    .bold,
                                                            textColor:
                                                                textColor),
                                                      )
                                                      // Image.network(
                                                      //   category.subCategoryName[0],
                                                      //   fit: BoxFit.fill,
                                                      // ),
                                                      ),
                                                ),
                                                SizedBox(
                                                    height:
                                                        Responsive.getHeight(
                                                            4)),
                                                WantText2(
                                                  text:
                                                      category.subCategoryName,
                                                  fontSize:
                                                      Responsive.getFontSize(
                                                          12),
                                                  fontWeight:
                                                      AppFontWeight.regular,
                                                  textColor: isSelected
                                                      ? Colors.blue
                                                      : Colors.black,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  }),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: Responsive.getHeight(250),
                        ),
                        Image.asset(
                          "assets/category.png",
                          width: Responsive.getWidth(64),
                          height: Responsive.getWidth(64),
                        ),
                        SizedBox(
                          height: Responsive.getHeight(24),
                        ),
                        WantText2(
                            text: "No Category Item!",
                            fontSize: Responsive.getFontSize(20),
                            fontWeight: AppFontWeight.semiBold,
                            textColor: textGray17),
                      ],
                    ),
                  ),
                );
              }

              final artItems = snapshot.data ?? [];

              return SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: Responsive.getWidth(20)),
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
                            artItems.length == 0
                                ? Flexible(
                                  child: Center(
                                      child: WantText2(
                                          text: widget.Category_name,
                                          fontSize: Responsive.getFontSize(18),
                                          fontWeight: AppFontWeight.medium,
                                          textColor: textBlack),
                                    ),
                                )
                                : Flexible(
                                    child: Center(
                                      child: WantText2(
                                          text: artItems[0]
                                                      .category
                                                      .subCategory ==
                                                  null
                                              ? widget.Category_name
                                              : artItems[0]
                                                  .category
                                                  .subCategory!
                                                  .subCategoryName,
                                          fontSize: Responsive.getFontSize(18),
                                          fontWeight: AppFontWeight.medium,
                                          textColor: textBlack),
                                    ),
                                  ),
                          ],
                        ),
                      ),
                      SizedBox(height: Responsive.getHeight(16)),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: Responsive.getWidth(20)),
                        child: SizedBox(
                          height: Responsive.getHeight(100),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: ListView.builder(
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                itemCount: subCategories.length,
                                itemBuilder: (context, index) {
                                  final category = subCategories[index];
                                  final bgColor = getRandomBackgroundColor();
                                  final isSelected = selectedSubCategoryId ==
                                      category.subCategoryId;
                                  final textColor =
                                      getContrastTextColor(bgColor);
                                  return Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          print(
                                              "SubCategoryId: ${category.subCategoryId.toString()}");
                                          setState(() {
                                            selectedSubCategoryId = category
                                                .subCategoryId
                                                .toString();
                                            artData = fetchCategoryProducts(category
                                                .subCategoryId
                                                .toString()); // Fetch new products
                                          });
                                        },
                                        child: Container(
                                          width: Responsive.getWidth(50),
                                          height: Responsive.getWidth(70),
                                          margin: EdgeInsets.only(
                                              right: index ==
                                                      subCategories.length - 1
                                                  ? 0
                                                  : 25),
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
                                                  color:
                                                      bgColor.withOpacity(0.5),
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                ),
                                                child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                    child: Center(
                                                      child: WantText2(
                                                          text: category
                                                                  .subCategoryName[
                                                              0],
                                                          fontSize: Responsive
                                                              .getFontSize(20),
                                                          fontWeight:
                                                              AppFontWeight
                                                                  .bold,
                                                          textColor: textColor),
                                                    )
                                                    // Image.network(
                                                    //   category.subCategoryName[0],
                                                    //   fit: BoxFit.fill,
                                                    // ),
                                                    ),
                                              ),
                                              SizedBox(
                                                  height:
                                                      Responsive.getHeight(4)),
                                              WantText2(
                                                text: category.subCategoryName,
                                                fontSize:
                                                    Responsive.getFontSize(12),
                                                fontWeight:
                                                    AppFontWeight.regular,
                                                textColor: isSelected
                                                    ? Colors.blue
                                                    : Colors.black,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }),
                          ),
                        ),
                      ),
                      SizedBox(height: Responsive.getHeight(16)),
                      _buildProductGrid(artItems),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProductGrid(List<CustomerAllArtModel> artItems) {
    return SizedBox(
      width: Responsive.getMainWidth(context),
      child: artItems.length == 0
          ? Column(
              children: [
                SizedBox(
                  height: Responsive.getHeight(250),
                ),
                Image.asset(
                  "assets/category.png",
                  width: Responsive.getWidth(64),
                  height: Responsive.getWidth(64),
                ),
                SizedBox(
                  height: Responsive.getHeight(24),
                ),
                WantText2(
                    text: "No Category Item!",
                    fontSize: Responsive.getFontSize(20),
                    fontWeight: AppFontWeight.semiBold,
                    textColor: textGray17),
              ],
            )
          : Center(
              child: Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: Responsive.getWidth(20)),
                child: StaggeredGridView.countBuilder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: artItems.length,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 20,
                    crossAxisCount: 4,
                    staggeredTileBuilder: (index) => StaggeredTile.fit(2),
                    itemBuilder: (context, index) {
                      final art = artItems[index];
                      return Center(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => SingleProductDetailScreen(
                                        artUniqueId: art.artUniqueId)));
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: Responsive.getHeight(174),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                      Responsive.getWidth(16)),
                                  // image: DecorationImage(
                                  //   image: NetworkImage(
                                  //       art.artImages[0].image),
                                  //   fit: BoxFit.fill,
                                  // ),
                                ),
                                child: art.artImages.length == 0
                                    ? Center(
                                        child: WantText2(
                                            text: art.title,
                                            fontSize:
                                                Responsive.getFontSize(20),
                                            fontWeight: AppFontWeight.bold,
                                            textColor: black),
                                      )
                                    : ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: Image.network(
                                          art.artImages[0].image,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                              ),
                              SizedBox(height: Responsive.getHeight(6)),
                              Container(
                                height: Responsive.getHeight(59),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
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
                    }),
              ),
            ),
    );
  }
}
