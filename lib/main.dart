import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:artist/test.dart';
import 'package:artist/view/artist_side/artist_create_art_page/artist_upload_art_screens/artist_add_story_screen.dart';
import 'package:artist/view/artist_side/artist_create_art_page/artist_upload_art_screens/artist_exhibition_or_auction_screen.dart';
import 'package:artist/view/artist_side/artist_create_art_page/artist_upload_art_screens/artist_exhibition_space_screen.dart';
import 'package:artist/view/artist_side/artist_create_art_page/artist_upload_art_screens/artist_list_exhibition_screen.dart';
import 'package:artist/view/artist_side/artist_create_art_page/artist_upload_art_screens/artist_private_upload_screnn.dart';
import 'package:artist/view/artist_side/artist_create_art_page/artist_upload_art_screens/artist_review_art_screen.dart';
import 'package:artist/view/artist_side/artist_create_art_page/artist_upload_art_screens/artist_online_upload_art_screen.dart';
import 'package:artist/view/artist_side/artist_create_art_page/artist_upload_art_screens/artist_upload_picture_screen.dart';
import 'package:artist/view/artist_side/artist_create_art_page/artist_upload_art_screens/artist_upload_picture_screen_for_mookup.dart';
import 'package:artist/view/artist_side/artist_home_page/artist_home_screens/all_art_for_story_screen.dart';
import 'package:artist/view/artist_side/artist_home_page/artist_home_screens/artist_art_enquiry_chat_screen.dart';
import 'package:artist/view/artist_side/artist_home_page/artist_home_screens/artist_booking_request_screen.dart';
import 'package:artist/view/artist_side/artist_home_page/artist_home_screens/artist_my_art_for_home_screen.dart';
import 'package:artist/view/artist_side/artist_home_page/artist_home_screens/artist_return_order_all_chat_screen.dart';
import 'package:artist/view/artist_side/artist_home_page/artist_home_screens/artist_total_order_screen.dart';
import 'package:artist/view/artist_side/artist_my_art_page/artist_my_art_screen.dart';
import 'package:artist/view/artist_side/artist_my_art_page/single_art_screen/artist_single_art_screen.dart';
import 'package:artist/view/artist_side/artist_notification/artist_notification_screen.dart';
import 'package:artist/view/artist_side/artist_profile_screen/artist_profile_screens/artist_address_book_screen.dart';
import 'package:artist/view/artist_side/artist_profile_screen/artist_profile_screens/artist_donate_now_screen.dart';
import 'package:artist/view/artist_side/artist_profile_screen/artist_profile_screens/artist_faq_screen.dart';
import 'package:artist/view/artist_side/artist_profile_screen/artist_profile_screens/artist_help_center_all_chat_screen.dart';
import 'package:artist/view/artist_side/artist_profile_screen/artist_profile_screens/artist_help_center_screen.dart';
import 'package:artist/view/artist_side/artist_profile_screen/artist_profile_screens/artist_my_details_screen.dart';
import 'package:artist/view/artist_side/artist_profile_screen/artist_profile_screens/artist_my_ticket_screen.dart';
import 'package:artist/view/artist_side/artist_profile_screen/artist_profile_screens/artist_notification_settings_screen.dart';
import 'package:artist/view/artist_side/artist_order_page/artist_order_screen.dart';
import 'package:artist/view/artist_side/artist_profile_screen/artist_profile_screens/artist_privacy_policy_screen.dart';
import 'package:artist/view/artist_side/artist_profile_screen/artist_profile_screens/bank_details_screen.dart';
import 'package:artist/view/artist_side/artist_profile_screen/artist_profile_screens/wallet_pages/artist_wallet_screen.dart';
import 'package:artist/view/artist_side/artist_side_bottom_nav_bar.dart';
import 'package:artist/view/auth/account_created_screen.dart';
import 'package:artist/view/auth/forgot_password.dart';
import 'package:artist/view/auth/sign_in_screen.dart';
import 'package:artist/view/auth/signup_screen.dart';
import 'package:artist/view/choose_role/choose_role_screen.dart';
import 'package:artist/view/not_found_screen.dart';
import 'package:artist/view/splash_screens/splash_screen.dart';
import 'package:artist/view/user_side/artists_stories_screen/all_artist_stories_screen.dart';
import 'package:artist/view/user_side/cart_screen/checkout/confirm_order_screen.dart';
import 'package:artist/view/user_side/cart_screen/checkout/select_address_screen.dart';
import 'package:artist/view/user_side/home_screen/artist_profile/all_artist_screen.dart';
import 'package:artist/view/user_side/home_screen/home_screen.dart';
import 'package:artist/view/user_side/home_screen/product_detail/all_private_product_details.dart';
import 'package:artist/view/user_side/home_screen/product_detail/all_product_details.dart';
import 'package:artist/view/user_side/home_screen/upcoming_exhibition/upcoming_exhibitions_screen.dart';
import 'package:artist/view/user_side/notification/notification_screen.dart';
import 'package:artist/view/user_side/profile_screen/profile_screens/address_book_screen.dart';
import 'package:artist/view/user_side/profile_screen/profile_screens/art_enquiry_chat_screen.dart';
import 'package:artist/view/user_side/profile_screen/profile_screens/art_enquiry_screen.dart';
import 'package:artist/view/user_side/profile_screen/profile_screens/faq_screen.dart';
import 'package:artist/view/user_side/profile_screen/profile_screens/help_center_all_chat_screen.dart';
import 'package:artist/view/user_side/profile_screen/profile_screens/help_center_screen.dart';
import 'package:artist/view/user_side/profile_screen/profile_screens/mira_monet_team_chat_screen.dart';
import 'package:artist/view/user_side/profile_screen/profile_screens/my_details_screen.dart';
import 'package:artist/view/user_side/profile_screen/profile_screens/my_ticket_screen.dart';
import 'package:artist/view/user_side/profile_screen/profile_screens/notification_settings_screen.dart';
import 'package:artist/view/user_side/profile_screen/profile_screens/order_screen/order_screen.dart';
import 'package:artist/view/user_side/profile_screen/profile_screens/order_screen/return_order_all_chat_screen.dart';
import 'package:artist/view/user_side/profile_screen/profile_screens/privacy_policy_screen.dart';
import 'package:artist/view/user_side/profile_screen/profile_screens/private_sale_enquiry_screen.dart';
import 'package:artist/view/user_side/profile_screen/profile_screens/wishlist_list_screen.dart';
import 'package:artist/view/user_side/user_side_bottom_nav_bar.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

