import 'package:artist/config/toast.dart';
import 'package:artist/core/api_service/api_service.dart';
import 'package:artist/core/utils/app_font_weight.dart';
import 'package:artist/core/widgets/custom_text.dart';
import 'package:artist/core/widgets/general_button.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/colors.dart';
import '../../core/utils/responsive.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  late DatabaseReference _databaseReference;
  bool isInMaintenance = false;
  @override
  void initState() {
    super.initState();

    loadKeysAndNavigate();
    // _requestPermissions();
    // final status = Permission.storage.status;
    // print(status);

    // _getToken();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received a message while in the foreground: ${message.messageId}');
      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
        _showLocalNotification(message);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Message clicked!');
    });

    _initializeLocalNotifications();
    _databaseReference = FirebaseDatabase.instance.ref('user');
    _getData();
  }

  void _getData() async {
    DataSnapshot snapshot = await _databaseReference.get();
    if (snapshot.exists) {
      var data = snapshot.value;
      print("Data from Firebase: $data");
      if (data == "true") {
        setState(() {
          isInMaintenance = true;
        });
      }
    } else {
      print("No data available.");
    }
  }

  Future<void> loadKeysAndNavigate() async {
    bool success = await ApiService.fetchStripeKeys();
    await Future.delayed(Duration(seconds: 2)); // Optional delay

    if (success) {
      _checkNotificationPermission(context);
      // _requestPermissions(context);
    } else {
      print("Failed to fetch keys");
    }
  }

  // Initialize local notifications
  void _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'chat_notifications',
      'Chat Notifications',
      channelDescription: 'Notifications for chat messages.',
      importance: Importance.high,
      priority: Priority.high,
      // sound: RawResourceAndroidNotificationSound("notification_sound"),
      playSound: true,
      showWhen: false,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      0,
      message.notification?.title ?? "No Title",
      message.notification?.body ?? "No Body",
      platformDetails,
    );
  }

  // Future<void> _requestPermissions() async {
  //
  // }

  String? FcmToken;
  Future<void> _getToken() async {
    FcmToken = await FirebaseMessaging.instance.getToken();
    print('FCM Token: $FcmToken');
  }

  // Future<void> _requestPermissions() async {
  //   FirebaseMessaging messaging = FirebaseMessaging.instance;
  //
  //   NotificationSettings settings = await messaging.requestPermission(
  //     alert: true,
  //     badge: true,
  //     sound: true,
  //   );
  //
  //   if (settings.authorizationStatus == AuthorizationStatus.authorized) {
  //     print('User granted permission');
  //   } else if (settings.authorizationStatus ==
  //       AuthorizationStatus.provisional) {
  //     print('User granted provisional permission');
  //   } else {
  //     print('User declined or has not accepted permission');
  //   }
  //   List<Permission> permissions = [
  //     Permission.storage,
  //     Permission.camera,
  //     Permission.microphone,
  //     Permission.location,
  //     Permission.phone,
  //     Permission.photos,
  //     // Permission.manageExternalStorage
  //   ];
  //
  //   Map<Permission, PermissionStatus> statuses = await permissions.request();
  //
  //   statuses.forEach((permission, status) {
  //     if (status.isGranted) {
  //       print('$permission granted');
  //     } else if (status.isDenied) {
  //       print('$permission denied');
  //     } else if (status.isPermanentlyDenied) {
  //       print('$permission permanently denied');
  //       openAppSettings();
  //     }
  //   });
  //
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   bool isLoggedIn = prefs.getString('UserToken') != null;
  //   String? role = prefs.getString('role');
  //   String customerUniqueId = (prefs.get('customerUniqueId') is String)
  //       ? prefs.getString('customerUniqueId') ?? ''
  //       : prefs.getInt('customerUniqueId')?.toString() ?? '';
  //
  //   Future.delayed(const Duration(seconds: 3), () {
  //     if (isLoggedIn) {
  //       sendFCMTokenUpdate(customerUniqueId.toString(), FcmToken.toString());
  //       if (role == 'customer') {
  //         Navigator.pushNamedAndRemoveUntil(
  //           context,
  //           '/User',
  //           (Route<dynamic> route) => false,
  //         );
  //       } else if (role == 'seller') {
  //         Navigator.pushNamedAndRemoveUntil(
  //           context,
  //           '/Artist',
  //           (Route<dynamic> route) => false,
  //         );
  //       }
  //     } else {
  //       Navigator.pushNamedAndRemoveUntil(
  //         context,
  //         '/SplashScreen1',
  //         (Route<dynamic> route) => false,
  //       );
  //     }
  //   });
  //   // _navigateToHomeScreen();
  // }

  Future<void> _checkNotificationPermission(BuildContext context) async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Get current notification settings
    NotificationSettings settings = await messaging.getNotificationSettings();

    print("Notification Permission Status: ${settings.authorizationStatus}");

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('✅ User has already granted permission');
      _getToken();
      _requestPermissions(context);
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('🟡 User has provisional permission');
      _requestPermissionsWithoutNotification(context);
    } else {
      _requestPermissionsWithoutNotification(context);
      print('❌ User has NOT granted permission');
      // You can show a custom dialog to ask the user to enable notifications
    }
  }

  // Future<void> _requestPermissionsCheckNotification(
  //     BuildContext context) async {
  //   FirebaseMessaging messaging = FirebaseMessaging.instance;
  //
  //   // Request notification permissions
  //   NotificationSettings settings = await messaging.requestPermission(
  //       alert: true,
  //       badge: true,
  //       sound: true,
  //       announcement: true,
  //       carPlay: true,
  //       criticalAlert: true,
  //       provisional: true);
  //
  //   if (settings.authorizationStatus == AuthorizationStatus.authorized) {
  //     print('User granted permission');
  //     _requestPermissions(context);
  //   } else if (settings.authorizationStatus ==
  //       AuthorizationStatus.provisional) {
  //     _requestPermissionsWithoutNotification(context);
  //     print('User granted provisional permission');
  //   } else {
  //     _requestPermissionsWithoutNotification(context);
  //     print('User declined or has not accepted permission');
  //   }
  // }

  Future<void> _requestPermissions(BuildContext context) async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // NotificationSettings settings = await messaging.requestPermission(
    //     alert: true,
    //     badge: true,
    //     sound: true,
    //     announcement: true,
    //     carPlay: true,
    //     criticalAlert: true,
    //     provisional: true);
    //
    // if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    //   print('User granted permission');
    // } else if (settings.authorizationStatus ==
    //     AuthorizationStatus.provisional) {
    //   print('User granted provisional permission');
    // } else {
    //   print('User declined or has not accepted permission');
    // }

    // Request other permissions
    List<Permission> permissions = [
      Permission.storage,
      Permission.camera,
      // Permission.microphone,
      Permission.location,
      // Permission.phone,
      Permission.photos,
    ];

    Map<Permission, PermissionStatus> statuses = await permissions.request();

    // for (var entry in statuses.entries) {
    //   if (entry.value.isPermanentlyDenied) {
    //     print('${entry.key} permanently denied');
    //     openAppSettings();
    //   } else if (entry.value.isDenied) {
    //     print('${entry.key} denied');
    //   } else {
    //     print('${entry.key} granted');
    //   }
    // }

    // Get shared preferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getString('UserToken') != null;
    String? role = prefs.getString('role');

    String customerUniqueId = (prefs.get('customerUniqueId') is String)
        ? prefs.getString('customerUniqueId') ?? ''
        : prefs.getInt('customerUniqueId')?.toString() ?? '';

    try {
      String? fcmToken = await messaging.getToken();
      if (fcmToken != null) {
        sendFCMTokenUpdate(customerUniqueId, fcmToken);
      } else {
        print("FCM Token is null");
      }
    } catch (e, stackTrace) {
      print("Error getting FCM Token: $e");
      print("Stack Trace: $stackTrace");
    }
    isInMaintenance
        ? Navigator.pushNamedAndRemoveUntil(
            context,
            '/NotFoundScreen',
            (Route<dynamic> route) => false,
          )
        : navigateToScreen(context, isLoggedIn: isLoggedIn, role: role);
    // Navigate after a short delay
    // Future.delayed(const Duration(seconds: 3), () {
    //   if (!context.mounted) return; // Ensure context is still valid
    //
    //   if (isLoggedIn) {
    //     if (role == 'customer') {
    //       Navigator.pushNamedAndRemoveUntil(
    //         context,
    //         '/User',
    //         (Route<dynamic> route) => false,
    //       );
    //     } else if (role == 'seller') {
    //       Navigator.pushNamedAndRemoveUntil(
    //         context,
    //         '/Artist',
    //         (Route<dynamic> route) => false,
    //       );
    //     }
    //   } else {
    //     Navigator.pushNamedAndRemoveUntil(
    //       context,
    //       '/SplashScreen1',
    //       (Route<dynamic> route) => false,
    //     );
    //   }
    // });
  }

  Future<void> _requestPermissionsWithoutNotification(
      BuildContext context) async {
    // Request other permissions
    List<Permission> permissions = [
      Permission.storage,
      Permission.camera,
      // Permission.microphone,
      Permission.location,
      // Permission.phone,
      Permission.photos,
    ];

    await permissions.request();

    // for (var entry in statuses.entries) {
    //   if (entry.value.isPermanentlyDenied) {
    //     print('${entry.key} permanently denied');
    //     openAppSettings();
    //   } else if (entry.value.isDenied) {
    //     print('${entry.key} denied');
    //   } else {
    //     print('${entry.key} granted');
    //   }
    // }

    // Get shared preferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // bool isLoggedIn = prefs.getString('UserToken') != null;
    bool isLoggedIn = prefs.getString('UserToken') != null;
    String? role = prefs.getString('role');

    String customerUniqueId = (prefs.get('customerUniqueId') is String)
        ? prefs.getString('customerUniqueId') ?? ''
        : prefs.getInt('customerUniqueId')?.toString() ?? '';

    isInMaintenance
        ? Navigator.pushNamedAndRemoveUntil(
            context,
            '/NotFoundScreen',
            (Route<dynamic> route) => false,
          )
        : navigateToScreen(context, isLoggedIn: isLoggedIn, role: role);

    // Future.delayed(const Duration(seconds: 3), () {
    //   if (!context.mounted) return; // Ensure context is still valid
    //
    //   if (isLoggedIn) {
    //     if (role == 'customer') {
    //       Navigator.pushNamedAndRemoveUntil(
    //         context,
    //         '/User',
    //         (Route<dynamic> route) => false,
    //       );
    //     } else if (role == 'seller') {
    //       Navigator.pushNamedAndRemoveUntil(
    //         context,
    //         '/Artist',
    //         (Route<dynamic> route) => false,
    //       );
    //     }
    //   } else {
    //     Navigator.pushNamedAndRemoveUntil(
    //       context,
    //       '/SplashScreen1',
    //       (Route<dynamic> route) => false,
    //     );
    //   }
    // });
  }

  void navigateToScreen(BuildContext context,
      {required bool isLoggedIn, String? role}) {
    Future.delayed(const Duration(seconds: 3), () {
      if (!context.mounted) return; // Ensure context is still valid

      if (isLoggedIn) {
        if (role == 'customer') {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/User',
            (Route<dynamic> route) => false,
          );
        } else if (role == 'seller') {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/Artist',
            (Route<dynamic> route) => false,
          );
        }
      } else {
        // Navigator.pushNamedAndRemoveUntil(
        //   context,
        //   '/SplashScreen1',
        //       (Route<dynamic> route) => false,
        // );
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/SplashScreen1',
          (Route<dynamic> route) => false,
        );
      }
    });
  }

  // Future<void> _requestPermissions() async {
  //   Map<Permission, PermissionStatus> statuses = await [
  //     Permission.camera,
  //     Permission.location,
  //     Permission.storage,
  //     Permission.phone,
  //     Permission.microphone,
  //     Permission.manageExternalStorage,
  //   ].request();
  //
  //
  //   // Map<Permission, PermissionStatus> statuses = await permissions.request();
  //
  //   bool allPermissionsGranted = true;
  //
  //   statuses.forEach((permission, status) {
  //     if (status.isGranted) {
  //       print('$permission granted');
  //     } else if (status.isDenied) {
  //       print('$permission denied');
  //       allPermissionsGranted = false;
  //     } else if (status.isPermanentlyDenied) {
  //       print('$permission permanently denied');
  //       allPermissionsGranted = false;
  //       openAppSettings(); // Redirect to settings if permanently denied
  //     }
  //   });
  //
  //   if (allPermissionsGranted) {
  //     print("All required permissions granted");
  //     _navigateToHomeScreen(); // Navigate only if all permissions are granted
  //   } else {
  //     print("Some permissions were denied. Please grant them.");
  //     // Optionally, show a dialog to inform the user about the denied permissions
  //   }
  // }

  // void _navigateToHomeScreen() {
  //   _checkLoginStatus();
  // }

  String responseMessage = '';
  void sendFCMTokenUpdate(
    String customerId,
    String fcmToken,
  ) async {
    try {
      final response = await ApiService().updateFCM(customerId, fcmToken);
      setState(() {
        responseMessage =
            response['message'] ?? 'FCM token updated successfully';
        // showToast(message: responseMessage);
      });
    } catch (e) {
      setState(() {
        responseMessage = e.toString();
        // showToast(message: responseMessage);
      });
    }
  }

  // void _checkLoginStatus() async {
  //
  // }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // SizedBox(
            //   height: Responsive.getHeight(250),
            // ),
            SizedBox(
              height: Responsive.getHeight(10),
            ),
            Image.asset(
              "assets/logo_3.png",
              height: Responsive.getHeight(200),
              width: Responsive.getWidth(300),
            ),
            // Text(
            //   "Artist",
            //   style: GoogleFonts.playfairDisplay(
            //       color: Colors.white,
            //       fontSize: Responsive.getFontSize(40),
            //       fontWeight: AppFontWeight.bold,
            //       letterSpacing: 1.5),
            // ),
            // WantText(
            //   text: "LOGO",
            //   fontSize: Responsive.getFontSize(32),
            //   fontWeight: AppFontWeight.bold,
            //   textColor: Colors.white,
            // ),
            // SizedBox(
            //   height: Responsive.getHeight(306),
            // ),
            Image.asset(
              "assets/splash_screen.png",
              height: Responsive.getHeight(55),
              width: Responsive.getHeight(311),
            ),
          ],
        ),
      ),
    );
  }
}

