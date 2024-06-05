// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:lifeshareapplication/model/data_flow.dart';
import 'package:lifeshareapplication/model/detail.dart';
import 'package:lifeshareapplication/model/pref.dart';
import 'package:lifeshareapplication/profile_entry.dart';
import 'package:lifeshareapplication/tabbar.dart';
import 'package:provider/provider.dart';

import 'http_client.dart' ;

TextEditingController _phone = TextEditingController();
TextEditingController _password = TextEditingController();
Color darkPrimaryColor = const Color.fromARGB(255, 1, 46, 69);
UserProfileData? userProfileData;
 bool obsecureText=true;
TextStyle textstyle = const TextStyle(
    fontSize: 25, fontWeight: FontWeight.w700, color: Colors.white);

void check(BuildContext context) async {
  Map<String, dynamic>? userData = await _checkCredentials(
    context,
    int.parse(_phone.text),
    _password.text,
  );
  if(context.mounted){
 Provider.of<UuidProvider>(context, listen: false).setUserId(userData?['Id']?.toString() ?? '');
   await UserDetailSharedPreferences.setId(userData?['Id']?.toString() ?? ''); 
  }
    print('Name before assignment: ${userData?['Name']}');
      final String sname =  userData?['Name']?.toString() ?? '';
      final String phone = userData?['Phone']?.toString() ?? '';
      final String city=userData?['City']?.toString() ?? '';
      final String state=userData?['State']?.toString() ?? '';
      final String country=userData?['Country']?.toString() ?? '';
    
      if (context.mounted) {
      Provider.of<UserProvider>(context, listen: false).setUserDetails(
        sname,
        phone
      );
      Provider.of<LocationProvider>(context, listen: false).setUserLocation(
        city,
        state,
        country
      );
      print(city);
       await UserDetailSharedPreferences.setName(sname);
    await UserDetailSharedPreferences.setPhone(phone);
    await UserDetailSharedPreferences.setCity(city);
    await UserDetailSharedPreferences.setState(state);
    await UserDetailSharedPreferences.setCountry(country);   
    
  }

  if (userData != null) {
    await PreferencesHelper.setLoggedIn(true);
    if (context.mounted) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => const MyTabbar()));
    }
  } else {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid credentials')),
      );
    }
  }
}

Future<Map<String, dynamic>?> _checkCredentials(
    BuildContext context, int phone, String password) async {
   final url = Uri.https(
    'lifeshare-873ea-default-rtdb.firebaseio.com',
    'details.json',
    {'orderBy': '"Phone"', 'equalTo': '$phone'},
  );


  try {
    final response = await client.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );
    
     if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (responseData.isNotEmpty) {
        for (final MapEntry<String, dynamic> entry in responseData.entries) {
          final Map<String, dynamic> user = entry.value;
          final int storedPhone = user['Phone'];
          final String storedPassword = user['Password'];

          if (storedPhone == phone) {
    
            if (storedPassword == password) {
              print(user);
              return user;
            }
            return null;
          }
        }
      } else {
        // User not found
        return null;
      }
    } else {
      print('Failed to authenticate: ${response.statusCode}');
      print('Received response: ${response.body}');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
             behavior: SnackBarBehavior.floating,
            content: Text('Failed to check credentials')),
        );
      }
      return null;
    }
  } catch (error) {
    print('Error during authentication: $error');
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
           behavior: SnackBarBehavior.floating,
            content: Text('An error occurred while checking credentials')),
      );
    }
    return null;
  }
  return null;
}

