import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../config/colors.dart';
import '../../../../core/api_service/api_service.dart';
import '../../../../core/models/faq_model.dart';
import '../../../../core/utils/app_font_weight.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/custom_text_2.dart';
import 'bloc/faq_bloc/faq_bloc.dart';
import 'bloc/faq_bloc/faq_event.dart';
import 'bloc/faq_bloc/faq_state.dart';

class FaqScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FAQBloc(ApiService()),
      child: FaqView(),
    );
  }
}

class FaqView extends StatefulWidget {
  @override
  _FaqViewState createState() => _FaqViewState();
}

class _FaqViewState extends State<FaqView> {
  String role = '';

  void _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      role = (prefs.get('role') is String)
          ? prefs.getString('role') ?? ''
          : prefs.getInt('role')?.toString() ?? '';
    });
    context.read<FAQBloc>().add(FetchFAQs(role));
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _loadUserData();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: Responsive.getWidth(16)),
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
                  SizedBox(width: Responsive.getWidth(110)),
                  WantText2(
                    text: "FAQ's",
                    fontSize: Responsive.getFontSize(18),
                    fontWeight: AppFontWeight.medium,
                    textColor: textBlack,
                  ),
                ],
              ),
            ),
            SizedBox(height: Responsive.getHeight(10)),

            // FAQ List
            BlocBuilder<FAQBloc, FAQState>(
              builder: (context, state) {
                if (state is FAQLoading) {
                  return Container(
                    width: Responsive.getMainWidth(context),
                    height: Responsive.getHeight(500),
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
                } else if (state is FAQError) {
                  return Container(
                    height: Responsive.getHeight(500),
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/profile_image/headphones.png",
                          width: Responsive.getWidth(64),
                          height: Responsive.getWidth(64),
                        ),
                        SizedBox(height: Responsive.getHeight(10)),
                        WantText2(
                          text: "No FAQ!",
                          fontSize: Responsive.getFontSize(20),
                          fontWeight: AppFontWeight.semiBold,
                          textColor: textBlack11,
                        ),
                      ],
                    ),
                  );
                } else if (state is FAQLoaded) {
                  return Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: Responsive.getWidth(10)),
                    // height: Responsive.getHeight(723),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: state.faqItems.length,
                      itemBuilder: (context, index) {
                        return FAQTile(faqItem: state.faqItems[index]);
                      },
                    ),
                  );
                } else {
                  return Container(
                    height: Responsive.getHeight(500),
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/profile_image/headphones.png",
                          width: Responsive.getWidth(64),
                          height: Responsive.getWidth(64),
                        ),
                        SizedBox(height: Responsive.getHeight(10)),
                        WantText2(
                          text: "No FAQ!",
                          fontSize: Responsive.getFontSize(20),
                          fontWeight: AppFontWeight.semiBold,
                          textColor: textBlack11,
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class FAQTile extends StatefulWidget {
  final FAQItem faqItem;

  FAQTile({required this.faqItem});

  @override
  _FAQTileState createState() => _FAQTileState();
}

class _FAQTileState extends State<FAQTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor:
              Colors.transparent, // Removes the top and bottom dividers
        ),
        child: Container(
          decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(
                      width: 1,
                      color: _isExpanded
                          ? Colors.transparent
                          : Colors.grey[300]!))),
          child: ExpansionTile(
            backgroundColor: _isExpanded ? Colors.grey[100] : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Responsive.getWidth(20)),
            ),
            trailing: _isExpanded
                ? Image.asset(
                    "assets/close.png",
                    width: Responsive.getWidth(24),
                    height: Responsive.getWidth(24),
                  )
                : Image.asset(
                    "assets/open.png",
                    width: Responsive.getWidth(24),
                    height: Responsive.getWidth(24),
                  ),
            title: Text(
              widget.faqItem.title,
              style: GoogleFonts.poppins(
                  letterSpacing: 1.5,
                  fontWeight: AppFontWeight.semiBold,
                  fontSize: Responsive.getFontSize(16)),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  widget.faqItem.para,
                  textAlign: TextAlign.start,
                  style: GoogleFonts.poppins(
                    letterSpacing: 1.5,
                    fontSize: Responsive.getFontSize(14),
                  ),
                ),
              ),
            ],
            onExpansionChanged: (bool expanded) {
              setState(() {
                _isExpanded = expanded;
              });
            },
          ),
        ),
      ),
    );
  }
}
