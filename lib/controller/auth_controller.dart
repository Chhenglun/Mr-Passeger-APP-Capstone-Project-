// ignore_for_file: await_only_futures, avoid_print, unnecessary_null_comparison, prefer_const_constructors, unused_local_variable, deprecated_member_use

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:scholarar/data/model/body/auth_model.dart';
import 'package:scholarar/data/repository/auth_repository.dart';
import 'package:scholarar/helper/token_helper.dart';
import 'package:scholarar/util/app_constants.dart';
import 'package:scholarar/util/loading_dialog.dart';
import 'package:scholarar/util/next_screen.dart';
import 'package:scholarar/view/custom/custom_show_snakbar.dart';
import 'package:scholarar/view/screen/account/login_screen.dart';
import 'package:scholarar/view/screen/splash/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController extends GetxController implements GetxService {
  final AuthRepository authRepository;
  late final SharedPreferences sharedPreferences;
  final TokenHelper _tokenHelper = TokenHelper();
  AuthController({required this.authRepository, required this.sharedPreferences});

  // deviceInfo
  String? deviceName;
  String? deviceToken;
  String? pushToken;
  String? location;
  String? country;
  String? ipAddress;
  int? pushChannel;

  //set newb
  bool _isFirstName = false;
  bool _isLastName = false;
  bool _isGender = false;
  bool _isPhoneNumber = false;
  bool _isEmail = false;
  bool _isPassword = false;
  bool _isConfirmPassword = false;
  bool _isAgree = false;
  bool _isEnableVerificationCode = false;

  // set
  bool _isLoading = false;
  bool _isTypingCompleted = false;
  bool _userName = false;
  String _verificationCode = "";
  List? _subscriptionList;
  PickedFile? _pickedImage;
  File? _file;

  // get new
  bool get isFirstName => _isFirstName;
  bool get isLastName => _isLastName;
  bool get isGender => _isGender;
  bool get isPhoneNumber => _isPhoneNumber;
  bool get isEmail => _isEmail;
  bool get isPassword => _isPassword;
  bool get isConfirmPassword => _isConfirmPassword;
  bool get isAgree => _isAgree;
  Map<String, dynamic>? _userInfoMap;
  Map<String, dynamic>? _userPassengerMap;
  //get
  Map<String, dynamic>? get userPassengerMap => _userPassengerMap;
  bool get isLoading => _isLoading;
  bool get isTypingCompleted => _isTypingCompleted;
  bool get userName => _userName;
  List? get subscriptionList => _subscriptionList;
  Map<String, dynamic>? get userInfoMap => _userInfoMap;
  bool get isEnableVerificationCode => _isEnableVerificationCode;
  String get verificationCode => _verificationCode;
  PickedFile? get pickedImage => _pickedImage;
  File? get file => _file;

  final hidePassword = true.obs;
  final email = TextEditingController(); // Controller for email input
  final lastName = TextEditingController(); // Controller for last name input
  final username = TextEditingController(); // Controller for username input
  final password = TextEditingController(); // Controller for password input
  final firstName = TextEditingController(); // Controller for first name input
  final phoneNumber =
      TextEditingController(); // Controller for phone number input
  GlobalKey<FormState> signUpFormKey =
      GlobalKey<FormState>(); // Form key for form validation

  String token = "";
  String role = "";
  final String key = "secure_basicInfo_key";
  static const String noCache = "noCache";

  setTypingCompleted(bool isCompleted) {
    _isTypingCompleted = isCompleted;
    update();
  }

  setUserName(bool userName) {
    _userName = userName;
    update();
  }

  setPassword(bool isPassword) {
    _isPassword = isPassword;
    update();
  }

  setConfirmPassword(bool isConfirmPassword) {
    _isConfirmPassword = isConfirmPassword;
    update();
  }

  updateVerificationCode(String query) {
    if (query.length == 6) {
      _isEnableVerificationCode = true;
    } else {
      _isEnableVerificationCode = false;
    }
    _verificationCode = query;
    update();
  }

  void setCache({required String token}) async {
    const storage = FlutterSecureStorage();
    storage.write(key: "token", value: token);
  }

  Future<String> getCache() async {
    const storage = FlutterSecureStorage();
    String? content = await storage.read(key: "token");
    return content ?? noCache;
  }

  Future<void> isCheckToken({context, page}) async {
    try {
      String token = sharedPreferences.getString(AppConstants.token)!;
      if (token.isNotEmpty) {
        print("Hello Profile Token $token");
        nextScreen(context, page);
      } else {
        print("No Token :");
        nextScreen(context, LoginScreen());
      }
    } catch (e) {
      nextScreen(context, LoginScreen());
    }
  }

