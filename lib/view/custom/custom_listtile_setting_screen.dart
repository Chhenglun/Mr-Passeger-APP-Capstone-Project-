// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
//import 'package:google_fonts/google_fonts.dart';
import 'package:scholarar/util/color_resources.dart';
import 'package:scholarar/util/style.dart';

class CustomListWidget {
  //Todo: customListTileSettingScreen
  static Widget customListTileSettingScreen({
    required String title,
    Widget? titleColors,
    required IconData icon,
    //required trailing,
    bool isSwitched = false,
    required Function onPress,
    Function(bool)? onChange,
    //required Function onTap,
  }) {
    return Container(
      height: 60,
      width: Get.width * 0.9,
      decoration: BoxDecoration(
        color: ColorResources.greyColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: ColorResources.blackColor,
          //size: 22,
        ),
        title: Text(
          title,
          style: textStyleMedium.copyWith(
            fontSize: 18,
            color:  ColorResources.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        titleAlignment: ListTileTitleAlignment.center,
        trailing: FaIcon(FontAwesomeIcons.angleRight, color: ColorResources.primaryColor),
        // trailing: IconButton(
        //   icon: FaIcon(FontAwesomeIcons.angleRight, color: Colors.blueGrey),
        //   onPressed: () => onTap(),
        // ),
        onTap: () => onPress(),
      ),
    );
  }

  //Todo: customListTileNew
  static Widget customListTile({
    required String title,
    required Function onPress,
    required IconData iconleading, 
  }) {
    return Container(
      width: Get.width * 0.9,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          ListTile(
            leading: Icon(iconleading, color: Colors.blueGrey,) ,
            title: Text(
              title,
              style: textStyleMedium.copyWith(
                fontSize: 18,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            titleAlignment: ListTileTitleAlignment.center,
            // trailing: IconButton(
            //   icon: Icon(Icons.edit , color: Colors.blueGrey, size: 30,),
            //   color: ColorResources.primaryColor,
            //   onPressed: () => onPress(),
            // ),
            onTap: () => onPress(),
          ),
          Divider(),
        ],
      ),
    );
  }

  //Todo: Texformfield
  static Widget customTextformfield({
    required String labelText,
    required IconData icon,
    required Function(String) validator,
    required Function(String) onChanged,
    required TextInputType keyboardType,
    required bool obscureText,
    required TextInputAction textInputAction,
    required TextStyle style,
    required TextEditingController controller,
  }) {
    {
      return TextFormField(
        controller: controller,
        onChanged: onChanged,
        obscureText: obscureText,
        textInputAction: textInputAction,
        keyboardType: keyboardType,
        style: style,
        validator: (value) => validator(value!),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.grey),
          prefixIconColor: Colors.grey,
          labelText: labelText,
          floatingLabelStyle: TextStyle(color: Colors.grey),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey, width: 2)),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.white, width: 2)),
          labelStyle: TextStyle(color: Colors.grey),
        ),
      );
    }
  }
}
