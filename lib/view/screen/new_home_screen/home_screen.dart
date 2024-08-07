import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scholarar/controller/auth_controller.dart';
import 'package:scholarar/controller/tracking_controller.dart';
import 'package:scholarar/util/app_constants.dart';
import 'package:scholarar/util/color_resources.dart';
import 'package:scholarar/util/firebase_api.dart';
import 'package:scholarar/util/next_screen.dart';
import 'package:scholarar/view/custom/custom_show_snakbar.dart';
import 'package:scholarar/view/screen/booking_driver/dri_to_pas.dart';
import 'package:scholarar/view/screen/booking_driver/booking_driver_screen.dart';
import 'package:scholarar/view/screen/new_home_screen/slide.dart';
import 'package:scholarar/view/screen/new_home_screen/booking_passapp.dart';
import '../../../controller/splash_controller.dart';

class NewHomeScreen extends StatefulWidget {
  const NewHomeScreen({super.key});

  @override
  State<NewHomeScreen> createState() => _NewHomeScreenState();
}

class _NewHomeScreenState extends State<NewHomeScreen> {
  final AuthController authController = Get.find<AuthController>();
  final TrackingController trackingController = Get.find<TrackingController>();
  final FirebaseAPI _firebaseAPI = FirebaseAPI();
  bool isLoading = false;

  @override
  void initState() {
    setState(() {
      init();
    });
    super.initState();
  }

  Future<void> init() async {
    await authController.getPassengerInfoController();
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 3,
      child: GetBuilder<SplashController>(builder: (splash){
      return Scaffold(
        appBar: _buildAppbar(),
        body:_buildBody(),
          );
        }
      ),
    );
  }
  //Todo: _buildAppbar
  AppBar _buildAppbar(){
    return AppBar(
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          CircleAvatar(
            backgroundImage: AssetImage('assets/images/logo.jpg'),
          ),
          SizedBox(width: 10,),
          TypewriterAnimatedTextKit(
            text: ['សូមស្វាគមន៍មកកាន់ Mr. Driver'],
            textStyle: TextStyle(
              color: Colors.red,
              fontSize: 19.0,
              fontWeight: FontWeight.bold,
            ),
            speed: Duration(milliseconds: 200),
          ),
        ],
      ),
      // actions: [
      //   IconButton(
      //       onPressed: () {
      //         nextScreen(context, DriverPick());
      //       },
      //       icon: Icon(
      //         Icons.notifications,
      //         color: Colors.red,
      //       ))
      // ],
    );
  }
  //Todo: _buildBody
  Widget _buildBody(){
    return Expanded(
      child: ListView(
        children: [
          SliderHome(),
          SizedBox(height: 20,),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [Text('សូមជ្រេីសរេីសការកក់របស់អ្នក', style: TextStyle(color: ColorResources.blackColor,fontSize: 19,fontWeight: FontWeight.w500),)]),
          ),
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Expanded(child: _buildHumanButton()),
          ),
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Expanded(child: _buildPassAppButton()),
          ),
        ],
      ),
    );
  }

  //Todo: buildHumanButton
  Widget _buildHumanButton() {
    var userNextDetails = authController.userPassengerMap?['userDetails'];
    return InkWell(
      onTap: () async{
        await _firebaseAPI.initNotifications();
        String? deviceToken = frmTokenPublic;
        print("deviceToken : $deviceToken");
        String? passengerId = userNextDetails?["_id"];
        print("passengerId : $passengerId");// Ensure this is the correct driver ID
        if (deviceToken != null && passengerId != null) {
          trackingController.updatePassengerTokenController(deviceToken, passengerId);
          isLoading = true;
          //customShowSnackBar('ការបើកការកក់របស់អ្នកទទួលបានជោគជ័យ', context, isError: false);
          nextScreen(context, BookingDriver());
        } else {
          customShowSnackBar('Device token or driver ID is missing', context, isError: true);
          nextScreen(context, BookingDriver());
        }
        nextScreen(context, BookingDriver());
      },
      child: Column(
        children: [
          SizedBox(height: 5,),
          Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                height: Get.height/4,
                child: Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                        color: ColorResources.backgroundBannerColor,
                      borderRadius: BorderRadius.circular(16)
                    ),
                    padding: EdgeInsets.all(5),
                    alignment: Alignment.center,
                    child: CircleAvatar(
                      backgroundImage: AssetImage('assets/images/human.jpg'),
                      radius: 50,
                    )
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 15),
                  child: Text('កក់អ្នកបេីកបរ', style: TextStyle(color: ColorResources.blackColor,fontSize: 17,fontWeight: FontWeight.bold),)),
            ],
          ),
        ],
      ),
    );
  }
  Widget _buildPassAppButton(){
    return InkWell(
      onTap: () {
        nextScreen(context, BookingPassApp());
      },
      child: Column(
        children: [
          SizedBox(height: 5,),
          Stack(
            alignment: Alignment.bottomCenter,
            children:[
              Container(
                height: Get.height/4,
                child: Card(
                  color: Colors.grey.shade400,
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                        color: ColorResources.backgroundBannerColor,
                        borderRadius: BorderRadius.circular(16)
                    ),
                    padding: EdgeInsets.all(5),
                    alignment: Alignment.center,
                    child: CircleAvatar(
                      backgroundImage: AssetImage('assets/images/passapp.jpg'),
                      radius: 50,
                    ),
                  ),
                ),
              ),
              Container(
                  margin: EdgeInsets.only(bottom: 15),
                  child: Text('កក់កង់បី', style: TextStyle(color: ColorResources.blackColor,fontSize: 17,fontWeight: FontWeight.bold),)),
            ]
          ),
        ],
      ),
    );
  }

}