import 'core/api_service/base_url.dart';


FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Permission.notification.isDenied.then((value) {
    if (value) {
      Permission.notification.request();
    }
  });
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: "AIzaSyBPupfrdJD66G1QwYXInkUhXBrHrhEMrlU",
        appId: "1:1065014349983:android:e4dc59284bef6d248692aa",
        messagingSenderId: "1065014349983",
        projectId: "mira-monet",
      ),
    );
  } else if (Platform.isIOS) {
    await Firebase.initializeApp(
      name: "miramonet",
      options: FirebaseOptions(
        apiKey: "AIzaSyBPupfrdJD66G1QwYXInkUhXBrHrhEMrlU",
        appId: "1:1065014349983:ios:506541d614cfa8258692aa",
        messagingSenderId: "1065014349983",
        projectId: "mira-monet",
        storageBucket: "mira-monet.firebasestorage.app",
        iosBundleId: "com.miramonet.artist", // Your iOS bundle ID
      ),
    );
  } else {
    await Firebase.initializeApp();
  }
  FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);

  // Declare iOS initialization settings first
  const DarwinInitializationSettings initializationSettingsDarwin =
      DarwinInitializationSettings(
    requestSoundPermission: true,
    requestBadgePermission: true,
    requestAlertPermission: true,
  );

  // Declare Android initialization settings
  var initializationSettingsAndroid =
      const AndroidInitializationSettings('@mipmap/ic_launcher');

  // Combine both settings
  var initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsDarwin,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  runApp(MyApp());
}

