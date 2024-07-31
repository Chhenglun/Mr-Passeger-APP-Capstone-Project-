import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scholarar/util/next_screen.dart';
import 'package:scholarar/view/screen/home/current_location.dart';
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
        appBar: AppBar(
          backgroundColor: Colors.red,
          centerTitle: true,
          title: Text('Mr.Driver',style: TextStyle(fontSize: 24,color: Colors.white),),
        ),
        body: Column(
          children: [
            Expanded(
              child: Column(
                children: [
                  Expanded(child: _buildHumanButton()),
                  Expanded(child: _buildPassAppButton()),
                ],
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
        nextScreen(context, CurrentLocation());
      },
      child: Card(
        color: Colors.grey,
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          alignment: Alignment.center,
          child: CircleAvatar(
            backgroundImage: AssetImage('assets/images/human.jpg'),
            radius: 60,
          )
        ),
      ),
    );
  }
  Widget _buildPassAppButton(){
    return InkWell(
      onTap: () {},
      child: Card(
        color: Colors.grey,
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          alignment: Alignment.center,
          child: CircleAvatar(
            backgroundImage: AssetImage('assets/images/passapp.jpg'),
            radius: 60,
          ),
        ),
      ),
    );
  }

}
