// ignore_for_file: avoid_print, unused_local_variable

import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:lifeshareapplication/http_client.dart';
import 'package:lifeshareapplication/model/data_flow.dart';
import 'package:lifeshareapplication/model/detail.dart';
import 'package:lifeshareapplication/tabbar.dart';
import 'package:provider/provider.dart';



class DonorRegistration extends StatefulWidget {
  const DonorRegistration({super.key});

  @override
  State<DonorRegistration> createState() => _DonorRegistrationState();
}

class _DonorRegistrationState extends State<DonorRegistration> {

 
    final List<String> _medicalReportBase64List = [];
  final List<bool> _imageSelectionList = [];



void removeSelectedImage(int index) {
  setState(() {
    if (index >= 0 && index < _medicalReportBase64List.length && index < _imageSelectionList.length) {
      _medicalReportBase64List.removeAt(index);
      _imageSelectionList.removeAt(index);
    }
  });
}


Future<List<String>> convertImages(List<File> files) async {
  List<String> base64Images = [];
  for (File file in files) {
    final bytes = await file.readAsBytes();
    String base64Image = base64Encode(bytes);
    base64Images.add(base64Image);
  }
  return base64Images;
}



  DonorData donorData = DonorData();
  bool isEditingName = false;
  bool isEditingDOB = false;
  bool isEditingPhone = false;
  bool isEditingGender = false;

  List<String> questions = [
    "Do you have infectious disease?",
    "Do you suffer from cancer?",
    "Do you suffer from hepatitis?",
    "Do you suffer from diabetes?",
  ];
    List<bool?> answers = [null,null,null,null];

  // The method to update the answer and the index
  void updateAnswer(int index, bool value) {
    setState(() {
      answers[index] = value; // Set the answer for the current question
    });
  }


  String formatDate(DateTime date) {
    int day = date.day;
    int month = date.month;
    int year = date.year;
    String twoDigitMonth = month.toString().padLeft(2, '0');
    String twoDigitDay = day.toString().padLeft(2, '0');
    return "$twoDigitDay/$twoDigitMonth/$year";
  }

  Color darkPrimaryColor = const Color.fromARGB(255, 1, 46, 69);
  final _age = TextEditingController();
  final _weight = TextEditingController();

  late final GlobalKey<FormState> _formKeyDonor;

  @override
  void initState() {
    super.initState();
    _formKeyDonor = GlobalKey<FormState>();
  }

  @override
  void dispose() {
    _weight.dispose();
    _age.dispose();
    super.dispose();
  }

  int? age;
  int? weight;
  String? _selectedGender;
  bool isDonating = true;
  BigInt? phoneNumber;
  String? name;
  bool showInfectiousDiseaseQuestion=true;
  DateTime? _selectedDate;
  bool isDonatingBlood = false;
  bool isDonatingOrgans = false;
  String? _selectedBloodType;
  String? _selectedOrganType;
  List<String> bloodGroups = [
    "",
    "A+",
    "A-",
    "B+",
    "B-",
    "AB+",
    "AB-",
    "O+",
    "O-"
  ];

  var gender = ["Male", "Female", "Other"];
  bool obsecureText = true;
Future<bool> _checkPhoneNumber(int phoneNumber) async {
  final url = Uri.https(
    'lifeshare-873ea-default-rtdb.firebaseio.com',
    'donorDetails.json',
  );

  try {
    final response = await client.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final extractedData = jsonDecode(response.body) as Map<String, dynamic>?;

      if (extractedData != null) {
        // Check if the phone number already exists in the database
        final existingPhoneNumbers = extractedData.values.where((data) => data['Phone'] == phoneNumber).toList();
        return existingPhoneNumbers.isEmpty;
      } else {
        // No data found in the backend
        return true;
      }
    } else {
      // Failed to fetch data from the server
      print('Failed to fetch existing phone numbers: ${response.statusCode}');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to check phone number availability')),
        );
      }
      return false;
    }
  } catch (error) {
    // Error fetching data
    print('Error fetching phone numbers: $error');
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred while checking phone number')),
      );
    }
    return false;
  }
}

