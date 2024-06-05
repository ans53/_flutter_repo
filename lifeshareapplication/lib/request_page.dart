// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:lifeshareapplication/http_client.dart';
import 'package:lifeshareapplication/model/data_flow.dart';
import 'package:lifeshareapplication/request_card.dart';
import 'package:provider/provider.dart';

class Requests extends StatefulWidget {
  const Requests({super.key});

  @override
  State<Requests> createState() => _RequestsState();
}

class _RequestsState extends State<Requests> {
  String storedName = "";
  String storedPhone = "";
  String storedBloodGroup = "";
  String storedBloodType = "";
  String storedOrganType = "";
  String storedState = "";
  String storedCity = "";
  String storedId = "";
  String storedCountry = "";
  String storedRequiredByDate = "";
  bool storedisOrganRequired = false;
  String storedQuantity = "";

  List<Widget> recipientDetailsCard = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMyDetails();
  }

  Future<void> fetchMyDetails() async {
    final uidProvider = Provider.of<UuidProvider>(context, listen: false);
    final url = Uri.https(
      'lifeshare-873ea-default-rtdb.firebaseio.com',
      'recipientDetails.json',
      {'orderBy': '"Id"', 'equalTo': '"${uidProvider.uid}"'},
    );

    try {
      final response = await client.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );
      print(response.body);
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData.isNotEmpty) {
          final Map<String, dynamic> user = responseData.values.first;
          setState(() {
            storedId = user['Id'].toString();
            storedName = user['Name'];
            storedPhone = user['Phone'].toString();
            storedBloodGroup = user['Blood group'];
            storedBloodType = user['Blood Type'].toString();
            storedOrganType = user['Organ Type'].toString();
            storedState = user['State'];
            storedCity = user['City'];
            storedCountry = user['Country'];
            storedQuantity = user['Blood Quantity'].toString();
            storedRequiredByDate = user['Required by Date'].toString();
            storedisOrganRequired = user['isOrganRequired'];
            isLoading = false;
          });
          print(storedRequiredByDate);
          recipientDetailsCard.add(
            RequestCard(
              city: storedCity,
              state: storedState,
              country: storedCountry,
              name: storedName,
              phone: storedPhone,
              id: storedId,
              bloodGroup: storedBloodGroup,
              bloodType: storedBloodType,
              isOrganRequired: storedisOrganRequired,
              organType: storedOrganType,
              quantity: storedQuantity,
              requiredByDate: storedRequiredByDate,
              onDelete: removeRequest, // Pass the onDelete function
            ),
          );
          print(recipientDetailsCard);
        } else {
          setState(() {
            isLoading = false;
          });
        }
      } else {
        throw 'Failed to fetch donor details: ${response.statusCode}';
      }
    } catch (error) {
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

  @override
  Widget build(BuildContext context) {
    print('Building widget...');
    return Scaffold(
      appBar: AppBar(
        title: const Text("Requests Made"),
        automaticallyImplyLeading: false,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : recipientDetailsCard.isEmpty
              ? const Center(
                  child: Text(
                      'No requests have been made or\nAdmin has rejected the your request'))
              : ListView.builder(
                  itemCount: recipientDetailsCard.length,
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: recipientDetailsCard[index],
                  ),
                  padding: const EdgeInsets.all(10),
                ),
    );
  }

  void removeRequest(String id) async {
    final uidProvider = Provider.of<UuidProvider>(context, listen: false);
    final url = Uri.https(
      'lifeshare-873ea-default-rtdb.firebaseio.com',
      'recipientDetails.json',
      {'orderBy': '"Id"', 'equalTo': "'${uidProvider.uid}'"},
    );

    try {
      final response = await client.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body) as Map<String, dynamic>;
        if (responseData.isNotEmpty) {
          final entry = responseData.entries.firstWhere(
            (entry) => entry.value['Id'] == uidProvider.uid,
          );

          final key = entry.key;
          final deleteUrl = Uri.https(
            'lifeshare-873ea-default-rtdb.firebaseio.com',
            'recipientDetails/$key.json',
          );

          final deleteResponse = await client.delete(deleteUrl);

          if (deleteResponse.statusCode == 200) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Donation removed successfully'),
                ),
              );
            }
            setState(() {
              // Resetting the state variables to null or empty to reflect the removal in the UI
              storedName = "";
              storedPhone = "";
              storedBloodGroup = "";
              storedBloodType = "";
              storedOrganType = "";
              storedState = "";
              storedCity = "";
              storedCountry = "";
              storedisOrganRequired = false;
              storedQuantity = "";
              storedRequiredByDate = "";

              storedId = "";
            });
          } else {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Failed to remove donation'),
                ),
              );
            }
          }
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No donations found for the user'),
              ),
            );
          }
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to fetch donations'),
            ),
          );
        }
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $error'),
          ),
        );
      }
    }
  }
}
