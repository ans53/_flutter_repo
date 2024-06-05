// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:csc_picker/csc_picker.dart';
import 'package:flutter/material.dart';
import 'package:lifeshareapplication/model/data_flow.dart';
import 'package:lifeshareapplication/model/detail.dart';
import 'package:lifeshareapplication/tabbar.dart';
import 'package:provider/provider.dart';

import 'http_client.dart';

class RecipientRegistration extends StatefulWidget {
  const RecipientRegistration({super.key});
  @override
  State<RecipientRegistration> createState() => _RecipientRegistrationState();
}

class _RecipientRegistrationState extends State<RecipientRegistration> {
  @override
  void initState() {
    super.initState();
    _formKeyRecipient = GlobalKey<FormState>();
  }

  @override
  void dispose() {
    _attendeePhoneController.dispose();
    _patientNameController.dispose();
    super.dispose();
  }

  late final GlobalKey<FormState> _formKeyRecipient;
  Future<bool> _checkPhoneNumber(int phoneNumber) async {
    final url = Uri.https(
      'lifeshare-873ea-default-rtdb.firebaseio.com',
      'recipientDetails.json',
    );

    try {
      final response = await client.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final extractedData =
            jsonDecode(response.body) as Map<String, dynamic>?;

        if (extractedData != null) {
          // Check if the phone number already exists in the database
          final existingPhoneNumbers = extractedData.values
              .where((data) => data['Phone'] == phoneNumber)
              .toList();
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
            const SnackBar(
                content: Text('Failed to check phone number availability')),
          );
        }
        return false;
      }
    } catch (error) {
      // Error fetching data
      print('Error fetching phone numbers: $error');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('An error occurred while checking phone number')),
        );
      }
      return false;
    }
  }

  bool isOrganRecipient = false;
  String? name;
  BigInt? phoneNumber;
  String? _selectedOrganType;
  Future<void> _saveItem() async {
    if (_formKeyRecipient.currentState!.validate()) {
      _formKeyRecipient.currentState!.save();

      final id = Provider.of<UuidProvider>(context, listen: false);
      RecipientData recipientData = RecipientData(
        uuid: id.uid,
        patientName: name,
        attendeePhone: phoneNumber,
        city: cityValue,
        country: countryValue,
        state: stateValue,
        requiredByDate: _selectedDate,
        selectedBloodGroup: _selectedBloodGroup,
        selectedBloodType: _selectedBloodType,
        selectedUnits: _selectedUnits,
        isCritical: isCritical,
        isOrganRecipient: isOrganRecipient,
        selectedOrganType: _selectedOrganType,
      );

      bool isPhoneNumberUnique = await _checkPhoneNumber(
          int.parse(recipientData.attendeePhone!.toString()));

      if (isPhoneNumberUnique) {
        try {
          final url = Uri.https(
            'lifeshare-873ea-default-rtdb.firebaseio.com',
            'recipientDetails.json',
          );

          final response = await client.post(
            url,
            headers: {
              'Content-Type': 'application/json',
            },
            body: json.encode({
              'Id': recipientData.uuid,
              'Name': recipientData.patientName,
              'Phone': recipientData.attendeePhone?.toInt(),
              'City': recipientData.city,
              'State': recipientData.state,
              'Country': recipientData.country,
              'Required by Date': recipientData.requiredByDate.toString(),
              'Critical Request': recipientData.isCritical,
              'isBloodRequired': recipientData.isBloodRecipient,
              'isOrganRequired': recipientData.isOrganRecipient,
              'Blood group': recipientData.selectedBloodGroup,
              'Blood Type': recipientData.selectedBloodType,
              'Blood Quantity': recipientData.selectedUnits,
              'Organ Type': recipientData.selectedOrganType
            }),
          );

          if (response.statusCode == 200) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Data saved successfully')),
              );

              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const MyTabbar()));
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
                content: Text('An error occurred while saving data')),
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

  RecipientData recipientData = RecipientData();
  final _patientNameController = TextEditingController();
  final _attendeePhoneController = TextEditingController();
  String? countryValue;
  String? stateValue;
  String? cityValue;
  String? _selectedBloodType = "Blood";
  String? _selectedBloodGroup;
  String? _selectedUnits;
  DateTime? _selectedDate;
  Color darkPrimaryColor = const Color.fromARGB(255, 1, 46, 69);
  List<String> unitsOfPlasmaAndPlatelets = [
    '200 ml',
    '250 ml',
    '300 ml',
    '350 ml',
    '400 ml',
    '450 ml',
    '500 ml'
  ];
  String formatDate(DateTime date) {
    int day = date.day;
    int month = date.month;
    int year = date.year;
    String twoDigitMonth = month.toString().padLeft(2, '0');
    String twoDigitDay = day.toString().padLeft(2, '0');
    return "$twoDigitDay/$twoDigitMonth/$year";
  }

  bool isCritical = false;
  bool isBloodRecipient = false;

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
  List<String> bloodTypes = ["", "Platelet", "Plasma", "Blood"];
  List<String> unitsOfBlood = [
    "",
    "1 unit",
    "2 unit",
    "3 unit",
    "4 unit",
    "5 unit",
    "6 unit"
  ];

  List<String> getUnitsForBloodType(String bloodType) {
    if (bloodType == 'Blood') {
      return unitsOfBlood;
    } else {
      return unitsOfPlasmaAndPlatelets;
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget buildBloodTypeDropdown() {
      return DropdownButtonFormField<String>(
        value: _selectedBloodType,
        items: bloodTypes
            .map((type) => DropdownMenuItem<String>(
                  value: type,
                  child: Text(type),
                ))
            .toList(),
        onChanged: (value) {
          setState(() {
            _selectedBloodType = value!;
            _selectedUnits =
                null; // Reset selected units when blood type changes
          });
        },
        decoration: const InputDecoration(labelText: 'Select Blood Type'),
      );
    }

    Widget buildOrganTypeDropdown() {
      return DropdownButtonFormField<String>(
        value: _selectedOrganType,
        items: ["", "Liver", "Kidney", "Intestine"]
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

    Widget buildBloodUnitsDropDown() {
      return DropdownButtonFormField<String>(
        value: _selectedUnits,
        items: getUnitsForBloodType(_selectedBloodType ?? 'Blood')
            .map((unit) => DropdownMenuItem<String>(
                  value: unit,
                  child: Text(
                      '$unit ${_selectedBloodType == 'Blood' ? 'unit(s)' : 'mL'}'),
                ))
            .toList(),
        onChanged: (value) {
          setState(() {
            _selectedUnits = value;
          });
        },
        decoration: const InputDecoration(labelText: 'Select Volume'),
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Recipient '),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKeyRecipient,
          child: Align(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                    child: Text(
                      'Recipient Registration',
                      style: TextStyle(
                          color: darkPrimaryColor,
                          fontSize: 30,
                          fontWeight: FontWeight.w900),
                    ),
                  ),
                  TextFormField(
                    controller: _patientNameController,
                    maxLength: 20,
                    decoration: const InputDecoration(
                      labelText: 'Patient Name',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(40))),
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
                  TextFormField(
                    controller: _attendeePhoneController,
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                    decoration: const InputDecoration(
                        labelText: 'Attendee Phone Number',
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(40)))),
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
                  CheckboxListTile(
                    title: const Text('Blood Required?',
                        style:
                            TextStyle(color: Color.fromARGB(255, 1, 46, 69))),
                    checkColor: Colors.tealAccent,
                    activeColor: const Color.fromARGB(255, 1, 46, 69),
                    value: isBloodRecipient,
                    onChanged: (value) {
                      setState(() {
                        isBloodRecipient = value!;
                        isOrganRecipient = false;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: const Text('Organ Required?',
                        style:
                            TextStyle(color: Color.fromARGB(255, 1, 46, 69))),
                    checkColor: Colors.tealAccent,
                    activeColor: const Color.fromARGB(255, 1, 46, 69),
                    value: isOrganRecipient,
                    onChanged: (value) {
                      setState(() {
                        isOrganRecipient = value!;
                        isBloodRecipient = false;
                      });
                    },
                  ),
                  if (!isOrganRecipient) buildBloodTypeDropdown(),
                  DropdownButtonFormField<String>(
                    value: _selectedBloodGroup,
                    items: bloodGroups
                        .map((group) => DropdownMenuItem<String>(
                              value: group,
                              child: Text(group),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedBloodGroup = value;
                      });
                    },
                    decoration:
                        const InputDecoration(labelText: 'Select Blood Group'),
                  ),
                  if (!isOrganRecipient) buildBloodUnitsDropDown(),
                  const SizedBox(height: 10),
                  if (!isBloodRecipient) buildOrganTypeDropdown(),
                  const Text(
                    'Required by Date: ',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color.fromARGB(255, 1, 46, 69)),
                  ),
                  IconButton(
                    iconSize: 30,
                    color: const Color.fromARGB(255, 1, 46, 69),
                    onPressed: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2101),
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
                          fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                  CSCPicker(
                    layout: Layout.horizontal,
                    showStates: true,
                    showCities: true,
                    dropdownDecoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                        color: Colors.white,
                        border: Border.all(color: Colors.black, width: 1)),
                    disabledDropdownDecoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
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
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const Text('Critical Request?'),
                      Switch(
                        activeTrackColor: Colors.tealAccent,
                        activeColor: Colors.teal,
                        value: isCritical,
                        onChanged: (value) {
                          setState(() {
                            isCritical = value;
                          });
                        },
                      ),
                    ],
                  ),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        _saveItem();
                      },
                      child: const Text('Send Request'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