Future<void> fetchStripeKeys() async {
  final response =
      await http.get(Uri.parse("$serverUrl/get_key"));

  if (response.statusCode == 200) {
    final data = json.decode(response.body);

    if (data['status'] == true) {
      String publishableKey = data['data']['stripe_key'];
      String secretKey = data['data']['secret_key'];

      if (publishableKey.isNotEmpty && secretKey.isNotEmpty) {
        Stripe.publishableKey = publishableKey;

        await Stripe.instance.applySettings();
      } else {
        throw Exception("Stripe keys are empty.");
      }
    } else {
      throw Exception("Failed to fetch Stripe keys.");
    }
  } else {
    throw Exception("Failed to load Stripe keys.");
  }
}

Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message: ${message.messageId}');
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Widget build(BuildContext context) {
    return
      MaterialApp(
      title: 'Artist',
      initialRoute: '/',
      routes: {
        "/": (context) => SplashScreen(),
        "/NotFoundScreen": (context) => NotFoundScreen(),
        "/SplashScreen1": (context) => SplashScreen1(),
        "/SplashScreen2": (context) => SplashScreen2(),
        "/SplashScreen3": (context) => SplashScreen3(),
        "/ChooseRole": (context) => ChooseRoleScreen(),
        "/User": (context) => UserSideBottomNavBar(index: 0),
        "/HomeScreen": (context) => HomeScreen(),
        "/SignIn": (context) => SignInScreen(),
        "/SignIn/ForgotPassword": (context) => ForgotPassword(),
        "/SignIn/ForgotPassword/PasswordChanged": (context) =>
            AccountCreatedScreen(),
        "/SignUP": (context) => SignUpScreen(),
        "/SignIn/User": (context) => UserSideBottomNavBar(index: 0),
        "/SignUP/User": (context) => UserSideBottomNavBar(index: 0),
        "/User/Notification": (context) => NotificationScreen(),
        // "/User/SingleUpcomingExhibitionScreen": (context) =>
        //     SingleUpcomingExhibitionScreen(),
        // "/User/SingleUpcomingExhibitionScreen/TicketScreen": (context) =>
        //     TicketScreen(),
        "/User/AllProductDetails": (context) => AllProductDetails(),
        "/User/UpcomingExhibitionsScreen": (context) =>
            UpcomingExhibitionsScreen(),
        "/User/AllPrivateProductDetails": (context) =>
            AllPrivateProductDetails(),

        "/User/SingleProductDetailScreen/SelectAddressScreen": (context) =>
            SelectAddressScreen(),
        // "/User/SingleProductDetailScreen/SelectAddressScreen/PaymentScreen":
        //     (context) => PaymentScreen(),
        "/User/AllArtistScreen": (context) => AllArtistScreen(),
        "/User/AllArtistStoriesScreen": (context) => AllArtistStoriesScreen(),
        "/User/Profile/MyDetails": (context) => MyDetailsScreen(),
        "/User/Profile/ArtEnquiryScreen": (context) => ArtEnquiryScreen(),
        "/User/Profile/PrivateSaleEnquiryScreen": (context) =>
            PrivateSaleEnquiryScreen(),
        // "/User/Profile/DonateNow": (context) => DonateNowScreen(),
        "/User/Profile/AddressBook": (context) => AddressBookScreen(),
        "/User/Profile/NotificationSetting": (context) =>
            NotificationSettingsScreen(),
        "/User/Profile/Faq": (context) => FaqScreen(),
        "/User/Profile/OnlineArtEnquiryChatScreen": (context) =>
            ArtEnquiryChatScreen(
              index: 0,
            ),
        "/User/Profile/PrivateArtEnquiryChatScreen": (context) =>
            ArtEnquiryChatScreen(
              index: 1,
            ),
        "/User/Profile/PrivacyPolicy": (context) => PrivacyPolicyScreen(),
        "/User/Profile/WishlistListScreen": (context) => WishlistListScreen(),
        "/User/Profile/OrderScreen": (context) => OrderScreen(),
        "/User/Profile/HelpCenterScreen": (context) => HelpCenterScreen(),
        "/User/Profile/MiraMonetTeamChatScreen": (context) =>
            MiraMonetTeamChatScreen(),
        "/User/Profile/HelpCenterAllChatScreen": (context) =>
            HelpCenterAllChatScreen(),
        "/User/Profile/ReturnOrderAllChatScreen": (context) =>
            ReturnOrderAllChatScreen(),
        "/User/Profile/MyTicketScreen": (context) => MyTicketScreen(),
        "/User/Cart/SelectAddressScreen": (context) => SelectAddressScreen(),
        // "/User/Cart/SelectAddressScreen/PaymentScreen": (context) =>
        //     PaymentScreen(),
        "/User/Cart/SelectAddressScreen/OrderConfirmationPage": (context) =>
            OrderConfirmationPage(),
        "/Artist": (context) => ArtistSideBottomNavBar(index: 0),
        "/Artist/order": (context) => ArtistSideBottomNavBar(index: 3),
        "/Artist/totalorder": (context) => ArtistTotalOrderScreen(
              initialTabIndex: 0,
            ),
        "/SignIn/Artist": (context) => ArtistSideBottomNavBar(index: 0),
        "/SignUP/Artist": (context) => ArtistSideBottomNavBar(index: 0),
        "/Artist/Profile": (context) => ArtistSideBottomNavBar(index: 4),
        "/Artist/ArtistMyArtForHomeScreen": (context) =>
            ArtistMyArtForHomeScreen(),
        "/Artist/ArtistReturnOrderAllChatScreen": (context) =>
            ArtistReturnOrderAllChatScreen(),
        "/Artist/AllArtForStoryScreen": (context) => AllArtForStoryScreen(),
        "/Artist/ArtistMyEnquiryReplayScreen0": (context) =>
            ArtistArtEnquiryChatScreen(
              index: 0,
            ),
        "/Artist/ArtistMyEnquiryReplayScreen1": (context) =>
            ArtistArtEnquiryChatScreen(
              index: 1,
            ),
        "/Artist/ArtistMyArtScreen": (context) => ArtistMyArtScreen(),
        "/Artist/ArtistMyArtScreen/ArtistSingleArtScreen": (context) =>
            ArtistSingleArtScreen(),
        "/Artist/ArtistBookingRequestScreen": (context) =>
            ArtistBookingRequestScreen(),
        "/Artist/ArtistListExhibitionScreen": (context) =>
            ArtistListExhibitionScreen(),
        "/Artist/ArtistOnlineUploadArtScreen": (context) =>
            ArtistOnlineUploadArtScreen(),
        "/Artist/ArtistPrivateUploadScrenn": (context) =>
            ArtistPrivateUploadScrenn(),
        "/Artist/ArtistExhibitionOrAuctionScreen": (context) =>
            ArtistExhibitionOrAuctionScreen(),
        "/Artist/ArtistExhibitionSpaceScreen": (context) =>
            ArtistExhibitionSpaceScreen(),
        // "/Artist/ArtistExhibitionUploadScreen": (context) =>
        //     ArtistExhibitionUploadScreen(),
        // "/Artist/ArtistOnlineUploadArtScreen/ArtistAdditionalDetailScreen":
        //     (context) => ArtistAdditionalDetailScreen(),
        "/Artist/ArtistOnlineUploadArtScreen/ArtistAdditionalDetailScreen/ArtistUploadPictureScreen":
            (context) => ArtistUploadPictureScreen(),
        "/Artist/ArtistOnlineUploadArtScreen/ArtistAdditionalDetailScreen/ArtistUploadPictureScreenForMookup":
            (context) => ArtistUploadPictureScreenForMookup(),
        "/Artist/ArtistOnlineUploadArtScreen/ArtistAdditionalDetailScreen/ArtistUploadPictureScreen/ArtistReviewArtScreen":
            (context) => ArtistReviewArtScreen(),
        "/Artist/Notification": (context) => ArtistNotificationScreen(),
        "/Artist/Profile/MyDetails": (context) => ArtistMyDetailsScreen(),
        "/Artist/Profile/BankDetailsScreen": (context) => BankDetailsScreen(),
        "/Artist/Profile/ArtistMyTicketScreen": (context) =>
            ArtistMyTicketScreen(),
        "/Artist/Profile/ArtistDonateNowScreen": (context) =>
            ArtistDonateNowScreen(),
        "/Artist/Profile/AddressBook": (context) => ArtistAddressBookScreen(),
        "/Artist/Profile/NotificationSetting": (context) =>
            ArtistNotificationSettingsScreen(),
        "/Artist/Profile/Faq": (context) => ArtistFaqScreen(),
        "/Artist/Profile/ArtistHelpCenterScreen": (context) =>
            ArtistHelpCenterScreen(),
        "/Artist/Profile/ArtistHelpCenterAllChatScreen": (context) =>
            ArtistHelpCenterAllChatScreen(),
        "/Artist/Profile/PrivacyPolicy": (context) =>
            ArtistPrivacyPolicyScreen(),
        "/Artist/Profile/OrderScreen": (context) => ArtistOrderScreen(),
        "/Artist/Profile/ArtistWalletScreen": (context) =>
            ArtistWalletScreen(),
        "/Artist/Profile/ArtistAddStoryScreen": (context) =>
            ArtistAddStoryScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
    MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Test());
  }
}
