import 'dart:convert';

import 'package:artist/config/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../config/colors.dart';
import '../../../../core/api_service/base_url.dart';
import '../../../../core/utils/app_font_weight.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/app_text_form_field.dart';
import '../../../../core/widgets/custom_text_2.dart';
import 'package:http/http.dart' as http;

class FeedbackScreen extends StatefulWidget {
  final artName;
  final artistName;
  final artUniqueId;
  final customerUniqueId;
  const FeedbackScreen(
      {super.key,
      required this.artName,
      required this.artistName,
      required this.artUniqueId,
      required this.customerUniqueId});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _leaveController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  double _currentRating = 2.0;

  @override
  void initState() {
    _nameController.text = widget.artName;
    _emailController.text = widget.artistName;
    super.initState();
  }

  Future<void> submitArtFeedback() async {
    // Replace with your API endpoint
    const String url = "$serverUrl/artFeedBack";

    // Payload for the API request
    final Map<String, String> payload = {
      "art_name": widget.artName,
      "artist_name": widget.artistName,
      "art_unique_id": widget.artUniqueId,
      "customer_unique_id": widget.customerUniqueId,
      "rating": _currentRating.toString(),
      "comment": _leaveController.text.toString()
    };

    print(payload);

    try {
      setState(() {
        isLoading = true;
      });
      // Make the POST request
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);

        if (jsonResponse['status'] == true) {
          String message = jsonResponse['message'];
          Map<String, dynamic> data = jsonResponse['data'];

          print("Message: $message");

          showToast(message: message);
          int feedbackId = data['art_feedback_id'];
          String artistName = data['artist_name'];
          String rating = data['rating'];
          String comment = data['comment'];

          print("Feedback ID: $feedbackId");
          print("Artist Name: $artistName");
          print("Rating: $rating");
          print("Comment: $comment");
        } else {
          print("Failed: ${jsonResponse['message']}");
        }
        Navigator.pop(context);
        setState(() {
          isLoading = false;
        });
        print("Feedback submitted successfully!");
        print("Response: ${response.body}");
      } else {
        setState(() {
          isLoading = false;
        });
        print("Failed to submit feedback. Status: ${response.statusCode}");
        print("Error: ${response.body}");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("An error occurred: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return Scaffold(
      backgroundColor: white,
      body: ListView(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: Responsive.getWidth(16)),
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
                SizedBox(width: Responsive.getWidth(80)),
                WantText2(
                    text: "Feedback",
                    fontSize: Responsive.getFontSize(18),
                    fontWeight: AppFontWeight.medium,
                    textColor: textBlack)
              ],
            ),
          ),
          SizedBox(
            height: Responsive.getHeight(16),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: Responsive.getWidth(16)),
            child: Divider(
              color: Color.fromRGBO(230, 230, 230, 1.0),
            ),
          ),
          SizedBox(
            height: Responsive.getHeight(9),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: Responsive.getWidth(16)),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  WantText2(
                      text: "Art Name",
                      fontSize: Responsive.getFontSize(16),
                      fontWeight: AppFontWeight.medium,
                      textColor: textBlack9),
                  SizedBox(
                    height: Responsive.getHeight(5),
                  ),
                  AppTextFormField(
                    fillColor: Color.fromRGBO(247, 248, 249, 1),
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: Responsive.getWidth(18),
                        vertical: Responsive.getHeight(14)),
                    borderRadius: Responsive.getWidth(8),
                    controller: _nameController,
                    borderColor: textFieldBorderColor,
                    readOnly: true,
                    hintStyle: GoogleFonts.urbanist(
                      color: textGray,
                      fontSize: Responsive.getFontSize(15),
                      fontWeight: AppFontWeight.medium,
                    ),
                    textStyle: GoogleFonts.urbanist(
                      color: textBlack,
                      fontSize: Responsive.getFontSize(15),
                      fontWeight: AppFontWeight.medium,
                    ),
                    hintText: "Enter Art Name",
                  ),
                  SizedBox(
                    height: Responsive.getHeight(15),
                  ),
                  WantText2(
                      text: "Artist Name",
                      fontSize: Responsive.getFontSize(16),
                      fontWeight: AppFontWeight.medium,
                      textColor: textBlack9),
                  SizedBox(
                    height: Responsive.getHeight(5),
                  ),
                  AppTextFormField(
                    fillColor: Color.fromRGBO(247, 248, 249, 1),
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: Responsive.getWidth(18),
                        vertical: Responsive.getHeight(14)),
                    borderRadius: Responsive.getWidth(8),
                    controller: _emailController,
                    borderColor: textFieldBorderColor,
                    hintStyle: GoogleFonts.urbanist(
                      color: textGray,
                      fontSize: Responsive.getFontSize(15),
                      fontWeight: AppFontWeight.medium,
                    ),
                    readOnly: true,
                    textStyle: GoogleFonts.urbanist(
                      color: textBlack,
                      fontSize: Responsive.getFontSize(15),
                      fontWeight: AppFontWeight.medium,
                    ),
                    hintText: "Enter Artist Name",
                  ),
                  SizedBox(
                    height: Responsive.getHeight(15),
                  ),
                  Row(
                    children: [
                      WantText2(
                          text: "Leave Comment",
                          fontSize: Responsive.getFontSize(16),
                          fontWeight: AppFontWeight.medium,
                          textColor: textBlack9),
                      WantText2(
                          text: "*",
                          fontSize: Responsive.getFontSize(12),
                          fontWeight: AppFontWeight.medium,
                          textColor: Color.fromRGBO(246, 0, 0, 1.0)),
                    ],
                  ),
                  SizedBox(
                    height: Responsive.getHeight(5),
                  ),
                  AppTextFormField(
                    fillColor: Color.fromRGBO(247, 248, 249, 1),
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: Responsive.getWidth(18),
                        vertical: Responsive.getHeight(14)),
                    borderRadius: Responsive.getWidth(8),
                    controller: _leaveController,
                    borderColor: textFieldBorderColor,
                    hintStyle: GoogleFonts.urbanist(
                      color: textGray,
                      fontSize: Responsive.getFontSize(15),
                      fontWeight: AppFontWeight.medium,
                    ),
                    maxLines: 10,
                    textStyle: GoogleFonts.urbanist(
                      color: textBlack,
                      fontSize: Responsive.getFontSize(15),
                      fontWeight: AppFontWeight.medium,
                    ),
                    // keyboardType: TextInputType.numberWithOptions(
                    //     signed: true, decimal: true),
                    // onChanged: (p0) {
                    //   _formKey.currentState!.validate();
                    // },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Leave Comment cannot be empty';
                      }
                      return null;
                    },
                    hintText: "Enter Leave comment",
                  ),
                  SizedBox(
                    height: Responsive.getHeight(15),
                  ),
                  Center(
                    child: RatingBar.builder(
                      initialRating: _currentRating,
                      minRating: 1,
                      itemSize: 50,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                      itemBuilder: (context, _) => Icon(
                        Icons.star_rounded,
                        size: 50,
                        color: Color.fromRGBO(253, 219, 0, 1.0),
                      ),
                      unratedColor: Color.fromRGBO(217, 217, 217, 1.0),
                      onRatingUpdate: (rating) {
                        setState(() {
                          _currentRating = rating;
                        });
                        print("Rating: $rating");
                      },
                    ),
                  ),
                  SizedBox(
                    height: Responsive.getHeight(40),
                  ),
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        if (_formKey.currentState!.validate()) {
                          submitArtFeedback();
                        }
                        // submitChatRequest();
                      },
                      child: Container(
                        height: Responsive.getHeight(50),
                        width: Responsive.getWidth(354),
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
                                isLoading
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
                                        "FEEDBACK SUBMIT",
                                        style: GoogleFonts.poppins(
                                          letterSpacing: 1.5,
                                          textStyle: TextStyle(
                                            fontSize:
                                                Responsive.getFontSize(18),
                                            letterSpacing: 1.5,
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
                  // GeneralButton(
                  //   Width: Responsive.getWidth(354),
                  //   onTap: () {
                  //     submitChatRequest();
                  //   },
                  //   label: "",
                  //   isBoarderRadiusLess: true,
                  // ),
                  SizedBox(
                    height: Responsive.getHeight(10),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
