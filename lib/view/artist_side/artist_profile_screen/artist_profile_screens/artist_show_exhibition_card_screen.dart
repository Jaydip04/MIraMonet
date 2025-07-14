import 'package:artist/config/colors.dart';
import 'package:artist/config/toast.dart';
import 'package:artist/core/utils/app_font_weight.dart';
import 'package:artist/core/widgets/custom_text_2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'dart:typed_data';
import 'dart:io';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/general_button.dart';

class ArtistShowExhibitionCardScreen extends StatefulWidget {
  final Map<String, dynamic> exhibitionData;
  const ArtistShowExhibitionCardScreen(
      {super.key, required this.exhibitionData});

  @override
  State<ArtistShowExhibitionCardScreen> createState() =>
      _ArtistShowExhibitionCardScreenState();
}

class _ArtistShowExhibitionCardScreenState
    extends State<ArtistShowExhibitionCardScreen> {
  late final int colorInt;
  late final int colorInt2;
  late ScreenshotController screenshotController;
  late ScreenshotController screenshotController2;

  @override
  void initState() {
    super.initState();
    print(widget.exhibitionData);
    final String colors = widget.exhibitionData['exhibition']["card_colour"];
    final String colors2 = widget.exhibitionData['exhibition']["text_colour"];
    final String formattedColor =
        colors.startsWith("#") ? colors.substring(1) : colors;
    colorInt = int.parse(formattedColor, radix: 16);

    final String formattedColor2 =
        colors2.startsWith("#") ? colors2.substring(1) : colors2;
    colorInt2 = int.parse(formattedColor2, radix: 16);
    screenshotController = ScreenshotController();
    screenshotController2 = ScreenshotController();
  }

  // Future<void> captureAndSave() async {
  //   try {
  //     // Capture the widget as an image
  //     Uint8List? image = await screenshotController.capture();
  //     Uint8List? image2 = await screenshotController2.capture();
  //     if (image != null) {
  //       // Get the directory to store the image
  //       final directory = Directory('/storage/emulated/0/Pictures');
  //       if (!directory.existsSync()) {
  //         directory.createSync(
  //             recursive: true); // Create directory if not exists
  //       }
  //       final path =
  //           '${directory.path}/exhibition_card_${DateTime.now().millisecondsSinceEpoch}.png';
  //
  //       // Save the captured image as a file
  //       final file = File(path);
  //       await file.writeAsBytes(image);
  //
  //       // Optionally, show a success message or share the file
  //       showToast(message: "Download I Card");
  //       Navigator.pop(context);
  //       print('Image saved at $path');
  //     }
  //     if (image2 != null) {
  //       // Get the directory to store the image
  //       final directory = Directory('/storage/emulated/0/Pictures');
  //       if (!directory.existsSync()) {
  //         directory.createSync(
  //             recursive: true); // Create directory if not exists
  //       }
  //       final path =
  //           '${directory.path}/exhibition_card_${DateTime.now().millisecondsSinceEpoch}.png';
  //
  //       // Save the captured image as a file
  //       final file = File(path);
  //       await file.writeAsBytes(image2);
  //
  //       // Optionally, show a success message or share the file
  //       showToast(message: "Download I Card");
  //       Navigator.pop(context);
  //       print('Image saved at $path');
  //     }
  //   } catch (e) {
  //     print('Error saving the image: $e');
  //   }
  // }

  Future<void> captureAndSave() async {
    try {
      Uint8List? image1 = await screenshotController.capture();
      Uint8List? image2 = await screenshotController2.capture();

      if (image1 == null && image2 == null) {
        print('No images captured.');
        return;
      }

      Directory? directory;

      if (Platform.isAndroid) {
        // Request storage permission for Android 13+
        if (await Permission.storage.request().isGranted) {
          directory = Directory('/storage/emulated/0/Pictures');
        } else {
          print('Storage permission denied');
          return;
        }
      } else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory != null) {
        if (!directory.existsSync()) {
          directory.createSync(recursive: true);
        }

        if (image1 != null) {
          await saveImage(directory, image1, "exhibition_card_1");
        }
        if (image2 != null) {
          await saveImage(directory, image2, "exhibition_card_2");
        }

        showToast(message: "Download I Card");
        Navigator.pop(context);
      }
    } catch (e) {
      print('Error saving the image: $e');
    }
  }

  Future<void> saveImage(Directory directory, Uint8List image, String fileName) async {
    final path = '${directory.path}/${fileName}_${DateTime.now().millisecondsSinceEpoch}.png';
    final file = File(path);
    await file.writeAsBytes(image);
    print('Image saved at $path');
  }

  // String? image = "assets/card_logo.png";
  String? image;

  @override
  Widget build(BuildContext context) {
    Color myColor = Color(0xFF000000 | colorInt);
    Color myColor2 = Color(0xFF000000 | colorInt2);
    Responsive.init(context);
    return Scaffold(
      backgroundColor: white,
      body: SafeArea(
        child: Center(
          child: ListView(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: Responsive.getWidth(16)),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: Responsive.getWidth(41),
                        height: Responsive.getHeight(41),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(
                              Responsive.getWidth(12)),
                          border: Border.all(
                              color: textFieldBorderColor, width: 1.0),
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new_outlined,
                          size: Responsive.getWidth(19),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: Responsive.getHeight(50),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  WantText2(
                      text: "Please find your ticket below.",
                      fontSize: Responsive.getFontSize(20),
                      fontWeight: AppFontWeight.medium,
                      textColor: textBlack10),
                ],
              ),
              SizedBox(
                height: Responsive.getHeight(20),
              ),
              Column(
                children: [
                  Column(
                    children: [
                    Screenshot(
                    controller: screenshotController,
                    child:
                    Container(
                          width: 210,
                          height: 346,
                          decoration: BoxDecoration(
                            color: myColor,
                            border: Border.all(
                              color: myColor2.toString().contains("000000")
                                  ? myColor2
                                  : Colors.transparent,
                            ),
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                child: Container(
                                  height: 8,
                                  width: 68,
                                  decoration: BoxDecoration(
                                      color: white,
                                      borderRadius: BorderRadius.circular(8)),
                                ),
                                right: 70,
                                left: 70,
                                top: 8,
                              ),
                              Positioned(
                                child: Image.asset("assets/design.png"),
                              ),
                              Positioned(
                                child: Column(
                                  children: [
                                    WantText2(
                                        text: widget
                                            .exhibitionData['exhibition']
                                                ['name']
                                            .toString()
                                            .toUpperCase(),
                                        fontSize: 12,
                                        fontWeight: AppFontWeight.bold,
                                        textColor: myColor2),
                                  ],
                                ),
                                top: 28,
                                left: 0,
                                right: 0,
                              ),
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Column(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(50),
                                      child: Image.network(
                                        widget.exhibitionData['exhibition']
                                            ['logo'],
                                        width: 66,
                                        height: 66,
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    WantText2(
                                        text: widget
                                                .exhibitionData['customer_data']
                                            ['name'],
                                        fontSize: 16,
                                        fontWeight: AppFontWeight.bold,
                                        textColor: myColor2),
                                    WantText2(
                                        text: "Artist",
                                        fontSize: 10,
                                        fontWeight: AppFontWeight.light,
                                        textColor: myColor2),
                                    WantText2(
                                        text:
                                            "ID Number: ${widget.exhibitionData['registration_code']}",
                                        fontSize: 8,
                                        fontWeight: AppFontWeight.medium,
                                        textColor: myColor2),
                                    widget.exhibitionData['exhibition']
                                                ['exhibition_booth_id'] ==
                                            null
                                        ? SizedBox()
                                        : WantText2(
                                            text:
                                                "Booth : ${widget.exhibitionData['exhibition']['exhibition_booth_id']},${widget.exhibitionData['exhibition']['seat_name']}",
                                            fontSize: 8,
                                            fontWeight: AppFontWeight.medium,
                                            textColor: myColor2),
                                    SizedBox(
                                      height: 11,
                                    ),
                                    Container(
                                      height: 74,
                                      width: 74,
                                      child: QrImageView(
                                        data:
                                            "https://www.art.genixbit.com/artist/${widget.exhibitionData["registration_code"]}",
                                        version: QrVersions.auto,
                                        size: 200,
                                        backgroundColor: Colors.white,
                                        gapless: true,
                                        errorStateBuilder: (cxt, err) {
                                          return const Center(
                                            child: Text("Error"),
                                          );
                                        },
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              WantText2(
                                                  text: "Address: ",
                                                  fontSize: 10,
                                                  fontWeight:
                                                      AppFontWeight.medium,
                                                  textColor: myColor2),
                                              Container(
                                                width: 90,
                                                child: WantText2(
                                                    text:
                                                        "${widget.exhibitionData['exhibition']['address1']}, ${widget.exhibitionData['exhibition']['name_of_city']}, ${widget.exhibitionData['exhibition']['state_subdivision_name']}, ${widget.exhibitionData['exhibition']['country_name']}",
                                                    fontSize: 8,
                                                    fontWeight:
                                                        AppFontWeight.regular,
                                                    textColor: myColor2),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              WantText2(
                                                  text: "More Detail",
                                                  fontSize: 10,
                                                  fontWeight:
                                                      AppFontWeight.medium,
                                                  textColor: myColor2),
                                              Container(
                                                width: 90,
                                                child: Center(
                                                  child: WantText2(
                                                      text:
                                                          widget.exhibitionData[
                                                                  'exhibition']
                                                              ['website_link'],
                                                      fontSize: 8,
                                                      fontWeight:
                                                          AppFontWeight.regular,
                                                      textColor: myColor2),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )),),
                      SizedBox(
                        height: Responsive.getHeight(20),
                      ),
                  Screenshot(
                    controller: screenshotController2,
                    child:
                    Container(
                          width: 210,
                          height: 346,
                          decoration: BoxDecoration(
                            color: myColor,
                            border: Border.all(
                              color: myColor2.toString().contains("000000")
                                  ? myColor2
                                  : Colors.transparent,
                            ),
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                child: Container(
                                  height: 8,
                                  width: 68,
                                  decoration: BoxDecoration(
                                      color: white,
                                      borderRadius: BorderRadius.circular(8)),
                                ),
                                right: 70,
                                left: 70,
                                top: 8,
                              ),
                              Positioned(
                                child: Image.asset("assets/design.png"),
                              ),
                              Positioned(
                                child: Column(
                                  children: [
                                    WantText2(
                                        text: "Disclaimer",
                                        fontSize: 12,
                                        fontWeight: AppFontWeight.bold,
                                        textColor: myColor2),
                                  ],
                                ),
                                top: 28,
                                left: 0,
                                right: 0,
                              ),
                              Positioned(
                                top: 60,
                                left: 0,
                                right: 0,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                  child: Column(
                                    children: [
                                      Text(
                                        maxLines: 22,
                                        textAlign: TextAlign.start,
                                        widget.exhibitionData['exhibition']
                                                ['disclaimer']
                                            .toString(),
                                        style: GoogleFonts.poppins(
                                            color: myColor2,
                                            fontSize: Responsive.getFontSize(8),
                                            fontWeight: AppFontWeight.regular,
                                            letterSpacing: 1.5),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )),),
                    ],
                  ),
                ],
              ),
              SizedBox(
                height: Responsive.getHeight(20),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GeneralButton(
                    Width: Responsive.getWidth(307),
                    onTap: captureAndSave,
                    label: "Download I Card",
                    isBoarderRadiusLess: true,
                    buttonClick: false,
                    isSelected: true,
                  ),
                  SizedBox(
                    height: Responsive.getHeight(17),
                  ),
                ],
              ),
              SizedBox(
                height: Responsive.getHeight(20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
