import 'dart:convert';
import 'dart:io';

import 'package:artist/core/widgets/general_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../config/colors.dart';
import '../../../../config/toast.dart';
import '../../../../core/api_service/api_service.dart';
import '../../../../core/models/user_side/donation_page_content_model.dart';
import '../../../../core/utils/app_font_weight.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/app_text_form_field.dart';
import '../../../../core/widgets/custom_text_2.dart';
import '../../../../keys.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
class DonateNowScreen extends StatefulWidget {
  const DonateNowScreen({super.key});

  @override
  State<DonateNowScreen> createState() => _DonateNowScreenState();
}

class _DonateNowScreenState extends State<DonateNowScreen> {
  List<String> imagePaths = [
    'assets/gallery_1.png',
    'assets/gallery_2.png',
    'assets/donate.png',
    'assets/gallery_1.png',
    'assets/gallery_2.png',
    'assets/donate.png',
  ];

  late Future<List<DonationPageContent>> futureDonationPageContent;
  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    futureDonationPageContent = apiService.fetchDonationPageContent();
  }

  final String url = "https://miramonet.org/";
  Future<void> _launchURL() async {
    final Uri uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint("Could not launch $url");
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: FutureBuilder<List<DonationPageContent>>(
            future: futureDonationPageContent,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container(
                  width: Responsive.getMainWidth(context),
                  height: Responsive.getMainHeight(context),
                  child: Center(
                    child: SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: Colors.black,
                      ),
                    ),
                  ),
                );
              } else if (snapshot.hasError) {
                return Center(child: Column(
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
                                      color: textFieldBorderColor,
                                      width: 1.0)),
                              child: Icon(
                                Icons.arrow_back_ios_new_outlined,
                                size: Responsive.getWidth(19),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: Responsive.getWidth(80),
                          ),
                          WantText2(
                              text: "Donate Now",
                              fontSize: Responsive.getFontSize(18),
                              fontWeight: AppFontWeight.medium,
                              textColor: textBlack)
                        ],
                      ),
                    ),
                    SizedBox(height: Responsive.getHeight(350),),
                    Text('No data available'),
                  ],
                ));
              } else if (snapshot.hasData) {
                final donationPageContents = snapshot.data!;
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: donationPageContents.length,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final content = donationPageContents[index];
                    return Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: Responsive.getWidth(22)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
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
                                          color: textFieldBorderColor,
                                          width: 1.0)),
                                  child: Icon(
                                    Icons.arrow_back_ios_new_outlined,
                                    size: Responsive.getWidth(19),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: Responsive.getWidth(80),
                              ),
                              WantText2(
                                  text: "Donate Now",
                                  fontSize: Responsive.getFontSize(18),
                                  fontWeight: AppFontWeight.medium,
                                  textColor: textBlack)
                            ],
                          ),
                          SizedBox(
                            height: Responsive.getHeight(20),
                          ),
                          Text(
                            textAlign: TextAlign.center,
                            content.heading,
                            style: GoogleFonts.poppins(
                              letterSpacing: 1.5,
                              color: textBlack,
                              fontSize: Responsive.getFontSize(26),
                              fontWeight: AppFontWeight.bold,
                            ),
                          ),
                          SizedBox(
                            height: Responsive.getHeight(10),
                          ),
                          Center(
                            child: Image.network(
                              content.donationImages[0].images,
                              fit: BoxFit.contain,
                              height: Responsive.getHeight(310),
                              width: Responsive.getWidth(328),
                            ),
                          ),
                          SizedBox(
                            height: Responsive.getHeight(20),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              WantText2(
                                  text: "${content.title} : ",
                                  fontSize: Responsive.getFontSize(12),
                                  fontWeight: AppFontWeight.regular,
                                  textColor: textBlack),
                              SizedBox(
                                height: Responsive.getHeight(4),
                              ),
                              WantText2(
                                  text: content.subHeading,
                                  fontSize: Responsive.getFontSize(16),
                                  fontWeight: AppFontWeight.medium,
                                  textColor: textBlack),
                              SizedBox(
                                height: Responsive.getHeight(9),
                              ),
                              Text(
                                textAlign: TextAlign.start,
                                content.donationParagraph[0].paragraph,
                                style: GoogleFonts.poppins(
                                  letterSpacing: 1.5,
                                  color: textGray13,
                                  fontSize: Responsive.getFontSize(12),
                                  fontWeight: AppFontWeight.regular,
                                ),
                              ),
                              SizedBox(
                                height: Responsive.getHeight(20),
                              ),
                              Text(
                                textAlign: TextAlign.start,
                                content.donationHeading,
                                style: GoogleFonts.poppins(
                                  letterSpacing: 1.5,
                                  color: textBlack12,
                                  fontSize: Responsive.getFontSize(25),
                                  fontWeight: AppFontWeight.bold,
                                ),
                              ),
                              SizedBox(
                                height: Responsive.getHeight(19),
                              ),
                              Container(
                                alignment: Alignment.center,
                                child: StaggeredGridView.countBuilder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  crossAxisCount: 4,
                                  itemCount: content.donationImages.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    String imagePath = content
                                        .donationImages[index].images
                                        .toString();
                                    return ClipRRect(
                                      borderRadius: BorderRadius.circular(16.0),
                                      child: Image.network(
                                        imagePath,
                                        fit: BoxFit.contain,
                                      ),
                                    );
                                  },
                                  staggeredTileBuilder: (int index) {
                                    if (index % 5 == 0) {
                                      return const StaggeredTile.count(4, 2);
                                    } else if (index % 5 == 1 ||
                                        index % 5 == 2) {
                                      return const StaggeredTile.count(1, 2);
                                    } else {
                                      return const StaggeredTile.count(2, 1);
                                    }
                                  },
                                  mainAxisSpacing: 8.0,
                                  crossAxisSpacing: 8.0,
                                ),
                              ),
                              SizedBox(
                                height: Responsive.getHeight(11),
                              ),
                              ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: content.donationParagraph.length,
                                  itemBuilder: (context, index) {
                                    return Text(
                                      textAlign: TextAlign.start,
                                      content
                                          .donationParagraph[index].paragraph,
                                      style: GoogleFonts.poppins(
                                        letterSpacing: 1.5,
                                        color: textGray13,
                                        fontSize: Responsive.getFontSize(12),
                                        fontWeight: AppFontWeight.regular,
                                      ),
                                    );
                                  }),
                              SizedBox(
                                height: Responsive.getHeight(11),
                              ),
                              // content.donateNow.toLowerCase() == "yes"
                              //     ?
                              GeneralButton(
                                      Width: Responsive.getWidth(335),
                                      onTap: () {
                                        _launchURL();
                                        // showRegisterDialog(context);
                                      },
                                      label: "DONATE NOW",
                                      isBoarderRadiusLess: true,
                                    ),
                                  // :
                              // Container(),
                              SizedBox(
                                height: Responsive.getHeight(20),
                              )
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              } else {
                return Center(child: Column(
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
                                      color: textFieldBorderColor,
                                      width: 1.0)),
                              child: Icon(
                                Icons.arrow_back_ios_new_outlined,
                                size: Responsive.getWidth(19),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: Responsive.getWidth(80),
                          ),
                          WantText2(
                              text: "Donate Now",
                              fontSize: Responsive.getFontSize(18),
                              fontWeight: AppFontWeight.medium,
                              textColor: textBlack)
                        ],
                      ),
                    ),
                    SizedBox(height: Responsive.getHeight(350),),
                    Text('No data available'),
                  ],
                ));
              }
            },
          ),
        ),
      ),
    );
  }

  void showRegisterDialog(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return RegisterDialog();
      },
    );
  }
}