//Todo : GetIPNetwork
  Future<void> getNetworkIP() async {
    try {
      _isLoading = true;
      update();
      var response = await http.get(Uri.parse('https://api.ipify.org'));
      if (response.statusCode == 200) {
        ipAddress = response.body;
        _isLoading = false;
        update();
      } else {
        throw Exception('Failed to get network IP');
      }
      _isLoading = false;
      update();
    } catch (e) {
      print(e.toString());
      _isLoading = false;
      update();
    }
  }

  // Todo: phoneSignIn
  Future phoneSignIn(AuthModel authModel, context) async {
    loadingDialogs(context);
    try {
      _isLoading = true;
      Response apiResponse = await authRepository.signInWithPhone(authModel);
      if (apiResponse.statusCode == 200) {
        if (apiResponse.body['message'] == "OK") {
          Navigator.pop(context);
          Map map = apiResponse.body;
          try {
            token = map['data']["token"];
          } catch (e) {
            print(e.toString());
          }
          if (token != null && token.isNotEmpty) {
            authRepository.saveUserToken(token: token);
          }
        } else {
          customShowSnackBar("${apiResponse.body['message']}".tr, context);
          Navigator.pop(context);
        }
      } else {
        customShowSnackBar("serverDown".tr, context);
        Navigator.pop(context);
      }
      _isLoading = false;
      update();
    } catch (e) {
      print(e.toString());
      _isLoading = false;
      update();
    }
  }

  Future loginWithPhone(BuildContext context,
      {required String phone, required String password}) async {
    loadingDialogs(Get.context!);
    try {
      _isLoading = true;
      update();
      Response apiResponse = await authRepository.loginWithPhone(phone, password, context);
      if (apiResponse.body['status'] == 200) {
        print("Hello World: ${apiResponse.body['message']}");
        if (apiResponse.body['message'] == "OK") {
          Navigator.pop(Get.context!);
          Map map = apiResponse.body;
          try {
            token = map['data']["token"];
          } catch (e) {
            print(e.toString());
          }
          if (token != null && token.isNotEmpty) {
            authRepository.saveUserToken(token: token);
          }
        } else {
          customShowSnackBar("${apiResponse.body['message']}".tr, context);
          Navigator.pop(context);
        }
      } else {
        customShowSnackBar("serverDown".tr, context);
        Navigator.pop(context);
      }
    } catch (e) {
      print(e.toString());
      _isLoading = false;
      update();
    }
  }

  //Todo : LoginWithEmail
  Future loginWithEmail(BuildContext context,
      {required String email, required String password}) async {
    loadingDialogs(Get.context!);
    try {
      _isLoading = true;
      update();
      Response apiResponse =
          await authRepository.loginWithEmail(email, password, context);
      if (apiResponse.body['status'] == 200) {
        if (apiResponse.body['message'] == "OK") {
          Navigator.pop(Get.context!);
          Map map = apiResponse.body;
          try {
            token = map['data']["token"];
          } catch (e) {
            print(e.toString());
          }
          if (token != null && token.isNotEmpty) {
            await _tokenHelper.saveToken(token: token).then((_) async {
              nextScreenNoReturn(Get.context!, SplashScreen());
            });
          }
          _isLoading = false;
          update();
        } else {
          customShowSnackBar("${apiResponse.body['message']}".tr, Get.context!);
          Navigator.pop(Get.context!);
        }
      } else {
        customShowSnackBar("${apiResponse.body['message']}".tr, Get.context!);
        Navigator.pop(Get.context!);
      }
    } catch (e) {
      print("Error B");
      print(e.toString());
      _isLoading = false;
      update();
    }
  }

  Future<void> postDeviceToken(String passengerID) async {
    print(passengerID);
    print(frmTokenPublic);
    final String url = 'http://ec2-54-82-25-173.compute-1.amazonaws.com:8000/api/trips/updatePassengerToken';

    final Map<String, dynamic> data = {
      "passenger_id": passengerID,
      "deviceToken": frmTokenPublic
    };

    final response = await http.post(
      Uri.parse(url),
      // headers: <String, String>{
      //   'Content-Type': 'application/json',
      // },
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      print('Posted device token successfully');
    } else {
      print('response.statusCode device token ${response.statusCode}');
      print('Failed to post data device token');
    }
  }

  //Todo: LoginPassager
  Future<void> loginPassenger(
      BuildContext context, {
        String? email,
        String? phoneNumber,
        required String password,
      }) async {
    loadingDialogs(Get.context!);
    try {
      print("LoginPassenger: $email, $phoneNumber, $password");
      _isLoading = true;
      update();

      Response apiResponse = await authRepository.loginPassager(email!, phoneNumber!, password, context);

      if (apiResponse.statusCode == 200) {
        Navigator.pop(Get.context!);
        Map<String, dynamic> map = apiResponse.body;

        // Post device token
        await postDeviceToken(map['_id']);

        try {
          role = map['role'];
          print("Role: $role");
        } catch (e) {
          print(e.toString());
          print("Role Error: $e");
        }

        try {
          token = map["token"];
        } catch (e) {
          print(e.toString());
          customShowSnackBar("Invalid phone/email or password!".tr, Get.context!, isError: true);
        }

        if (token != null && token.isNotEmpty) {
          if (role == "passenger") {
            await _tokenHelper.saveToken(token: token).then((_) async {
              customShowSnackBar('successfulLoginAccount'.tr, Get.context!, isError: false);
              nextScreenNoReturn(Get.context!, SplashScreen());
            });
          } else {
            customShowSnackBar('Invalid role! You are not a passenger.'.tr, Get.context!, isError: true);
          }
        } else {
          customShowSnackBar('theAccountHasAlreadyBeenTaken'.tr, Get.context!, isError: true);
        }

        _isLoading = false;
        update();
      } else {
        Navigator.pop(Get.context!);
        customShowSnackBar('Invalid Email/Phone or Password'.tr, Get.context!, isError: true);
      }
    } catch (e) {
      print("Error B");
      print(e.toString());
      Navigator.pop(Get.context!);
      customShowSnackBar('Error during login. Please try again.'.tr, Get.context!, isError: true);
      _isLoading = false;
      update();
    }
  }



  //Todo: RegisterController
  Future registerController(BuildContext context,
      {required String name,
      required String gender,
      required String email,
      required String password,
      required String confirmPassword}) async {
    try {
      _isLoading = true;
      update();
      Response apiResponse = await authRepository.registerBooking(
          name, gender, email, password, phoneNumber as String);
      if (apiResponse.body['status'] == 200 &&
          apiResponse.body['message'] == "OK") {
        print("Register Success : ${apiResponse.body['message']}");
        Map map = apiResponse.body;
        String message = '';
        try {
          message = map["message"];
        } catch (e) {
          print(e.toString());
        }
        try {
          token = map['data']["token"];
        } catch (e) {
          print(e.toString());
        }
        if (token != null && token.isNotEmpty) {
          _tokenHelper.saveToken(token: token);
        }
        customShowSnackBar('successfulCreateAccount'.tr, Get.context!,
            isError: false);
        await _tokenHelper.saveToken(token: token).then((_) async {
          nextScreenNoReturn(Get.context!, SplashScreen());
        });
      } else {
        customShowSnackBar('thePhoneHasAlreadyBeenTaken'.tr, Get.context!,
            isError: true);
        if (apiResponse.hasError is String) {
          _isLoading = false;
          update();
        } else {
          _isLoading = false;
          update();
        }
      }
      _isLoading = false;
      update();
    } catch (e) {
      print(e.toString());
      _isLoading = false;
      update();
    }
  }

