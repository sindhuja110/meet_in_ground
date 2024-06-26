import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:meet_in_ground/Screens/authenticate/login_page.dart';
import 'package:meet_in_ground/util/Services/PreferencesService.dart';
import 'package:meet_in_ground/util/Services/refferral_service.dart';
import 'package:meet_in_ground/constant/themes_service.dart';
import 'package:http/http.dart' as http;
import 'package:meet_in_ground/widgets/Loader.dart';

import '../../util/Services/mobileNo_service.dart';
import 'userdetails_page.dart';

class SetPasswordPage extends StatefulWidget {
  final String mobile;
  final String color;
  final String hero;
  final int status;

  const SetPasswordPage({
    Key? key,
    required this.mobile,
    required this.color,
    required this.hero,
    required this.status,
  }) : super(key: key);

  @override
  State<SetPasswordPage> createState() => _SetPasswordPageState();
}

class _SetPasswordPageState extends State<SetPasswordPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmpasswordController =
      TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool isLoading = false;

  void _submitpatchform() async {
    String Base_url = dotenv.get("BASE_URL", fallback: null);
    setState(() {
      isLoading = true;
    });

    String mobile = widget.mobile;
    String password = passwordController.text;
    String confirmPassword = confirmpasswordController.text;

    // Prepare data for API call
    Map<String, dynamic> requestData = {
      "phoneNumber": mobile,
      "newPassword": password,
      "confirmPassword": confirmPassword,
    };

    // API endpoint
    final String apiUrl = '$Base_url/user/resetPassword';

    try {
      // Make PATCH request
      final response = await http.patch(
        Uri.parse(apiUrl),
        body: jsonEncode(requestData),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      final Map<String, dynamic> responseData = json.decode(response.body);

      // Check response status
      if (response.statusCode == 200) {
        // Password reset successful
        Fluttertoast.showToast(
          msg: 'Login successfully',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 2,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
        await MobileNo.saveMobilenumber(mobile);
        await RefferalService.clearRefferal();
        await RefferalService.saveRefferal("${responseData['referralId']}");

        // Navigate to the home page
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => LoginPage(),
          ),
          (route) => false,
        );
        // Handle navigation or any other action as needed
      } else {
        // Password reset failed
        Fluttertoast.showToast(
          msg: 'Login failed. Please try again later',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 2,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
        // Handle error response as needed
      }
    } catch (exception) {
      // Exception occurred during API call
      print(exception);
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeService.background,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8.0, 100, 8, 50),
                    child: Image.asset(
                      'assets/login.png',
                      width: MediaQuery.of(context).size.width,
                      height: 280,
                      fit: BoxFit.fill,
                    ),
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: [
                            Text(
                              'Password',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: ThemeService.textColor),
                            ),
                            Text(
                              '*',
                              style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          style: TextStyle(color: ThemeService.textColor),
                          obscureText:
                              !_isPasswordVisible, // This hides the entered text
                          controller:
                              passwordController, // Your controller for handling the input
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: ThemeService.primary),
                            ),
                            prefixStyle:
                                TextStyle(color: ThemeService.textColor),
                            prefixIcon:
                                Icon(Icons.lock), // Icon for password input
                            hintText: 'Enter Password',
                            hintStyle: TextStyle(color: ThemeService.textColor),
                            suffixStyle:
                                TextStyle(color: ThemeService.textColor),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                          ),
                          validator: (password) {
                            if (password == null || password.isEmpty) {
                              return 'Please enter Password';
                            } else if (password.length < 8) {
                              return 'Password must be at least 8 characters long';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20),
                        Row(
                          children: [
                            Text(
                              'Confirm Password',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: ThemeService.textColor),
                            ),
                            Text(
                              '*',
                              style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          style: TextStyle(color: ThemeService.textColor),
                          obscureText:
                              !_isConfirmPasswordVisible, // This hides the entered text
                          controller:
                              confirmpasswordController, // Your controller for handling the input
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: ThemeService.primary),
                            ),
                            prefixStyle:
                                TextStyle(color: ThemeService.textColor),
                            prefixIcon:
                                Icon(Icons.lock), // Icon for password input
                            hintText: 'Enter Confirm Password',
                            hintStyle: TextStyle(color: ThemeService.textColor),
                            suffixStyle:
                                TextStyle(color: ThemeService.textColor),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isConfirmPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isConfirmPasswordVisible =
                                      !_isConfirmPasswordVisible;
                                });
                              },
                            ),
                          ),
                          validator: (confirmPassword) {
                            if (confirmPassword == null ||
                                confirmPassword.isEmpty) {
                              return 'Please enter Confirm Password';
                            } else if (confirmPassword !=
                                passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        Center(
                          child: Container(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () async {
                                if (_formKey.currentState?.validate() ??
                                    false) {
                                  String mobile = widget.mobile;
                                  String hero = widget.hero;
                                  String color = widget.color;
                                  String password = passwordController.text;
                                  String confirmPassword =
                                      confirmpasswordController.text;
                                  if (widget.status == 200) {
                                    _submitpatchform();
                                    ;
                                  } else {
                                    setState(() {
                                      isLoading = true;
                                    });
                                    await PreferencesService.saveValue(
                                        "mobile", mobile);
                                    await PreferencesService.saveValue(
                                        "hero", hero);
                                    await PreferencesService.saveValue(
                                        "color", color);
                                    await PreferencesService.saveValue(
                                        "password", password);
                                    await PreferencesService.saveValue(
                                        "confirmPassword", confirmPassword);
                                    await PreferencesService.saveValue(
                                        'login', "true");

                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => UserOnBoard(
                                              mobile: mobile,
                                              favhero: hero,
                                              favcolor: color,
                                              password: password,
                                              confirmpassword:
                                                  confirmPassword)),
                                      (route) => false,
                                    );

                                    Fluttertoast.showToast(
                                      msg: 'Favourites  Addded Successfully',
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.TOP,
                                      timeInSecForIosWeb: 2,
                                      backgroundColor: Colors.green,
                                      textColor: Colors.white,
                                    );
                                    setState(() {
                                      isLoading = false;
                                    });
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                backgroundColor: ThemeService.buttonBg,
                              ),
                              child: const Text(
                                'Submit',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: Loader(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
