// ignore_for_file: avoid_print, unnecessary_overrides

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lifeshareapplication/admin panel/add_admin.dart';
import 'package:lifeshareapplication/admin%20panel/recipient_details_card.dart';
import 'package:lifeshareapplication/http_client.dart';
import 'package:lifeshareapplication/tabbar.dart';

class RecipientRecord extends StatefulWidget {
  const RecipientRecord({super.key});

  @override
  State<RecipientRecord> createState() => _RecipientRecordState();
}

class _RecipientRecordState extends State<RecipientRecord> {
  List<Widget> recipientDetailsCard = [];
  List<String> searchItems = [];
  String searchPhone = ''; // New state variable for search

  Future<void> getData(BuildContext context) async {
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
        final Map<String, dynamic>? responseData = jsonDecode(response.body);

        if (responseData != null && responseData.isNotEmpty) {
          recipientDetailsCard.clear();
          searchItems.clear();

          for (final MapEntry<String, dynamic> entry in responseData.entries) {
            final Map<String, dynamic> user = entry.value;

            final String storedName = user['Name'] ?? "Unknown";
            final String storedPhone = user['Phone'].toString();
            searchItems.add(storedPhone);
            final String storedId = user['Id'].toString();
            final String bloodType = user['Blood Type'] ?? "Unknown";
            final String bloodGroup = user['Blood group'] ?? "Unknown";
            final String quantity = user['Blood Quantity'].toString();
            final String requiredByDate = user['Required by Date'].toString();
            final String country = user['Country'] ?? "Unknown";
            final String city = user['City'] ?? "Unknown";
            final String state = user['State'] ?? "Unknown";
            final bool isOrganRequired = user['isOrganRequired'];
            final String organType = user['Organ Type'] ?? "Unknown";

            if (searchPhone.isEmpty ||
                storedPhone.contains(searchPhone.trim())) {
              recipientDetailsCard.add(
                RecipientDetailsCard(
                  city: city,
                  state: state,
                  country: country,
                  name: storedName,
                  phone: storedPhone,
                  id: storedId,
                  bloodGroup: bloodGroup,
                  bloodType: bloodType,
                  isOrganRequired: isOrganRequired,
                  organType: organType,
                  quantity: quantity,
                  requiredByDate: requiredByDate,
                  onDelete: (userId, context) =>
                      deleteUserData(userId, context),
                ),
              );
            }
          }
        }
      }
    } catch (error) {
      if (context.mounted) {
        String errorMessage;
        if (error is SocketException) {
          errorMessage = 'Network error: Please check your connection.';
        } else {
          errorMessage = 'An error occurred: $error';
          // Log detailed error information for debugging
          print(error);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipient List'),
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const MyTabbar()),
            );
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.search,
              color: Colors.white,
              size: 30,
            ),
            onPressed: () {
              showSearch(
                context: context,
                delegate: CustomSearchDelegate(
                  onSearch: (searchPhone) => setState(() {
                    this.searchPhone = searchPhone;
                  }),
                  searchItems: searchItems,
                  detailsCards: recipientDetailsCard,
                  searchPhone: searchPhone, // Pass searchPhone here
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.add_circle_rounded,
              color: Colors.white,
              size: 40,
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const AddAdmin()),
              );
            },
          ),
        ],
        centerTitle: true,
      ),
      body: FutureBuilder<void>(
        future: getData(context), // Pass context here
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              // Handle the error case
              return const Center(child: Text('Error loading data'));
            } else {
              // Check if recipientDetailsCard is empty
              if (recipientDetailsCard.isEmpty) {
                return const Center(child: Text('No matching data found'));
              } else {
                // Use the recipientDetailsCard list to build the ListView
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: recipientDetailsCard.length,
                  itemBuilder: (context, index) {
                    if (index < recipientDetailsCard.length) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: recipientDetailsCard[index],
                      );
                    } else {
                      return const SizedBox();
                      // Return an empty SizedBox if index is out of bounds
                    }
                  },
                  padding: const EdgeInsets.all(10),
                );
              }
            }
          } else {
            // Handle loading state if needed
            return Container(
              alignment: Alignment.center,
              height: 600,
              width: 600,
              child: const CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }

  void deleteUserData(String userId, BuildContext context) async {
    final url = Uri.https(
      'lifeshare-873ea-default-rtdb.firebaseio.com',
      'recipientDetails.json',
    );

    try {
      final response = await client.get(url);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        final entry = responseData.entries.firstWhere(
          (entry) => entry.value['Id'] == userId,
        );

        final key = entry.key;

        final deleteUrl = Uri.https(
          'lifeshare-873ea-default-rtdb.firebaseio.com',
          'recipientDetails/$key.json',
        );

        final deleteResponse = await client.delete(deleteUrl);

        if (deleteResponse.statusCode == 200) {
          // Deletion successful
          int indexToRemove = recipientDetailsCard.indexWhere(
            (card) => card is RecipientDetailsCard && card.id == userId,
          );

          if (indexToRemove != -1) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('User deleted successfully')),
              );
            }
          } else {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Failed to delete user')),
              );
            }
          }
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to delete user')),
            );
          }
        }
      } else {
        // Failed to fetch data
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to fetch user data')),
          );
        }
      }
    } catch (error, stackTrace) {
      // Handle errors
      print('Error during user deletion: $error');
      print('Stack trace: $stackTrace');
    }
  }
}

class CustomSearchDelegate extends SearchDelegate {
  final Function(String) onSearch;
  final List<String> searchItems;
  final List<Widget> detailsCards;
  final String searchPhone; // Add searchPhone as a parameter

  CustomSearchDelegate({
    required this.onSearch,
    required this.searchItems,
    required this.detailsCards,
    required this.searchPhone, // Initialize searchPhone in the constructor
  });

  @override
  void close(BuildContext context, [result]) {
    super.close(context, result); // Call the default close method
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () => query = '',
        icon: const Icon(Icons.clear),
      )
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () => close(context, null),
      icon: const Icon(Icons.arrow_back_ios),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // Filter detailsCards based on the searchPhone
    final filteredCards = detailsCards
        .where((card) =>
            card is RecipientDetailsCard &&
            card.phone.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: filteredCards.length,
      itemBuilder: (context, index) => filteredCards[index],
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final List<String> filteredSuggestions = searchItems.where((suggestion) {
      return suggestion.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: filteredSuggestions.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(filteredSuggestions[index]),
          onTap: () {
            query = filteredSuggestions[
                index]; // Update query with selected suggestion
            onSearch(filteredSuggestions[
                index]); // Call onSearch with selected suggestion
            close(context, query); // Close the search bar
          },
        );
      },
    );
  }

  @override
  void showResults(BuildContext context) {
    if (query.isNotEmpty) {
      onSearch(query); // Trigger search based on the current query
    }
  }

  @override
  void showSuggestions(BuildContext context) {
    super.showSuggestions(context);
  }
}