//Todo: RegisterPassager
  Future registerPassagerController(
      BuildContext context, {
        required String firstName,
        required String lastName,
        String? email,
        required String password,
        required String phoneNumber,
        required String gender,
        required String dateOfBirth,
      }) async {
    try {
      _isLoading = true;
      update();

      // Log the input parameters
      print("Registering passenger with: $firstName, $lastName, $email, $password, $phoneNumber, $gender, $dateOfBirth");

      Response apiResponse = await authRepository.registerPassager(
        firstName,
        lastName,
        email!,
        password,
        phoneNumber,
        gender,
        dateOfBirth,
      );

      // Log the response status and body
      print("Response status: ${apiResponse.statusCode}");
      print("Response body: ${apiResponse.body}");

      if (apiResponse.statusCode == 201 && apiResponse.body['status_code'] == "success") {
        print("Register Success : ${apiResponse.body['status_code']}");
        Map map = apiResponse.body;
        try {
          token = map["token"];
        } catch (e) {
          print(e.toString());
        }
        if (token != null && token.isNotEmpty) {
          _tokenHelper.saveToken(token: token);
        }
        customShowSnackBar('successfulCreateAccount'.tr, Get.context!,
            isError: false);
        await _tokenHelper.saveToken(token: token).then((_) async {
          nextScreenNoReturn(Get.context!, SplashScreen());
        });
      } else {
        customShowSnackBar('theAccountHasAlreadyBeenTaken'.tr, Get.context!, isError: true);
      }

      _isLoading = false;
      update();
    } catch (e) {
      print("Exception caught: ${e.toString()}");
      customShowSnackBar('An error occurred. Please try again.', context, isError: true);
      _isLoading = false;
      update();
    }
  }