OutlineInputBorder border = const OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(40)),
    borderSide: BorderSide(color: Colors.teal, width: 5.0));

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(title: const Text('User Login')),
      resizeToAvoidBottomInset: false,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        backgroundColor: darkPrimaryColor,
        onPressed: () {
          // Navigate to the DestinationScreen when the FAB is pressed
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddProfile()),
          );
        },
        child: const Icon(Icons.person_add, color: Colors.amber,),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
           const Padding(
                      padding: EdgeInsets.fromLTRB(20,80,20,20),
                     child: Text('Login',style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800,color:Color.fromARGB(255, 11, 51, 72)),)
                   ),
          Center(
            child: Container(
              height: 400,
              width: 350,
              decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 1, 46, 69),
                  border: Border.all(
                    width: 5,
                    color: darkPrimaryColor,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(30))),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(30, 0, 30, 10),
                        child: TextField(
                          style: const TextStyle(color: Colors.white),
                          controller: _phone,
                           maxLength: 10,
                          decoration: InputDecoration(
                            
                            focusedBorder: border,
                            labelStyle: textstyle,
                            label: const Text("Phone"),
                            helperStyle:const TextStyle(color: Colors.amber),
                            errorStyle: const TextStyle(color: Colors.amber),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(30, 10, 30, 10),
                        child: TextField(
                          style: const TextStyle(color: Colors.white),
                          controller: _password,
                          obscureText: obsecureText,
                          decoration: InputDecoration(
                            suffixIcon: IconButton(onPressed: (){
                      setState(() {
                        obsecureText=!obsecureText;
                      });
                    }, icon: const Icon(Icons.remove_red_eye_outlined, color:Colors.white)),
                            focusedBorder: border,
                            labelStyle: textstyle,
                            label: const Text("Password"),
                           hintText: 'Aa1(!@#\$%^&*)',
                            hintMaxLines: 2,
                            hintStyle: const TextStyle(color: Colors.amber),
                            helperStyle: const TextStyle(color: Colors.amber),
                             errorStyle: const TextStyle(color: Colors.amber),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: ElevatedButton(
                          child: const Text('Log in',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 20)),
                          onPressed: () async {
                            try {
                              print('Attempting to check credentials...');
                              check(context);
                              _password.clear();
                              _phone.clear();
                            } catch (error) {
                              print('Error in onPressed callback: $error');
                            }
                          },
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          showDialog(
                          
      context: context,
      builder: (BuildContext context) {
        return const ForgotPasswordDialog();
      },
    );
                        },
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
}
class ForgotPasswordDialog extends StatefulWidget {
  const ForgotPasswordDialog({super.key});

  @override
  State<ForgotPasswordDialog> createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends State<ForgotPasswordDialog> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _answerController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  String? selectedQuestion;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Forgot Password',
        style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700, color: darkPrimaryColor),
      ),
      content: SingleChildScrollView(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8, // Adjust the width as needed
          height: MediaQuery.of(context).size.height * 0.3,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _phoneController,
                maxLength: 10,
                decoration: const InputDecoration(labelText: 'Phone'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                isExpanded: true,
                value: selectedQuestion,
                itemHeight: 70,
                isDense: true,
                items: [
                  "What was the first video game you ever played?",
                  "What was the name of your favorite childhood cartoon character?",
                  "What was the name of your favorite childhood superhero?",
                  "What was the name of your first ever roommate?",
                ].map((question) {
                  return DropdownMenuItem<String>(
                    value: question,
                    child: Text(question),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedQuestion = value;
                  });
                },
                decoration: const InputDecoration(labelText: 'Select Security Question'),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _answerController,
                decoration: const InputDecoration(labelText: 'Your Answer'),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () async {
            final String answer = _answerController.text.trim();
            final int phone = int.tryParse(_phoneController.text) ?? 0;

            if (selectedQuestion == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please select a security question.'),
                ),
              );
              return;
            }

            final String? userKey = await _getAnswers(phone, selectedQuestion!, answer);
            if (userKey != null) {
              // If answer matches, show dialog for new password
              if(context.mounted){
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return NewPasswordDialog(
                    newPasswordController: _newPasswordController,
                    userKey: userKey,
                  );
                },
              );
              }
            } else {
              // Show error message or handle incorrect answer
              if(context.mounted){
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Incorrect answer or phone number.'),
                ),
              );
              }
            }
          },
          child: const Text('Submit'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

class NewPasswordDialog extends StatelessWidget {
  final TextEditingController newPasswordController;
  final String userKey;

  const NewPasswordDialog({
    super.key,
    required this.newPasswordController,
    required this.userKey,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New Password'),
      content: TextFormField(
        controller: newPasswordController,
        obscureText: true,
        decoration: const InputDecoration(labelText: 'Enter New Password'),
          validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        value.trim().length < 6) {
                      return 'Must be 6 characters';
                    }
                    if (!Password().isPasswordValid(value)) { // Using the Password class to validate the password
                      return 'Must contain one capital letter,\n one small letter, one digit, and one symbol(@!#\$%^&*)';
                    }
                    return null;
                  },
      ),
      actions: [
        TextButton(
          onPressed: () {
            // Logic to update password
            final String newPassword = newPasswordController.text.trim();
            if (newPassword.isNotEmpty) {
              
              updatePassword(context, userKey, newPassword);
            } else {
             ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please Enter the Passowrd'),
                ),
              );
            }
          },
          child: const Text('Submit'),
        ),
      ],
    );
  }
}
Future<String?> _getAnswers(int phone, String securityQuestion, String answer) async {
  final url = Uri.https(
    'lifeshare-873ea-default-rtdb.firebaseio.com',
    'details.json',
    {'orderBy': '"Phone"', 'equalTo': '$phone'},
  );

  try {
    final response = await client.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (responseData.isNotEmpty) {
        for (final MapEntry<String, dynamic> entry in responseData.entries) {
          final String userKey = entry.key;
          final Map<String, dynamic> user = entry.value;
          final int storedPhone = user['Phone'];

          if (storedPhone == phone) {
            // Iterate through the user's data to find the key corresponding to the selected security question's answer
            String? storedSecurityQuestionKey;
            user.forEach((key, value) {
              // Convert both answers to lowercase for case-insensitive comparison
              if (value.toString().toLowerCase() == answer.toLowerCase() && key == securityQuestion) {
                storedSecurityQuestionKey = key;
              }
            });

            if (storedSecurityQuestionKey != null) {
              return userKey;
            }
          }
          }
      }
    } else {
      print('Failed to retrieve data: ${response.statusCode}');
      print('Received response: ${response.body}');
      return null;
    }
  } catch (error) {
    print('Error during data retrieval: $error');
    return null;
  }
  return null;
}

void updatePassword(BuildContext context, String userKey, String newPassword) async {
  try {
    final url = Uri.https(
      'lifeshare-873ea-default-rtdb.firebaseio.com',
      'details/$userKey.json',
    );

    final response = await client.patch(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'Password': newPassword}), // Update password using user key
    );

    if (response.statusCode == 200) {
      if(context.mounted){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password updated successfully')),
      );
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } else {
        if(context.mounted){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update password')),
      );
    }
    }
  } catch (error) {
    print('Error updating password: $error');
      if(context.mounted){
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('An error occurred')),
    );
      }
  }
}
