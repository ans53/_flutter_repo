
import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:csc_picker/csc_picker.dart';
import 'package:flutter/material.dart';
import 'package:lifeshareapplication/login_page.dart';
import 'package:lifeshareapplication/model/data_flow.dart';
import 'package:lifeshareapplication/model/detail.dart';
import 'package:lifeshareapplication/model/pref.dart';
import 'package:lifeshareapplication/tabbar.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import 'package:telephony/telephony.dart';
import 'package:uuid/uuid.dart';

import 'http_client.dart'; // Import the shared HTTP client

class AddProfile extends StatefulWidget {
  const AddProfile({super.key});

  @override
  State<AddProfile> createState() => AddProfileState();
}

class AddProfileState extends State<AddProfile> {
  late final TextEditingController _verificationCodeController =
      TextEditingController();
  bool obsecureText = true;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _securityQuestionController =
      TextEditingController();
  String? stateValue;
  String? cityValue;
  String? countryValue;
  String? name;
  String? email;
  String? password;
  BigInt? phoneNumber;
  final Telephony telephony = Telephony.instance;
  String? _selectedQuestions;
  String? answer;
  String? storedOTP;
  int _start = 30; // Change timer duration to 30 seconds
  late Timer _otpTimer; // Declare Timer object for OTP timer

  @override
  void initState() {
    super.initState();
    telephony.listenIncomingSms(
      onNewMessage: (SmsMessage message) {
        String? receivedMessage = message.body;
        if (receivedMessage!.contains("Your OTP code is: ")) {
          String otp = receivedMessage.replaceAll("Your OTP code is: ", "");
          _verifyOTP(otp);
        }
      },
      listenInBackground: false,
    );
  }

  @override
  void dispose() {
    _otpTimer.cancel(); // Dispose of the OTP timer
    _phone.dispose();
    _verificationCodeController.dispose();
    _name.dispose();
    _password.dispose();
    _verificationCodeController.dispose();
    super.dispose();
  }

  String generateShortUniqueId(String uuid) {
    var bytes = utf8.encode(uuid);
    var digest = sha256.convert(bytes);
    var hash = digest.toString();

    var shortId = hash.substring(0, 12);

    return shortId;
  }

