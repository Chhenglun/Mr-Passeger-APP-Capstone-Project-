// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sort_child_properties_last

import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scholarar/controller/auth_controller.dart';
import 'package:scholarar/util/color_resources.dart';
import 'package:scholarar/view/custom/custom_listtile_setting_screen.dart';
import 'package:intl/intl.dart';
import 'package:scholarar/view/screen/home/current_location.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

String urlImagProfile =
    'https://www.pngitem.com/pimgs/m/146-1468479_my-profile-icon-blank-profile-picture-circle-hd.png';

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
          appBar: AppBar(
            leading: IconButton(
              onPressed: () {
                Get.back();
              },
              icon: Icon(
                Icons.arrow_back,
                color: ColorResources.primaryColor,
              ),
            ),
            title: Text(
              'ព័ត៌មានផ្ទាល់ខ្លួន',
              style: GoogleFonts.notoSerifKhmer(
                fontSize: 20,
                color: ColorResources.primaryColor,
              ),
            ),
            centerTitle: true,
            backgroundColor: ColorResources.backgroundBannerColor,
          ),
          body: isLoading != false
              ? Center(child: CircularProgressIndicator())
              : _buildBody(authController),
        );
      },
    );
  }

  Widget _buildBody(AuthController authController) {
    //var userDetails = authController.userPassengerMap?['userDetails'];
    var userDetails = authController.userPassengerMap;
    print("aaa ${userDetails}");
    if (userDetails == null) {
      return Center(child: CircularProgressIndicator());
    }

    return SafeArea(
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: _buildProfile(authController),
      ),
    );
  }

  Widget _buildProfile(AuthController authController) {
    var userNextDetails = authController.userPassengerMap?['userDetails'];
    var userDetails = authController.userPassengerMap;
    return userDetails != null
        ? Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  SizedBox(height: 16),
                  // Todo : Image Profile
                  _image == null
                      ? Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: CachedNetworkImageProvider(urlImagProfile),
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                      : CircleAvatar(
                          backgroundImage: Image.file(
                            File(_image!.path),
                          ).image,
                          radius: 50,
                        ),
                  // Todo: pickImage
                  TextButton.icon(
                    onPressed: () {
                      Get.dialog(
                        AlertDialog(
                          title: Text(
                            'Choose an option',
                            style:
                                TextStyle(color: ColorResources.primaryColor),
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
                                  label: Text("Select from Gallery"),
                                ),
                                Padding(padding: EdgeInsets.all(8.0)),
                                TextButton.icon(
                                  onPressed: () {
                                    pickImage(ImageSource.camera);
                                    Get.back();
                                  },
                                  icon: Icon(Icons.camera_alt_outlined),
                                  label: Text("Take a Photo"),
                                )
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
                  // SizedBox(height: 16),
                  // Todo: More information
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "ព័ត៌មានផ្ទាល់ខ្លួន",
                        style: GoogleFonts.notoSerifKhmer(
                          fontSize: 16,
                          color: ColorResources.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  // Todo: ListTile of Profile
                  //Text(authController.userPassengerMap?['email'] ?? "N/A"),
                  SizedBox(height: 16),
                  CustomListWidget.customListTile(
                    title: userNextDetails?['first_name'] ?? "N/A",
                    iconleading: Icons.person,
                    onPress: () {},
                  ),
                  SizedBox(height: 16),
                  CustomListWidget.customListTile(
                    title: userNextDetails?['last_name'] ?? "N/A",
                    iconleading: Icons.person,
                    onPress: () {},
                  ),
                  SizedBox(height: 16),
                  CustomListWidget.customListTile(
                    iconleading: Icons.email,
                    title: authController.userPassengerMap?['email'] ?? "N/A",
                    onPress: () {},
                  ),
                  SizedBox(height: 16),
                  CustomListWidget.customListTile(
                    title: userNextDetails?['phone_number'] ?? "N/A",
                    iconleading: Icons.phone,
                    onPress: () {},
                  ),
                  SizedBox(height: 16),
                  CustomListWidget.customListTile(
                    title: userNextDetails?['gender'] ?? "N/A",
                    iconleading: Icons.wc,
                    onPress: () {},
                  ),
                  SizedBox(height: 16),
                  CustomListWidget.customListTile(
                    title: formatDateOfBirth(userNextDetails?['date_of_birth']),
                    iconleading: Icons.calendar_today,
                    onPress: () {},
                  ),
                  SizedBox(height: 16),
                ],
              ),
            ),
          )
        : Center(child: CircularProgressIndicator());
  }
}
