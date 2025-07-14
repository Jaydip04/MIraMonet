import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as path;
import '../../../../config/colors.dart';
import '../../../../config/toast.dart';
import '../../../../core/api_service/api_service.dart';
import '../../../../core/utils/app_font_weight.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/custom_text_2.dart';
import '../../../../core/widgets/general_button.dart';

class ArtistUploadPictureScreen extends StatefulWidget {
  @override
  _ArtistUploadPictureScreenState createState() =>
      _ArtistUploadPictureScreenState();
}

class _ArtistUploadPictureScreenState extends State<ArtistUploadPictureScreen> {
  String? _imageUrl1;
  String? _imageUrl2;
  String? _imageUrl3;
  String? _imageUrl4;
  String? _imageUrl5;
  String? _imageUrl6;

  final ImagePicker _picker = ImagePicker();
  var artUniqueID;

  // Map to track loading states for each index
  Map<int, bool> isLoadingMap = {
    1: false,
    2: false,
    3: false,
    4: false,
    5: false,
    6: false,
  };

  String? _artImageId1;
  String? _artImageId2;
  String? _artImageId3;
  String? _artImageId4;
  String? _artImageId5;
  String? _artImageId6;

  Future<void> _pickImage(int index, String artType) async {
    setState(() {
      isLoadingMap[index] = true;
    });

    XFile? pickedImage = await _picker.pickImage(source: ImageSource.gallery);

    File imageFile = File(pickedImage!.path);
    int fileSizeInBytes = await imageFile.length();
    double fileSizeInMB = fileSizeInBytes / (1024 * 1024);

    if (fileSizeInMB > 2) {
      print("Image size is greater than 2 MB. Compressing...");

      File? compressedImage = await _compressImage(imageFile);

      if (compressedImage != null) {
        imageFile = compressedImage;
        print("Image compressed successfully.");
      } else {
        print("Failed to compress image.");
        setState(() {
          isLoadingMap[index] = false;
        });
        return;
      }
    } else {
      print(
          "Image size is within the limit: ${fileSizeInMB.toStringAsFixed(2)} MB.");
    }

    if (imageFile != null) {
      try {
        final response = await ApiService().uploadImage(
          artUniqueId: artUniqueID.toString(),
          artType: artType.toString(),
          image: imageFile,
        );

        print(response);
        if (response['status']) {
          setState(() {
            final imageUrl = response['image_path'];
            final artImageId = response['art_image_id'].toString();
            // Update the image URL based on the index
            if (index == 1) {
              _imageUrl1 = imageUrl;
              _artImageId1 = artImageId;
            } else if (index == 2) {
              _imageUrl2 = imageUrl;
              _artImageId2 = artImageId;
            } else if (index == 3) {
              _imageUrl3 = imageUrl;
              _artImageId3 = artImageId;
            } else if (index == 4) {
              _imageUrl4 = imageUrl;
              _artImageId4 = artImageId;
            } else if (index == 5) {
              _imageUrl5 = imageUrl;
              _artImageId5 = artImageId;
            } else if (index == 6) {
              _imageUrl6 = imageUrl;
              _artImageId6 = artImageId;
            }
            isLoadingMap[index] = false;
          });

          showToast(message: response['message']);
        } else {
          showToast(message: response['message']);
        }
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
    } else if (index == 2) {
      artImageId = _artImageId2;
    } else if (index == 3) {
      artImageId = _artImageId3;
    } else if (index == 4) {
      artImageId = _artImageId4;
    } else if (index == 5) {
      artImageId = _artImageId5;
    } else if (index == 6) {
      artImageId = _artImageId6;
    }

    if (artImageId != null) {
      try {
        final response = await ApiService().deleteImage(artImageId);

        if (response['status']) {
          setState(() {
            if (index == 1) {
              _imageUrl1 = null;
              _artImageId1 = null;
            } else if (index == 2) {
              _imageUrl2 = null;
              _artImageId2 = null;
            } else if (index == 3) {
              _imageUrl3 = null;
              _artImageId3 = null;
            } else if (index == 4) {
              _imageUrl4 = null;
              _artImageId4 = null;
            } else if (index == 5) {
              _imageUrl5 = null;
              _artImageId5 = null;
            } else if (index == 6) {
              _imageUrl6 = null;
              _artImageId6 = null;
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
                      SizedBox(width: Responsive.getWidth(70)),
                      WantText2(
                          text: "Upload Picture",
                          fontSize: Responsive.getFontSize(18),
                          fontWeight: AppFontWeight.medium,
                          textColor: Colors.black)
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
                  SizedBox(height: Responsive.getHeight(20)),
                  Container(
                    width: Responsive.getMainWidth(context),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        uploadItem(1, _imageUrl1, "Upload Without Background",
                            "without_background_photo"),
                        Spacer(),
                        uploadItem(2, _imageUrl2, "Upload Front Side Photo",
                            "front_side_photo"),
                      ],
                    ),
                  ),
                  SizedBox(height: Responsive.getHeight(15)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      uploadItem(3, _imageUrl3, "Upload Back Side Photo",
                          "back_side_photo"),
                      uploadItem(4, _imageUrl4, "Upload Left Angle Photo",
                          "left_angle_photo"),
                    ],
                  ),
                  SizedBox(height: Responsive.getHeight(15)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      uploadItem(5, _imageUrl5, "Upload Right Angle Photo",
                          "right_angle_photo"),
                      uploadItem(
                          6,
                          _imageUrl6,
                          "Upload Full Photo With Background",
                          "full_photo_with_background"),
                    ],
                  ),
                  SizedBox(height: Responsive.getHeight(50)),
                  GeneralButton(
                    Width: Responsive.getWidth(341),
                    onTap: () {
                      if (_imageUrl1 == null) {
                        showToast(message: "Image 1 is not available.");
                      } else if (_imageUrl2 == null) {
                        showToast(message: "Image 2 is not available.");
                      } else if (_imageUrl3 == null) {
                        showToast(message: "Image 3 is not available.");
                      } else if (_imageUrl4 == null) {
                        showToast(message: "Image 4 is not available.");
                      } else if (_imageUrl5 == null) {
                        showToast(message: "Image 5 is not available.");
                      } else if (_imageUrl6 == null) {
                        showToast(message: "Image 6 is not available.");
                      } else {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/Artist/ArtistOnlineUploadArtScreen/ArtistAdditionalDetailScreen/ArtistUploadPictureScreen/ArtistReviewArtScreen',
                          (Route<dynamic> route) => false,
                        );
                      }
                    },
                    label: "Review Art",
                    isBoarderRadiusLess: true,
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

  // Widget to display the upload items
  Widget uploadItem(int index, String? imageUrl, String text, String artType) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            if (imageUrl == null) {
              _pickImage(index, artType);
            } else {
              showToast(
                  message:
                      "The image already exists. Please delete the existing image before uploading a new one.");
            }
          },
          child: Stack(
            children: [
              Container(
                height: Responsive.getWidth(160),
                width: Responsive.getWidth(160),
                padding: EdgeInsets.all(Responsive.getWidth(16)),
                decoration: BoxDecoration(
                  color: Color.fromRGBO(250, 249, 245, 1),
                  border: Border.all(
                      color: Color.fromRGBO(158, 158, 158, 0.4), width: 1),
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
                            padding: EdgeInsets.all(Responsive.getWidth(12)),
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: AssetImage(
                                        "assets/artist/upload_page/frame.png"))),
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
              if (imageUrl != null)
                Positioned(
                  top: 5,
                  right: 8,
                  child: GestureDetector(
                    onTap: () {
                      showCongratulationsDialog(context, index);
                    },
                    child: Image.asset(
                      "assets/artist/upload_page/delete.png",
                      height: Responsive.getWidth(18),
                      width: Responsive.getWidth(18),
                    ),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: Responsive.getWidth(13)),
        Row(
          children: [
            Container(
              height: Responsive.getWidth(6),
              width: Responsive.getWidth(6),
              decoration: BoxDecoration(
                  color: Color.fromRGBO(235, 98, 98, 1),
                  borderRadius: BorderRadius.circular(10)),
            ),
            SizedBox(width: Responsive.getWidth(5)),
            Container(
              width: Responsive.getWidth(160),
              child: WantText2(
                  text: text,
                  fontSize: Responsive.getFontSize(10),
                  fontWeight: AppFontWeight.medium,
                  textColor: Color.fromRGBO(235, 98, 98, 1)),
            ),
          ],
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
