// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:scholarar/controller/splash_controller.dart';
import 'package:scholarar/util/app_constants.dart';
import 'package:scholarar/util/color_resources.dart';
import 'package:scholarar/view/screen/account/login_screen.dart';
import 'package:scholarar/view/screen/account/sing_in_account_screen.dart';
import 'package:scholarar/view/screen/new_home_screen/booking_screen.dart';
import 'package:scholarar/view/screen/new_home_screen/home_screen.dart';
import 'package:scholarar/view/screen/profile/settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppScreen extends StatefulWidget {
  const AppScreen({super.key});

  @override
  State<AppScreen> createState() => _AppScreenState();
}

class _AppScreenState extends State<AppScreen> {
  SharedPreferences? sharedPreferences;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Widget>? listScreen;
  final PageController _pageController = PageController();
  final NewHomeScreen _newHomeScreen = NewHomeScreen();
  final BookingHistoryScreen _bookingHistoryScreen = BookingHistoryScreen();
  final SettingScreen _settingScreen = SettingScreen();

  @override
  void initState() {
    super.initState();
    _initSharedPreferences();
    listScreen = [
      _newHomeScreen,
      _bookingHistoryScreen,
      _settingScreen,
    ];
  }

  Future<void> _initSharedPreferences() async {
    sharedPreferences = await SharedPreferences.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 4,
      child: GetBuilder<SplashController>(builder: (splash) {
        return Scaffold(
          key: _scaffoldKey,
          body: _buildBody(splash),
          bottomNavigationBar: _buildBottomNavigationBar(splash),
        );
      }),
    );
  }

  // Todo: buildBody
  Widget _buildBody(SplashController splash) {
    return PageView(
      physics: NeverScrollableScrollPhysics(),
      controller: _pageController,
      onPageChanged: (index) {
        splash.changeIndex(index);
      },
      children: listScreen!,
    );
  }

  // Todo: buildBottomNavigationBar
  Widget _buildBottomNavigationBar(SplashController splash) {
    return NavigationBarTheme(
      data: NavigationBarThemeData(
        indicatorColor: ColorResources.primaryColor,
        labelTextStyle: MaterialStateProperty.all(TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            fontStyle: FontStyle.normal)),
      ),
      child: NavigationBar(
        backgroundColor: ColorResources.primaryColor,
        height: 70,
        selectedIndex: splash.selectedIndex,
        onDestinationSelected: (index) async {
          splash.changeIndex(index);
          _pageController.jumpToPage(index);
         /* if (index == 2) {
            // Check if user has token
            String token = sharedPreferences?.getString(AppConstants.token) ?? "";
            if (token.isNotEmpty) {
              splash.changeIndex(index);
              _pageController.jumpToPage(index);
            } else {
              Get.to(SignInAccountScreen());
            }
          } else {
            splash.changeIndex(index);
            _pageController.jumpToPage(index);
          }*/
        },
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        destinations: [
          NavigationDestination(
            icon: FaIcon(Icons.home, color: Colors.white, size: 20),
            selectedIcon: FaIcon(Icons.home, color: Colors.white, size: 33),
            label: 'Home'.tr,
          ),
          NavigationDestination(
            icon: FaIcon(FontAwesomeIcons.history, color: Colors.white, size: 17),
            selectedIcon:
            FaIcon(FontAwesomeIcons.history, color: Colors.white, size: 29),
            label: 'My Booking'.tr,
          ),
          NavigationDestination(
            icon: FaIcon(Icons.person_pin, color: Colors.white, size: 20),
            selectedIcon: FaIcon(Icons.person_pin, color: Colors.white, size: 33),
            label: 'Account'.tr,
          ),
        ],
      ),
    );
  }
}
