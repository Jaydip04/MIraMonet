import 'package:artist/view/user_side/profile_screen/profile_screens/full_screen_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../config/colors.dart';
import '../../../core/api_service/api_service.dart';
import '../../../core/models/gallery_model.dart';
import '../../../core/utils/app_font_weight.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/custom_text_2.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  late Future<Gallery> futureGallery;

  @override
  void initState() {
    super.initState();
    futureGallery = ApiService().fetchGalleryData();
  }

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
        centerTitle: false,
        title: Text(
          "Gallery",
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
                    Navigator.pushNamed(
                      context,
                      '/User/Notification',
                    );
                  },
                  child: Padding(
                    padding: EdgeInsets.only(right: 16),
                    child: Stack(
                      children: [
                        Container(
                          padding: EdgeInsets.all(6),
                          width: Responsive.getWidth(32),
                          height: Responsive.getWidth(32),
                          decoration: BoxDecoration(
                            color: Color.fromRGBO(249, 250, 251, 1),
                            boxShadow: [
                              BoxShadow(
                                color: Color.fromRGBO(0, 0, 0, 0.05),
                                spreadRadius: 0,
                                offset: Offset(0, 1),
                                blurRadius: 2,
                              ),
                            ],
                            borderRadius:
                                BorderRadius.circular(Responsive.getWidth(8)),
                            border: Border.all(
                              width: 1,
                              color: Color.fromRGBO(0, 0, 0, 0.05),
                            ),
                          ),
                          child: Image.asset(
                            "assets/bell_blank.png",
                            width: Responsive.getWidth(24),
                            height: Responsive.getHeight(24),
                          ),
                        ),
                        // Positioned(
                        //   top: 0,
                        //   right: 0,
                        //   child: Container(
                        //     width: 15,
                        //     height: 15,
                        //     decoration: BoxDecoration(
                        //         color: Colors.red,
                        //         borderRadius: BorderRadius.circular(30)),
                        //     child: Center(
                        //       child: WantText2(
                        //         text: "1",
                        //         fontSize: Responsive.getWidth(10),
                        //         fontWeight: AppFontWeight.bold,
                        //         textColor: white,
                        //       ),
                        //     ),
                        //   ),
                        // )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: FutureBuilder<Gallery>(
        future: futureGallery,
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
            return Center(child: Text('No data available'));
          } else if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.galleryPageContent!.length,
              itemBuilder: (context, index) {
                final content = snapshot.data!.galleryPageContent![index];
                return Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: Responsive.getWidth(10)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ..._interleaveImagesAndParagraphs(
                          content.galleryImagesData!, content.galleryParasData!),
                    ],
                  ),
                );
              },
            );
          } else {
            return Center(child: Text('No data available'));
          }
        },
      ),
    );
  }

  List<Widget> _interleaveImagesAndParagraphs(
      List<GalleryImage> images, List<GalleryParagraph> paragraphs) {
    List<Widget> interleavedList = [];
    int itemCount =
    images.length > paragraphs.length ? paragraphs.length : images.length;

    for (int i = 0; i < itemCount; i++) {
      if (i < images.length) {
        interleavedList.add(
          GestureDetector(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (_) => FullScreenImage(image:  images[i].image!)));
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(Responsive.getWidth(10)),
              child: Image.network(
                images[i].image!,
                width: double.infinity,
                fit: BoxFit.contain,
              ),
            ),
          ),
        );
      }
      if (i < paragraphs.length && paragraphs[i].paragraph != null) {
        interleavedList.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              paragraphs[i].paragraph!,
              style: GoogleFonts.poppins(
                letterSpacing: 1.5,
                color: textGray11,
                fontSize: Responsive.getFontSize(12),
                fontWeight: AppFontWeight.regular,
              ),
            ),
          ),
        );
      }
    }

    return interleavedList;
  }

// List<Widget> _interleaveImagesAndParagraphs(
  //     List<GalleryImage> images, List<GalleryParagraph> paragraphs) {
  //   List<Widget> interleavedList = [];
  //   int itemCount =
  //       images.length > paragraphs.length ? paragraphs.length : images.length;
  //
  //   for (int i = 0; i < itemCount; i++) {
  //     if (i < images.length) {
  //       interleavedList.add(
  //         ClipRRect(
  //           borderRadius: BorderRadius.circular(Responsive.getWidth(10)),
  //           child: Image.network(
  //             // height: Responsive.getHeight(300),
  //             width: double.infinity,
  //             images[i].image!,
  //             fit: BoxFit.contain,
  //           ),
  //         ),
  //       );
  //     }
  //     if (i < paragraphs.length) {
  //       interleavedList.add(
  //         Padding(
  //           padding: const EdgeInsets.symmetric(vertical: 8.0),
  //           child: Text(
  //             paragraphs[i].paragraph!,
  //             style: GoogleFonts.poppins(
  //               letterSpacing: 1.5,
  //               color: textGray11,
  //               fontSize: Responsive.getFontSize(12),
  //               fontWeight: AppFontWeight.regular,
  //             ),
  //           ),
  //         ),
  //       );
  //     }
  //   }
  //
  //   return interleavedList;
  // }
}
