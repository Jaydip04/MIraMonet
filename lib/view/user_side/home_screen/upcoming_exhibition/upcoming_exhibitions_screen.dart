import 'package:artist/view/user_side/home_screen/upcoming_exhibition/single_upcoming_exhibitions/single_upcoming_exhibition_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../config/colors.dart';
import '../../../../core/api_service/api_service.dart';
import '../../../../core/models/user_side/customer_exhibitions_model.dart';
import '../../../../core/utils/app_font_weight.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/custom_text_2.dart';

class UpcomingExhibitionsScreen extends StatefulWidget {
  const UpcomingExhibitionsScreen({super.key});

  @override
  State<UpcomingExhibitionsScreen> createState() =>
      _UpcomingExhibitionsScreenState();
}

class _UpcomingExhibitionsScreenState extends State<UpcomingExhibitionsScreen> {
  late Future<List<CustomerExhibitionsModel>> futureExhibitions;
  @override
  void initState() {
    super.initState();
    futureExhibitions = ApiService().fetchExhibitionsForCustomer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          children: [
            Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: Responsive.getWidth(20)),
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
                    width: Responsive.getWidth(30),
                  ),
                  WantText2(
                      text: "Upcoming Exhibitions",
                      fontSize: Responsive.getFontSize(18),
                      fontWeight: AppFontWeight.medium,
                      textColor: textBlack),
                ],
              ),
            ),
            SizedBox(
              height: Responsive.getHeight(20),
            ),
            Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: Responsive.getWidth(20)),
              child: FutureBuilder<List<CustomerExhibitionsModel>>(
                future: futureExhibitions,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container(
                      child: Center(
                        child: SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                        child: WantText2(
                            text: "No exhibitions found",
                            fontSize: Responsive.getFontSize(16),
                            fontWeight: AppFontWeight.regular,
                            textColor: black));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                        child: Center(
                            child: WantText2(
                                text: "No exhibitions found",
                                fontSize: Responsive.getFontSize(16),
                                fontWeight: AppFontWeight.regular,
                                textColor: black)));
                  }
                  final exhibition = snapshot.data!;
                  return StaggeredGridView.countBuilder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: exhibition.length,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 20,
                    crossAxisCount: 2,
                    staggeredTileBuilder: (index) => StaggeredTile.fit(1),
                    itemBuilder: (context, index) {
                      final item = exhibition[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      SingleUpcomingExhibitionScreen(
                                        exhibition_unique_id:
                                        item.exhibitionUniqueId,
                                      )));
                        },
                        child: Container(
                          // width: Responsive.getWidth(120),
                          // height: Responsive.getHeight(196),
                          // margin: EdgeInsets.only(right: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                // width: Responsive.getWidth(120),
                                height: Responsive.getHeight(150),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  image: DecorationImage(
                                    image: NetworkImage(item.logo),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              SizedBox(height: 6),
                              Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    item.name.toUpperCase(),
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.poppins(
                                        color: Colors.black,
                                        fontSize:
                                        Responsive.getFontSize(12),
                                        fontWeight: AppFontWeight.semiBold,
                                        letterSpacing: 1.5),
                                  ),
                                  SizedBox(height: 3),
                                  Row(
                                    children: [
                                      Icon(Icons.location_on_outlined,
                                          size: 10),
                                      SizedBox(width: 2),
                                      Flexible(
                                        child: Text(
                                          maxLines: 1,
                                          "${item.address1} ${item.city!.nameOfCity} ${item.state.stateSubdivisionName} ${item.country.countryName}",
                                          style: GoogleFonts.poppins(
                                              color: Colors.black
                                                  .withOpacity(0.8),
                                              fontSize:
                                              Responsive.getFontSize(
                                                  10),
                                              fontWeight: FontWeight.normal,
                                              letterSpacing: 1.5),
                                          // TextStyle(
                                          //     fontSize: 10,
                                          //     fontWeight: FontWeight.normal,
                                          //     color: Colors.black.withOpacity(0.8)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                  //   ListView.builder(
                  //   shrinkWrap: true,
                  //   // physics: NeverScrollableScrollPhysics(),
                  //   // controller: _scrollController,
                  //   scrollDirection: Axis.horizontal,
                  //   itemCount: exhibition.length,
                  //   itemBuilder: (context, index) {
                  //     final item = exhibition[index];
                  //     return GestureDetector(
                  //       onTap: () {
                  //         Navigator.push(
                  //             context,
                  //             MaterialPageRoute(
                  //                 builder: (_) =>
                  //                     SingleUpcomingExhibitionScreen(
                  //                       exhibition_unique_id:
                  //                       item.exhibitionUniqueId,
                  //                     )));
                  //       },
                  //       child: Container(
                  //         width: Responsive.getWidth(120),
                  //         // height: Responsive.getHeight(196),
                  //         margin: EdgeInsets.only(right: 20),
                  //         child: Column(
                  //           crossAxisAlignment: CrossAxisAlignment.start,
                  //           children: [
                  //             Container(
                  //               width: Responsive.getWidth(120),
                  //               height: Responsive.getHeight(150),
                  //               decoration: BoxDecoration(
                  //                 borderRadius: BorderRadius.circular(5),
                  //                 image: DecorationImage(
                  //                   image: NetworkImage(item.logo),
                  //                   fit: BoxFit.cover,
                  //                 ),
                  //               ),
                  //             ),
                  //             SizedBox(height: 6),
                  //             Column(
                  //               crossAxisAlignment:
                  //               CrossAxisAlignment.start,
                  //               mainAxisAlignment: MainAxisAlignment.center,
                  //               children: [
                  //                 Text(
                  //                   item.name.toUpperCase(),
                  //                   overflow: TextOverflow.ellipsis,
                  //                   style: GoogleFonts.poppins(
                  //                       color: Colors.black,
                  //                       fontSize:
                  //                       Responsive.getFontSize(12),
                  //                       fontWeight: AppFontWeight.semiBold,
                  //                       letterSpacing: 1.5),
                  //                 ),
                  //                 SizedBox(height: 3),
                  //                 Row(
                  //                   children: [
                  //                     Icon(Icons.location_on_outlined,
                  //                         size: 10),
                  //                     SizedBox(width: 2),
                  //                     Flexible(
                  //                       child: Text(
                  //                         maxLines: 1,
                  //                         "${item.address1} ${item.city.nameOfCity} ${item.state.stateSubdivisionName} ${item.country.countryName}",
                  //                         style: GoogleFonts.poppins(
                  //                             color: Colors.black
                  //                                 .withOpacity(0.8),
                  //                             fontSize:
                  //                             Responsive.getFontSize(
                  //                                 10),
                  //                             fontWeight: FontWeight.normal,
                  //                             letterSpacing: 1.5),
                  //                         // TextStyle(
                  //                         //     fontSize: 10,
                  //                         //     fontWeight: FontWeight.normal,
                  //                         //     color: Colors.black.withOpacity(0.8)),
                  //                       ),
                  //                     ),
                  //                   ],
                  //                 ),
                  //               ],
                  //             ),
                  //           ],
                  //         ),
                  //       ),
                  //     );
                  //   },
                  // );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