class SplashScreen1 extends StatelessWidget {
  const SplashScreen1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SplashScreenContent(
        onTap: () {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/SplashScreen2',
            (Route<dynamic> route) => false,
          );
        },
        sliderImage: 'assets/onboarding/onboarding_slider_1.png',
        backgroundImage: 'assets/onboarding/onboarding_1.png',
        stepImage: 'assets/onboarding/step_1.png',
        headingText: 'Discover the finest street art masterpiece.',
        currentIndex: 0,
        isShow: true,
      ),
    );
  }
}

// class NavigatorWidget extends StatelessWidget {
//   final int currentIndex;
//   const NavigatorWidget({super.key, required this.currentIndex});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       alignment: Alignment.center,
//       margin: const EdgeInsets.symmetric(vertical: 20),
//       height: 5,
//       width: 250,
//       child: ListView.builder(
//         scrollDirection: Axis.horizontal,
//         itemCount: 3,
//         shrinkWrap: true,
//         itemBuilder: (context, index) {
//           return Container(
//             margin: const EdgeInsets.symmetric(horizontal: 5),
//             padding: EdgeInsets.symmetric(
//                 vertical: 2, horizontal: index == currentIndex ? 20 : 5),
//             decoration: BoxDecoration(
//               color: index == currentIndex
//                   ? Colors.black
//                   : const Color(0XFF7D7D7D),
//               borderRadius: BorderRadius.circular(25),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