Future<void> _saveItem(BuildContext context) async {
  final id = Provider.of<UuidProvider>(context, listen: false);
  final location = Provider.of<LocationProvider>(context, listen: false);
  
  if (_formKeyDonor.currentState!.validate()) {
    _formKeyDonor.currentState!.save();

    DonorData donorData = DonorData(
      uuid: id.uid,
      name: name,
      age: age,
      phoneNumber: phoneNumber,
      selectedGender: _selectedGender,
      weight: weight,
      dateOfLastDonation: _selectedDate,
      isDonatingBlood: isDonatingBlood,
      isDonatingOrgans: isDonatingOrgans,
      selectedBloodGroup: _selectedBloodType,
      selectedOrganType: _selectedOrganType,
      hasDonatedBefore: _selectedDate != null,
    );

    bool isPhoneNumberUnique = await _checkPhoneNumber(int.parse(donorData.phoneNumber!.toString()));

    if (isPhoneNumberUnique) {
       final List<Map<String, dynamic>> encodedMedicalReportImages = _medicalReportBase64List.map((base64Image) {
          return {
            'imageData': base64Image,
          };
        }).toList();
      try {
        final url = Uri.https(
          'lifeshare-873ea-default-rtdb.firebaseio.com',
          'donorDetails.json',
        );

        final response = await client.post(
          url,
          headers: {
            'Content-Type': 'application/json',
          },
          body: json.encode({
            'Id': donorData.uuid,
            'Name': donorData.name,
            'Phone': donorData.phoneNumber?.toInt(),
            'Age': donorData.age,
            'Weight': donorData.weight,
            'Gender': donorData.selectedGender,
            'Date of Last Donation': donorData.dateOfLastDonation.toString(),
            'isDonating': donorData.isDonating,
            'isDonatingBlood': donorData.isDonatingBlood,
            'isDonatingOrgan': donorData.isDonatingOrgans,
            'Blood Group': donorData.selectedBloodGroup,
            'Organ Type': donorData.selectedOrganType,
            'City': location.city,
            'State': location.state,
            'Country': location.country,
            'Medical Report': encodedMedicalReportImages,
            'ConsentUploaded': donorData.hasConsent,
            'hasDonatedBefore': donorData.hasDonatedBefore,
          }),
        );

        if (response.statusCode == 200) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Data saved successfully')),
            );
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const MyTabbar()),
            );
          }
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to save data')),
            );
          }
        }
      } catch (error) {
        if (!context.mounted) return;
        print('Error saving data: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An error occurred while saving data'),
          ),
        );
      }
    } else {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phone number already registered')),
      );
    }
  }
}

  @override
  Widget build(BuildContext context) {
bool isMedicalImageSelected = false; // Track if a medical image is selected
Future<void> pickMedicalReportImages() async {
  final FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    allowMultiple: true, // Allow multiple file selection
  );

  if (result != null) {
    List<File> files = result.paths.map((path) => File(path!)).toList();
    List<String> base64Images = await convertImages(files);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Medical report images selected')),
      );
    }
    setState(() {
      _medicalReportBase64List.addAll(base64Images);
      // Initialize selection status for newly added images
      _imageSelectionList.addAll(List<bool>.filled(base64Images.length, false));
    });
  } else {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No images selected')),
      );
    }
  }
}

    final userProvider = Provider.of<UserProvider>(context);
    final phoneController =
        TextEditingController(text: userProvider.userPhone.toString());
    final nameContoller = TextEditingController(text: userProvider.userName);
    print(userProvider.userPhone);
    print(userProvider.userName);
     bool allAnswersNo = answers.every((answer) => answer == false);


    Widget buildOrganTypeDropdown() {
      return DropdownButtonFormField<String>(
        value: _selectedOrganType,
        items: ["", "Liver", "Kidney","Intestine"]
            .map((organType) => DropdownMenuItem<String>(
                  value: organType,
                  child: Text(organType),
                ))
            .toList(),
        onChanged: (value) {
          setState(() {
            _selectedOrganType = value;
          });
        },
        decoration: const InputDecoration(labelText: 'Select Organ Type'),
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
          title: Text(
        'Donate',
        style: TextStyle(color: darkPrimaryColor),
      )),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKeyDonor,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 5, 10, 160),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                    child: Text(
                      'Donor Registration',
                      style: TextStyle(
                          color: darkPrimaryColor,
                          fontSize: 30,
                          fontWeight: FontWeight.w900),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: TextFormField(
                          cursorColor: Colors.teal,
                          readOnly: isEditingName,
                          maxLength: 20,
                          controller: nameContoller,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(40))),
                            label: Text('Name'),
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
                            name = value!;
                          },
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: TextFormField(
                          maxLength: 3,
                          textAlign: TextAlign.center,
                          cursorColor: Colors.teal,
                          controller: _age,
                          decoration: const InputDecoration(
                              label: Text('Age'),
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(40)))),
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                int.tryParse(value) == null) {
                              return 'Enter correct value';
                            }
                            int? val = int.tryParse(_age.text);
                            if (val! <= 18) {
                              return 'Age 18 or above';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            age = int.parse(value!);
                          },
                        ),
                      ),
                      const SizedBox(width: 15,),
                      Expanded(
                        child: TextFormField(
                          maxLength: 2,
                          controller: _weight,
                          textAlign: TextAlign.center,
                          cursorColor: Colors.amber,
                          decoration: const InputDecoration(
                            suffixText: 'Kg',
                            hintText: "Weight",
                            label: Text('Weight'),
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(40))),
                          ),
                          validator: (value) {
                            int? val = int.tryParse(_weight.text);
                            if (value == null || value.isEmpty) {
                              return 'Invalid weight';
                            }
                            if (val! > 80 ) {
                              return 'Weight too much';
                            }
                            if (val < 30 ) {
                              return 'Weight too little';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            weight = int.parse(value!);
                          },
                        ),
                      ),
                    ],
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: TextFormField(
                            maxLength: 10,
                            readOnly: isEditingPhone,
                            controller: phoneController,
                            cursorColor: Colors.amber,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.phone),
                              hintText: "Must be 10 digit",
                              label: Text('Phone'),
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(40))),
                            ),
                            validator: (value) {
                              if (value == null ||
                                  value.isEmpty ||
                                  value.trim().length != 10) {
                                return 'Phone Incorrect';
                              }
                              if (num.tryParse(value) == null) {
                                return 'Phone must be all digits';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              phoneNumber = BigInt.parse(value!);
                            },
                          ),
                        ),
                      ]),
                      const Center(
                        child: Text(
                          'If made donation before tell us the Date else leave empty',
                          style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 10, 
                              color: Color.fromARGB(255, 1, 46, 69)),
                        ),
                      ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const Text(
                        'Date of Last Donation: ',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: Color.fromARGB(255, 1, 46, 69)),
                      ),
                      IconButton(
                        iconSize: 25,
                        color: const Color.fromARGB(255, 1, 46, 69),
                        onPressed: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2001),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null && picked != _selectedDate) {
                            setState(() {
                              _selectedDate = picked;
                            });
                          }
                        },
                        icon: const Icon(Icons.calendar_month_outlined),
                      ),
                      if (_selectedDate != null)
                        Text(
                          formatDate(_selectedDate!),
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w800),
                        ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 200,
                        child: DropdownButtonFormField<String>(
                          value: _selectedGender,
                          items: gender
                              .map((genderItem) => DropdownMenuItem<String>(
                                    value: genderItem,
                                    child: Text(genderItem),
                                  ))
                              .toList(),
                          onChanged: (gender) {
                            setState(() {
                              _selectedGender = gender!;
                            });
                          },
                          decoration: const InputDecoration(
                            labelText: "Gender",
                            enabled: false,
                            border: UnderlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

               for (int i = 0; i < questions.length; i++)
              Visibility(
                visible: i == 0 || (i > 0 && answers[i - 1] == false),
                child: Column(
                  children: [
                    Text(
                      questions[i], // Display the question
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: answers[i] == true,
                          onChanged: (value) {
                            if(value!=null){
                            updateAnswer(i, value);
                             } // Update the answer and the index
                          },
                        ),
                        const Text('Yes'),
                        Checkbox(
                          value: answers[i] == false,
                          onChanged: (value) {
                            if(value!=null){
                            updateAnswer(i, !value); 
                            }// Update the answer and the index
                          },
                        ),
                        const Text('No'),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
         
             if (allAnswersNo) 
             Column(
               children: [
                 CheckboxListTile(
                     title: const Text('Willing to donate blood?'),
                     checkColor: Colors.tealAccent,
                     activeColor: const Color.fromARGB(255, 1, 46, 69),
                     value: isDonatingBlood,
                     onChanged: (value) {
                       setState(() {
                         isDonatingBlood = value!;
                              
                       });
                     },
                   ),
                              
                   CheckboxListTile(
                     title: const Text('Willing to donate organs?'),
                     checkColor: Colors.tealAccent,
                     activeColor: const Color.fromARGB(255, 1, 46, 69),
                     value: isDonatingOrgans,
                     onChanged: (value) {
                       setState(() {
                         isDonatingOrgans = value!;
                         isDonatingBlood = false;
                   
                       });
                     },
                   ),
                              
                   DropdownButtonFormField<String>(
                     value: _selectedBloodType,
                     items: bloodGroups
                         .map((bloodType) => DropdownMenuItem<String>(
                               value: bloodType,
                               child: Text(bloodType),
                             ))
                         .toList(),
                     onChanged: (value) {
                       setState(() {
                         _selectedBloodType = value;
                       });
                     },
                     decoration: const InputDecoration(
                         labelText: 'Select Blood Group'),
                   ),
                              
                  if(!isDonatingBlood)
                     buildOrganTypeDropdown(),
                              
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
              onPressed: (){
                pickMedicalReportImages();
                },
              child: const Text('Upload Medical Report Image'),
            ),
                  ),
                   if (_medicalReportBase64List.isNotEmpty)
      if (_medicalReportBase64List.isNotEmpty)
      Column(
        children: List.generate(_medicalReportBase64List.length, (index) {
          return Column(
            children: [
              // Display the image
              SizedBox(
                width: 400,
                height: 550,
                child: Image.memory(
                  base64Decode(_medicalReportBase64List[index]),
                ),
              ),
              // Button to toggle image selection
              ElevatedButton(
                onPressed: () => removeSelectedImage(index),
                child: const Text('Remove Image'),
              ),
              // Button to remove selected image
             
            ],
          );
        }),
      ),

         
                   const SizedBox(
                     height: 10,
                   ),
                   Center(
                     child: ElevatedButton(
                       onPressed: () {
                         _saveItem(context);
                         // Implement your logic here
                       },
                       child: const Text('Send Request'),
                     ),
                   ),
               ],
             ),
// Other Widgets...

Visibility(
   visible: answers.contains(true),
  child: const AnimatedOpacity(
    opacity: 1.0,
    duration: Duration(milliseconds: 600),
    child: SizedBox(
      height: 100,
      child: Padding(
        padding: EdgeInsets.fromLTRB(40, 50, 10, 0),
        child: Text(
          'You are not eligible for donations',
          style: TextStyle(color: Colors.red, fontSize: 25, fontWeight: FontWeight.w800),
        ),
      ),
    ),
  ),
),
                ],
              ),
            ),
          ),
        ),
      )
    );
  }
}