//Todo: editePassengerController
//   Future editePassengerController(
//     BuildContext context, {
//     String? firstName,
//     String? lastName,
//     String? phoneNumber,
//     String? dateOfBirth,
//     String? gender,
//     String? email,
//     String? oldPassword,
//     String? newPassword,
//   required String userId,
//   required String token,
//   }) async {
//     try {
//       _isLoading = true;
//       update();
//      Response apiResponse = await authRepository.editePassengerRepository(firstName:firstName, lastName:lastName, phoneNumber:, gender, dateOfBirth, email, oldPassword, newPassword)
//   }catch(e){
//     print(e.toString());
//     customShowSnackBar('An error occurred. Please try again.', context, isError: true);
//     }}

  // Todo: signOut
  Future signOut(context) async {
    try {
      _isLoading = true;
      update();
      await _tokenHelper.clearStorage().then((_) {
        _userPassengerMap = null;
        update();
        print("Sign Out");
        print("User Info : $_userPassengerMap");
        nextScreenNoReturn(context, SplashScreen());
      });
      _isLoading = false;
      update();
    } catch (e) {
      print(e.toString());
      _isLoading = false;
      update();
    }
  }

  // Todo: getUserInfo
  Future getUserInfo() async {
    try {
      _isLoading = true;
      Response apiResponse = await authRepository.getUserInfo();
      if (apiResponse.body['status'] == "success") {
        _userInfoMap = apiResponse.body['data'];
        print("User Info : $_userInfoMap");
        _isLoading = false;
        update();
      } else {
        _userInfoMap = null;
        _isLoading = false;
        update();
      }
      _isLoading = false;
      update();
    } catch (e) {
      print(e.toString());
      _isLoading = false;
      update();
    }
  }

  //Todo: getPassagerInfo
  Future getPassengerInfoController() async {
    try {
      _isLoading = true;
      //update();
      Response response = await authRepository.getPassengerRepo();
      if (response.body["status"] == 200 &&
          response.body["message"] == "User login success") {
        print("b sl o ${response.body}");
        _userPassengerMap = response.body;
        newUserInfo = response.body;
        print("UserEmail : ${response.body["email"]}");
        print("Get Passager Info : $_userPassengerMap");
        _isLoading = false;
        update();
      } else {
        print("getPassengerProfileError1");
        _isLoading = false;
        update();
      }
    } catch (e) {
      print("getPassengerProfileCatch2");
      throw e.toString();
    }
  }

  //Todo: getSubscriptionList
  Future getSubscriptionList() async {
    try {
      _isLoading = true;
      update();
      Response response = await authRepository.getSubscription();
      if (response.body['status'] == 200) {
        print("getSubscription");
        _subscriptionList = response.body['data']['lists'];
        _isLoading = false;
        update();
      } else {
        print("getSubscriptionError");
        _isLoading = false;
        update();
      }
    } catch (e) {
      print("getSubscriptionCatch");
      throw e.toString();
    }
  }

  //Capstone
  Future registerBoookingController(
    BuildContext context, {
    required String name,
    required String gender,
    required String phoneNumber,
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      update();
      Response apiResponse = await authRepository.registerBooking(
          name, gender, email, password, phoneNumber);
      print(apiResponse.body['status']);
      if (apiResponse.body['status'] == 200) {
        print("Register Success : ${apiResponse.body['message']}");
        Map map = apiResponse.body;
        String message = '';
        try {
          message = map["status_code"];
        } catch (e) {
          print("status_code");
          print(e.toString());
        }
        try {
          token = map["token"];
        } catch (e) {
          print("token");
          print(e.toString());
        }
        if (token != null && token.isNotEmpty) {
          _tokenHelper.saveToken(token: token);
        }
        customShowSnackBar('successfulCreateAccount'.tr, Get.context!,
            isError: false);
        await _tokenHelper.saveToken(token: token).then((_) async {
          nextScreenNoReturn(Get.context!, SplashScreen());
        });
      }
      // else {
      //   customShowSnackBar('thePhoneHasAlreadyBeenTaken'.tr, Get.context!,
      //       isError: true);
      //   if (apiResponse.hasError is String) {
      //     _isLoading = false;
      //     print('false re1');
      //     update();
      //   } else {
      //     _isLoading = false;
      //     print('false re2');
      //     update();
      //   }
      // }
      _isLoading = false;
      update();
    } catch (e) {
      print('false re1');
      print(e.toString());
      _isLoading = false;
      update();
    }
  }
}
