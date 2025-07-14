import 'dart:convert';
import 'dart:io';

import 'package:artist/config/toast.dart';
import 'package:artist/core/widgets/custom_text_2.dart';
import 'package:artist/core/widgets/general_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;

import '../../../../../config/colors.dart';
import '../../../../../core/api_service/base_url.dart';
import '../../../../../core/utils/app_font_weight.dart';
import '../../../../../core/utils/responsive.dart';
import '../../../../../core/widgets/app_text_form_field.dart';

class ReturnOrderScreen extends StatefulWidget {
  final customer_unique_id;
  final art_unique_id;
  final artist_unique_id;
  final fcmToken;
  const ReturnOrderScreen(
      {super.key,
      required this.art_unique_id,
      required this.artist_unique_id,
      required this.fcmToken,
      required this.customer_unique_id});

  @override
  State<ReturnOrderScreen> createState() => ReturnOrderScreenState();
}

class ReturnOrderScreenState extends State<ReturnOrderScreen> {
  TextEditingController _reasonController = TextEditingController();
  TextEditingController _uploadController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final List<File> _images = [];
  final ImagePicker _picker = ImagePicker();

  Future<void> submitChatRequest() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    var uri = Uri.parse("$serverUrl/return_order");
    var request = http.MultipartRequest('POST', uri);

    // Add fields to the request
    request.fields['customer_unique_id'] = customerUniqueID.toString();
    request.fields['art_unique_id'] = widget.art_unique_id.toString() ?? '';
    request.fields['artist_fcm_token'] = widget.fcmToken.toString() ?? '';
    request.fields['artist_unique_id'] =
        widget.artist_unique_id.toString() ?? '';
    request.fields['reason'] = _reasonController.text.toString() ?? '';

