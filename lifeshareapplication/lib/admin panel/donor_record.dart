import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lifeshareapplication/admin panel/add_admin.dart';
import 'package:lifeshareapplication/admin%20panel/donor_details_card.dart';
import 'package:lifeshareapplication/http_client.dart';
import 'package:lifeshareapplication/tabbar.dart';

class DonorRecord extends StatefulWidget {
  const DonorRecord({super.key});

  @override
  State<DonorRecord> createState() => _DonorRecordState();
}

class _DonorRecordState extends State<DonorRecord> {
  List<Widget> detailsCards = [];
  List<String> searchItems = [];
  String searchPhone = ''; // New state variable for search

  Future<void> getData(BuildContext context) async {
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
        final Map<String, dynamic>? responseData = jsonDecode(response.body);

        if (responseData != null && responseData.isNotEmpty) {
          detailsCards.clear();
          searchItems.clear();

          for (final MapEntry<String, dynamic> entry in responseData.entries) {
            final Map<String, dynamic> user = entry.value;

            final String storedName = user['Name'] ?? "Unknown";
            final String storedPhone = user['Phone'].toString();
            searchItems.add(storedPhone);

            // Check if searchPhone is empty or matches the stored phone
            if (searchPhone.isEmpty ||
                storedPhone.contains(searchPhone.trim())) {
              final String storedId = user['Id'].toString();
              final String gender = user['Gender'] ?? "Unknown";
              final bool isDonatingOrgan = user['isDonatingOrgan'];
              final String bloodtype = user['Blood Group'] ?? "Unknown";
              final String age = user['Age'].toString();
              final bool hasDonatedBefore = user['hasDonatedBefore'];
              final String lastdayofdonation =
                  user['Date of Last Donation'].toString();
              final String country = user['Country'] ?? "Unknown";
              final String state = user['State'] ?? "Unknown";
              final String city = user['City'] ?? "Unknown";
              final String organType = user['Organ Type'] ?? "Unknown";
              final String weight = user['Weight'].toString();
              final List<dynamic>? medicalReportData = user['Medical Report'];
              List<String> medicalReportImages = [];
              if (medicalReportData != null) {
                medicalReportImages = medicalReportData.map((dynamic item) {
                  if (item is String) {
                    // If the item is a string (presumably image data), return it directly
                    return item;
                  } else if (item is Map<String, dynamic>) {
                    // If the item is a map, extract the image data
                    final String imageData = item['imageData'];
                    return imageData;
                  } else {
                    // Handle other types if needed
                    return '';
                  }
                }).toList();
              }

              // Print the type of medicalReportData
              print(medicalReportData.runtimeType);
              detailsCards.add(
                DonorDetailsCard(
                  name: storedName,
                  phone: storedPhone,
                  id: storedId,
                  gender: gender,
                  age: age,
                  weight: weight,
                  organType: organType,
                  isDonatingOrgan: isDonatingOrgan,
                  bloodtype: bloodtype,
                  lastdayofdonation: lastdayofdonation,
                  city: city,
                  state: state,
                  country: country,
                  medicalReportImages: medicalReportImages,
                  hasDonatedBefore: hasDonatedBefore,
                  onDelete: (String userId, BuildContext context,
                      {bool approved = false}) {
                    deleteUserData(userId, context, approved: approved);
                  },
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
        title: const Text('Donor List'),
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
                  detailsCards: detailsCards,
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
              // Check if detailsCards is empty
              if (detailsCards.isEmpty) {
                return const Center(child: Text('No matching data found'));
              } else {
                // Use the detailsCards list to build the ListView
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: detailsCards.length,
                  itemBuilder: (context, index) {
                    if (index < detailsCards.length) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: detailsCards[index],
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

  void deleteUserData(String userId, BuildContext context,
      {bool approved = false}) async {
    final url = Uri.https(
      'lifeshare-873ea-default-rtdb.firebaseio.com',
      'donorDetails.json',
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
          'donorDetails/$key.json',
        );

        final deleteResponse = await client.delete(deleteUrl);

        if (deleteResponse.statusCode == 200) {
          // Deletion successful
          int indexToRemove = detailsCards.indexWhere(
            (card) => card is DonorDetailsCard && card.id == userId,
          );

          if (indexToRemove != -1) {
            if (context.mounted) {
              // Check if the user is being deleted due to approval or not
              if (!approved) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('User deleted successfully')),
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
            card is DonorDetailsCard &&
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
