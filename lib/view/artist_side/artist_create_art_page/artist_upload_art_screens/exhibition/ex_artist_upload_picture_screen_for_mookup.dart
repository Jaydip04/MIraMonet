import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as path;

import '../../../../../config/colors.dart';
import '../../../../../config/toast.dart';
import '../../../../../core/api_service/api_service.dart';
import '../../../../../core/utils/app_font_weight.dart';
import '../../../../../core/utils/responsive.dart';
import '../../../../../core/widgets/custom_text_2.dart';
import 'artist_upload_picture_for_exhibition_screen.dart';
import 'ex_mookup_Image_list_screen.dart';

class ExArtistUploadPictureScreenForMookup extends StatefulWidget {
  final exhibitionUniqueId;
  final categoryName;
  final categoryId;
  final exhibition_type;
  const ExArtistUploadPictureScreenForMookup(
      {super.key,
      required this.exhibitionUniqueId,
      required this.categoryName,
      required this.exhibition_type,
      required this.categoryId});

  @override
  _ExArtistUploadPictureScreenForMookupState createState() =>
      _ExArtistUploadPictureScreenForMookupState();
}

class _ExArtistUploadPictureScreenForMookupState
    extends State<ExArtistUploadPictureScreenForMookup> {
  String? _imageUrl1;

  final ImagePicker _picker = ImagePicker();
  var artUniqueID;

  Map<int, bool> isLoadingMap = {
    1: false,
  };

  String? _artImageId1;

  Future<void> _pickImage(int index, String artType) async {
    setState(() {
      isLoadingMap[index] = true;
    });

    XFile? pickedImage = await _picker.pickImage(source: ImageSource.gallery);

    // File imageFile = File(pickedImage!.path);
    // int fileSizeInBytes = await imageFile.length();
    // double fileSizeInMB = fileSizeInBytes / (1024 * 1024);
    //
    // if (fileSizeInMB > 2) {
    //   print("Image size is greater than 2 MB. Compressing...");
    //
    //   File? compressedImage = await _compressImage(imageFile);
    //
    //   if (compressedImage != null) {
    //     imageFile = compressedImage;
    //     print("Image compressed successfully.");
    //   } else {
    //     print("Failed to compress image.");
    //     setState(() {
    //       isLoadingMap[index] = false;
    //     });
    //     return;
    //   }
    // } else {
    //   print(
    //       "Image size is within the limit: ${fileSizeInMB.toStringAsFixed(2)} MB.");
    // }

    if (pickedImage != null) {
      try {
        final response = await ApiService().uploadImageForMookUp(
          artUniqueId: artUniqueID.toString(),
          customer_id: customerUniqueID.toString(),
          image: File(pickedImage.path),
        );

        print(response);
        setState(() {
          // final imageUrl = response['image_path'];
          // final artImageId = response['art_image_id'].toString();
          List<String> imageUrls = List<String>.from(response['urls'] ?? []);
          showToast(message: response['message']);

          if (response['status'] == true) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ExMookupImageListScreen(
                  exhibition_type: widget.exhibition_type,
                  categoryId: widget.categoryId,
                  categoryName: widget.categoryName,
                  exhibitionUniqueId: widget.exhibitionUniqueId,
                  imageUrls: imageUrls,
                  art_unique_id: artUniqueID.toString(),
                ),
              ),
            );
          }

          isLoadingMap[index] = false;
        });

        showToast(message: response['message']);
      } catch (e) {
        setState(() {
          isLoadingMap[index] = false;
        });
        print('Error: $e');
      }
    } else {
      setState(() {
        isLoadingMap[index] = false;
      });
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

  Future<void> _requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.photos,
      Permission.camera,
      Permission.storage,
    ].request();

    if (statuses[Permission.photos] != PermissionStatus.granted ||
        statuses[Permission.camera] != PermissionStatus.granted ||
        statuses[Permission.storage] != PermissionStatus.granted) {
      // showToast(message: "Permission denied. Please enable access to photos, camera, and storage.");
    }
  }

  Future<String?> getArtUniqueId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('artUniqueId');
  }

  Future<void> _deleteImage(int index) async {
    String? artImageId;
    if (index == 1) {
      artImageId = _artImageId1;
    }

    if (artImageId != null) {
      try {
        final response = await ApiService().deleteImage(artImageId);

        if (response['status']) {
          setState(() {
            if (index == 1) {
              _imageUrl1 = null;
              _artImageId1 = null;
            }
          });
          showToast(message: response['message']);
          Navigator.pop(context);
          // showToast(message: "Image deleted successfully.");
        } else {
          showToast(message: response['message']);
        }
      } catch (e) {
        print('Error deleting image: $e');
      }
    }
  }

  @override
  void initState() {
    _requestPermissions();
    _loadUserData();
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

  String? customerUniqueID;
  void _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String customerUniqueId = (prefs.get('customerUniqueId') is String)
        ? prefs.getString('customerUniqueId') ?? ''
        : prefs.getInt('customerUniqueId')?.toString() ?? '';

    print(customerUniqueId.toString());
    // fetchCustomerData(customerUniqueId);
    setState(() {
      customerUniqueID = customerUniqueId;
    });
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

  @override
  void dispose() {
    showDeleteDialog(context, artUniqueID.toString());
    super.dispose();
  }

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
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: SafeArea(
            child: Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: Responsive.getWidth(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () =>
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
                          text: "Upload Picture",
                          fontSize: Responsive.getFontSize(18),
                          fontWeight: AppFontWeight.medium,
                          textColor: Colors.black),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      ArtistUploadPictureForExhibitionScreen(
                                        exhibition_type: widget.exhibition_type,
                                        categoryName: widget.categoryName,
                                        categoryId: widget.categoryId,
                                        exhibitionUniqueId: widget
                                            .exhibitionUniqueId
                                            .toString(),
                                      )));
                        },
                        child: WantText2(
                            text: "Skip",
                            fontSize: Responsive.getFontSize(14),
                            fontWeight: AppFontWeight.regular,
                            textColor: Colors.black),
                      )
                    ],
                  ),
                  SizedBox(height: Responsive.getHeight(15)),
                  Text(
                    textAlign: TextAlign.start,
                    'Add as many as you can so Buyers can see every detail.',
                    style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontSize: Responsive.getFontSize(14),
                        fontWeight: AppFontWeight.regular,
                        letterSpacing: 1.5),
                  ),
                  SizedBox(height: Responsive.getHeight(50)),
                  Container(
                    width: Responsive.getMainWidth(context),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        uploadItem(2, _imageUrl1, "Upload Without Background",
                            "without_background_photo"),
                      ],
                    ),
                  ),
                  // SizedBox(height: Responsive.getHeight(50)),
                  // GeneralButton(
                  //   Width: Responsive.getWidth(341),
                  //   onTap: () {
                  //     if (_imageUrl1 == null) {
                  //       showToast(message: "Image 1 is not available.");
                  //     } else {
                  //       Navigator.pushNamedAndRemoveUntil(
                  //         context,
                  //         '/Artist/ArtistOnlineUploadArtScreen/ArtistAdditionalDetailScreen/ArtistUploadPictureScreen/ArtistReviewArtScreen',
                  //         (Route<dynamic> route) => false,
                  //       );
                  //     }
                  //   },
                  //   label: "Review Art",
                  //   isBoarderRadiusLess: true,
                  // ),
                  // SizedBox(height: Responsive.getHeight(20)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget to display the upload items
  Widget uploadItem(int index, String? imageUrl, String text, String artType) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
            _pickImage(index, artType);
          },
          child: Stack(
            children: [
              Container(
                height: Responsive.getWidth(160),
                width: Responsive.getWidth(200),
                // padding: EdgeInsets.all(Responsive.getWidth(16)),
                decoration: BoxDecoration(
                  color: Color.fromRGBO(250, 249, 245, 1),
                  // border: Border.all(
                  //     color: Color.fromRGBO(158, 158, 158, 0.4), width: 1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: isLoadingMap[index] == true
                    ? Center(
                        child: SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: Colors.black,
                          ),
                        ),
                      )
                    : imageUrl == null
                        ? Container(
                            // padding: EdgeInsets.all(Responsive.getWidth(12)),
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: AssetImage(
                                        "assets/artist/upload_page/frame.png"),
                                    fit: BoxFit.fill)),
                            child: Image.asset(
                              "assets/artist/upload_page/index_$index.png",
                              width: Responsive.getWidth(52),
                              height: Responsive.getWidth(52),
                            ),
                          )
                        : Image.network(
                            fit: BoxFit.contain,
                            imageUrl!,
                            width: Responsive.getWidth(52),
                            height: Responsive.getWidth(52),
                          ),
              ),
              // if (imageUrl != null)
              //   Positioned(
              //     top: 5,
              //     right: 8,
              //     child: GestureDetector(
              //       onTap: () {
              //         showCongratulationsDialog(context, index);
              //       },
              //       child: Image.asset(
              //         "assets/artist/upload_page/delete.png",
              //         height: Responsive.getWidth(18),
              //         width: Responsive.getWidth(18),
              //       ),
              //     ),
              //   ),
            ],
          ),
        ),
        SizedBox(height: Responsive.getWidth(13)),
        SizedBox(
          width: Responsive.getWidth(200),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    height: Responsive.getWidth(6),
                    width: Responsive.getWidth(6),
                    decoration: BoxDecoration(
                        color: Color.fromRGBO(235, 98, 98, 1),
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  SizedBox(width: Responsive.getWidth(5)),
                  WantText2(
                      text: "Image must be straight.",
                      fontSize: Responsive.getFontSize(10),
                      fontWeight: AppFontWeight.medium,
                      textColor: Color.fromRGBO(235, 98, 98, 1)),
                ],
              ),
              SizedBox(
                height: Responsive.getHeight(15),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    height: Responsive.getWidth(6),
                    width: Responsive.getWidth(6),
                    decoration: BoxDecoration(
                        color: Color.fromRGBO(235, 98, 98, 1),
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  SizedBox(width: Responsive.getWidth(5)),
                  SizedBox(
                    width: Responsive.getWidth(180),
                    child: Text(
                      "Image must have 4 corners appear properly.",
                      style: GoogleFonts.poppins(
                          color: Color.fromRGBO(235, 98, 98, 1),
                          fontSize: Responsive.getFontSize(10),
                          fontWeight: AppFontWeight.medium,
                          letterSpacing: 1.5),
                    ),
                  ),
                  // WantText2(
                  //     text: "Image must have 4 corners appear properly.",
                  //     fontSize: Responsive.getFontSize(10),
                  //     fontWeight: AppFontWeight.medium,
                  //     textColor: Color.fromRGBO(235, 98, 98, 1)),
                ],
              ),
              SizedBox(
                height: Responsive.getHeight(15),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    height: Responsive.getWidth(6),
                    width: Responsive.getWidth(6),
                    decoration: BoxDecoration(
                        color: Color.fromRGBO(235, 98, 98, 1),
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  SizedBox(width: Responsive.getWidth(5)),
                  SizedBox(
                    width: Responsive.getWidth(180),
                    child: Text(
                      "Image format allowed jpg and jpeg.",
                      style: GoogleFonts.poppins(
                          color: Color.fromRGBO(235, 98, 98, 1),
                          fontSize: Responsive.getFontSize(10),
                          fontWeight: AppFontWeight.medium,
                          letterSpacing: 1.5),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  void showCongratulationsDialog(BuildContext context, int index) {
    showDialog(
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
                    Image.asset(
                      "assets/dialog_delete.png",
                      height: Responsive.getWidth(78),
                      width: Responsive.getWidth(78),
                    ),
                    SizedBox(height: Responsive.getHeight(12)),
                    WantText2(
                        text: "Delete Picture",
                        fontSize: Responsive.getFontSize(20),
                        fontWeight: AppFontWeight.semiBold,
                        textColor: textBlack),
                    SizedBox(height: Responsive.getHeight(8)),
                    Text(
                      textAlign: TextAlign.center,
                      "Are you sure you want to delete this Picture?\nThis action cannot be undone.",
                      style: GoogleFonts.poppins(
                        letterSpacing: 1.5,
                        color: Color.fromRGBO(128, 128, 128, 1),
                        fontSize: Responsive.getFontSize(14),
                        fontWeight: AppFontWeight.regular,
                      ),
                    ),
                    SizedBox(height: Responsive.getHeight(24)),
                    Center(
                        child: GestureDetector(
                      onTap: () {
                        _deleteImage(index);
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
                                Text(
                                  "Delete",
                                  style: GoogleFonts.urbanist(
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
}
