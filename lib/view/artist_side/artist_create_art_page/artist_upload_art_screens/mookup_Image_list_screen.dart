import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../config/colors.dart';
import '../../../../config/toast.dart';
import '../../../../core/api_service/api_service.dart';
import '../../../../core/api_service/base_url.dart';
import '../../../../core/utils/app_font_weight.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/custom_text_2.dart';
import 'package:http/http.dart' as http;

import 'artist_upload_picture_screen.dart';

class MookupImageListScreen extends StatefulWidget {
  final List<String> imageUrls;
  final art_unique_id;

  const MookupImageListScreen(
      {Key? key, required this.imageUrls, required this.art_unique_id})
      : super(key: key);

  @override
  State<MookupImageListScreen> createState() => _MookupImageListScreenState();
}

class _MookupImageListScreenState extends State<MookupImageListScreen> {
  var artUniqueID;
  bool isLoading = false;
  bool isClick = false;
  Future<bool?> showDeleteDialog(BuildContext context, String artUniqueId) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: whiteBack,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          insetPadding:
              EdgeInsets.symmetric(horizontal: Responsive.getWidth(14)),
          child: Container(
            margin: EdgeInsets.all(0),
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: Responsive.getWidth(11),
                    vertical: Responsive.getHeight(24)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Image.asset(
                    //   "assets/dialog_delete.png",
                    //   height: Responsive.getWidth(78),
                    //   width: Responsive.getWidth(78),
                    // ),
                    // SizedBox(height: Responsive.getHeight(12)),
                    // WantText2(
                    //     text: "Delete Art",
                    //     fontSize: Responsive.getFontSize(20),
                    //     fontWeight: AppFontWeight.semiBold,
                    //     textColor: textBlack),
                    // SizedBox(height: Responsive.getHeight(8)),
                    // Text(
                    //   textAlign: TextAlign.center,
                    //   "Are you sure you want to delete this Art?\nThis action cannot be undone.",
                    //   style: GoogleFonts.poppins(
                    //     color: Color.fromRGBO(128, 128, 128, 1),
                    //     fontSize: Responsive.getFontSize(14),
                    //     fontWeight: AppFontWeight.regular,
                    //   ),
                    // ),
                    // SizedBox(height: Responsive.getHeight(24)),
                    Center(
                        child: GestureDetector(
                      onTap: () async {
                        setState(() {
                          isLoading = true;
                        });
                        ApiService apiService = ApiService();
                        final response =
                        await apiService.cancelArtwork(artUniqueId);
                        // final response =
                        //     await ApiService.cancelArtwork(artUniqueId);

                        if (response != null && response['status'] == true) {
                          setState(() {
                            isLoading = false;
                          });
                          removeArtUniqueId();
                          showToast(message: response['message']);
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/Artist',
                            (Route<dynamic> route) => false,
                          );
                          print("Artwork cancelled successfully.");
                        } else {
                          setState(() {
                            isLoading = false;
                          });
                          showToast(
                              message: response?['message'] ??
                                  'Failed to cancel artwork.');
                          print("Failed to cancel artwork.");
                        }
                      },
                      child: Container(
                        height: Responsive.getHeight(44),
                        width: Responsive.getWidth(311),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Color.fromRGBO(217, 45, 32, 1.0),
                            ),
                            color: Color.fromRGBO(217, 45, 32, 1.0),
                            borderRadius: BorderRadius.circular(10),
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
                                        "Discard",
                                        style: GoogleFonts.urbanist(
                                          textStyle: TextStyle(
                                            fontSize:
                                                Responsive.getFontSize(18),
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
                    )),
                    SizedBox(height: Responsive.getHeight(12)),
                    Center(
                        child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        height: Responsive.getHeight(44),
                        width: Responsive.getWidth(311),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Color.fromRGBO(208, 213, 221, 1.0),
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "Cancel",
                                  style: GoogleFonts.urbanist(
                                    textStyle: TextStyle(
                                      fontSize: Responsive.getFontSize(18),
                                      color: Color.fromRGBO(52, 64, 84, 1.0),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> removeArtUniqueId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('artUniqueId');
  }

  Future<String?> getArtUniqueId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('artUniqueId');
  }

  @override
  void dispose() {
    showDeleteDialog(context, artUniqueID.toString());
    super.dispose();
  }

  @override
  void initState() {
    getArtUniqueId().then((artUniqueId) {
      if (artUniqueId != null) {
        setState(() {
          artUniqueID = artUniqueId;
        });
        print("Retrieved Art Unique ID: $artUniqueId");
      }
    });
    super.initState();
  }

  List<String> selectedImages = [];
  void toggleSelection(String imageUrl) {
    setState(() {
      if (selectedImages.contains(imageUrl)) {
        selectedImages.remove(imageUrl);
      } else {
        if (selectedImages.length < 6) {
          selectedImages.add(imageUrl);
        } else {
          showToast(message: "You can only add up to 6 images.");
          // print("");
        }
      }
    });
  }

  Future<void> sendSelectedImages(List<String> selectedImages) async {
    setState(() {
      isClick = true;
    });
    // final String apiUrl = "https://artistai.genixbit.com/select-images/";
    final String apiUrl = "https://ai.miramonet.com/select-images/";

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({"urls": selectedImages}),
      );

      if (response.statusCode == 200) {
        sendMockupImages(widget.art_unique_id, selectedImages);
        final responseData = jsonDecode(response.body);
        print("Response: $responseData");
      } else {
        print("Error: ${response.statusCode}, ${response.body}");
      }
    } catch (e) {
      print("Exception: $e");
    }
  }

  Future<void> sendMockupImages(
      String artUniqueId, List<String> imageUrls) async {
    final String apiUrl = "$serverUrl/mockup_images";

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "art_unique_id": artUniqueId,
          "data": imageUrls,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData["status"] == true) {
          setState(() {
            isClick = false;
          });
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/Artist/ArtistOnlineUploadArtScreen/ArtistAdditionalDetailScreen/ArtistUploadPictureScreen/ArtistReviewArtScreen',
            (Route<dynamic> route) => false,
          );
        }
        print("Response: $responseData");
      } else {
        print("Error: ${response.statusCode}, ${response.body}");
      }
    } catch (e) {
      print("Exception: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // final shouldPop = await showDeleteDialog(context, artUniqueID);
        bool shouldPop = await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return Dialog(
              backgroundColor: whiteBack,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              insetPadding:
                  EdgeInsets.symmetric(horizontal: Responsive.getWidth(14)),
              child: Container(
                margin: EdgeInsets.all(0),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: Responsive.getWidth(11),
                      vertical: Responsive.getHeight(24),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Image.asset(
                        //   "assets/dialog_delete.png",
                        //   height: Responsive.getWidth(78),
                        //   width: Responsive.getWidth(78),
                        // ),
                        // SizedBox(height: Responsive.getHeight(12)),
                        // WantText2(
                        //   text: "Delete Art",
                        //   fontSize: Responsive.getFontSize(20),
                        //   fontWeight: AppFontWeight.semiBold,
                        //   textColor: textBlack,
                        // ),
                        // SizedBox(height: Responsive.getHeight(8)),
                        // Text(
                        //   textAlign: TextAlign.center,
                        //   "Are you sure you want to delete this Art?\nThis action cannot be undone.",
                        //   style: GoogleFonts.poppins(
                        //     color: Color.fromRGBO(128, 128, 128, 1),
                        //     fontSize: Responsive.getFontSize(14),
                        //     fontWeight: AppFontWeight.regular,
                        //   ),
                        // ),
                        // SizedBox(height: Responsive.getHeight(24)),
                        Center(
                          child: GestureDetector(
                            onTap: () async {
                              setState(() {
                                isLoading = true;
                              });
                              ApiService apiService = ApiService();
                              final response =
                              await apiService.cancelArtwork(artUniqueID);
                              // final response =
                              //     await ApiService.cancelArtwork(artUniqueID);

                              if (response != null &&
                                  response['status'] == true) {
                                setState(() {
                                  isLoading = false;
                                });
                                removeArtUniqueId();
                                showToast(message: response['message']);
                                Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  '/Artist',
                                  (Route<dynamic> route) => false,
                                );
                              } else {
                                setState(() {
                                  isLoading = false;
                                });
                                showToast(
                                  message: response?['message'] ??
                                      'Failed to cancel artwork.',
                                );
                              }
                            },
                            child: Container(
                              height: Responsive.getHeight(44),
                              width: Responsive.getWidth(311),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Color.fromRGBO(217, 45, 32, 1.0),
                                ),
                                color: Color.fromRGBO(217, 45, 32, 1.0),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: isLoading
                                    ? CircularProgressIndicator(
                                        strokeWidth: 3,
                                        color: Colors.white,
                                      )
                                    : Text(
                                        "Discard",
                                        style: GoogleFonts.urbanist(
                                          textStyle: TextStyle(
                                            fontSize:
                                                Responsive.getFontSize(18),
                                            color: Colors.white,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: Responsive.getHeight(12)),
                        Center(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context,
                                  false); // Return `false` to cancel navigation
                            },
                            child: Container(
                              height: Responsive.getHeight(44),
                              width: Responsive.getWidth(311),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Color.fromRGBO(208, 213, 221, 1.0),
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  "Cancel",
                                  style: GoogleFonts.urbanist(
                                    textStyle: TextStyle(
                                      fontSize: Responsive.getFontSize(18),
                                      color: Color.fromRGBO(52, 64, 84, 1.0),
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
              ),
            );
          },
        );

        return shouldPop ?? false;
      },
      child: Scaffold(
        backgroundColor: white,
        // appBar: AppBar(title: Text("Uploaded Images")),
        body: SingleChildScrollView(
          child: SafeArea(
            child: Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: Responsive.getWidth(16)),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () =>
                            // Navigator.pop(context),
                            showDeleteDialog(context, artUniqueID.toString()),
                        child: Container(
                          width: Responsive.getWidth(41),
                          height: Responsive.getHeight(41),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(
                                  Responsive.getWidth(12)),
                              border: Border.all(
                                  color: Color.fromRGBO(158, 158, 158, 0.4),
                                  width: 1.0)),
                          child: Icon(
                            Icons.arrow_back_ios_new_outlined,
                            size: Responsive.getWidth(19),
                          ),
                        ),
                      ),
                      // SizedBox(width: Responsive.getWidth(70)),
                      WantText2(
                          text: "Select Mockups",
                          fontSize: Responsive.getFontSize(18),
                          fontWeight: AppFontWeight.medium,
                          textColor: Colors.black),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => ArtistUploadPictureScreen()));
                        },
                        child: WantText2(
                            text: "Skip",
                            fontSize: Responsive.getFontSize(14),
                            fontWeight: AppFontWeight.regular,
                            textColor: Colors.black),
                      )
                    ],
                  ),
                  SizedBox(height: Responsive.getHeight(20)),
                  widget.imageUrls.isEmpty
                      ? Center(child: Text("No images available"))
                      : SizedBox(
                          height: Responsive.getHeight(650),
                          child: ListView.builder(
                            shrinkWrap: true,
                            // physics: NeverScrollableScrollPhysics(),
                            itemCount: widget.imageUrls.length,
                            itemBuilder: (context, index) {
                              final imageUrl = widget.imageUrls[index];
                              final isSelected =
                                  selectedImages.contains(imageUrl);
                              return GestureDetector(
                                onTap: () => toggleSelection(imageUrl),
                                child: Container(
                                  margin: EdgeInsets.only(
                                      bottom: Responsive.getHeight(20)),
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: isSelected
                                              ? Colors.black
                                              : Colors.transparent,
                                          width: Responsive.getWidth(2)),
                                      borderRadius: BorderRadius.circular(
                                          Responsive.getWidth(7))),
                                  // height: Responsive.getHeight(243),
                                  child: ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                          Responsive.getWidth(5)),
                                      child: Stack(
                                        children: [
                                          Image.network(widget.imageUrls[index],
                                              fit: BoxFit.contain),
                                          isSelected
                                              ? Positioned(
                                                  child: Icon(
                                                    Icons
                                                        .radio_button_checked_outlined,
                                                    color: black,
                                                  ),
                                                  top: 10,
                                                  right: 10,
                                                )
                                              : SizedBox(),
                                        ],
                                      )),
                                ),
                              );
                              //   Card(
                              //   margin: EdgeInsets.symmetric(vertical: 8),
                              //   child: Column(
                              //     children: [
                              //       Image.network(widget.imageUrls[index], fit: BoxFit.cover),
                              //       Padding(
                              //         padding: const EdgeInsets.all(8.0),
                              //         child: Text(
                              //           "Image ${index + 1}",
                              //           style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              //         ),
                              //       ),
                              //     ],
                              //   ),
                              // );
                            },
                          ),
                        ),
                  SizedBox(height: Responsive.getHeight(10)),
                  Align(
                    alignment: Alignment.center,
                    child: GestureDetector(
                      onTap: () {
                        print(selectedImages);
                        print(widget.imageUrls);
                        if (selectedImages.length < 3) {
                          showToast(message: "Please select at least 3 images.");
                          // print("object");
                        } else {
                          sendSelectedImages(selectedImages);
                          // print("object1");
                        }
                      },
                      child: Container(
                        height: Responsive.getHeight(45),
                        width: Responsive.getWidth(335),
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
                                        "NEXT",
                                        style: GoogleFonts.poppins(
                                          letterSpacing: 1.5,
                                          textStyle: TextStyle(
                                            fontSize:
                                                Responsive.getFontSize(18),
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
                  SizedBox(height: Responsive.getHeight(20)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