    for (var image in _images) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'images[]',
          await image.readAsBytes(),
          filename: image.path.split('/').last,
        ),
      );
    }

    try {
      setState(() {
        isLoading = true;
      });
      var response = await request.send();

      final responseBody = await response.stream.bytesToString();
      final data = jsonDecode(responseBody);
      showToast(message: data["message"]);
      // Print the entire response body
      print('Response body: $responseBody');
      if (response.statusCode == 200) {
        setState(() {
          isLoading = false;
        });
        final responseBody = await response.stream.bytesToString();
        final data = jsonDecode(responseBody);
        print("data : $data");
        if (data["status"] == true) {
          setState(() {
            isLoading = false;
          });
          showToast(message: data["message"]);
          Navigator.pop(context);
          print("Request submitted successfully");
        } else {
          setState(() {
            isLoading = false;
          });
          showToast(message: data["message"]);
          Navigator.pop(context);
          print("Error: ${data["message"]}");
        }
      } else {
        Navigator.pop(context);
        setState(() {
          isLoading = false;
        });
        print("Error: ${response.statusCode}");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      Navigator.pop(context);
      print("Error submitting request: $e");
    }
  }

  Future<List<String>> _prepareImages(List<File> images) async {
    List<String> base64Images = [];

    for (var image in images) {
      List<int> imageBytes = await image.readAsBytes();
      String base64Image = base64Encode(imageBytes);
      base64Images.add(base64Image);
    }

    return base64Images;
  }

  Future<void> _pickImage() async {
    if (_images.length >= 3) {
      print("You can only select up to 3 images.");
      return;
    }

    try {
      final XFile? pickedFile =
          await _picker.pickImage(source: ImageSource.camera);

      if (pickedFile == null) {
        print("No image selected.");
        return;
      }

      File imageFile = File(pickedFile.path);

      // Check the file size and compress if necessary
      int fileSizeInBytes = await imageFile.length();
      double fileSizeInMB = fileSizeInBytes / (1024 * 1024);

      if (fileSizeInMB > 2) {
        print("Image size is greater than 2 MB. Compressing...");
        File? compressedImage = await _compressImage(imageFile);

        if (compressedImage != null) {
          print("Image compressed successfully.");
          setState(() {
            _images.add(compressedImage);
          });
        } else {
          print("Failed to compress image.");
        }
      } else {
        print(
            "Image size is within the limit: ${fileSizeInMB.toStringAsFixed(2)} MB.");
        setState(() {
          _images.add(imageFile);
        });
      }
    } catch (e) {
      print("Error capturing or compressing image: $e");
    }
  }

  Future<File?> _compressImage(File file) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final targetPath =
          path.join(tempDir.path, "compressed_${path.basename(file.path)}");

      final File? compressedFile =
          await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: 85,
      );

      if (compressedFile == null) {
        throw Exception("Image compression failed.");
      }

      return compressedFile;
    } catch (e) {
      print("Error compressing image: $e");
      return null;
    }
  }

  String? _selectedPurpose;
  List<String> _frame = [];
  List<Map<String, dynamic>> _categories = [];
  String? _selectedCategoryName;
  int? _selectedCategoryId;
  bool isLoading = false;
  Future<void> fetchEnquiryCategories() async {
    const String endpoint =
        "$serverUrl/get_enquiry_category";
    final payload = {"role": "customer"};

    try {
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["status"] == true) {
          setState(() {
            // Store category ID and Name in _categories
            _categories =
                List<Map<String, dynamic>>.from(data["data"].map((item) => {
                      "enquiry_category_id": item["enquiry_category_id"],
                      "enquiry_category_name": item["enquiry_category_name"]
                    }));
          });
        } else {
          print("Error: ${data["message"]}");
        }
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchEnquiryCategories();
    _loadUserData();
  }

  String? customerUniqueID;
  void _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String customerUniqueId = (prefs.get('customerUniqueId') is String)
        ? prefs.getString('customerUniqueId') ?? ''
        : prefs.getInt('customerUniqueId')?.toString() ?? '';

    print(customerUniqueId.toString());
    setState(() {
      customerUniqueID = customerUniqueId;
    });
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
                SizedBox(width: Responsive.getWidth(70)),
                WantText2(
                    text: "Return order",
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
                  Row(
                    children: [
                      WantText2(
                          text: "Reason",
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
                    controller: _reasonController,
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
                    // onChanged: (p0) {
                    //   _formKey.currentState!.validate();
                    // },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Reason cannot be empty';
                      }
                      return null;
                    },
                    hintText: "Enter Reason",
                  ),
                  SizedBox(
                    height: Responsive.getHeight(15),
                  ),
                  Row(
                    children: [
                      WantText2(
                          text: "Supporting document Or Artwork",
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
                    controller: _uploadController,
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
                    suffixIcon: Icon(
                      Icons.camera_alt_outlined,
                      color: Color.fromRGBO(161, 161, 161, 1.0),
                      size: Responsive.getWidth(24),
                    ),
                    readOnly: true,
                    onTap: _images.length < 3 ? _pickImage : null,
                    hintText: "${_images.length} / 3",
                  ),
                  SizedBox(
                    height: Responsive.getHeight(15),
                  ),
                  Row(
                    mainAxisAlignment: _images.length > 2
                        ? MainAxisAlignment.spaceAround
                        : MainAxisAlignment.start,
                    children: _images
                        .map(
                          (image) => Stack(
                            children: [
                              Container(
                                height: Responsive.getHeight(114),
                                width: Responsive.getWidth(107),
                                margin: EdgeInsets.only(
                                    right: _images.length > 2
                                        ? Responsive.getWidth(0)
                                        : Responsive.getWidth(6)),
                                padding: EdgeInsets.all(Responsive.getWidth(5)),
                                decoration: BoxDecoration(
                                  color: Color.fromRGBO(250, 249, 245, 1),
                                  border: Border.all(
                                      color: Color.fromRGBO(158, 158, 158, 0.4),
                                      width: 1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Image.file(image, fit: BoxFit.contain),
                              ),
                              // if (imageUrl != null)
                              Positioned(
                                top: 5,
                                right: 8,
                                child: GestureDetector(
                                  onTap: () {
                                    _images.remove(image);
                                    setState(() {
                                      // _uploadController.text = "${_images.length} / 3";
                                    });
                                    // showCongratulationsDialog(context, index);
                                  },
                                  child: Image.asset(
                                    "assets/artist/upload_page/delete.png",
                                    height: Responsive.getWidth(16),
                                    width: Responsive.getWidth(16),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                        .toList(),
                  ),
                  SizedBox(
                    height: Responsive.getHeight(15),
                  ),
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        if (_images.length > 1) {
                          submitChatRequest();
                        } else {
                          showToast(message: "Add Image First");
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
                                        "SUBMIT REQUEST",
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
                  //   label: "Submit Request",
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

  InputDecoration _inputDecoration(
      FormFieldState<String> state, String hintText) {
    return InputDecoration(
      isDense: true,
      hintText: hintText,
      hintStyle: GoogleFonts.poppins(
        letterSpacing: 1.5,
        color: Color.fromRGBO(131, 145, 161, 1.0),
        fontSize: 14.0,
        fontWeight: FontWeight.normal,
      ),
      contentPadding: EdgeInsets.fromLTRB(16, 15, 16, 15),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide.none,
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide(color: textFieldBorderColor, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide(color: textFieldBorderColor, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide(color: textFieldBorderColor, width: 1),
      ),
      errorText: state.errorText, // Show error message
    );
  }
}
