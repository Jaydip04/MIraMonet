import 'package:artist/core/api_service/api_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../config/colors.dart';
import '../../../../config/toast.dart';
import '../../../../core/utils/app_font_weight.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/custom_text_2.dart';

class ArtistAddStoryScreen extends StatefulWidget {
  const ArtistAddStoryScreen({super.key});

  @override
  State<ArtistAddStoryScreen> createState() => _ArtistAddStoryScreenState();
}

class _ArtistAddStoryScreenState extends State<ArtistAddStoryScreen> {
  var artUniqueID;
  TextEditingController _storyController = TextEditingController();

  Future<String?> getArtUniqueId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('artUniqueId');
  }

  void initState() {
    super.initState();
    getArtUniqueId().then((artUniqueId) {
      if (artUniqueId != null) {
        setState(() {
          artUniqueID = artUniqueId;
        });
        print("Retrieved Art Unique ID: $artUniqueId");
      }
    });
  }

  @override
  void dispose() {
    _storyController.dispose();
    super.dispose();
  }

  bool isClick = false;
  Future<void> removeArtUniqueId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('artUniqueId');
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
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: Responsive.getWidth(16)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: Responsive.getWidth(41),
                      height: Responsive.getHeight(41),
                    ),
                    WantText2(
                        text: "Art Story",
                        fontSize: Responsive.getFontSize(18),
                        fontWeight: AppFontWeight.medium,
                        textColor: textBlack),
                    GestureDetector(
                      onTap: () {
                        removeArtUniqueId().then((onValue) {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/Artist',
                            (Route<dynamic> route) => false,
                          );
                        });
                      },
                      child: WantText2(
                          text: "Skip",
                          fontSize: Responsive.getFontSize(13),
                          fontWeight: AppFontWeight.medium,
                          textColor: Color.fromRGBO(94, 101, 110, 1.0)),
                    )
                  ],
                ),
                SizedBox(
                  height: Responsive.getHeight(22),
                ),
                WantText2(
                    text: "Art Story",
                    fontSize: Responsive.getFontSize(16),
                    fontWeight: AppFontWeight.medium,
                    textColor: textBlack11),
                SizedBox(
                  height: Responsive.getHeight(4),
                ),
                Flexible(
                  child: Form(
                    key: _formKey,
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: TextFormField(
                        controller: _storyController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Story cannot be empty';
                          }
                          return null;
                        },
                        maxLines: null,
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
                          isDense: true,
                          errorMaxLines: 3,
                          counterText: "",
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(
                                Responsive.getWidth(8),
                              ),
                            ),
                            borderSide: BorderSide.none,
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(
                                Responsive.getWidth(8),
                              ),
                            ),
                            borderSide: BorderSide(color: Colors.red, width: 1),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(
                                Responsive.getWidth(8),
                              ),
                            ),
                            borderSide: BorderSide(
                                color:
                                    textFieldBorderColor ?? Colors.transparent,
                                width: 1),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(
                                Responsive.getWidth(8),
                              ),
                            ),
                            borderSide: BorderSide(
                                color:
                                    textFieldBorderColor ?? Colors.transparent,
                                width: 1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(
                                Responsive.getWidth(8),
                              ),
                            ),
                            borderSide: BorderSide(
                                color:
                                    textFieldBorderColor ?? Colors.transparent,
                                width: 1),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                    height:
                        16.0), // Spacing between the TextField and the button
                Align(
                  alignment: Alignment.center,
                  child: GestureDetector(
                    onTap: () async {
                      if (_formKey.currentState!.validate()) {
                        print("artUniqueID : $artUniqueID");
                        print("story : ${_storyController.text.toString()}");
                        setState(() {
                          isClick = true;
                        });
                        await ApiService()
                            .addArtistArtStory(
                                artUniqueID, _storyController.text.toString())
                            .then((onValue) {
                          setState(() {
                            isClick = false;
                          });
                          removeArtUniqueId().then((onValue) {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/Artist',
                              (Route<dynamic> route) => false,
                            );
                          });
                        });
                      } else {
                        showToast(message: 'Form is invalid');
                        print("Form is invalid");
                      }
                    },
                    child: Container(
                      height: Responsive.getHeight(45),
                      width: Responsive.getMainWidth(context),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          color: black,
                          borderRadius:
                              BorderRadius.circular(Responsive.getWidth(8)),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              isClick
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
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
