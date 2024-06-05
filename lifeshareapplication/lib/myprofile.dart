import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:lifeshareapplication/http_client.dart';
import 'package:lifeshareapplication/login_page.dart';
import 'package:lifeshareapplication/model/data_flow.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

TextStyle styling = const TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    letterSpacing: 2,
    color: Color.fromARGB(255, 1, 46, 69));

class MyProfile extends StatefulWidget {
  const MyProfile({super.key});

  @override
  State<MyProfile> createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  bool isDonating = false;
  bool isLoading = true;
  Map<String, dynamic>? userDetails;
  Map<String, dynamic>? donorDetails;
  Map<String, dynamic>? approveddonorDetails;

  Icon symbol =
      const Icon(Icons.question_mark_rounded, color: Colors.red, size: 65);

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final uuidProvider = Provider.of<UuidProvider>(context, listen: false);
      if (uuidProvider.uid != null) {
        final urlDetails = Uri.https(
          'lifeshare-873ea-default-rtdb.firebaseio.com',
          'details.json',
          {'orderBy': '"Id"', 'equalTo': '"${uuidProvider.uid}"'},
        );
        final urldonorDetails = Uri.https(
          'lifeshare-873ea-default-rtdb.firebaseio.com',
          'donorDetails.json',
          {'orderBy': '"Id"', 'equalTo': '"${uuidProvider.uid}"'},
        );

        final urlapprovedDonorDetails = Uri.https(
          'lifeshare-873ea-default-rtdb.firebaseio.com',
          'approvedDonorDetails.json',
          {'orderBy': '"Id"', 'equalTo': '"${uuidProvider.uid}"'},
        );

        final responseDetails = await client.get(
          urlDetails,
          headers: {'Content-Type': 'application/json'},
        );

        final responseapprovedDonorDetails = await client.get(
          urlapprovedDonorDetails,
          headers: {'Content-Type': 'application/json'},
        );
        final responsedonorDetails = await client.get(
          urldonorDetails,
          headers: {'Content-Type': 'application/json'},
        );

        if (responseDetails.statusCode == 200) {
          final Map<String, dynamic> detailsData =
              jsonDecode(responseDetails.body);
          userDetails = detailsData.values.first;
        }

        if (responseapprovedDonorDetails.statusCode == 200) {
          final Map<String, dynamic> approveddonorData =
              jsonDecode(responseapprovedDonorDetails.body);
          if (approveddonorData.isNotEmpty) {
            approveddonorDetails = approveddonorData.values.first;
            updateSymbol(
                approveddonorDetails); // Update symbol with approved data
          }
        }

        if (responsedonorDetails.statusCode == 200) {
          final Map<String, dynamic> detailsdonorData =
              jsonDecode(responsedonorDetails.body);
          if (detailsdonorData.isNotEmpty) {
            donorDetails = detailsdonorData.values.first;
            if (approveddonorDetails == null) {
              updateSymbol(
                  donorDetails); // Update symbol if no approved donor data
            }
          }
        }
      }
    } finally {
      if (context.mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // Method to update the symbol based on gender
  void updateSymbol(Map<String, dynamic>? details) {
    if (details != null) {
      if (details['Gender'] == 'Female') {
        setState(() {
          symbol = const Icon(Icons.female, color: Colors.pink, size: 65);
        });
      } else if (details['Gender'] == 'Male') {
        setState(() {
          symbol = const Icon(Icons.male, color: Colors.lightBlue, size: 65);
        });
      } else if (details['Gender'] == 'Others') {
        setState(() {
          symbol = const Icon(Icons.circle, color: Colors.amber, size: 65);
        });
      } else {
        setState(() {
          symbol = Icon(Icons.question_mark_rounded,
              color: Colors.red[900], size: 65);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 189, 244, 255),
      appBar: AppBar(
        title: const Text("Profile"),
      ),
      body: isLoading ? const CircularProgressIndicator() : buildUserData(),
    );
  }

  // Helper method to build the UI based on fetched data
  Widget buildUserData() {
    Map<String, dynamic>? displayDetails = approveddonorDetails ?? userDetails;

    String status = 'Account Created';
    if (approveddonorDetails != null) {
      if (approveddonorDetails!['ConsentUploaded'] == true) {
        status =
            "Consent Uploaded,\nYour Request for Donation\nhas been Approved";
      } else {
        status = "Data Approved,\nWaiting for Consent";
      }
    } else if (donorDetails != null) {
      status = "Requested For Donation";
    } else if (approveddonorDetails != null) {
      status = "Request Accepted";
    } else {
      status = "No Request Made Yet";
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          height: 200.0,
          decoration: const BoxDecoration(
            color: Colors.orange,
            image: DecorationImage(
              image: AssetImage('assets/health-frames.gif'),
              alignment: Alignment.center,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(80.0),
              bottomRight: Radius.circular(80.0),
            ),
          ),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: CircleAvatar(
              radius: 33,
              backgroundColor: Colors.orange[500],
              child: symbol,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
          height: 400,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Status:", style: styling),
                  Text(status, style: styling),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Name:", style: styling),
                  Text(displayDetails?['Name'] ?? 'N/A', style: styling),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Mobile:", style: styling),
                  Text(displayDetails?['Phone']?.toString() ?? '',
                      style: styling),
                ],
              ),
              if (approveddonorDetails != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Blood Group:", style: styling),
                    Text(displayDetails?['Blood Group'] ?? 'N/A',
                        style: styling),
                  ],
                ),
              if (approveddonorDetails != null)
                if (displayDetails?['isDonatingOrgan'])
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Blood Group:", style: styling),
                      Text(displayDetails?['Organ Type'] ?? 'N/A',
                          style: styling),
                    ],
                  ),
              if (approveddonorDetails != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Gender:", style: styling),
                    Text(displayDetails?['Gender'] ?? 'N/A', style: styling),
                  ],
                ),
              if (approveddonorDetails != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Weight:", style: styling),
                    Text(displayDetails?['Weight']?.toString() ?? '',
                        style: styling),
                  ],
                ),
              if (approveddonorDetails != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Age:", style: styling),
                    Text(displayDetails?['Age']?.toString() ?? '',
                        style: styling),
                  ],
                ),
              if (approveddonorDetails != null || approveddonorDetails == null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Country:", style: styling),
                    Text(displayDetails?['Country'] ?? 'N/A', style: styling),
                  ],
                ),
              if (approveddonorDetails != null || approveddonorDetails == null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("State:", style: styling),
                    Text(displayDetails?['State'] ?? 'N/A', style: styling),
                  ],
                ),
              if (approveddonorDetails != null || approveddonorDetails == null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("City:", style: styling),
                    Text(displayDetails?['City'] ?? 'N/A', style: styling),
                  ],
                ),
            ],
          ),
        ),
        ElevatedButton(
          onPressed: () async {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.clear();
            if (context.mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            }
          },
          child: const Text('Log Out'),
        ),
        const SizedBox(
          height: 10,
        ),
      ],
    );
  }
}
