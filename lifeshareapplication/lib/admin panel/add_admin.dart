import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lifeshareapplication/admin%20panel/admin_login.dart';
import 'package:lifeshareapplication/admin%20panel/donor_record.dart';
import 'package:lifeshareapplication/http_client.dart';
import 'package:lifeshareapplication/model/detail.dart';
import 'package:pinput/pinput.dart';
import 'package:telephony/telephony.dart';

class AddAdmin extends StatefulWidget {
  const AddAdmin({super.key});

  @override
  State<AddAdmin> createState() => _AddAdminState();
}

class _AddAdminState extends State<AddAdmin> {
  final GlobalKey<FormState> _adminformKey = GlobalKey<FormState>();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _securityQuestionController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  late final Telephony telephony;
  bool _otpVerified = false;
  int _timerDuration = 0;
  late Timer _timer;

  AdminProfileData? adminProfileData;

  // Ensure these fields are not null
  String? name;
  String? email;
  String? password;
  BigInt? phoneNumber;
  String? answer;
  String? _selectedQuestions;

  String _generateOTP() {
    // Generate a 6-digit random OTP
    var rng = Random();
    return rng.nextInt(999999).toString().padLeft(6, '0');
  }

  @override
  void initState() {
    super.initState();
    telephony = Telephony.instance;
  }

  @override
  void dispose() {
    _phone.dispose();
    _name.dispose();
    _password.dispose();
    _otpController.dispose();
    _securityQuestionController.dispose();
    super.dispose();
  }

  void _verifyOTP(String otp) {
    if (_otpController.text == otp) {
      setState(() {
        _otpVerified = true;
      });
      _timer.cancel();
      _saveItem(); // Save item after successful OTP verification
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Wrong Otp')),
      );
    }
  }

  void sendOTP() {
    if (_adminformKey.currentState!.validate()) {
      String phoneNumber = '+91${_phone.text}';
      String otp = _generateOTP();
      String message = 'Your OTP code is: $otp';

      telephony.sendSms(
        to: phoneNumber,
        message: message,
      );

      _startTimer();
    }
  }

  void _startTimer() {
    const oneSec = Duration(seconds: 1);
    setState(() {
      _timerDuration = 60;
    });
    _timer = Timer.periodic(oneSec, (timer) {
      setState(() {
        if (_timerDuration > 0) {
          _timerDuration--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  Future<bool> _checkPhoneNumber(String phoneNumber) async {
    final url = Uri.https(
      'lifeshare-873ea-default-rtdb.firebaseio.com',
      'adminDetails.json',
      {'orderBy': '"Phone"', 'equalTo': '"$phoneNumber"'}
    );

    try {
      final response = await client.get(url, headers: {'Content-Type': 'application/json'});

      if (response.statusCode == 200) {
        final extractedData = jsonDecode(response.body) as Map<String, dynamic>?;

        if (extractedData != null) {
          return extractedData.isEmpty;
        } else {
          return true;
        }
      } else {
        print('Failed to fetch existing phone numbers: ${response.statusCode}');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to check phone number availability')),
          );
        }
        return false;
      }
    } catch (error) {
      print('Error fetching phone numbers: $error');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An error occurred while checking phone number')),
        );
      }
      return false;
    }
  }

  Future<void> _saveItem() async {
    if (_adminformKey.currentState!.validate() && _otpVerified) {
      _adminformKey.currentState!.save();

      adminProfileData = AdminProfileData(
        name: _name.text,
        password: _password.text,
        phoneNumber: phoneNumber,
      );

      bool isPhoneNumberUnique = await _checkPhoneNumber(adminProfileData!.phoneNumber!.toString());

      if (isPhoneNumberUnique) {
        try {
          final url = Uri.https(
            'lifeshare-873ea-default-rtdb.firebaseio.com',
            'adminDetails.json',
          );

          final response = await client.post(
            url,
            headers: {
              'Content-Type': 'application/json',
            },
            body: json.encode({
              'Name': adminProfileData!.name,
              'Password': adminProfileData!.password,
              'Phone': adminProfileData!.phoneNumber?.toInt(),
              _selectedQuestions ?? 'SecurityQuestion': _securityQuestionController.text,
            }),
          );

          if (!mounted) return;

          if (response.statusCode == 200) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Data saved successfully')),
            );
            mainPage(context);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to save data')),
            );
          }
        } catch (error) {
          if (!mounted) return;
          print('Error saving data: $error');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('An error occurred while saving data')),
          );
        }
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Phone number already registered')),
        );
      }
    }
  }

  void mainPage(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => const DonorRecord(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('AddProfile'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AdminLoginScreen()),
          );
        },
        child: const Icon(Icons.login_rounded),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _adminformKey,
          child: SizedBox(
            height: 570,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text('Sign up', style: Theme.of(context).textTheme.headlineLarge),
                ),
                Expanded(
                  child: TextFormField(
                    cursorColor: Colors.teal,
                    maxLength: 20,
                    controller: _name,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(40))),
                      labelText: 'Name',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty || value.trim().length <= 2) {
                        return 'Must be 3 to 20 words';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      name = value!;
                    },
                  ),
                ),
                Expanded(
                  child: TextFormField(
                    maxLength: 20,
                    controller: _password,
                    cursorColor: Colors.amber,
                    obscureText: true,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.lock),
                      hintText: "Must have 6 characters",
                      labelText: 'Password',
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(40))),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty || value.trim().length <= 6) {
                        return 'Must be 6 characters';
                      }
                      // Add your password validation logic here if needed
                      return null;
                    },
                    onSaved: (value) {
                      password = value!;
                    },
                  ),
                ),
                Expanded(
                  child: TextFormField(
                    maxLength: 10,
                    controller: _phone,
                    cursorColor: Colors.amber,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.phone),
                      hintText: "Must be 10 digit",
                      labelText: 'Phone',
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(40))),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty || value.trim().length != 10) {
                        return 'Phone number must be 10 digits';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      phoneNumber = BigInt.tryParse(value!);
                    },
                  ),
                ),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  value: _selectedQuestions,
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
                      _selectedQuestions = value;
                    });
                  },
                  decoration: const InputDecoration(labelText: 'Select Security Question'),
                ),
                const SizedBox(height: 30),
                Expanded(
                  child: TextFormField(
                    cursorColor: Colors.teal,
                    controller: _securityQuestionController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(40))),
                      labelText: 'Your Answer',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty || value.trim().length <= 2) {
                        return 'Can be 3 to 20 words';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      answer = value!;
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    sendOTP();
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Enter OTP'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Pinput(
                                controller: _otpController,
                                length: 6,
                                separatorBuilder: (index) => const SizedBox(width: 8),
                                onCompleted: (pin) {
                                  _verifyOTP(pin);
                                  Navigator.pop(context);
                                },
                              ),
                              if (_timerDuration > 0)
                                Text(
                                  'Resend OTP in $_timerDuration seconds',
                                  style: const TextStyle(color: Colors.blue),
                                ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  child: const Text(
                    "Save",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                if (_timerDuration > 0)
                  Text(
                    'Resend OTP in $_timerDuration seconds',
                    style: const TextStyle(color: Colors.red),
                  ),
                const SizedBox(height: 120),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

