import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scholarar/controller/auth_controller.dart';
import 'package:scholarar/controller/splash_controller.dart';
import 'package:scholarar/util/app_constants.dart';
import 'package:scholarar/util/color_resources.dart';
import 'package:scholarar/util/next_screen.dart';
import 'package:scholarar/view/app/app_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  SharedPreferences? sharedPreferences;
  final AuthController authController = Get.find<AuthController>();
  final SplashController splashController = Get.find<SplashController>();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    init();  // Line 20
    afterSplash();  // Line 21
  }

  Future<void> init() async {
    await authController.getPassengerInfoController();
    if (mounted) {  // Line 27
      setState(() {  // Line 28
        isLoading = false;
      });
    }
  }

  Future<void> afterSplash() async {
    sharedPreferences = await SharedPreferences.getInstance();
    splashController.changeIndex(0);
    if (mounted) {  // Line 37
      try {
        String token = sharedPreferences!.getString(AppConstants.token) ?? '';  // Line 39
        if (token.isNotEmpty) {
          print("First Check Token $token");
          await authController.getUserInfo().then((_) {  // Line 42
            if (mounted) {  // Line 43
              nextScreenReplace(Get.context, AppScreen());  // Line 44
            }
          });
        } else {
          print("Logout Token: ");
          if (mounted) {  // Line 48
            nextScreenReplace(Get.context, AppScreen());  // Line 49
          }
        }
      } catch (e) {
        print('else');
        Timer(Duration(seconds: 5), () {  // Line 54
          if (mounted) {  // Line 55
            nextScreenReplace(Get.context, AppScreen());  // Line 56
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorResources.whiteColor,
      body: Center(
        child: Image(
          width: 300,
          height: 300,
          image: AssetImage(AppConstants.logo),
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
