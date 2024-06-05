// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:lifeshareapplication/donor_card.dart';
import 'package:lifeshareapplication/donor_filter_drawer.dart';
import 'package:lifeshareapplication/http_client.dart';
import 'package:lifeshareapplication/model/data_flow.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DonorList extends StatefulWidget {
  const DonorList({super.key});

  @override
  DonorListState createState() => DonorListState();
}

class DonorListState extends State<DonorList> {
  final List _donors = [];
  bool _loading = true;
  String? selectedBloodGroup;
  String? selectedOrganType;

  @override
  void initState() {
    super.initState();
    // Load filter preferences from shared preferences
    loadFilterPreferences();
  }

  Future<void> loadFilterPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedBloodGroup = prefs.getString('selectedBloodGroup');
      selectedOrganType = prefs.getString('selectedOrganType');
    });

    // Call method to fetch donor details with filters applied
    fetchDonorDetails();
  }

  Future<void> fetchDonorDetails() async {
    final locationProvider =
        Provider.of<LocationProvider>(context, listen: false);

    // Fetch all donors
    final allDonorsUrl = Uri.https(
      'lifeshare-873ea-default-rtdb.firebaseio.com',
      'approvedDonorDetails.json',
    );

    try {
      final allDonorsResponse = await client.get(
        allDonorsUrl,
        headers: {'Content-Type': 'application/json'},
      );

      if (allDonorsResponse.statusCode == 200) {
        final Map<String, dynamic> allDonorsData =
            jsonDecode(allDonorsResponse.body);
        List allDonors = allDonorsData.values.toList();

        // Filter donors based on selected criteria
        List filteredDonors = allDonors.where((donor) {
          bool bloodGroupMatches = selectedBloodGroup == null ||
              donor['Blood Group'] == selectedBloodGroup;
          bool organTypeMatches = selectedOrganType == null ||
              donor['Organ Type'] == selectedOrganType;

          bool consentUploaded = donor['ConsentUploaded'] == true;

          return bloodGroupMatches && organTypeMatches && consentUploaded;
        }).toList();

        // Sort the filtered donors based on city matching and then state matching
        filteredDonors.sort((a, b) {
          bool isACityMatch = a['City'] == locationProvider.city;
          bool isBCityMatch = b['City'] == locationProvider.city;
          bool isAStateMatch = a['State'] == locationProvider.state;
          bool isBStateMatch = b['State'] == locationProvider.state;

          if (isACityMatch == isBCityMatch) {
            if (isAStateMatch == isBStateMatch) {
              return 0;
            } else if (isAStateMatch) {
              return -1;
            } else {
              return 1;
            }
          } else if (isACityMatch) {
            return -1;
          } else {
            return 1;
          }
        });

        setState(() {
          _donors.clear(); // Clear existing donors
          _donors.addAll(filteredDonors); // Add sorted and filtered donors
          _loading = false;
        });
      } else {
        throw 'Failed to fetch donor details';
      }
    } catch (error) {
      setState(() {
        _loading = false;
      });
      if (context.mounted) {
        print('Error fetching donor details: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error fetching donor details: $error'),
          ),
        );
      }
    }
  }

  void updateFilter(String? bloodGroup, String? organType) {
    setState(() {
      selectedBloodGroup = bloodGroup;
      selectedOrganType = organType;
      _loading = true; // Show loading indicator while fetching new data
      fetchDonorDetails(); // Fetch new data based on updated filters
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: DonorFilterDrawer(
        onFilterChanged: updateFilter,
      ),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AppBar(
          title: const Text("Willing to Donate"),
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 228, 247, 253),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _donors.isEmpty
              ? const Center(child: Text('No Donors available'))
              : ListView.builder(
                  itemCount: _donors.length,
                  itemBuilder: (context, index) {
                    final donorDetails = _donors[index];
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                      child: DonorCard(donorDetails: donorDetails),
                    );
                  },
                  padding: const EdgeInsets.all(10),
                ),
    );
  }
}
