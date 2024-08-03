// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sort_child_properties_last

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scholarar/controller/auth_controller.dart';
import 'package:scholarar/util/color_resources.dart';
import 'package:scholarar/util/next_screen.dart';
import 'package:scholarar/view/custom/custom_button_widget.dart';
import 'package:scholarar/view/custom/custom_listtile_setting_screen.dart';
import 'package:intl/intl.dart';
import 'package:scholarar/view/screen/account/edite_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

String urlImagProfile = 'https://www.pngitem.com/pimgs/m/146-1468479_my-profile-icon-blank-profile-picture-circle-hd.png';

class _ProfileScreenState extends State<ProfileScreen> {
  AuthController authController = Get.find<AuthController>();
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

  final ImagePicker _picker = ImagePicker();
  XFile? _image;

  Future<void> pickImage(ImageSource source) async {
    final XFile? selectedImage = await _picker.pickImage(source: source);
    setState(() {
      _image = selectedImage;
    });
  }

  String formatDateOfBirth(String? dateOfBirth) {
    if (dateOfBirth == null) return "N/A";
    DateTime dob = DateTime.parse(dateOfBirth);
    DateFormat formatter = DateFormat('dd-MM-yyyy');
    return formatter.format(dob);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(
      builder: (authController) {
        var item = authController.userPassengerMap?['userDetails'];
        print("User Details: $item"); // Debug print to ensure data is fetched
        return Scaffold(
          backgroundColor: ColorResources.primaryColor,
          body: isLoading
              ? Center(child: CircularProgressIndicator())
              : _buildBody(authController),
        );
      },
    );
  }

  Widget _buildBody(AuthController authController) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Container(
          width: Get.width,
          height: Get.height,
          color: ColorResources.primaryColor,
          child: Stack(
            children: [
              Column(
                children: [
                  SizedBox(
                    height: 50,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () {
                            Get.back();
                          },
                          icon: FaIcon(FontAwesomeIcons.angleLeft, color: ColorResources.whiteColor),
                        ),
                        Text(
                          'ត្រឡប់ក្រោយ',
                          style: GoogleFonts.notoSerifKhmer(fontSize: 20, color: ColorResources.whiteColor),
                        ),
                      ],
                    ),
                  ),
                  Expanded(child: Container()),
                  Expanded(
                      child: Container(
                        width: Get.width,
                        height: Get.height,
                        color: ColorResources.whiteBackgroundColor,
                      )),
                ],
              ),
              Positioned(
                top: Get.height * 0.03,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        color: ColorResources.primaryColor,
                        height: 100,
                        width: Get.width,
                      ),
                      Container(
                        height: Get.height - 150,
                        child: _buildProfile(authController),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: Get.height * 0.1,
                left: (Get.width / 2) - 80,
                child: _buildImageProfile(authController),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageProfile(AuthController authController) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _image == null
            ? CircleAvatar(
          radius: 50,
          backgroundImage: Image.asset("assets/images/user.jpg").image,
        )
            : CircleAvatar(
          backgroundImage: Image.file(
            File(_image!.path),
          ).image,
          radius: 50,
        ),
        TextButton.icon(
          onPressed: () {
            Get.dialog(
              AlertDialog(
                title: Text(
                  'ជ្រើសរើសរូបភាព',
                  style: TextStyle(color: ColorResources.primaryColor),
                ),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Divider(),
                      TextButton.icon(
                        onPressed: () {
                          pickImage(ImageSource.gallery);
                          Get.back();
                        },
                        icon: Icon(Icons.photo),
                        label: Text("ជ្រើសរើសពីរូបភាព", style: TextStyle(color: ColorResources.blackColor)),
                      ),
                      Padding(padding: EdgeInsets.all(8.0)),
                      TextButton.icon(
                        onPressed: () {
                          pickImage(ImageSource.camera);
                          Get.back();
                        },
                        icon: Icon(Icons.camera_alt_outlined),
                        label: Text("បើកកាមេរ៉ា", style: TextStyle(color: ColorResources.blackColor)),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          icon: Icon(Icons.camera_alt_outlined),
          label: Text(
            'កែប្រែរូបភាព',
            style: TextStyle(
              color: ColorResources.primaryColor,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfile(AuthController authController) {
    var userNextDetails = authController.userPassengerMap?['userDetails'];
    return Container(
      decoration: BoxDecoration(
        color: ColorResources.whiteColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: 90),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "ព័ត៌មានរបស់ខ្ញុំ",
                  style: GoogleFonts.notoSerifKhmer(
                    fontSize: 28,
                    color: ColorResources.primaryColor,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Container(
              height: Get.height * 0.6,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                physics: BouncingScrollPhysics(),
                child: Column(
                  children: [
                    CustomListWidget.customListTile(
                      title: userNextDetails?['first_name'] ?? "N/A",
                      iconleading: Icons.person,
                      onPress: () {},
                    ),
                    SizedBox(height: 8),
                    CustomListWidget.customListTile(
                      title: userNextDetails?['last_name'] ?? "N/A",
                      iconleading: Icons.person,
                      onPress: () {},
                    ),
                    SizedBox(height: 8),
                    CustomListWidget.customListTile(
                      iconleading: Icons.email,
                      title: authController.userPassengerMap?['email'] ?? "N/A",
                      onPress: () {},
                    ),
                    SizedBox(height: 16),
                    CustomListWidget.customListTile(
                      title:"+855 ${ userNextDetails?['phone_number'] ?? "N/A"} ",
                      iconleading: Icons.phone,
                      onPress: () {},
                    ),
                    SizedBox(height: 8),
                    CustomListWidget.customListTile(
                      title: userNextDetails?['gender'] ?? "N/A",
                      iconleading: Icons.wc,
                      onPress: () {},
                    ),
                    SizedBox(height: 8),
                    CustomListWidget.customListTile(
                      title: formatDateOfBirth(userNextDetails?['date_of_birth']),
                      iconleading: Icons.calendar_today,
                      onPress: () {},
                    ),
                    SizedBox(height: 32),
                    CustomButtonWidget.buildButtonClick(
                      title: 'កែប្រែព័ត៌មាន',
                      onPress: () {
                        nextScreen(context, EditeProfileScreen());
                      },
                      size: 50,
                    ),
                    SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