class SplashScreen2 extends StatelessWidget {
  const SplashScreen2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: SplashScreenContent(
          onTap: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/SplashScreen3',
              (Route<dynamic> route) => false,
            );
          },
          sliderImage: 'assets/onboarding/onboarding_slider_2.png',
          backgroundImage: 'assets/onboarding/onboarding_2.png',
          stepImage: 'assets/onboarding/step_2.png',
          headingText:
              'Experience the creativity of diverse and distinctive paintings.',
          currentIndex: 1,
          isShow: false,
        ));
  }
}

class SplashScreen3 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SplashScreenContent(
        onTap: () {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/HomeScreen',
            (Route<dynamic> route) => false,
          );
        },
        sliderImage: 'assets/onboarding/onboarding_slider_3.png',
        backgroundImage: 'assets/onboarding/onboarding_3.png',
        stepImage: 'assets/onboarding/step_3.png',
        headingText: 'Find the perfect offer tailored to your needs',
        currentIndex: 2,
        isShow: false,
      ),
    );
  }
}

class SplashScreenContent extends StatelessWidget {
  final String backgroundImage;
  final String sliderImage;
  final String stepImage;
  final String headingText;
  final int currentIndex;
  final bool isShow;
  final void Function()? onTap;

  const SplashScreenContent({
    super.key,
    required this.backgroundImage,
    required this.sliderImage,
    required this.stepImage,
    required this.headingText,
    required this.isShow,
    required this.currentIndex,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return SafeArea(
      child: Container(
        width: Responsive.getMainWidth(context),
        height: Responsive.getMainHeight(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: Responsive.getHeight(24)),
            Image.asset(
              sliderImage,
              width: Responsive.getWidth(375),
              height: Responsive.getHeight(2.3),
            ),
            SizedBox(height: Responsive.getHeight(57)),
            Image.asset(
              backgroundImage,
              width: Responsive.getWidth(318),
              height: Responsive.getHeight(308),
            ),
            SizedBox(height: Responsive.getHeight(15)),
            Container(
              width: Responsive.getWidth(242),
              child: Stack(
                children: [
                  if (isShow)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      left: 0,
                      child: Image.asset(
                        "assets/onboarding/loop.png",
                        height: 46,
                        width: 163,
                      ),
                    ),
                  Text(
                    headingText,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.portLligatSans(
                      fontWeight: AppFontWeight.regular,
                      fontSize: Responsive.getFontSize(30),
                      color: textBlack,
                    ),
                  ),
                ],
              ),
            ),
            Spacer(),
            currentIndex == 2
                ? GeneralButton(
                    Width: Responsive.getWidth(343),
                    onTap: () {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/SignIn',
                        (Route<dynamic> route) => false,
                      );
                    },
                    label: "Login",
                    isBoarderRadiusLess: true,
                    buttonClick: true,
                    isSelected: false,
                  )
                : SizedBox(),
            SizedBox(
              height: Responsive.getHeight(10),
            ),
            GeneralButton(
              Width: Responsive.getWidth(343),
              onTap: onTap,
              label: currentIndex == 2 ? "START" : "NEXT",
              isBoarderRadiusLess: true,
              buttonClick: false,
              isSelected: true,
            ),
            SizedBox(
              height: Responsive.getHeight(16),
            ),
          ],
        ),
      ),
    );
  }
}
// "Get Started"
