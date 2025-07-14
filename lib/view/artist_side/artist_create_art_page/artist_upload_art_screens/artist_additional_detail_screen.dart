import 'package:artist/config/colors.dart';
import 'package:artist/core/api_service/api_service.dart';
import 'package:artist/core/widgets/general_button.dart';
import 'package:artist/view/artist_side/artist_create_art_page/artist_upload_art_screens/artist_upload_picture_screen_for_mookup.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../config/toast.dart';
import '../../../../core/models/upload_art_model/addtional__title_model.dart';
import '../../../../core/utils/app_font_weight.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/app_text_form_field.dart';
import '../../../../core/widgets/custom_text_2.dart';

class ArtistAdditionalDetailScreen extends StatefulWidget {
  final category_id;
  const ArtistAdditionalDetailScreen({super.key, required this.category_id});

  @override
  State<ArtistAdditionalDetailScreen> createState() =>
      _ArtistAdditionalDetailScreenState();
}

class _ArtistAdditionalDetailScreenState
    extends State<ArtistAdditionalDetailScreen> {
  final _descriptionController = TextEditingController();
  List<Map<String, dynamic>> artDataList = [];
  List<TextEditingController> controllers = [];
  List<ArtResponse> _artDataList = [];
  int? _selectedArtId;
  String? _selectedArtName;
  var artUniqueID;
  @override
  void initState() {
    super.initState();
    fetchArtData(widget.category_id);
    print("category_id : ${widget.category_id}");
    // _loadArtData();
    getArtUniqueId().then((artUniqueId) {
      if (artUniqueId != null) {
        setState(() {
          artUniqueID = artUniqueId;
        });
        print("Retrieved Art Unique ID: $artUniqueId");
      }
    });
  }

  Future<void> fetchArtData(String categoryId) async {
    try {
      final response = await ApiService.getArtData(categoryId);

      if (response["status"] == true && response["artData"] is List) {
        setState(() {
          artDataList = List<Map<String, dynamic>>.from(response["artData"]);
          controllers =
              List.generate(artDataList.length, (_) => TextEditingController());
        });
      }
    } catch (e) {
      print('Error fetching art data: $e');
    }
  }

  Future<void> submitArtData() async {
    setState(() {
      isClick = true;
    });
    List<Map<String, String>> submittedData = [];

    for (int i = 0; i < artDataList.length; i++) {
      submittedData.add({
        "art_data_id": artDataList[i]["art_data_id"].toString(),
        "description": controllers[i].text
      });
    }

    bool success = await ApiService.submitArtData(artUniqueID, submittedData);

    if (success) {
      setState(() {
        isClick = false;
      });
      if (widget.category_id == "1") {
        print("object");
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => ArtistUploadPictureScreenForMookup()));
      } else {
        setState(() {
          isClick = false;
        });
        Navigator.pushNamed(
          context,
          '/Artist/ArtistOnlineUploadArtScreen/ArtistAdditionalDetailScreen/ArtistUploadPictureScreen',
          // (Route<dynamic> route) => false,
        );
      }

      showToast(message: "Data submitted successfully!");
      // ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(content: Text("Data submitted successfully!"))
      // );
    } else {
      setState(() {
        isClick = false;
      });
      showToast(message: "Failed to submit data");
      // ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(content: Text("Failed to submit data"))
      // );
    }
  }

  Future<void> _loadArtData() async {
    try {
      final fetchedCategories = await ApiService.fetchArtData();
      setState(() {
        _artDataList = fetchedCategories;
      });
    } catch (e) {
      print('Error fetching Art: $e');
      setState(() {});
    }
  }

  Future<String?> getArtUniqueId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('artUniqueId');
  }

  List<Map<String, String>> _additionalDetails = [];

  void _addAdditionalDetails(
      String artUniqueId, String artDataId, String description) async {
    print("Click");
    try {
      final response = await ApiService()
          .addAdditionalDetails(artUniqueId, artDataId, description);
      if (response['status']) {
        setState(() {
          // Clear the existing list to replace it with the new data
          _additionalDetails.clear();

          // Assuming the response contains a list of additional details
          List<dynamic> additionalDetailsList = response['additional_details'];
          for (var details in additionalDetailsList) {
            _additionalDetails.add({
              'title': details['art_data_title'],
              'description': details['description'],
            });
          }
        });
      } else {
        showToast(message: response['message']);
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  bool isClick = false;

  Future<void> removeArtUniqueId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('artUniqueId');
  }

  @override
  void dispose() {
    showDeleteDialog(context, artUniqueID.toString());
    _descriptionController.dispose();
    super.dispose();
  }

  bool isLoading = false;
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
                    // SizedBox(height: Responsive.getHeight(10)),
                    Center(
                        child: GestureDetector(
                      onTap: () async {
                        setState(() {
                          isLoading = true;
                        });
                        ApiService apiService = ApiService();
                        final response =
                            await apiService.cancelArtwork(artUniqueId);

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

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
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
                        // SizedBox(height: Responsive.getHeight(10)),
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
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: Responsive.getWidth(16)),
            child: ListView(
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () =>
                          showDeleteDialog(context, artUniqueID.toString()),
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
                      width: Responsive.getWidth(65),
                    ),
                    WantText2(
                        text: "Art Information",
                        fontSize: Responsive.getFontSize(18),
                        fontWeight: AppFontWeight.medium,
                        textColor: textBlack)
                  ],
                ),
                SizedBox(
                  height: Responsive.getHeight(29),
                ),
                Form(
                  key: _formKey,
                  child: ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: artDataList.length,
                    itemBuilder: (context, index) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              WantText2(
                                text: artDataList[index]["art_data_title"],
                                fontSize: Responsive.getFontSize(16),
                                fontWeight: AppFontWeight.medium,
                                textColor: textBlack11,
                              ),
                              artDataList[index]["required"] == "1"
                                  ? WantText2(
                                      text: "*",
                                      fontSize: Responsive.getFontSize(12),
                                      fontWeight: AppFontWeight.medium,
                                      textColor: Color.fromRGBO(246, 0, 0, 1.0))
                                  : SizedBox(),
                            ],
                          ),
                          SizedBox(height: Responsive.getHeight(4)),
                          AppTextFormField(
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: Responsive.getWidth(18),
                              vertical: Responsive.getHeight(18),
                            ),
                            borderRadius: Responsive.getWidth(8),
                            controller: controllers[
                                index], // Each text field has its own controller
                            borderColor: textFieldBorderColor,
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
                            validator: (value) {
                              if (artDataList[index]["required"] == "1") {
                                if (value == null || value.isEmpty) {
                                  return '${artDataList[index]["art_data_title"]} cannot be empty';
                                }
                                return null;
                              }
                            },
                            hintText:
                                "${artDataList[index]["placeholder"]}",
                          ),
                          SizedBox(height: Responsive.getHeight(13)),
                        ],
                      );
                    },
                  ),
                ),

                // InputDecorator(
                //   decoration: InputDecoration(
                //     isDense: true,
                //     hintText: 'Select',
                //     hintStyle: GoogleFonts.poppins(
                //       letterSpacing: 1.5,
                //       color: textGray,
                //       fontSize: 14.0,
                //       fontWeight: FontWeight.normal,
                //     ),
                //     contentPadding: EdgeInsets.fromLTRB(16, 15, 16, 15),
                //     focusedErrorBorder: OutlineInputBorder(
                //       borderRadius: BorderRadius.all(Radius.circular(10)),
                //       borderSide: BorderSide.none,
                //     ),
                //     errorBorder: OutlineInputBorder(
                //       borderRadius: BorderRadius.all(Radius.circular(10)),
                //       borderSide: const BorderSide(color: Colors.red, width: 1),
                //     ),
                //     border: OutlineInputBorder(
                //       borderRadius: BorderRadius.all(Radius.circular(10)),
                //       borderSide:
                //           BorderSide(color: textFieldBorderColor, width: 1),
                //     ),
                //     enabledBorder: OutlineInputBorder(
                //       borderRadius: BorderRadius.all(Radius.circular(10)),
                //       borderSide:
                //           BorderSide(color: textFieldBorderColor, width: 1),
                //     ),
                //     focusedBorder: OutlineInputBorder(
                //       borderRadius: BorderRadius.all(Radius.circular(10)),
                //       borderSide:
                //           BorderSide(color: textFieldBorderColor, width: 1),
                //     ),
                //   ),
                //   child: DropdownButtonHideUnderline(
                //     child: DropdownButton<String>(
                //       dropdownColor: white,
                //       hint: WantText2(
                //         text: "Select",
                //         fontSize: Responsive.getFontSize(16),
                //         fontWeight: AppFontWeight.regular,
                //         textColor: textBlack11,
                //       ),
                //       icon: Icon(
                //         Icons.keyboard_arrow_down_outlined,
                //         color: Color.fromRGBO(131, 131, 131, 1),
                //         size: Responsive.getWidth(28),
                //       ),
                //       value: _selectedArtName,
                //       isDense: true,
                //       onChanged: (value) {
                //         setState(() {
                //           _selectedArtName = value;
                //
                //           // Find the selected art data ID based on selected name
                //           final selectedArt = _artDataList
                //               .expand((artResponse) => artResponse.artData)
                //               .firstWhere(
                //                   (artData) => artData.artDataTitle == value);
                //
                //           _selectedArtId = selectedArt.artDataId;
                //         });
                //         print("Selected Art ID: $_selectedArtId");
                //         print("Selected Art Name: $_selectedArtName");
                //       },
                //       items: _artDataList.expand((artResponse) {
                //         return artResponse.artData.map((artData) {
                //           return DropdownMenuItem<String>(
                //             value: artData.artDataTitle,
                //             child: WantText2(
                //               text: artData.artDataTitle,
                //               fontSize: Responsive.getFontSize(16),
                //               fontWeight: AppFontWeight.medium,
                //               textColor: textBlack11,
                //             ),
                //           );
                //         });
                //       }).toList(),
                //     ),
                //   ),
                // ),
                // SizedBox(
                //   height: Responsive.getHeight(16),
                // ),
                // WantText2(
                //     text: "Description",
                //     fontSize: Responsive.getFontSize(16),
                //     fontWeight: AppFontWeight.medium,
                //     textColor: textBlack11),
                // SizedBox(
                //   height: Responsive.getHeight(4),
                // ),
                // AppTextFormField(
                //   maxLines: 4,
                //   contentPadding: EdgeInsets.symmetric(
                //       horizontal: Responsive.getWidth(18),
                //       vertical: Responsive.getHeight(18)),
                //   borderRadius: Responsive.getWidth(8),
                //   controller: _descriptionController,
                //   borderColor: textFieldBorderColor,
                //   hintStyle: GoogleFonts.poppins(
                //     letterSpacing: 1.5,
                //     color: textGray,
                //     fontSize: Responsive.getFontSize(15),
                //     fontWeight: AppFontWeight.medium,
                //   ),
                //   textStyle: GoogleFonts.poppins(
                //     letterSpacing: 1.5,
                //     color: textBlack,
                //     fontSize: Responsive.getFontSize(15),
                //     fontWeight: AppFontWeight.medium,
                //   ),
                //   hintText: "text",
                // ),
                // SizedBox(
                //   height: Responsive.getHeight(16),
                // ),
                // Center(
                //   child: GestureDetector(
                //     onTap: () {
                //       _addAdditionalDetails(
                //           artUniqueID,
                //           _selectedArtId.toString(),
                //           _descriptionController.text.toString());
                //     },
                //     child: Container(
                //       height: Responsive.getHeight(28),
                //       width: Responsive.getWidth(115),
                //       child: Container(
                //         decoration: BoxDecoration(
                //           border: Border.all(color: black),
                //           color: black,
                //           borderRadius:
                //               BorderRadius.circular(Responsive.getWidth(5)),
                //         ),
                //         child: Center(
                //           child: Row(
                //             mainAxisAlignment: MainAxisAlignment.center,
                //             crossAxisAlignment: CrossAxisAlignment.center,
                //             children: [
                //               Text(
                //                 "Add to List",
                //                 style: GoogleFonts.poppins(
                //                   letterSpacing: 1.5,
                //                   textStyle: TextStyle(
                //                     fontSize: Responsive.getFontSize(13),
                //                     color: white,
                //                     fontWeight: AppFontWeight.bold,
                //                   ),
                //                 ),
                //               ),
                //             ],
                //           ),
                //         ),
                //       ),
                //     ),
                //   ),
                // ),
                // SizedBox(
                //   height: Responsive.getHeight(25),
                // ),
                // WantText2(
                //     text: "Additional Detail",
                //     fontSize: Responsive.getFontSize(16),
                //     fontWeight: AppFontWeight.regular,
                //     textColor: textBlack),
                // SizedBox(
                //   height: Responsive.getHeight(10),
                // ),
                // Container(
                //   decoration: BoxDecoration(
                //     border: Border.all(color: Colors.grey),
                //     borderRadius: BorderRadius.circular(10),
                //   ),
                //   child: SingleChildScrollView(
                //     child: DataTable(
                //       dataRowHeight: Responsive.getHeight(55),
                //       columnSpacing: 0,
                //       columns: [
                //         DataColumn(
                //           label: Container(
                //             child: WantText2(
                //               text: "Title",
                //               fontSize: Responsive.getFontSize(13),
                //               fontWeight: AppFontWeight.regular,
                //               textColor: textBlack11,
                //             ),
                //             width: Responsive.getWidth(78),
                //           ),
                //         ),
                //         DataColumn(
                //           label: Container(
                //             height: Responsive.getHeight(50),
                //             child: Column(
                //               children: [
                //                 Container(
                //                   decoration: BoxDecoration(color: Colors.grey),
                //                   height: Responsive.getHeight(50),
                //                   width: 1,
                //                 ),
                //               ],
                //             ),
                //           ),
                //         ),
                //         DataColumn(
                //           label: Container(
                //             child: WantText2(
                //               text: "Description",
                //               fontSize: Responsive.getFontSize(13),
                //               fontWeight: AppFontWeight.regular,
                //               textColor: textBlack11,
                //             ),
                //             width: Responsive.getWidth(196),
                //           ),
                //         ),
                //       ],
                //       rows: _additionalDetails.map((detail) {
                //         return DataRow(cells: [
                //           // Title Column
                //           DataCell(Container(
                //             child: WantText2(
                //               text: detail['title']!,
                //               fontSize: Responsive.getFontSize(10),
                //               fontWeight: AppFontWeight.regular,
                //               textColor: textBlack11,
                //             ),
                //             width: Responsive.getWidth(78),
                //             alignment: Alignment.centerLeft,
                //           )),
                //
                //           // Vertical Divider
                //           DataCell(Container(
                //             decoration: BoxDecoration(
                //               color: Colors.grey,
                //               border: Border(
                //                 left:
                //                     BorderSide(color: Colors.grey, width: 1.0),
                //               ),
                //             ),
                //             width: 1,
                //           )),
                //
                //           // Description Column
                //           DataCell(Container(
                //             child: Text(
                //               detail['description']!,
                //               maxLines: 3,
                //               overflow: TextOverflow.ellipsis,
                //               textAlign: TextAlign.start,
                //               style: GoogleFonts.poppins(
                //                 letterSpacing: 1.5,
                //                 color: textBlack11,
                //                 fontSize: Responsive.getFontSize(10),
                //                 fontWeight: AppFontWeight.regular,
                //               ),
                //             ),
                //             width: Responsive.getWidth(196),
                //             height: Responsive.getHeight(50),
                //             alignment: Alignment.centerLeft,
                //           )),
                //         ]);
                //       }).toList(),
                //     ),
                //   ),
                // ),
                // SizedBox(
                //   height: Responsive.getHeight(30),
                // ),
                Align(
                  alignment: Alignment.center,
                  child: GestureDetector(
                    onTap: () {
                      if (_formKey.currentState!.validate()) {
                        submitArtData();
                      } else {
                        showToast(message: 'Form is invalid');
                        print("Form is invalid");
                      }
                    },
                    child: Container(
                      height: Responsive.getHeight(45),
                      width: Responsive.getWidth(331),
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
                SizedBox(
                  height: Responsive.getHeight(20),
                )
                // GeneralButton(
                //   Width: Responsive.getWidth(331),
                //   onTap: () {
                //     submitArtData();
                //     // print("category_id : ${widget.category_id}");
                //     // if (_additionalDetails.isEmpty) {
                //     //   showToast(message: "Add Additional Information");
                //     // } else {
                //
                //     // }
                //   },
                //   label: "Next",
                //   isBoarderRadiusLess: true,
                // )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
