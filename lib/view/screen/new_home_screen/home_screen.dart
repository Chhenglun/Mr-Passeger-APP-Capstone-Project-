import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scholarar/util/color_resources.dart';
import 'package:scholarar/util/next_screen.dart';
import 'package:scholarar/view/screen/home/booking_driver.dart';
import 'package:scholarar/view/screen/home/slide.dart';
import 'package:scholarar/view/screen/new_home_screen/booking_passapp.dart';
import 'package:scholarar/view/screen/new_home_screen/developer_screen.dart';
import 'package:scholarar/view/screen/new_home_screen/premium.dart';
import '../../../controller/splash_controller.dart';

class NewHomeScreen extends StatefulWidget {
  const NewHomeScreen({super.key});

  @override
  State<NewHomeScreen> createState() => _NewHomeScreenState();
}

class _NewHomeScreenState extends State<NewHomeScreen> {

  @override

  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 3,
      child: GetBuilder<SplashController>(builder: (splash){
      return Scaffold(
        // appBar: AppBar(
        //   backgroundColor: Colors.red.shade600,
        //   centerTitle: true,
        //   title: Text('Mr. Driver App',style: TextStyle(fontSize: 24,color: Colors.white),),
        // ),
        appBar: AppBar(
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
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
              speed: Duration(milliseconds: 200),
            ),
          ],
        ),
        actions: [
          IconButton(
              onPressed: () {
                // LocalNotifications.showSimpleNotification(
                //     title: "Message from KUNVATH",
                //     body: "Hello! How are you today?",
                //     payload: "This is simple data");
              },
              icon: Icon(
                Icons.notifications,
                color: Colors.red,
              ))
        ],
      ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SliderHome(),
                    SizedBox(height: 20,),
                    Container(
                      //alignment: Alignment.centerLeft,
                        margin: EdgeInsets.only(left: 10),
                        child: Text('សូមជ្រេីសរេីសការកក់របស់អ្នក', style: TextStyle(color: ColorResources.blackColor,fontSize: 24,fontWeight: FontWeight.bold),)),
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Expanded(child: _buildHumanButton()),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Expanded(child: _buildPassAppButton()),
                    ),
                    //PremiumPlanPage()
                  ],
                ),
              ),
            ),
          ],
        ),
          );
        }
      ),
    );
  }
  Widget _buildHumanButton() {
    return InkWell(
      onTap: () {
        nextScreen(context, BookingDriver());
      },
      // onTap: () {
      //   //await _firebaseAPI.initNotifications();
      //   String? deviceToken =frmTokenPublic; // Use the token obtained from initNotifications
      //   String driverId =authController.userPassengerMap?["userDetails"]["_id"]; // Ensure this is the correct driver ID
      //   if (deviceToken != null && driverId != null) {
      //     _trackingController.updateToken(deviceToken, driverId);
      //     isLoading = true;
      //     customShowSnackBar('ការបើកការកក់របស់អ្នកទទួលបានជោគជ័យ', context, isError: false);
      //     nextScreen(context, CurrentLocation());
      //   } else {
      //     customShowSnackBar('Device token or driver ID is missing', context,
      //         isError: true);
      //   }
      // },
      child: Column(
        children: [

          SizedBox(height: 8,),
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
                margin: EdgeInsets.only(bottom: 20),
                  child: Text('កក់អ្នកបេីកបរ', style: TextStyle(color: ColorResources.blackColor,fontSize: 18,fontWeight: FontWeight.bold),)),
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
          SizedBox(height: 8,),
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
                  margin: EdgeInsets.only(bottom: 20),
                  child: Text('កក់កង់បី', style: TextStyle(color: ColorResources.blackColor,fontSize: 18,fontWeight: FontWeight.bold),)),
            ]
          ),
        ],
      ),
    );
  }

}
