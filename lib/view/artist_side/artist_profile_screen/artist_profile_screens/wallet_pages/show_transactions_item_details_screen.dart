import 'package:artist/core/api_service/api_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../config/colors.dart';
import '../../../../../core/utils/app_font_weight.dart';
import '../../../../../core/utils/responsive.dart';
import '../../../../../core/widgets/custom_text_2.dart';

class ShowTransactionsItemDetailsScreen extends StatefulWidget {
  final customer_id;
  final ordered_art_id;
  const ShowTransactionsItemDetailsScreen(
      {super.key, required this.customer_id, required this.ordered_art_id});

  @override
  State<ShowTransactionsItemDetailsScreen> createState() =>
      _ShowTransactionsItemDetailsScreenState();
}

class _ShowTransactionsItemDetailsScreenState
    extends State<ShowTransactionsItemDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return Scaffold(
      backgroundColor: white,
      body: FutureBuilder<Map<String, dynamic>>(
        future: ApiService().getSingleTransactionDetails(
            widget.customer_id, widget.ordered_art_id),
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
            return Center(child: Text('No data found'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('No data found'));
          } else {
            final data = snapshot.data;
            return SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: Responsive.getWidth(20)),
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
                          SizedBox(width: Responsive.getWidth(100)),
                          WantText2(
                            text: "Wallet",
                            fontSize: Responsive.getFontSize(18),
                            fontWeight: AppFontWeight.medium,
                            textColor: textBlack,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: Responsive.getHeight(17)),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: Responsive.getWidth(20)),
                      child: Divider(
                        color: Color.fromRGBO(228, 228, 228, 1),
                      ),
                    ),
                    SizedBox(height: Responsive.getHeight(17)),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: Responsive.getWidth(20)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          WantText2(
                            text: "Item",
                            fontSize: Responsive.getFontSize(16),
                            fontWeight: AppFontWeight.medium,
                            textColor: textBlack,
                          ),
                          SizedBox(height: Responsive.getHeight(24)),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Image.network(
                                'https://artist.genixbit.com/${data!['art_data']["image"]}',
                                width: Responsive.getWidth(140),
                                height: Responsive.getWidth(140),
                                fit: BoxFit.contain,
                              ),
                              SizedBox(width: 16),
                              Flexible(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      data['art_data']["title"],
                                      textAlign: TextAlign.start,
                                      style: GoogleFonts.poppins(
                                        letterSpacing: 1.5,
                                        color: textBlack,
                                        fontSize: Responsive.getFontSize(16),
                                        fontWeight: AppFontWeight.semiBold,
                                      ),
                                    ),
                                    SizedBox(height: Responsive.getHeight(3)),
                                    Text(
                                      data['art_data']["artist_name"],
                                      textAlign: TextAlign.start,
                                      style: GoogleFonts.poppins(
                                        letterSpacing: 1.5,
                                        color: Color.fromRGBO(133, 122, 122, 1),
                                        fontSize: Responsive.getFontSize(10),
                                        fontWeight: AppFontWeight.regular,
                                      ),
                                    ),
                                    Text(
                                      "\$${data['art_data']["price"]}",
                                      textAlign: TextAlign.start,
                                      style: GoogleFonts.poppins(
                                        letterSpacing: 1.5,
                                        color: textGray17,
                                        fontSize: Responsive.getFontSize(16),
                                        fontWeight: AppFontWeight.medium,
                                      ),
                                    ),
                                    SizedBox(height: Responsive.getHeight(8)),
                                    Text(
                                      data['art_data']["edition"],
                                      textAlign: TextAlign.start,
                                      maxLines: 9,
                                      style: GoogleFonts.poppins(
                                        letterSpacing: 1.5,
                                        color: textGray17,
                                        fontSize: Responsive.getFontSize(8),
                                        fontWeight: AppFontWeight.regular,
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
                    SizedBox(height: Responsive.getHeight(20)),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: Responsive.getWidth(8)),
                      child: Divider(
                        color: Color.fromRGBO(228, 228, 228, 1),
                        thickness: 8,
                      ),
                    ),
                    SizedBox(height: Responsive.getHeight(30)),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: Responsive.getWidth(20)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              WantText2(
                                  text: "Delivery",
                                  fontSize: Responsive.getFontSize(16),
                                  fontWeight: AppFontWeight.medium,
                                  textColor: textBlack),
                              Container(
                                width: Responsive.getWidth(145),
                                child: Text(
                                  "${data['delivery_address']["address"]}, ${data['delivery_address']["name_of_city"]}, ${data['delivery_address']["state_name"]}, ${data['delivery_address']["country_name"]}, ${data['delivery_address']["pincode"]}",
                                  textAlign: TextAlign.end,
                                  style: GoogleFonts.poppins(
                                    letterSpacing: 1.5,
                                    color: textGray17,
                                    fontSize: Responsive.getFontSize(14),
                                    fontWeight: AppFontWeight.regular,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: Responsive.getHeight(24)),
                          Divider(
                            color: Color.fromRGBO(228, 228, 228, 1),
                          ),
                          SizedBox(height: Responsive.getHeight(24)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              WantText2(
                                  text: "Order Number",
                                  fontSize: Responsive.getFontSize(16),
                                  fontWeight: AppFontWeight.medium,
                                  textColor: textBlack),
                              WantText2(
                                  text: data['data']['order_unique_id'],
                                  fontSize: Responsive.getFontSize(16),
                                  fontWeight: AppFontWeight.regular,
                                  textColor: textGray17),
                            ],
                          ),
                          SizedBox(height: Responsive.getHeight(24)),
                          Divider(
                            color: Color.fromRGBO(228, 228, 228, 1),
                          ),
                          SizedBox(height: Responsive.getHeight(24)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              WantText2(
                                  text: "Payment",
                                  fontSize: Responsive.getFontSize(16),
                                  fontWeight: AppFontWeight.medium,
                                  textColor: textBlack),
                              WantText2(
                                  text: data['oderdata']["payment_method"]
                                      .toString()
                                      .toUpperCase(),
                                  fontSize: Responsive.getFontSize(16),
                                  fontWeight: AppFontWeight.regular,
                                  textColor: textGray17),
                            ],
                          ),
                          SizedBox(height: Responsive.getHeight(24)),
                          Divider(
                            color: Color.fromRGBO(228, 228, 228, 1),
                          ),
                          SizedBox(height: Responsive.getHeight(24)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              WantText2(
                                  text: "Art Price",
                                  fontSize: Responsive.getFontSize(16),
                                  fontWeight: AppFontWeight.regular,
                                  textColor: textGray17),
                              WantText2(
                                  text: "US\$${data['data']['price']}",
                                  fontSize: Responsive.getFontSize(16),
                                  fontWeight: AppFontWeight.regular,
                                  textColor: textGray17),
                            ],
                          ),
                          SizedBox(height: Responsive.getHeight(4)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              WantText2(
                                  text: "Portal Percentage(${data['portal_percentage']})",
                                  fontSize: Responsive.getFontSize(16),
                                  fontWeight: AppFontWeight.regular,
                                  textColor: textGray17),
                              WantText2(
                                  text: "US\$${data['total_deductions']}",
                                  fontSize: Responsive.getFontSize(16),
                                  fontWeight: AppFontWeight.regular,
                                  textColor: textGray17),
                            ],
                          ),
                          SizedBox(height: Responsive.getHeight(4)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              WantText2(
                                  text: "Income",
                                  fontSize: Responsive.getFontSize(16),
                                  fontWeight: AppFontWeight.medium,
                                  textColor: textBlack),
                              WantText2(
                                  text:
                                      "US\$${data['total'].toString()}",
                                  fontSize: Responsive.getFontSize(16),
                                  fontWeight: AppFontWeight.medium,
                                  textColor: textBlack),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
