import 'package:artist/view/user_side/home_screen/all_category/single_category/single_category_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../../../config/colors.dart';
import '../../../../core/models/category_model.dart';
import '../../../../core/utils/app_font_weight.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/custom_text_2.dart';

class AllCategoryScreen extends StatelessWidget {
  final List<Category> categories;

  AllCategoryScreen({required this.categories});

  @override
  Widget build(BuildContext context) {
    int maxCategoriesToShow = 8;

    return Scaffold(
      backgroundColor: white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: Responsive.getWidth(16)),
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
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
                    width: Responsive.getWidth(80),
                  ),
                  WantText2(
                      text: "Categories",
                      fontSize: Responsive.getFontSize(18),
                      fontWeight: AppFontWeight.medium,
                      textColor: textBlack)
                ],
              ),
            ),
            SizedBox(
              height: Responsive.getHeight(10),
            ),
            StaggeredGridView.countBuilder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: categories.length,
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
              crossAxisCount: 4,
              staggeredTileBuilder: (index) => StaggeredTile.fit(1),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => SingleCategoryScreen(
                                  Category_id: categories[index].categoryId,
                                  Category_name: categories[index].categoryName,
                                )));
                  },
                  child: Column(
                    children: [
                      Container(
                        width: Responsive.getWidth(60),
                        height: Responsive.getWidth(70),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Container(
                            //   width: Responsive.getWidth(48),
                            //   height: Responsive.getWidth(48),
                            //   decoration: BoxDecoration(
                            //     color: Color.fromRGBO(233, 255, 248, 1),
                            //     borderRadius: BorderRadius.circular(Responsive.getWidth(30)),
                            //   ),
                            //   child: Center(
                            //     child: categories[index].categoryIcon.startsWith('http')
                            //     // Check if categoryIcon is a URL
                            //         ? Image.network(
                            //       categories[index].categoryIcon,
                            //       width: Responsive.getWidth(48),
                            //       height: Responsive.getWidth(48),
                            //       fit: BoxFit.cover,
                            //     )
                            //         : Icon(
                            //       IconData(
                            //         int.parse(categories[index].categoryIcon),
                            //         fontFamily: 'MaterialIcons',
                            //       ),
                            //       color: Color.fromRGBO(103, 196, 167, 1),
                            //       size: Responsive.getWidth(48),
                            //     ),
                            //   )
                            //
                            // ),
                            Container(
                              width: Responsive.getWidth(48),
                              height: Responsive.getWidth(48),
                              // padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Color.fromRGBO(233, 255, 248, 1),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(30),
                                child: Image.network(
                                  categories[index].categoryIcon,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            SizedBox(height: Responsive.getHeight(4)),
                            WantText2(
                              text: categories[index].categoryName,
                              fontSize: Responsive.getFontSize(12),
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
          ],
        ),
      ),
    );
  }
}