class RegisterDialog extends StatefulWidget {
  @override
  _RegisterDialogState createState() => _RegisterDialogState();
}

class _RegisterDialogState extends State<RegisterDialog> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _amountController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _leaveController = TextEditingController();
  TextEditingController _CompanyNameController = TextEditingController();

  bool _isChecked = false;
  int selectedIndex = 0;
  final List<String> amounts = ["25", "50", "100", "200", "250"];

  bool isEnable = true;
  String selectedAmount = "25";

  double amount = 20;
  Map<Stripe, dynamic>? intentPaymentData;
  late String paymentIntentId;
  late String payment_Id;

  Future<void> showPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet().then((onValue) async {
        // paymentIntentId = null;
        print(onValue);

        ApiService()
            .donationSuccessApp(
          paymentId: paymentIntentId.toString(),
          total: selectedAmount.toString(),
          email: _emailController.text.toString(),
          comment: _leaveController.text.toString(),
          name: _nameController.text.toString(),
          donationLogo: _selectedImage,
          company_name: _CompanyNameController.text.toString()
        )
            .then((onValue) {
          Navigator.pop(context);
        });
        showToast(
          message: "Payment is Success.",
        );
      }).onError((errorMsg, sTrace) {
        if (kDebugMode) {
          showToast(
            message: "Payment is Failed.",
          );
          // Navigator.pushReplacement(
          //   context,
          //   MaterialPageRoute(builder: (context) => OrderFailedScreen()),
          // );
          print(errorMsg.toString() + sTrace.toString());
        }
      });
    } on StripeException catch (error) {
      if (kDebugMode) {
        print(error);
      }
      showDialog(
          context: context,
          builder: (c) => AlertDialog(
                content: Text("Cancelled"),
              ));
    } catch (errorMsg) {
      if (kDebugMode) {
        print(errorMsg);
      }
      print(errorMsg.toString());
    }
  }

  Future<Map<String, dynamic>?> makeIntentForPayment(
      String amountToBeCharge, String currency) async {
    try {
      Map<String, dynamic> paymentInfo = {
        "amount": (int.parse(amountToBeCharge) * 100).toString(),
        "currency": currency,
        "payment_method_types[]": "card",
      };

      var responseFromStripeAPI = await http.post(
        Uri.parse("https://api.stripe.com/v1/payment_intents"),
        body: paymentInfo,
        headers: {
          "Authorization": "Bearer ${StripeKeys.secretKey}",
          "Content-Type": "application/x-www-form-urlencoded"
        },
      );

      if (responseFromStripeAPI.statusCode != 200) {
        throw Exception('Failed to create payment intent');
      }

      if (kDebugMode) {
        print("Response from API: ${responseFromStripeAPI.body}");
      }

      Map<String, dynamic> responseBody =
          jsonDecode(responseFromStripeAPI.body) as Map<String, dynamic>;

      setState(() {
        payment_Id = responseBody["id"].toString();
        paymentIntentId = responseBody["id"].toString();
        // paymentIntentId = responseBody["client_secret"].toString();
      });

      print("Payment Intent ID: $paymentIntentId");
      print("Payment ID: $payment_Id");

      return responseBody;
    } catch (errorMsg) {
      if (kDebugMode) {
        print(errorMsg);
      }
      return null;
    }
  }

  Future<void> paymentSheetInitialization(
      String amountToBeCharge, String currency) async {
    try {
      // Fetch payment intent data from the backend
      final intentPaymentData =
          await makeIntentForPayment(amountToBeCharge, currency);

      if (intentPaymentData == null) {
        showToast(message: "Failed to process payment. Please try again.");
        throw Exception("Failed to create payment intent");
      }

      // Initialize the payment sheet
      try {
        await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            allowsDelayedPaymentMethods: true,
            paymentIntentClientSecret: intentPaymentData["client_secret"],
            style: ThemeMode.dark,
            merchantDisplayName: "Mira Monet",
          ),
        );
        // Proceed with presenting the payment sheet
      } catch (e) {
        print("Error initializing payment sheet: $e");
        // Handle error accordingly
      }

      await showPaymentSheet();
    } catch (errorMsg, s) {
      if (kDebugMode) {
        print(s);
      }
      print(errorMsg.toString());
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _leaveController.dispose();
    super.dispose();
  }

  File? _selectedImage;
  String _fileName = "No File Chosen";

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
        _fileName = image.name;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return Dialog(
      backgroundColor: whiteBack,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: EdgeInsets.symmetric(horizontal: Responsive.getWidth(14)),
      child: Container(
        margin: EdgeInsets.all(0), // Remove all margins
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: Responsive.getWidth(11),
                vertical: Responsive.getHeight(11)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 1,
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(
                        CupertinoIcons.multiply_circle,
                        color: Colors.grey,
                      ),
                    )
                  ],
                ),
                WantText2(
                    text: "Your Donation",
                    fontSize: Responsive.getFontSize(12),
                    fontWeight: AppFontWeight.bold,
                    textColor: textBlack),
                SizedBox(height: Responsive.getHeight(7)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      height: Responsive.getWidth(40),
                      width: Responsive.getWidth(210),
                      decoration: BoxDecoration(
                        color: Color(0xFFF5F5F5), // light gray background
                        borderRadius: BorderRadius.horizontal(
                          left: Radius.circular(8.0),
                          right: Radius.circular(8.0),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            height: Responsive.getWidth(40),
                            width: Responsive.getWidth(32),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.horizontal(
                                left: Radius.circular(8.0),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '\$',
                                // style: TextStyle(
                                //   color: Colors.white,
                                //   fontSize: 16.0,
                                //   fontWeight: FontWeight.bold,
                                // ),
                                style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.5),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: Responsive.getWidth(170),
                            child: TextField(
                              controller: _amountController,
                              readOnly: isEnable,
                              style: GoogleFonts.poppins(
                                letterSpacing: 1.5,
                                color: textBlack,
                                fontSize: Responsive.getFontSize(15),
                                fontWeight: AppFontWeight.medium,
                              ),
                              cursorColor: Colors.black,
                              decoration: InputDecoration(
                                  isDense: true,
                                  fillColor: Color.fromRGBO(247, 248, 249, 1),
                                  filled: true,
                                  border: InputBorder.none),
                              onChanged: (value) {
                                setState(() {
                                  selectedAmount = value;
                                });
                              },
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 9,
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isEnable = !isEnable;
                          selectedAmount = "25";
                        });
                      },
                      child: Container(
                        height: Responsive.getHeight(40),
                        width: Responsive.getWidth(100),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius:
                                BorderRadius.circular(Responsive.getWidth(8)),
                          ),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                WantText2(
                                    text: "Enter Amount",
                                    fontSize: Responsive.getFontSize(8),
                                    fontWeight: AppFontWeight.bold,
                                    textColor: white)
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: Responsive.getHeight(10)),
                isEnable
                    ? Container(
                        height: Responsive.getHeight(30),
                        child: ListView.builder(
                          itemCount: amounts.length,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            bool isSelected = index == selectedIndex;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedIndex = index;
                                  setState(() {
                                    selectedAmount = amounts[index];
                                  });
                                });
                              },
                              child: Container(
                                margin: EdgeInsets.only(
                                  right: Responsive.getWidth(11),
                                ),
                                width: Responsive.getWidth(55),
                                height: Responsive.getHeight(30),
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.black, width: 1),
                                  borderRadius: BorderRadius.circular(
                                    Responsive.getWidth(5),
                                  ),
                                  color:
                                      isSelected ? Colors.black : Colors.white,
                                ),
                                child: Center(
                                  child: WantText2(
                                    text: "\$${amounts[index]}",
                                    fontSize: Responsive.getFontSize(11),
                                    fontWeight: AppFontWeight.regular,
                                    textColor: isSelected
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    : Container(),
                isEnable
                    ? SizedBox(height: Responsive.getHeight(10))
                    : Container(),
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      WantText2(
                          text: "Personal Info",
                          fontSize: Responsive.getFontSize(12),
                          fontWeight: AppFontWeight.bold,
                          textColor: textBlack9),
                      SizedBox(
                        height: Responsive.getHeight(5),
                      ),
                      Row(
                        children: [
                          WantText2(
                              text: "Name",
                              fontSize: Responsive.getFontSize(10),
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
                        controller: _nameController,
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
                            return 'Name cannot be empty';
                          }
                          return null;
                        },
                        hintText: "Enter your Name",
                      ),
                      SizedBox(
                        height: Responsive.getHeight(15),
                      ),
                      Row(
                        children: [
                          WantText2(
                              text: "Email",
                              fontSize: Responsive.getFontSize(10),
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
                        controller: _emailController,
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
                            return 'Email cannot be empty';
                          }
                          final emailRegex = RegExp(
                            r'^[a-z0-9][a-z0-9._%+-]*@[a-z0-9.-]+\.[a-z]{2,}$',
                            caseSensitive: false,
                          );
                          if (!emailRegex.hasMatch(value)) {
                            return 'Email is not valid';
                          }
                          return null;
                        },
                        hintText: "Enter Your Email",
                      ),
                      SizedBox(
                        height: Responsive.getHeight(15),
                      ),
                      Row(
                        children: [
                          WantText2(
                              text: "Leave Comment",
                              fontSize: Responsive.getFontSize(10),
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
                        maxLines: 5,
                        controller: _leaveController,
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
                            return 'Comment cannot be empty';
                          }
                          return null;
                        },
                        hintText: "Enter Leave Comment",
                      ),
                      // SizedBox(
                      //   height: Responsive.getHeight(10),
                      // ),
                      SizedBox(
                        height: Responsive.getHeight(15),
                      ),
                      WantText2(
                          text: "Company Name (Optional)",
                          fontSize: Responsive.getFontSize(10),
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
                        controller: _CompanyNameController,
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
                            return 'Company Name cannot be empty';
                          }
                          return null;
                        },
                        hintText: "Enter Company Name",
                      ),
                      SizedBox(
                        height: Responsive.getHeight(10),
                      ),
                      WantText2(
                          text: "Upload Your Company Logo (Optional)",
                          fontSize: Responsive.getFontSize(10),
                          fontWeight: AppFontWeight.medium,
                          textColor: textBlack9),
                      SizedBox(
                        height: Responsive.getHeight(5),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          vertical: Responsive.getWidth(8),
                          horizontal: Responsive.getWidth(8),
                        ),
                        child: Row(
                          children: [
                            Column(
                              children: [
                                Container(
                                  width: Responsive.getWidth(43),
                                  height: Responsive.getWidth(43),
                                  decoration: BoxDecoration(
                                    color: Color.fromRGBO(226, 230, 236, 1),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                  child: _selectedImage == null
                                      ? Icon(
                                          Icons.image_outlined,
                                          color:
                                              Color.fromRGBO(178, 185, 196, 1),
                                        )
                                      : ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(2),
                                          child: Image.file(
                                            _selectedImage!,
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                )
                              ],
                            ),
                            SizedBox(width: Responsive.getWidth(8)),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                WantText2(
                                  text:
                                      "Please upload square image, size less than 2024KB",
                                  fontSize: Responsive.getFontSize(6),
                                  fontWeight: AppFontWeight.light,
                                  textColor: black,
                                ),
                                SizedBox(height: Responsive.getHeight(5)),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: Responsive.getWidth(4),
                                    vertical: Responsive.getHeight(4),
                                  ),
                                  decoration: BoxDecoration(
                                    color: Color.fromRGBO(248, 252, 255, 1),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                  child: Row(
                                    children: [
                                      GestureDetector(
                                        onTap: _pickImage,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Colors.black,
                                              width: 0.4,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(2.2),
                                          ),
                                          padding: EdgeInsets.symmetric(
                                            vertical: Responsive.getHeight(4),
                                            horizontal: Responsive.getWidth(8),
                                          ),
                                          child: WantText2(
                                            text: "Choose File",
                                            fontSize: Responsive.getFontSize(7),
                                            fontWeight: AppFontWeight.medium,
                                            textColor: Colors.black,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: Responsive.getWidth(13)),
                                      SizedBox(
                                        width: Responsive.getWidth(135),
                                        child: WantText2(
                                          textOverflow: TextOverflow.ellipsis,
                                          text: _fileName,
                                          fontSize: Responsive.getFontSize(7),
                                          fontWeight: AppFontWeight.regular,
                                          textColor:
                                              Color.fromRGBO(60, 60, 60, 1),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        height: Responsive.getHeight(5),
                      ),
                      TermsCheckbox(),
                      SizedBox(
                        height: Responsive.getHeight(12),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          WantText2(
                              text: "Total Donation",
                              fontSize: Responsive.getFontSize(15),
                              fontWeight: AppFontWeight.semiBold,
                              textColor: textBlack9),
                          WantText2(
                              text: "\$ ${selectedAmount}",
                              fontSize: Responsive.getFontSize(15),
                              fontWeight: AppFontWeight.semiBold,
                              textColor: textBlack9)
                        ],
                      ),
                      SizedBox(
                        height: Responsive.getHeight(8),
                      ),
                      Center(
                        child: GeneralButton(
                          Width: Responsive.getWidth(315),
                          onTap: () {
                            if (_formKey.currentState!.validate()) {
                              paymentSheetInitialization(
                                  selectedAmount.toString(),
                                  "USD");
                            } else if (selectedAmount.isEmpty) {
                              showToast(message: "Select Amount");
                            } else if (_nameController.text.isEmpty) {
                              showToast(message: "Enter the name");
                            } else if (_emailController.text.isEmpty) {
                              showToast(message: "Enter the address");
                            } else if (_isChecked == false) {
                              showToast(
                                  message:
                                      "Please Check the terms and condition");
                            } else {
                              showToast(message: "Form is not valid");
                            }
                          },
                          label: "Donate Now",
                          isBoarderRadiusLess: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget TermsCheckbox() {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _isChecked = !_isChecked;
            });
          },
          child: Container(
            width: Responsive.getWidth(15),
            height: Responsive.getWidth(15),
            decoration: BoxDecoration(
                color: _isChecked ? black : Colors.transparent,
                borderRadius: BorderRadius.circular(Responsive.getWidth(4)),
                border: Border.all(color: Color.fromRGBO(0, 0, 0, 1))),
            child: _isChecked
                ? Center(
                    child: Icon(
                    Icons.check,
                    color: white,
                    size: 12,
                  ))
                : Container(),
          ),
        ),
        SizedBox(
          width: 5,
        ),
        Flexible(
          child: GestureDetector(
            onTap: () {
              _fetchAndShowTerms(context);
            },
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'I have read and agree to the ',
                    style: GoogleFonts.poppins(
                      letterSpacing: 1.5,
                      color: Color.fromRGBO(27, 43, 65, 0.72),
                      fontSize: Responsive.getFontSize(10),
                      fontWeight: AppFontWeight.medium,
                    ),
                  ),
                  TextSpan(
                    text: 'Terms of Service & Privacy Policy',
                    style: GoogleFonts.poppins(
                      // decoration: TextDecoration.underline,
                      letterSpacing: 1.5,
                      color: Color.fromRGBO(0, 0, 0, 1),
                      fontSize: Responsive.getFontSize(10),
                      fontWeight: AppFontWeight.medium,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _fetchAndShowTerms(BuildContext context) async {
    try {
      final termsData = await ApiService().getTermsConditions("Donation");
      _showTermsDialog(context, termsData);
    } catch (error) {
      print('Error fetching terms and conditions: $error');
    }
  }

  void _showTermsDialog(BuildContext context, Map<String, dynamic> termsData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          insetPadding: EdgeInsets.symmetric(horizontal: 14),
          child: Container(
            margin: EdgeInsets.all(0),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  for (var term in termsData['terms'])
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          term['heading'],
                          // style: TextStyle(
                          //   fontWeight: FontWeight.bold,
                          //   fontSize: 18,
                          // ),
                          style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5),
                        ),
                        for (var para in term['conditions_paras'])
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.6),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                SizedBox(width: 10),
                                Flexible(
                                  child: Text(
                                    para['paragraph'],
                                    style: GoogleFonts.poppins(
                                        fontWeight: AppFontWeight.regular,
                                        letterSpacing: 1.5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
