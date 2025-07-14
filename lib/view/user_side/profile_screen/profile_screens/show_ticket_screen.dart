import 'dart:io';

import 'package:artist/config/colors.dart';
import 'package:artist/core/utils/app_font_weight.dart';
import 'package:artist/core/widgets/custom_text_2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot/screenshot.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/general_button.dart';
import 'package:artist/config/toast.dart';
import 'dart:typed_data';
import 'package:qr_flutter/qr_flutter.dart';

class ShowTicketScreen extends StatefulWidget {
  final Map<String, dynamic> exhibitionData;

  const ShowTicketScreen({super.key, required this.exhibitionData});

  @override
  State<ShowTicketScreen> createState() => _ShowTicketScreenState();
}

class _ShowTicketScreenState extends State<ShowTicketScreen> {
  late ScreenshotController screenshotController;

  @override
  void initState() {
    super.initState();
    print(widget.exhibitionData);
    screenshotController = ScreenshotController();
  }

  Future<bool> requestStoragePermission() async {
    PermissionStatus status = await Permission.storage.request();
    if (status.isGranted) {
      print("Storage permission granted");
      return true;
    } else if (status.isDenied) {
      print("Storage permission denied");
    } else if (status.isPermanentlyDenied) {
      print(
          "Storage permission permanently denied. Redirecting to settings...");
      await openAppSettings();
    }
    return false;
  }

  Future<void> captureAndSave() async {
    try {
      Uint8List? image = await screenshotController.capture();
      if (image != null) {
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

          final path =
              '${directory.path}/exhibition_card_${DateTime.now().millisecondsSinceEpoch}.png';

          final file = File(path);
          await file.writeAsBytes(image);

          showToast(message: "Download Ticket");
          Navigator.pop(context);
          print('Image saved at $path');
        }
      }
    } catch (e) {
      print('Error saving the image: $e');
    }
  }

  String formatDate(String dateString) {
    DateTime date = DateTime.parse(dateString);

    DateFormat formatter = DateFormat('EEE dd MMM, yyyy');

    // Format the date and return it
    return formatter.format(date);
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return Scaffold(
      backgroundColor: white,
      body: SafeArea(
        child: Column(
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
            WantText2(
                text: "Please find your ticket below.",
                fontSize: Responsive.getFontSize(20),
                fontWeight: AppFontWeight.medium,
                textColor: textBlack10),
            SizedBox(
              height: Responsive.getHeight(10),
            ),
            Screenshot(
              controller: screenshotController,
              child: Container(
                height: 130,
                width: 327,
                decoration: BoxDecoration(
                    // color: Color.fromRGBO(245, 247, 249, 1.0),
                    image: DecorationImage(
                        image: AssetImage("assets/ticket_2.png"),
                        fit: BoxFit.fill)),
                child: Stack(
                  children: [
                    Positioned(
                      top: 0,
                      left: 0,
                      bottom: 0,
                      right: 0,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Image.asset("assets/ticket_up.png"),
                      ),
                    ),
                    Positioned(
                      top: 20,
                      child: Container(
                        height: 90,
                        width: 200,
                        child: Padding(
                          padding: EdgeInsets.only(left: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              WantText2(
                                  text: widget.exhibitionData['exhibition']
                                          ['name']
                                      .toString()
                                      .toUpperCase(),
                                  fontSize: 15,
                                  fontWeight: AppFontWeight.bold,
                                  textColor: black),
                              SizedBox(
                                child: Divider(
                                  color: black,
                                ),
                                width: 170,
                              ),
                              Text(
                                maxLines: 2,
                                "${widget.exhibitionData['exhibition']['address1']}, ${widget.exhibitionData['exhibition']['name_of_city']}, ${widget.exhibitionData['exhibition']['state_subdivision_name']}, ${widget.exhibitionData['exhibition']['country_name']}",
                                style: GoogleFonts.poppins(
                                    color: black,
                                    fontSize: 7,
                                    fontWeight: AppFontWeight.medium,
                                    letterSpacing: 1.5),
                              ),
                              Spacer(),
                              WantText2(
                                  text: "Terms And Condition",
                                  fontSize: 6,
                                  fontWeight: AppFontWeight.bold,
                                  textColor: black),
                              Text(
                                maxLines: 2,
                                "${widget.exhibitionData['exhibition']['disclaimer']}",
                                style: GoogleFonts.poppins(
                                    color: black,
                                    fontSize: 5,
                                    fontWeight: AppFontWeight.medium,
                                    letterSpacing: 1.5),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 10,
                      top: 15,
                      bottom: 0,
                      child: SizedBox(
                        width: 110,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            WantText2(
                                text:
                                    "${widget.exhibitionData['purpose_booking']}",
                                fontSize: 8,
                                fontWeight: AppFontWeight.bold,
                                textColor: black),
                            SizedBox(
                              height: 1,
                            ),
                            WantText2(
                                text: formatDate(
                                        widget.exhibitionData['exhibtion_date'])
                                    .toString(),
                                // "${]}",
                                fontSize: 6,
                                fontWeight: AppFontWeight.bold,
                                textColor: black),
                            SizedBox(
                              height: 1,
                            ),
                            WantText2(
                                text: "${widget.exhibitionData['slot_name']}",
                                fontSize: 5,
                                fontWeight: AppFontWeight.bold,
                                textColor: black),
                            QrImageView(
                              data:
                                  "https://www.art.genixbit.com/customer/${widget.exhibitionData["registration_code"]}",
                              version: QrVersions.auto,
                              size: 75,
                              backgroundColor: Colors.transparent,
                              gapless: true,
                              errorStateBuilder: (cxt, err) {
                                return const Center(
                                  child: Text("Error"),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: GeneralButton(
                    Width: Responsive.getWidth(335),
                    onTap: () {
                      captureAndSave();
                      // Navigator.pop(context);
                    },
                    label: "Download Ticket",
                    isBoarderRadiusLess: true,
                  ),
                ),
                // SizedBox(
                //   width: 11,
                // ),
                // GestureDetector(
                //   onTap: () {
                //     print(
                //         "name : ${widget.exhibitionData['customer_data']['name']}");
                //     print(
                //         "mobile : ${widget.exhibitionData['customer_data']['mobile']}");
                //     print(
                //         "registration_code : ${widget.exhibitionData["registration_code"]}");
                //     print(
                //         "exhibition_unique_id : ${widget.exhibitionData["exhibition"]["exhibition_unique_id"]}");
                //   },
                //   child: Container(
                //     height: Responsive.getHeight(50),
                //     width: Responsive.getWidth(50),
                //     padding: EdgeInsets.all(13),
                //     decoration: BoxDecoration(
                //       color: white,
                //       borderRadius:
                //           BorderRadius.circular(Responsive.getWidth(10)),
                //       boxShadow: [
                //         BoxShadow(
                //           color: Color.fromRGBO(0, 0, 0, 0.15),
                //           offset: Offset(0, 17),
                //           blurRadius: 43,
                //           spreadRadius: 0,
                //         )
                //       ],
                //     ),
                //     child: Icon(Icons.file_upload_outlined),
                //   ),
                // )
              ],
            ),
            SizedBox(
              height: Responsive.getHeight(20),
            )
          ],
        ),
      ),
    );
  }
}
