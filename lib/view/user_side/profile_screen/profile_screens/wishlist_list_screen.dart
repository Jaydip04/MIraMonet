import 'package:artist/core/api_service/api_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../config/colors.dart';
import '../../../../core/models/user_side/wishlist_model.dart';
import '../../../../core/utils/app_font_weight.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/custom_text_2.dart';
import '../../home_screen/product_detail/single_product/single_product_detail_screen.dart';

class WishlistListScreen extends StatefulWidget {
  const WishlistListScreen({super.key});

  @override
  State<WishlistListScreen> createState() => _WishlistListScreenState();
}

class _WishlistListScreenState extends State<WishlistListScreen> {
  String? customerUniqueID;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String customerUniqueId = (prefs.get('customerUniqueId') is String)
        ? prefs.getString('customerUniqueId') ?? ''
        : prefs.getInt('customerUniqueId')?.toString() ?? '';

    setState(() {
      customerUniqueID = customerUniqueId;
    });
  }

  Future<void> _refreshWishlist() async {
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    _loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<List<WishlistItem>>(
        future: ApiService().fetchWishlist(customerUniqueID.toString()),
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
            print(snapshot.error);
            return Container(
              height: Responsive.getMainHeight(context),
              width: Responsive.getMainWidth(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/heart_empty.png",
                    width: Responsive.getWidth(64),
                    height: Responsive.getWidth(64),
                  ),
                  SizedBox(
                    height: Responsive.getHeight(24),
                  ),
                  WantText2(
                      text: "No Wish List Item!",
                      fontSize: Responsive.getFontSize(20),
                      fontWeight: AppFontWeight.semiBold,
                      textColor: textGray17),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Container(
              height: Responsive.getMainHeight(context),
              width: Responsive.getMainWidth(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/heart_empty.png",
                    width: Responsive.getWidth(64),
                    height: Responsive.getWidth(64),
                  ),
                  SizedBox(
                    height: Responsive.getHeight(24),
                  ),
                  WantText2(
                      text: "No Wish List Item!",
                      fontSize: Responsive.getFontSize(20),
                      fontWeight: AppFontWeight.semiBold,
                      textColor: textGray17),
                ],
              ),
            );
          } else {
            final wishlist = snapshot.data!;
            return RefreshIndicator(
              onRefresh: _refreshWishlist,
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: SafeArea(
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
                                        color: textFieldBorderColor,
                                        width: 1.0)),
                                child: Icon(
                                  Icons.arrow_back_ios_new_outlined,
                                  size: Responsive.getWidth(19),
                                ),
                              ),
                            ),
                            SizedBox(width: Responsive.getWidth(100)),
                            WantText2(
                              text: "Wishlist",
                              fontSize: Responsive.getFontSize(18),
                              fontWeight: AppFontWeight.medium,
                              textColor: textBlack,
                            ),
                          ],
                        ),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: wishlist.length,
                        itemBuilder: (context, index) {
                          final item = wishlist[index];
                          print(item.status);
                          return Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: Responsive.getWidth(20),
                                    vertical: Responsive.getWidth(2)),
                                child: Divider(
                                  color: Color(0XFFE6E6E6),
                                ),
                              ),
                              Container(
                                height: Responsive.getHeight(100),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (_) =>
                                                    SingleProductDetailScreen(
                                                        artUniqueId:
                                                            item.artUniqueId)));
                                      },
                                      child: ClipRRect(
                                        child: Image.network(
                                          item.artImages[0].image,
                                          width: Responsive.getWidth(100),
                                          height: double.infinity,
                                          fit: BoxFit.contain,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                            Responsive.getWidth(4)),
                                      ),
                                    ),
                                    SizedBox(
                                      width: Responsive.getWidth(6),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: Responsive.getWidth(239),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    child: WantText2(
                                                        text: item.title,
                                                        fontSize: Responsive
                                                            .getFontSize(14),
                                                        fontWeight:
                                                            AppFontWeight
                                                                .semiBold,
                                                        textColor: textBlack11),
                                                    width: Responsive.getWidth(
                                                        220),
                                                  ),
                                                  WantText2(
                                                      text: item.artistName,
                                                      fontSize: Responsive
                                                          .getFontSize(12),
                                                      fontWeight:
                                                          AppFontWeight.regular,
                                                      textColor: Color.fromRGBO(
                                                          128, 128, 128, 1)),
                                                ],
                                              ),
                                              GestureDetector(
                                                child: Image.asset(
                                                  "assets/delete.png",
                                                  width:
                                                      Responsive.getWidth(18),
                                                  height:
                                                      Responsive.getWidth(18),
                                                ),
                                                onTap: () async {
                                                  print(
                                                      "wishlist_id : ${item.wishlist_id}");
                                                  await ApiService()
                                                      .deleteWishlistItem(item
                                                          .wishlist_id
                                                          .toString())
                                                      .then((onValue) {
                                                    _refreshWishlist();
                                                  });
                                                },
                                              )
                                            ],
                                          ),
                                        ),
                                        Spacer(),
                                        Container(
                                          width: Responsive.getWidth(239),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              WantText2(
                                                  text: "\$ ${item.price}",
                                                  fontSize:
                                                      Responsive.getFontSize(
                                                          14),
                                                  fontWeight:
                                                      AppFontWeight.semiBold,
                                                  textColor: textBlack11),
                                              item.status == "Sold"
                                                  ? SizedBox()
                                                  : GestureDetector(
                                                      onTap: () async {
                                                        print(
                                                            "customer_unique_id : ${customerUniqueID}");
                                                        print(
                                                            "art_unique_id : ${item.artUniqueId}");
                                                        print(
                                                            "wishlist_id : ${item.wishlist_id.toString()}");
                                                        await ApiService()
                                                            .moveToCart(
                                                                customerUniqueID
                                                                    .toString(),
                                                                item.artUniqueId
                                                                    .toString())
                                                            .then((onValue) {
                                                          _refreshWishlist();
                                                        });
                                                      },
                                                      child: Container(
                                                        height: Responsive
                                                            .getHeight(30),
                                                        width:
                                                            Responsive.getWidth(
                                                                95),
                                                        decoration: BoxDecoration(
                                                            color: textBlack11,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        6)),
                                                        child: Center(
                                                          child: WantText2(
                                                              text:
                                                                  "Move To Cart",
                                                              fontSize: Responsive
                                                                  .getFontSize(
                                                                      10),
                                                              fontWeight:
                                                                  AppFontWeight
                                                                      .medium,
                                                              textColor: white),
                                                        ),
                                                      ),
                                                    )
                                            ],
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
