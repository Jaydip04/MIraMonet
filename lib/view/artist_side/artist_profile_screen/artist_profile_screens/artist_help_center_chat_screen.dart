import 'dart:convert';
import 'dart:io';
import 'package:artist/core/api_service/api_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../config/colors.dart';
import '../../../../config/toast.dart';
import '../../../../core/models/user_side/art_reply_model.dart';
import '../../../../core/utils/app_font_weight.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/custom_text_2.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;

import '../../../user_side/profile_screen/profile_screens/full_screen_image.dart';

class ArtistHelpCenterChatScreen extends StatefulWidget {
  final reciver_unique_id;
  final customerUniqueID;
  final art_enquiry_chat_id;
  final art_type;
  final art_name;

  const ArtistHelpCenterChatScreen({
    super.key,
    required this.reciver_unique_id,
    required this.art_enquiry_chat_id,
    required this.art_type,
    required this.art_name,
    required this.customerUniqueID,
  });

  @override
  State<ArtistHelpCenterChatScreen> createState() =>
      _ArtistHelpCenterChatScreenState();
}

class _ArtistHelpCenterChatScreenState
    extends State<ArtistHelpCenterChatScreen> {
  TextEditingController messageController = TextEditingController();
  File? selectedImage;
  // late Future<List<Map<String, dynamic>>> replies;
  final ImagePicker _picker = ImagePicker();

  late Future<HelpEnquiryResponse> repliesData;
  @override
  void initState() {
    super.initState();
    repliesData = ApiService().fetchSingleHelpRepliesArtist(
        widget.reciver_unique_id, widget.art_enquiry_chat_id);
    // replies = fetchReplies();
    // print("replies : $replies");
    // repliesData = fetchSingleHelpReplies(widget.reciver_unique_id.toString(), widget.art_enquiry_chat_id.toString(),);
  }

  Future<void> _sendReply() async {
    try {
      var response = await ApiService().sendHelpCenterReplyArtist(
        widget.customerUniqueID,
        widget.reciver_unique_id,
        messageController.text.toString(),
        widget.art_enquiry_chat_id.toString(),
        selectedImage,
      );
      if (response != null && response['status'] == true) {
        messageController.clear();
        setState(() {
          selectedImage = null;
          isClick = true;
        });
        setState(() {
          repliesData = ApiService().fetchSingleHelpRepliesArtist(
              widget.reciver_unique_id, widget.art_enquiry_chat_id);
        });
      } else {
        messageController.clear();
        setState(() {
          selectedImage = null;
          isClick = true;
        });
        setState(() {
          repliesData = ApiService().fetchSingleHelpRepliesArtist(
              widget.reciver_unique_id, widget.art_enquiry_chat_id);
          // repliesData = fetchSingleHelpReplies(widget.reciver_unique_id.toString(), widget.art_enquiry_chat_id.toString(),);
          // replies = fetchReplies();
        });
      }

    } catch (e) {
      setState(() {
        selectedImage = null;
        isClick = true;
      });
      print('Failed to send art reply: $e');
    }
  }

  Future<void> captureAndCompressImageAndSetCamera(BuildContext context) async {
    try {
      final XFile? pickedFile =
      await _picker.pickImage(source: ImageSource.camera);

      if (pickedFile == null) {
        print("No image selected.");
        return;
      }

      File imageFile = File(pickedFile.path);

      int fileSizeInBytes = await imageFile.length();
      double fileSizeInMB = fileSizeInBytes / (1024 * 1024);

      if (fileSizeInMB > 2) {
        print("Image size is greater than 2 MB. Compressing...");

        File? compressedImage = await _compressImage(imageFile);

        if (compressedImage != null) {
          Navigator.pop(context);
          print("Image compressed successfully.");
          setState(() {
            selectedImage = compressedImage;
          });
        } else {
          Navigator.pop(context);
          print("Failed to compress image.");
        }
      } else {
        Navigator.pop(context);
        print(
            "Image size is within the limit: ${fileSizeInMB.toStringAsFixed(2)} MB.");
        setState(() {
          selectedImage = imageFile;
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
      // Navigator.pop(context);
      return compressedFile;
    } catch (e) {
      print("Error compressing image: $e");
      return null;
    }
  }

  Future<void> captureAndCompressImageAndSetGallery(
      BuildContext context) async {
    await _requestPermissions(context);
    try {
      final XFile? pickedFile =
      await _picker.pickImage(source: ImageSource.gallery);

      if (pickedFile == null) {
        print("No image selected.");
        return;
      }

      File imageFile = File(pickedFile.path);

      int fileSizeInBytes = await imageFile.length();
      double fileSizeInMB = fileSizeInBytes / (1024 * 1024);

      if (fileSizeInMB > 2) {
        print("Image size is greater than 2 MB. Compressing...");

        File? compressedImage = await _compressImage(imageFile);

        if (compressedImage != null) {
          Navigator.pop(context);
          print("Image compressed successfully.");
          setState(() {
            selectedImage = compressedImage;
          });
        } else {
          Navigator.pop(context);
          print("Failed to compress image.");
        }
      } else {
        Navigator.pop(context);
        print(
            "Image size is within the limit: ${fileSizeInMB.toStringAsFixed(2)} MB.");
        setState(() {
          selectedImage = imageFile;
        });
      }
    } catch (e) {
      print("Error capturing or compressing image: $e");
    }
  }

  bool isClick = true;

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GridView.count(
              padding: EdgeInsets.zero,
              crossAxisCount: 3,
              shrinkWrap: true,
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
              children: [
                _buildBottomSheetItem(context, Icons.camera_alt, "Camera",
                    "0XFFFF0E0E", captureAndCompressImageAndSetCamera),
                _buildBottomSheetItem(context, Icons.photo, "Gallery",
                    "0XFF7E2AD6", captureAndCompressImageAndSetGallery),
                _buildBottomSheetItem(context, Icons.file_present_rounded,
                    "File", "0XFF03973E", _pickAndCompressFile),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _requestPermissions(BuildContext context) async {
    var status = await Permission.storage.request();
    if (status.isDenied || status.isPermanentlyDenied) {
      // Handle permission denied
      print("Storage permission denied");
    } else if (status.isGranted) {
      print("Storage permission granted");
    }
  }

  Future<void> _pickAndCompressFile(BuildContext context) async {
    await _requestPermissions(context);
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'pdf',
        'doc',
        'docx',
        'xls',
        'xlsx',
        'txt',
        'ppt',
        'pptx'
      ],
    );
    if (result != null && result.files.single.path != null) {
      File pickedFile = File(result.files.single.path!);
      // Check file size before attempting compression
      int fileSizeInKB = pickedFile.lengthSync() ~/ 1024;
      print("Original file size: $fileSizeInKB KB");
      setState(() {
        selectedImage = pickedFile;
      });
      if (fileSizeInKB > 500) {
        File? compressedFile = await _compressDocument(pickedFile);
        if (compressedFile != null) {
          setState(() {
            selectedImage = compressedFile;
          });
          Navigator.pop(context);
          print("Compressed file path: ${compressedFile.path}");
          print(
              "Compressed file size: ${compressedFile.lengthSync() ~/ 1024} KB");
        } else {
          Navigator.pop(context);
          print("Compression failed.");
        }
      } else {
        Navigator.pop(context);
        print("File size is small, no compression needed.");
      }
    } else {
      Navigator.pop(context);
      print("No file selected.");
    }
  }

  Future<File?> _compressDocument(File file) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final targetPath =
      path.join(tempDir.path, "compressed_${path.basename(file.path)}");

      // Perform a simple manual compression by copying the file (you may use a better compression algorithm)
      File compressedFile = await file.copy(targetPath);

      return compressedFile;
    } catch (e) {
      print("Error compressing document: $e");
      return null;
    }
  }

  String? imageUrl;

  Widget _buildBottomSheetItem(BuildContext context, IconData icon,
      String label, String color, Function onTap) {
    double width = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () => onTap(context),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(boxShadow: [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.1),
                blurRadius: 16,
                spreadRadius: 2,
                offset: Offset(0, 5),
              ),
            ], color: white, borderRadius: BorderRadius.circular(30.00)),
            padding: EdgeInsets.all(width * 0.03),
            child: Icon(
              icon,
              size: width * 0.08,
              color: Color(int.parse(color)),
            ),
          ),
          SizedBox(height: 8),
          Text(label,
              style: TextStyle(
                  fontSize: width * 0.03,
                  color: Color(0XFF0D1217),
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return Scaffold(
      backgroundColor: white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: Responsive.getWidth(16)),
          child: ListView(
            children: [
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
                        borderRadius:
                            BorderRadius.circular(Responsive.getWidth(12)),
                        border:
                            Border.all(color: textFieldBorderColor, width: 1.0),
                      ),
                      child: Icon(Icons.arrow_back_ios_new_outlined,
                          size: Responsive.getWidth(19)),
                    ),
                  ),
                  SizedBox(
                    width: Responsive.getWidth(250),
                    child: Center(
                      child: WantText2(
                        text: widget.art_name,
                        fontSize: Responsive.getFontSize(18),
                        fontWeight: AppFontWeight.medium,
                        textColor: textBlack,
                      ),
                    ),
                  ),
                  SizedBox(width: Responsive.getWidth(10)),
                ],
              ),
              SizedBox(height: Responsive.getHeight(25)),
              selectedImage == null ? Container(
                width: Responsive.getMainWidth(context),
                height: Platform.isIOS
                    ? Responsive.getHeight(580)
                    : Responsive.getHeight(630),
                child: FutureBuilder<HelpEnquiryResponse>(
                  future: repliesData,
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
                      return Center(child: Text('No replies found.'));
                    } else if (!snapshot.hasData ||
                        snapshot.data!.status == false) {
                      return Center(child: Text('No replies found.'));
                    }

                    final helpEnquiryData = snapshot.data!.data!;
                    final chatDetails = helpEnquiryData.chatDetails;
                    final issueImages = helpEnquiryData.issueImages;

                    return Column(
                      children: [
                        issueImages.length != 0
                            ? SizedBox(
                          child: Row(
                            mainAxisAlignment: issueImages.length > 2
                                ? MainAxisAlignment.spaceAround
                                : MainAxisAlignment.start,
                            children: issueImages
                                .map(
                                  (image) => Stack(
                                children: [
                                  Container(
                                    height: Responsive.getHeight(114),
                                    width: Responsive.getWidth(107),
                                    margin: EdgeInsets.only(
                                        right: issueImages.length > 2
                                            ? Responsive.getWidth(0)
                                            : Responsive.getWidth(6)),
                                    padding: EdgeInsets.all(
                                        Responsive.getWidth(5)),
                                    decoration: BoxDecoration(
                                      color: Color.fromRGBO(
                                          250, 249, 245, 1),
                                      border: Border.all(
                                          color: Color.fromRGBO(
                                              158, 158, 158, 0.4),
                                          width: 1),
                                      borderRadius:
                                      BorderRadius.circular(10),
                                    ),
                                    child: Image.network(
                                        image.image.toString(),
                                        fit: BoxFit.contain),
                                  ),
                                ],
                              ),
                            )
                                .toList(),
                          ),
                          height: Responsive.getHeight(120),
                        )
                            : SizedBox(),
                        Container(
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: chatDetails.length,
                            itemBuilder: (context, index) {
                              final reply = chatDetails[index];
                              final isCustomer = reply.senderUniqueId ==
                                  widget.customerUniqueID;

                              return Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: Responsive.getHeight(8)),
                                child: Align(
                                  alignment: isCustomer
                                      ? Alignment.centerRight
                                      : Alignment.centerLeft,
                                  child: Column(
                                    crossAxisAlignment: isCustomer
                                        ? CrossAxisAlignment.end
                                        : CrossAxisAlignment.start,
                                    children: [
                                      reply.image == null
                                          ? SizedBox()
                                          : _buildFilePreview(
                                          reply.image!, isCustomer),
                                      SizedBox(
                                        height: Responsive.getHeight(2),
                                      ),
                                      reply.message == null
                                          ? SizedBox()
                                          : Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal:
                                            Responsive.getWidth(16),
                                            vertical:
                                            Responsive.getHeight(12)),
                                        margin: EdgeInsets.only(
                                          // top: Responsive.getHeight(6),
                                          // bottom: Responsive.getHeight(6),
                                            left: isCustomer
                                                ? Responsive.getWidth(42)
                                                : Responsive.getWidth(0),
                                            right: isCustomer
                                                ? Responsive.getWidth(0)
                                                : Responsive.getWidth(
                                                42)),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[100],
                                          // : Color.fromRGBO(245, 245, 245, 1.0),
                                          borderRadius:
                                          BorderRadius.circular(10),
                                          // isCustomer
                                          //     ? reply.image == null
                                          //     ? BorderRadius.only(
                                          //   topRight: Radius.circular(
                                          //     Responsive.getWidth(16),
                                          //   ),
                                          //   topLeft: Radius.circular(
                                          //     Responsive.getWidth(16),
                                          //   ),
                                          //   bottomLeft: Radius.circular(
                                          //     Responsive.getWidth(16),
                                          //   ),
                                          // )
                                          //     : BorderRadius.only(
                                          //   topRight: Radius.circular(
                                          //       Responsive.getWidth(0)),
                                          //   topLeft: Radius.circular(
                                          //       Responsive.getWidth(16)),
                                          //   bottomLeft: Radius.circular(
                                          //       Responsive.getWidth(16)),
                                          //   bottomRight: Radius.circular(
                                          //       Responsive.getWidth(16)),
                                          // )
                                          //     : reply.image == null
                                          //     ? BorderRadius.only(
                                          //     topRight: Radius.circular(
                                          //         Responsive.getWidth(16)),
                                          //     topLeft: Radius.circular(
                                          //         Responsive.getWidth(16)),
                                          //     bottomRight: Radius.circular(
                                          //         Responsive.getWidth(16)))
                                          //     : BorderRadius.only(
                                          //   topRight: Radius.circular(
                                          //       Responsive.getWidth(16)),
                                          //   topLeft: Radius.circular(
                                          //       Responsive.getWidth(0)),
                                          //   bottomLeft: Radius.circular(
                                          //       Responsive.getWidth(16)),
                                          //   bottomRight: Radius.circular(
                                          //       Responsive.getWidth(16)),
                                          // )
                                        ),
                                        child: Column(
                                          crossAxisAlignment: isCustomer
                                              ? CrossAxisAlignment.end
                                              : CrossAxisAlignment.start,
                                          children: [
                                            RichText(
                                              text: _parseMessage(
                                                  reply.message!,
                                                  isCustomer),
                                            ),
                                            // Text(
                                            //   reply.message,
                                            //   style: GoogleFonts.poppins(
                                            //       letterSpacing: 1.5,
                                            //       color: isCustomer
                                            //           ? white
                                            //           : Colors.black),
                                            // ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),

                          height: issueImages.length != 0
                              ? Platform.isIOS
                              ? Responsive.getHeight(460)
                              : Responsive.getHeight(510)
                              : Platform.isIOS
                              ? Responsive.getHeight(580)
                              : Responsive.getHeight(630)
                          // color: Colors.red,
                        ),
                      ],
                    );
                  },
                ),
              ) : SizedBox(),
              SizedBox(
                height: Responsive.getHeight(10),
              ),
              if (selectedImage != null) ...[
                SizedBox(height: Responsive.getHeight(10)),
                SizedBox(
                  child: _buildFilePreview(selectedImage!.path, false),
                  height: Platform.isIOS
                      ? Responsive.getHeight(580)
                      : Responsive.getHeight(630),
                ),
              ],
              SizedBox(
                height: Responsive.getHeight(10),
              ),
              Container(
                height: Responsive.getHeight(55),
                width: Responsive.getWidth(390),
                decoration: BoxDecoration(
                  color: white,
                  borderRadius: BorderRadius.circular(Responsive.getWidth(35)),
                  boxShadow: [
                    BoxShadow(
                        color: Color.fromRGBO(6, 51, 54, 0.1),
                        blurRadius: 16,
                        offset: Offset(0, 2),
                        spreadRadius: 0)
                  ],
                ),
                child: Row(
                  children: [
                    SizedBox(width: Responsive.getWidth(16)),
                    GestureDetector(
                      onTap: () {
                        _showBottomSheet(context);
                      },
                      child: Icon(
                        Icons.add,
                        color: Color.fromRGBO(60, 60, 60, 1.0),
                      ),
                    ),
                    SizedBox(width: Responsive.getWidth(10)),
                    Flexible(
                      child: TextField(
                        cursorColor: black,
                        controller: messageController,
                        style: GoogleFonts.poppins(
                          letterSpacing: 1.5,
                          color: textBlack,
                          fontSize: Responsive.getFontSize(15),
                          fontWeight: AppFontWeight.medium,
                        ),
                        onChanged: (value) {
                          setState(() {
                            isClick = true;
                          });
                        },
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintStyle: GoogleFonts.poppins(
                            letterSpacing: 1.5,
                            color: textGray,
                            fontSize: Responsive.getFontSize(15),
                            fontWeight: AppFontWeight.medium,
                          ),
                          hintText: "Type message here...",
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (isClick == true) {
                          if(selectedImage == null){
                            if(messageController.text.isNotEmpty){
                              setState(() {
                                isClick = false;
                              });
                              _sendReply();
                            }else{
                              showToast(message: "Enter message");
                            }
                          }else{
                            setState(() {
                              isClick = false;
                            });
                            _sendReply();
                          }
                        } else {
                          showToast(message: "Wait");
                        }
                      },
                      child: isClick
                          ? Image.asset(
                              "assets/send.png",
                              height: Responsive.getWidth(40),
                              width: Responsive.getWidth(40),
                            )
                          : Container(
                        height: Responsive.getWidth(40),
                        width: Responsive.getWidth(40),
                        decoration: BoxDecoration(
                            color: black,
                            borderRadius: BorderRadius.circular(50)),
                        child: Center(
                          child: SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              color: white,
                            ),
                          ),
                        ),
                      )
                    ),
                    SizedBox(
                      width: Responsive.getWidth(10),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: Responsive.getHeight(10),
              )
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildFilePreview(String filePath, bool? isCustomer) {
    String extension = path.extension(filePath).toLowerCase();

    if (_isNetworkFile(filePath)) {
      return _isImage(extension)
          ? Container(
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.grey[100],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => FullScreenImage(image: filePath)));
            },
            child: Image.network(
              filePath,
              // height: 200,
              width: Responsive.getWidth(200),
              fit: BoxFit.contain,
            ),
          ),
        ),
      )
          : _buildNetworkFileView(filePath, isCustomer);
    } else {
      return _buildLocalFileView(filePath, extension);
    }
  }

  bool _isImage(String extension) {
    return [".jpg", ".jpeg", ".png"].contains(extension);
  }

  bool _isNetworkFile(String filePath) {
    return filePath.startsWith("http://") || filePath.startsWith("https://");
  }

  Widget _buildLocalFileView(String filePath, String extension) {
    return _isImage(extension)
        ? Image.file(
      File(filePath),
      // height: 200,
      width: Responsive.getWidth(200),
      fit: BoxFit.contain,
    )
        : _buildDocumentView(filePath, extension);
  }

  Widget _buildNetworkFileView(String url, bool? isCustomer) {
    String extension = path.extension(url).toLowerCase();
    String imagePath;

    // Mapping file types to images
    if (extension == ".pdf") {
      imagePath = "assets/images2/PDF.png";
    } else if ([".doc"].contains(extension)) {
      imagePath = "assets/images2/DOC.png";
    } else if ([".docx"].contains(extension)) {
      imagePath = "assets/images2/DOCX.png";
    } else if ([".xls"].contains(extension)) {
      imagePath = "assets/images2/XSL.png";
    } else if ([".ppt"].contains(extension)) {
      imagePath = "assets/images2/PPT.png";
    } else if ([".xlsx"].contains(extension)) {
      imagePath = "assets/images2/XLSX.png";
    } else if ([".pptx"].contains(extension)) {
      imagePath = "assets/images2/PPTX.png";
    } else if (extension == ".txt") {
      imagePath = "assets/images2/TXT.png";
    } else {
      imagePath = "assets/images2/TXT.png";
    }

    return GestureDetector(
      onTap: () async {
        String localPath = await _downloadFile(url);
        OpenFilex.open(localPath);
      },
      child: Container(
        width: Responsive.getWidth(250),
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Image.asset(
              imagePath,
              // width: 30,
              height: Responsive.getHeight(40),
              fit: BoxFit.cover,
            ),
            SizedBox(width: Responsive.getWidth(12)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: Responsive.getWidth(180),
                  child: Text(
                    path.basename(url),
                    style: TextStyle(
                        fontSize: Responsive.getFontSize(16),
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                SizedBox(height: Responsive.getHeight(4)),
                Text(
                  "Tap to open",
                  style: TextStyle(fontSize: Responsive.getFontSize(14), color: Colors.black),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentView(String filePath, String extension) {
    String imagePath;

    if (extension == ".pdf") {
      imagePath = "assets/images2/PDF.png";
    } else if ([".doc"].contains(extension)) {
      imagePath = "assets/images2/DOC.png";
    } else if ([".docx"].contains(extension)) {
      imagePath = "assets/images2/DOCX.png";
    } else if ([".xls"].contains(extension)) {
      imagePath = "assets/images2/XSL.png";
    } else if ([".ppt"].contains(extension)) {
      imagePath = "assets/images2/PPT.png";
    } else if ([".xlsx"].contains(extension)) {
      imagePath = "assets/images2/XLSX.png";
    } else if ([".pptx"].contains(extension)) {
      imagePath = "assets/images2/PPTX.png";
    } else if (extension == ".txt") {
      imagePath = "assets/images2/TXT.png";
    } else {
      imagePath = "assets/images2/TXT.png";
    }

    return Container(
      margin: EdgeInsets.symmetric(vertical: Responsive.getHeight(220), horizontal: Responsive.getWidth(50)),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            imagePath,
            height: Responsive.getHeight(80),
            fit: BoxFit.fill,
          ),
          SizedBox(height: Responsive.getHeight(10)),
          Text(
            path.basename(filePath),
            style: TextStyle(
                fontSize: Responsive.getFontSize(16), fontWeight: FontWeight.bold, color: Colors.black),
            textAlign: TextAlign.center,
            overflow: TextOverflow.fade,
            maxLines: 1,
          ),
          TextButton(
            onPressed: () => OpenFilex.open(filePath),
            child: Text("Open File",
                style: TextStyle(fontSize: Responsive.getFontSize(16), color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  Future<String> _downloadFile(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final tempDir = await getTemporaryDirectory();
        final filePath = path.join(tempDir.path, path.basename(url));
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        return file.path;
      } else {
        throw Exception("Failed to download file: ${response.statusCode}");
      }
    } catch (e) {
      print("Error downloading file: $e");
      throw Exception("File download failed");
    }
  }

  TextSpan _parseMessage(String message, bool isCustomer) {
    final urlRegex = RegExp(r'((https?:\/\/|www\.)\S+)', caseSensitive: false);
    List<TextSpan> spans = [];

    message.splitMapJoin(
      urlRegex,
      onMatch: (match) {
        final url = match.group(0)!;
        spans.add(
          TextSpan(
            text: url,
            style: GoogleFonts.poppins(
              letterSpacing: 1.5,
              color: Colors.black,
              decoration: TextDecoration.underline,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () async {
                final fullUrl = url.startsWith('http') ? url : 'https://$url';
                if (await canLaunchUrl(Uri.parse(fullUrl))) {
                  await launchUrl(Uri.parse(fullUrl),
                      mode: LaunchMode.externalApplication);
                }
              },
          ),
        );
        return url;
      },
      onNonMatch: (text) {
        spans.add(TextSpan(
          text: text,
          style: GoogleFonts.poppins(
            letterSpacing: 1.5,
            color: Colors.black,
          ),
        ));
        return text;
      },
    );

    return TextSpan(children: spans);
  }
}
