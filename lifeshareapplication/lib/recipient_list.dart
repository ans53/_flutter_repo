// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:lifeshareapplication/http_client.dart';
import 'package:lifeshareapplication/model/data_flow.dart';
import 'package:lifeshareapplication/recipient_card.dart';
import 'package:lifeshareapplication/recipient_filter_drawer.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecipientList extends StatefulWidget {
  const RecipientList({super.key});

  @override
  State<RecipientList> createState() => _RecipientListState();
}

class _RecipientListState extends State<RecipientList> {
  final List _recipients = [];
  bool _loading = true;
  String? selectedBloodGroup;
  String? selectedOrganType;

  @override
  void initState() {
    super.initState();
    // Load recipient details initially
    loadFilterPreferencesRecipient();
  }

  Future<void> loadFilterPreferencesRecipient() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedBloodGroup = prefs.getString('recipientSelectedBloodGroup');
      selectedOrganType = prefs.getString('recipientSelectedOrganType');
    });
    fetchRecipientDetails();
  }

  Future<void> fetchRecipientDetails() async {
    final locationProvider =
        Provider.of<LocationProvider>(context, listen: false);

    // Fetch all recipients
    final allRecipientsUrl = Uri.https(
      'lifeshare-873ea-default-rtdb.firebaseio.com',
      'recipientDetails.json',
    );

    try {
      final allRecipientsResponse = await client.get(
        allRecipientsUrl,
        headers: {'Content-Type': 'application/json'},
      );

      if (allRecipientsResponse.statusCode == 200) {
        final Map<String, dynamic> allRecipientsData =
            jsonDecode(allRecipientsResponse.body);
        List allRecipients = allRecipientsData.values.toList();

        // Filter recipients based on selected criteria
        List filteredRecipients = allRecipients.where((recipient) {
          bool bloodGroupMatches = selectedBloodGroup == null ||
              recipient['Blood group'] == selectedBloodGroup;
          bool organTypeMatches = selectedOrganType == null ||
              recipient['Organ Type'] == selectedOrganType;

          return bloodGroupMatches && organTypeMatches;
        }).toList();

        // Sort the filtered recipients based on city matching
        filteredRecipients.sort((a, b) {
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
          _recipients.clear(); // Clear existing recipients
          _recipients.addAll(filteredRecipients); // Add sorted recipients
          _loading = false;
        });
      } else {
        throw 'Failed to fetch recipient details';
      }
    } catch (error) {
      setState(() {
        _loading = false;
      });
      if (context.mounted) {
        print('Error fetching recipient details: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error fetching recipient details: $error'),
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

      fetchRecipientDetails(); // Fetch new data based on updated filters
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: RecipientFilterDrawer(
        onFilterChanged: updateFilter,
      ),
      appBar: AppBar(title: const Text("Look For")),
      backgroundColor: const Color.fromARGB(255, 228, 247, 253),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _recipients.isEmpty
              ? const Center(child: Text('No Recipients available'))
              : ListView.builder(
                  itemCount: _recipients.length,
                  itemBuilder: (context, index) {
                    final recipientDetails = _recipients[index];
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                      child: RecipientCard(recipientDetails: recipientDetails),
                    );
                  },
                  padding: const EdgeInsets.all(10),
                ),
    );
  }
}
