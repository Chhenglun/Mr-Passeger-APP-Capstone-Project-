
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scholarar/util/color_resources.dart';
import 'package:scholarar/view/custom/custom_listtile_setting_screen.dart';

class DriverProfileScreen extends StatefulWidget {
  const DriverProfileScreen({super.key});

  @override
  State<DriverProfileScreen> createState() => _DriverProfileScreenState();
}

String urlImagProfile =
    'https://www.pngitem.com/pimgs/m/146-1468479_my-profile-icon-blank-profile-picture-circle-hd.png';

class _DriverProfileScreenState extends State<DriverProfileScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  Future<void> pickImage(ImageSource source) async {
    final XFile? selectedImage = await _picker.pickImage(source: source);
    setState(() {
      _image = selectedImage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(
            Icons.arrow_back,
            color: ColorResources.whiteBackgroundColor,
          ),
        ),
        title: Text(
          'ព័ត៌មានផ្ទាល់ខ្លួន',
          style: GoogleFonts.notoSerifKhmer(
            fontSize: 20,
            color: ColorResources.whiteBackgroundColor,
          ),
        ),
        centerTitle: true,
        backgroundColor: ColorResources.primaryColor.withOpacity(0.8),
      ),
      //backgroundColor: ColorResources.primaryColor,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  Container(
                      height: Get.height * 0.4,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            ColorResources.primaryColor.withOpacity(0.8),
                            ColorResources.whiteBackgroundColor,
                          ],
                        ),
                        color: ColorResources.primaryColor,
                      )),
                  Container(
                    height: Get.height * 0.5,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          ColorResources.whiteBackgroundColor,
                          ColorResources.primaryColor.withOpacity(0.2),
                        ],
                      ),
                      color: ColorResources.whiteBackgroundColor,
                    ),
                  ),
                ],
              ),
              Positioned(top: 40, left: 10, right: 10, child: _buildProfile()),
            ],
          )),
    );
  }

  //Todo : _buildProfile
  Widget _buildProfile() {
    return Container(
      height: MediaQuery.of(context).size.height,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          width: Get.width * 0.9,
          //height: Get.height,
          decoration: BoxDecoration(
            //color: ColorResources.whiteBackgroundColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Container(
            height: MediaQuery.of(context).size.height,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  SizedBox(height: 16),
                  //Todo : Image Profile
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

                  //Todo: More information
                  SizedBox(height: 32),
                  //Todo: ListTile of Profile
                  CustomListWidget.customListTile(
                    title: 'ឈ្មោះ',
                    iconleading: Icons.person,
                    onPress: () {},
                  ),
                  SizedBox(height: 16),
                  CustomListWidget.customListTile(
                    iconleading: Icons.email,
                    title: 'អ៊ីម៉ែល',
                    onPress: () {},
                  ),
                  SizedBox(height: 16),
                  CustomListWidget.customListTile(
                    title: 'លេខទូរស័ព្ទ',
                    iconleading: Icons.phone,
                    onPress: () {},
                  ),
                  SizedBox(height: 16),
                  CustomListWidget.customListTile(
                    title: 'ថ្ងៃខែឆ្នាំកំណត់',
                    iconleading: Icons.calendar_today,
                    onPress: () {},
                  ),
                  SizedBox(height: 16),
                  CustomListWidget.customListTile(
                    title: 'ភេទ',
                    iconleading: Icons.wc,
                    onPress: () {},
                  ),
                  SizedBox(height: 16),
                  CustomListWidget.customListTile(
                    title: 'អាសយដ្ឋាន',
                    iconleading: Icons.location_on,
                    onPress: () {},
                  ),
                  SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
