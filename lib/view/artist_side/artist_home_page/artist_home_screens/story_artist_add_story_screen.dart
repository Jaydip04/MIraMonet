// import 'package:artist/core/api_service/api_service.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../../../../config/colors.dart';
// import '../../../../core/utils/app_font_weight.dart';
// import '../../../../core/utils/responsive.dart';
// import '../../../../core/widgets/custom_text_2.dart';
//
// class StoryArtistAddStoryScreen extends StatefulWidget {
//   final artUniqueID;
//   const StoryArtistAddStoryScreen({super.key, required this.artUniqueID});
//
//   @override
//   State<StoryArtistAddStoryScreen> createState() =>
//       _StoryArtistAddStoryScreenState();
// }
//
// class _StoryArtistAddStoryScreenState extends State<StoryArtistAddStoryScreen> {
//   // var artUniqueID;
//   TextEditingController _storyController = TextEditingController();
//
//   Future<String?> getArtUniqueId() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     return prefs.getString('artUniqueId');
//   }
//
//   // void initState() {
//   //   super.initState();
//   //   // getArtUniqueId().then((artUniqueId) {
//   //   //   if (artUniqueId != null) {
//   //   //     setState(() {
//   //   //       artUniqueID = artUniqueId;
//   //   //     });
//   //   //     print("Retrieved Art Unique ID: $artUniqueId");
//   //   //   }
//   //   // });
//   // }
//
//   @override
//   void dispose() {
//     _storyController.dispose();
//     super.dispose();
//   }
//
//   bool isClick = false;
//   Future<void> removeArtUniqueId() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.remove('artUniqueId');
//   }
//
//   int _charCount = 0;
//
//   @override
//   void initState() {
//     super.initState();
//     _storyController.addListener(() {
//       setState(() {
//         _charCount = _storyController.text.length;
//       });
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     Responsive.init(context);
//     return WillPopScope(
//       onWillPop: () async {
//         return false;
//       },
//       child: Scaffold(
//         backgroundColor: white,
//         body: SafeArea(
//           child: Padding(
//             padding: EdgeInsets.symmetric(horizontal: Responsive.getWidth(16)),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     GestureDetector(
//                       onTap: () => Navigator.pop(context),
//                       child: Container(
//                         width: Responsive.getWidth(41),
//                         height: Responsive.getHeight(41),
//                         decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius:
//                                 BorderRadius.circular(Responsive.getWidth(12)),
//                             border: Border.all(
//                                 color: textFieldBorderColor, width: 1.0)),
//                         child: Icon(
//                           Icons.arrow_back_ios_new_outlined,
//                           size: Responsive.getWidth(19),
//                         ),
//                       ),
//                     ),
//                     WantText2(
//                         text: "Art Story",
//                         fontSize: Responsive.getFontSize(18),
//                         fontWeight: AppFontWeight.medium,
//                         textColor: textBlack),
//                     SizedBox(
//                       width: Responsive.getWidth(10),
//                     )
//                   ],
//                 ),
//                 SizedBox(
//                   height: Responsive.getHeight(22),
//                 ),
//                 WantText2(
//                     text: "Art Story",
//                     fontSize: Responsive.getFontSize(16),
//                     fontWeight: AppFontWeight.medium,
//                     textColor: textBlack11),
//                 SizedBox(
//                   height: Responsive.getHeight(4),
//                 ),
//                 // Flexible(
//                 //   child: Align(
//                 //     alignment: Alignment.topLeft,
//                 //     child: TextField(
//                 //
//                 //       controller: _storyController,
//                 //       maxLines: 10,
//                 //       maxLength: 1000,
//                 //       onChanged: (text) {
//                 //         if (text.length > 1000) {
//                 //           setState(() {
//                 //             _storyController.text = text.substring(0, 1000);
//                 //             _storyController.selection = TextSelection.fromPosition(
//                 //               TextPosition(offset: _storyController.text.length),
//                 //             );
//                 //           });
//                 //         }
//                 //       },
//                 //       style: GoogleFonts.poppins(
//                 //         letterSpacing: 1.5,
//                 //         color: textBlack,
//                 //         fontSize: Responsive.getFontSize(15),
//                 //         fontWeight: AppFontWeight.medium,
//                 //       ),
//                 //       cursorColor: black,
//                 //       decoration: InputDecoration(
//                 //         hintText: "Enter Art Story",
//                 //         hintStyle: GoogleFonts.poppins(
//                 //           letterSpacing: 1.5,
//                 //           color: textGray,
//                 //           fontSize: 14.0,
//                 //           fontWeight: FontWeight.normal,
//                 //         ),
//                 //         counterText: "${_storyController.text.length}/1000",
//                 //         counterStyle: TextStyle(color: Colors.grey),
//                 //         isDense: true,
//                 //         errorMaxLines: 3,
//                 //         // counterText: "",
//                 //         focusedErrorBorder: OutlineInputBorder(
//                 //           borderRadius: BorderRadius.all(
//                 //             Radius.circular(
//                 //               Responsive.getWidth(8),
//                 //             ),
//                 //           ),
//                 //           borderSide: BorderSide.none,
//                 //         ),
//                 //         errorBorder: OutlineInputBorder(
//                 //           borderRadius: BorderRadius.all(
//                 //             Radius.circular(
//                 //               Responsive.getWidth(8),
//                 //             ),
//                 //           ),
//                 //           borderSide: BorderSide(color: Colors.red, width: 1),
//                 //         ),
//                 //         border: OutlineInputBorder(
//                 //           borderRadius: BorderRadius.all(
//                 //             Radius.circular(
//                 //               Responsive.getWidth(8),
//                 //             ),
//                 //           ),
//                 //           borderSide: BorderSide(
//                 //               color: textFieldBorderColor ?? Colors.transparent,
//                 //               width: 1),
//                 //         ),
//                 //         enabledBorder: OutlineInputBorder(
//                 //           borderRadius: BorderRadius.all(
//                 //             Radius.circular(
//                 //               Responsive.getWidth(8),
//                 //             ),
//                 //           ),
//                 //           borderSide: BorderSide(
//                 //               color: textFieldBorderColor ?? Colors.transparent,
//                 //               width: 1),
//                 //         ),
//                 //         focusedBorder: OutlineInputBorder(
//                 //           borderRadius: BorderRadius.all(
//                 //             Radius.circular(
//                 //               Responsive.getWidth(8),
//                 //             ),
//                 //           ),
//                 //           borderSide: BorderSide(
//                 //               color: textFieldBorderColor ?? Colors.transparent,
//                 //               width: 1),
//                 //         ),
//                 //       ),
//                 //     ),
//                 //   ),
//                 // ),
//                 Flexible(
//                   child: Align(
//                     alignment: Alignment.topLeft,
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         TextField(
//                           controller: _storyController,
//                           maxLines: _charCount == 330 ? null : 10,
//                           maxLength: 1000,
//                           style: GoogleFonts.poppins(
//                             letterSpacing: 1.5,
//                             color: textBlack,
//                             fontSize: Responsive.getFontSize(15),
//                             fontWeight: AppFontWeight.medium,
//                           ),
//                           cursorColor: black,
//                           decoration: InputDecoration(
//                             hintText: "Enter Art Story",
//                             hintStyle: GoogleFonts.poppins(
//                               letterSpacing: 1.5,
//                               color: textGray,
//                               fontSize: 14.0,
//                               fontWeight: FontWeight.normal,
//                             ),
//                             counterText:
//                                 "$_charCount/1000", // Live character count
//                             counterStyle: TextStyle(color: Colors.grey),
//                             isDense: true,
//                             errorMaxLines: 3,
//                             focusedErrorBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.all(
//                                 Radius.circular(Responsive.getWidth(8)),
//                               ),
//                               borderSide: BorderSide.none,
//                             ),
//                             errorBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.all(
//                                 Radius.circular(Responsive.getWidth(8)),
//                               ),
//                               borderSide:
//                                   BorderSide(color: Colors.red, width: 1),
//                             ),
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.all(
//                                 Radius.circular(Responsive.getWidth(8)),
//                               ),
//                               borderSide: BorderSide(
//                                   color: textFieldBorderColor ??
//                                       Colors.transparent,
//                                   width: 1),
//                             ),
//                             enabledBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.all(
//                                 Radius.circular(Responsive.getWidth(8)),
//                               ),
//                               borderSide: BorderSide(
//                                   color: textFieldBorderColor ??
//                                       Colors.transparent,
//                                   width: 1),
//                             ),
//                             focusedBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.all(
//                                 Radius.circular(Responsive.getWidth(8)),
//                               ),
//                               borderSide: BorderSide(
//                                   color: textFieldBorderColor ??
//                                       Colors.transparent,
//                                   width: 1),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 SizedBox(
//                     height:
//                         16.0), // Spacing between the TextField and the button
//                 Align(
//                   alignment: Alignment.center,
//                   child: GestureDetector(
//                     onTap: () async {
//                       print("artUniqueID : ${widget.artUniqueID}");
//                       print("story : ${_storyController.text.toString()}");
//                       setState(() {
//                         isClick = true;
//                       });
//                       await ApiService()
//                           .addArtistArtStory(widget.artUniqueID,
//                               _storyController.text.toString())
//                           .then((onValue) {
//                         setState(() {
//                           isClick = false;
//                         });
//                         Navigator.pushNamedAndRemoveUntil(
//                           context,
//                           "/Artist",
//                           (route) => false,
//                         );
//                       });
//                     },
//                     child: Container(
//                       height: Responsive.getHeight(45),
//                       width: Responsive.getMainWidth(context),
//                       child: Container(
//                         decoration: BoxDecoration(
//                           border: Border.all(color: Colors.black),
//                           color: black,
//                           borderRadius:
//                               BorderRadius.circular(Responsive.getWidth(8)),
//                         ),
//                         child: Center(
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             crossAxisAlignment: CrossAxisAlignment.center,
//                             children: [
//                               isClick
//                                   ? Center(
//                                       child: SizedBox(
//                                         height: 20,
//                                         width: 20,
//                                         child: CircularProgressIndicator(
//                                           strokeWidth: 3,
//                                           color: Colors.white,
//                                         ),
//                                       ),
//                                     )
//                                   : Text(
//                                       "ADD STORY",
//                                       style: GoogleFonts.poppins(
//                                         letterSpacing: 1.5,
//                                         textStyle: TextStyle(
//                                           fontSize: Responsive.getFontSize(18),
//                                           color: Colors.white,
//                                           fontWeight: FontWeight.w500,
//                                         ),
//                                       ),
//                                     ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: 16.0),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:artist/core/api_service/api_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../config/colors.dart';
import '../../../../config/toast.dart';
import '../../../../core/utils/app_font_weight.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/custom_text_2.dart';

class StoryArtistAddStoryScreen extends StatefulWidget {
  final String artUniqueID;
  const StoryArtistAddStoryScreen({super.key, required this.artUniqueID});

  @override
  State<StoryArtistAddStoryScreen> createState() =>
      _StoryArtistAddStoryScreenState();
}

class _StoryArtistAddStoryScreenState extends State<StoryArtistAddStoryScreen> {
  TextEditingController _storyController = TextEditingController();
  bool isClick = false;
  int _charCount = 0;

  @override
  void initState() {
    super.initState();
    _storyController.addListener(() {
      setState(() {
        _charCount = _storyController.text.length;
      });
    });
  }

  @override
  void dispose() {
    _storyController.dispose();
    super.dispose();
  }
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        backgroundColor: white,
        body: SafeArea(
          child: Column(
            children: [
              // Top section (Title & Back Button)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: Responsive.getWidth(16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back Button & Title
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
                              borderRadius: BorderRadius.circular(Responsive.getWidth(12)),
                              border: Border.all(color: textFieldBorderColor, width: 1.0),
                            ),
                            child: Icon(
                              Icons.arrow_back_ios_new_outlined,
                              size: Responsive.getWidth(19),
                            ),
                          ),
                        ),
                        WantText2(
                          text: "Art Story",
                          fontSize: Responsive.getFontSize(18),
                          fontWeight: AppFontWeight.medium,
                          textColor: textBlack,
                        ),
                        SizedBox(width: Responsive.getWidth(10)),
                      ],
                    ),
                    SizedBox(height: Responsive.getHeight(22)),

                    // Art Story Label
                    WantText2(
                      text: "Art Story",
                      fontSize: Responsive.getFontSize(16),
                      fontWeight: AppFontWeight.medium,
                      textColor: textBlack11,
                    ),
                    SizedBox(height: Responsive.getHeight(4)),
                  ],
                ),
              ),

              // Scrollable Content (TextField)
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: Responsive.getWidth(16)),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Story TextField
                        TextFormField(
                          controller: _storyController,
                          maxLines:  10, // Dynamic maxLines
                          maxLength: 1000,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Story cannot be empty';
                            }
                            return null;
                          },
                          style: GoogleFonts.poppins(
                            letterSpacing: 1.5,
                            color: textBlack,
                            fontSize: Responsive.getFontSize(15),
                            fontWeight: AppFontWeight.medium,
                          ),
                          cursorColor: black,
                          decoration: InputDecoration(
                            hintText: "Enter Art Story",
                            hintStyle: GoogleFonts.poppins(
                              letterSpacing: 1.5,
                              color: textGray,
                              fontSize: 14.0,
                              fontWeight: FontWeight.normal,
                            ),
                            counterText: "$_charCount/1000", // Live character count
                            counterStyle: TextStyle(color: Colors.grey),
                            isDense: true,
                            errorMaxLines: 3,
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(Responsive.getWidth(8)),
                              ),
                              borderSide: BorderSide.none,
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(Responsive.getWidth(8)),
                              ),
                              borderSide: BorderSide(color: Colors.red, width: 1),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(Responsive.getWidth(8)),
                              ),
                              borderSide: BorderSide(
                                  color: textFieldBorderColor ?? Colors.transparent,
                                  width: 1),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(Responsive.getWidth(8)),
                              ),
                              borderSide: BorderSide(
                                  color: textFieldBorderColor ?? Colors.transparent,
                                  width: 1),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(Responsive.getWidth(8)),
                              ),
                              borderSide: BorderSide(
                                  color: textFieldBorderColor ?? Colors.transparent,
                                  width: 1),
                            ),
                          ),
                        ),
                        SizedBox(height: 16.0),
                      ],
                    ),
                  ),
                ),
              ),

              // Bottom Button (Pinned at Bottom)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: Responsive.getWidth(16), vertical: 12),
                child: GestureDetector(
                  onTap: () async {
                    if (_formKey.currentState!.validate()) {
                      if (_storyController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Please enter your art story.")),
                        );
                        return;
                      }
                      setState(() {
                        isClick = true;
                      });
                      try {
                        await ApiService().addArtistArtStory(
                          widget.artUniqueID,
                          _storyController.text.toString(),
                        );
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          "/Artist",
                              (route) => false,
                        );
                      } catch (e) {
                        print("Error adding story: $e");
                      } finally {
                        setState(() {
                          isClick = false;
                        });
                      }
                    } else {
                      showToast(message: 'Form is invalid');
                      print("Form is invalid");
                    }
                  },
                  child: Container(
                    height: Responsive.getHeight(45),
                    width: Responsive.getMainWidth(context),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      color: black,
                      borderRadius: BorderRadius.circular(Responsive.getWidth(8)),
                    ),
                    child: Center(
                      child: isClick
                          ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: Colors.white,
                        ),
                      )
                          : Text(
                        "ADD STORY",
                        style: GoogleFonts.poppins(
                          letterSpacing: 1.5,
                          textStyle: TextStyle(
                            fontSize: Responsive.getFontSize(18),
                            color: Colors.white,
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
    );
  }
}