  Future<bool> _checkPhoneNumber(int phoneNumber) async {
    final url = Uri.https(
      'lifeshare-873ea-default-rtdb.firebaseio.com',
      'details.json',
    );

    try {
      final response = await client.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final extractedData = jsonDecode(response.body) as Map<String, dynamic>?;
        if (extractedData != null) {
          final existingPhoneNumbers = extractedData.values
              .where((data) => data['Phone'] == phoneNumber)
              .toList();
          print('Existing phone numbers: $existingPhoneNumbers');
          return existingPhoneNumbers.isEmpty;
        } else {
          print('No existing phone numbers found in the backend');
          return true;
        }
      } else {
        print('Failed to fetch existing phone numbers: ${response.statusCode}');
        print('Fetching phone numbers from the server...');
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

  String generateOTP() {
    Random random = Random();
    // Generate a random number between 100000 and 999999 (inclusive)
    int otp = 100000 + random.nextInt(900000);
    return otp.toString();
  }

  Future<void> _sendOTP(String phoneNumber) async {
    try {
      storedOTP = generateOTP();
      await telephony.sendSms(
        to: phoneNumber,
        message: "Your OTP code is: $storedOTP",
        statusListener: (status) => print(status),
      );
if(context.mounted){
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Enter OTP"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Pinput(
                  controller: _verificationCodeController,
                  length: 6,
                  separatorBuilder: (index) => const SizedBox(width: 8),
                  onCompleted: (pin) {
                    _verifyOTP(pin);
                    Navigator.of(context).pop();
                  },
                ),
                StreamBuilder<int>(
                  stream: _otpTimerStream(),
                  builder: (context, snapshot) {
                    final value = snapshot.data ?? 0;
                    return Text(
                      '$value seconds left for OTP expiration',
                      style: const TextStyle(color: Colors.blue),
                    );
                  },
                ),
              ],
            ),
          );
        },
      );
}
      // Start the OTP timer
      _startTimer();
    } catch (e) {
      print('Error sending OTP: $e');
    }
  }

  // Start the OTP timer
  void _startTimer() {
    const oneSec = Duration(seconds: 1);
    _otpTimer = Timer.periodic(
      oneSec,
      (timer) {
        setState(() {
          if (_start < 1) {
            timer.cancel();
          } else {
            _start--;
          }
        });
      },
    );
  }

  // Stream for displaying countdown timer in UI
  Stream<int> _otpTimerStream() async* {
    while (_start > 0) {
      await Future.delayed(const Duration(seconds: 1));
      yield _start;
    }
  }

  Future<void> _verifyOTP(String otp) async {
    try {
      // Stop the timer when OTP verification starts
      _otpTimer.cancel();

      if (otp == storedOTP) {
        await saveItem(context);
      } else {
        print("Invalid OTP");
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Invalid OTP"),
              content: const Text("Please enter a valid OTP."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );
      }
       // Reset the timer every time OTP is sent
    _start = 30;
    // Start the OTP timer
    _startTimer();
    } catch (error) {
      print("Error verifying OTP: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    Color darkPrimaryColor = const Color.fromARGB(255, 1, 46, 69);
    return Scaffold(
       appBar:AppBar(title: const Text('SignUp')),
      resizeToAvoidBottomInset: false,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        backgroundColor: darkPrimaryColor,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        },
        child: const Icon(Icons.login_rounded, color: Colors.amber,),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
           
              Expanded(
                child: TextFormField(
                  cursorColor: Colors.teal,
                  maxLength: 20,
                  controller: _name,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(40))),
                    label: Text('Name'),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        value.trim().length < 3) {
                      return 'Must be 3 to 20 words';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    name = value!;
                  },
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Expanded(
                child: TextFormField(
                  maxLength: 20,
                  controller: _password,
                  cursorColor: Colors.amber,
                  obscureText: obsecureText,
                  decoration: InputDecoration(
                      suffixIcon: IconButton(onPressed: () {
                        setState(() {
                          obsecureText = !obsecureText;
                        });
                      }, icon: const Icon(Icons.remove_red_eye_outlined, color: Color.fromARGB(255, 1, 46, 69))),
                      prefixIcon: const Icon(Icons.lock),
                      hintText: "Must have 6 characters",
                      label: const Text('Password'),
                      errorMaxLines: 3,
                      border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(40)))
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        value.trim().length < 6) {
                      return 'Must be 6 characters';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    password = value!;
                  },
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Expanded(
                child: TextFormField(
                  maxLength: 10,
                  controller: _phone,
                  cursorColor: Colors.amber,
                  decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.phone),
                      hintText: "Must be 10 digit",
                      label: Text('Phone'),
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(40)))
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        value.trim().length != 10) {
                      return 'Phone Incorrect';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Phone must be all digits';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    phoneNumber = BigInt.parse(value!);
                  },
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              CSCPicker(
                layout: Layout.horizontal,
                showStates: true,
                showCities: true,
                dropdownDecoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    color: Colors.white,
                    border: Border.all(color: Colors.black, width: 1)),
                disabledDropdownDecoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    color: Colors.blue,
                    border: Border.all(color: Colors.blue, width: 1)),
                countrySearchPlaceholder: "Country",
                stateSearchPlaceholder: "State",
                citySearchPlaceholder: "City",
                countryDropdownLabel: "Country",
                stateDropdownLabel: "State",
                cityDropdownLabel: "City",
                selectedItemStyle: const TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.w900),
                dropdownHeadingStyle: const TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.w900),
                dropdownItemStyle: const TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
                countryFilter: const [CscCountry.India],
                defaultCountry: CscCountry.India,
                dropdownDialogRadius: 10.0,
                searchBarRadius: 10.0,
                onCountryChanged: (value) {
                  setState(() {
                    countryValue = value;
                  });
                },
                onStateChanged: (value) {
                  setState(() {
                    stateValue = value;
                  });
                },
                onCityChanged: (value) {
                  setState(() {
                    cityValue = value;
                  });
                },
              ),
              const SizedBox(
                height: 20,
              ),
              DropdownButtonFormField<String>(
                isExpanded: true,
                value: _selectedQuestions,
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
                    _selectedQuestions = value;
                  });
                },
                selectedItemBuilder: (BuildContext context) {
                  return [
                    "What was the first video game you ever played?",
                    "What was the name of your favorite childhood cartoon character?",
                    "What was the name of your favorite childhood superhero?",
                    "What was the name of your first ever roommate?",
                  ].map<Widget>((String item) {
                    return SizedBox(
                      width: MediaQuery.of(context).size.height / 1.4,
                      child: Text(
                        item,
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList();
                },
                decoration: const InputDecoration(labelText: 'Select Security Question'),
              ),
              const SizedBox(
                height: 15,
              ),
              Expanded(
                child: TextFormField(
                  cursorColor: Colors.teal,
                  controller: _securityQuestionController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(40))),
                    label: Text('Your Answer'),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        value.trim().length <= 2) {
                      return 'Can be 3 to 20 words';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    answer = value!;
                  },
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    String phoneNumber = '+91${_phone.text}';
                    _sendOTP(phoneNumber);
                  }
                },
                child: const Text('Sign Up', style: TextStyle(color: Colors.black),),
              ),
              const SizedBox(
                height: 40,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> saveItem(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      String uuid = const Uuid().v4();
      String shortId = generateShortUniqueId(uuid);

      UserProfileData userProfileData = UserProfileData(
        uuid: shortId,
        name: _name.text,
        password: _password.text,
        country: countryValue ?? '',
        city: cityValue ?? '',
        phoneNumber: phoneNumber,
        state: stateValue ?? '',
      );

      Provider.of<UserProvider>(context, listen: false).setUserDetails(
        userProfileData.name!,
        userProfileData.phoneNumber!.toString(),
      );
      await UserDetailSharedPreferences.setName(userProfileData.name!);
      await UserDetailSharedPreferences.setPhone(userProfileData.phoneNumber!.toString());

      if (context.mounted) {
        Provider.of<UuidProvider>(context, listen: false).setUserId(shortId);
      }
      await UserDetailSharedPreferences.setId(shortId);

      if (context.mounted) {
        Provider.of<LocationProvider>(context, listen: false).setUserLocation(
          userProfileData.city!,
          userProfileData.state!,
          userProfileData.country!,
        );
      }
      await UserDetailSharedPreferences.setCity(userProfileData.city!);
      await UserDetailSharedPreferences.setState(userProfileData.state!);
      await UserDetailSharedPreferences.setCountry(userProfileData.country!);

      bool isPhoneNumberUnique = await _checkPhoneNumber(userProfileData.phoneNumber!.toInt());

      if (isPhoneNumberUnique) {
        try {
          final url = Uri.https(
            'lifeshare-873ea-default-rtdb.firebaseio.com',
            'details.json',
          );


          final response = await client.post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'Id': shortId,
              'Name': userProfileData.name,
              'Password': userProfileData.password,
              'Country': userProfileData.country,
              'City': userProfileData.city,
              'State': userProfileData.state,
              'Phone': userProfileData.phoneNumber?.toInt(),
              _selectedQuestions ?? 'SecurityQuestion': _securityQuestionController.text,
            }),
          );

          if (response.statusCode == 200) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Data saved successfully')));
              PreferencesHelper.setLoggedIn(true);
              Future.delayed(const Duration(milliseconds: 500), () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const MyTabbar()));
              });
            }
          } else {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Failed to save data')),
              );
            }
          }
        } catch (error) {
          print('Error saving data: $error');
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('An error occurred while saving data')),
            );
          }
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Phone number already registered')),
          );
        }
      }
    }
  }
}

