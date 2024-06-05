// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:lifeshareapplication/http_client.dart';
import 'package:lifeshareapplication/model/data_flow.dart';
import 'package:provider/provider.dart';

TextStyle txt = const TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.w700,
    fontSize: 15,
    letterSpacing: 2);

class MyDonationRequest extends StatefulWidget {
  const MyDonationRequest({super.key});

  @override
  State<MyDonationRequest> createState() => MyDonationRequestState();
}

class MyDonationRequestState extends State<MyDonationRequest> {
  String storedName = "";
  String storedPhone = "";
  String storedBloodGroup = "";
  String storedBloodType = "";
  String storedOrganType = "";
  String storedState = "";
  String storedCity = "";
  String storedId = "";
  String storedCountry = "";
  String lastDateDonated = "";
  String age = "";
  String gender = "";
  String weight = "";
  String lasttimedonated = "";
  List<dynamic>? medicalReportData;
  String? consentLetterBase64;
  bool hasDonatedBefore = false;
  bool hasConsent = false;
  List<String> medicalReportImages = [];

  bool isLoading = true;
  bool isDonatingBlood = false;

  @override
  void initState() {
    super.initState();
    fetchMyDetails();
  }

  void removeDonation() async {
    final uidProvider = Provider.of<UuidProvider>(context, listen: false);
    final url = Uri.https(
      'lifeshare-873ea-default-rtdb.firebaseio.com',
      'approvedDonorDetails.json',
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
            (entry) => entry.value['Id'] == uidProvider,
          );

          final key = entry.key;
          final deleteUrl = Uri.https(
            'lifeshare-873ea-default-rtdb.firebaseio.com',
            'approvedDonorDetails/$key.json',
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

  void fetchMyDetails() async {
    final uidProvider = Provider.of<UuidProvider>(context, listen: false);
    final url = Uri.https(
      'lifeshare-873ea-default-rtdb.firebaseio.com',
      'approvedDonorDetails.json',
      {'orderBy': '"Id"', 'equalTo': '"${uidProvider.uid}"'},
    );

    try {
      final response = await client.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData.isNotEmpty) {
          final Map<String, dynamic> user = responseData.values.first;
          setState(() {
            storedId = user['Id'];
            storedName = user['Name'] ?? '';
            storedPhone = user['Phone']?.toString() ?? '';
            storedBloodGroup = user['Blood Group'] ?? '';
            storedBloodType = user['Blood Type'] ?? '';
            storedOrganType = user['Organ Type'] ?? '';
            storedState = user['State'] ?? '';
            storedCity = user['City'] ?? '';
            storedCountry = user['Country'] ?? '';
            age = user['Age']?.toString() ?? '';
            gender = user['Gender'] ?? '';
            weight = user['Weight']?.toString() ?? '';
            lasttimedonated = user['Date of Last Donation'].toString();
            hasDonatedBefore = user['hasDonatedBefore'] ?? false;
            isDonatingBlood = user['isDonatingBlood'] ?? false;
            medicalReportData = user['Medical Report'];

            if (medicalReportData != null) {
              medicalReportImages = medicalReportData!.map((dynamic item) {
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

            hasConsent = user['ConsentUploaded'];
            if (hasConsent) {
              consentLetterBase64 = user['ConsentLetter'].toString();
            }
            isLoading = false;
          });
          print(isDonatingBlood);
          print(response.body);
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

  void _showConsentLetterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Consent Letter'),
          content: hasConsent
              ? consentLetterBase64 != null
                  ? SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * 0.4,
                      child: _buildConsentLetterImage(context),
                    )
                  : const Text('No consent letter image available')
              : const Text('Consent not uploaded'),
          actions: <Widget>[
            IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.cancel_presentation_outlined),
            )
          ],
        );
      },
    );
  }

  Widget _buildConsentLetterImage(BuildContext context) {
    try {
      // Decode base64 string
      final image = Image.memory(
        base64Decode(consentLetterBase64!),
        fit: BoxFit.contain,
      );

      return Column(
        children: [
          Stack(
            alignment: AlignmentDirectional.bottomEnd,
            children: [
              InteractiveViewer(
                boundaryMargin: const EdgeInsets.all(10.0),
                minScale: 1.0,
                maxScale: 3.0,
                constrained: true,
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: image,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.download),
                onPressed: () {
                  _downloadConsentLetter(); // Call method to download the consent letter
                },
              ),
            ],
          ),
        ],
      );
    } catch (e) {
      print('Error decoding consent letter image: $e');
      return const Text('Error decoding consent letter image');
    }
  }

  void _downloadConsentLetter() async {
    try {
      // Convert base64 string to bytes
      final Uint8List bytes = base64Decode(consentLetterBase64!);

      // Save imageBytes to the device's gallery
      final result = await ImageGallerySaver.saveImage(bytes);

      if (result != null && result.isNotEmpty) {
        // If the result is not null or empty, the image was successfully saved
        // Show a snackbar to inform the user about the download status
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Consent letter downloaded successfully'),
            ),
          );
        }
      } else {
        // If the result is null or empty, the image failed to save
        // Show a snackbar to inform the user about the failure
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to download consent letter'),
            ),
          );
        }
      }
    } catch (e) {
      // Handle any exceptions that occur during the download process
      // Show a snackbar to inform the user about the error
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error downloading consent letter: $e'),
          ),
        );
      }
    }
  }

  void _showMedicalReportDialog(List<String> medicalReportBase64List) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Medical Report'),
          content: SingleChildScrollView(
            child: Column(
              children: medicalReportBase64List.map((base64String) {
                return Padding(
                  padding: const EdgeInsets.only(
                      bottom: 1.0), // Add padding between images
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width *
                        0.9, // Set width to 90% of screen width
                    height: MediaQuery.of(context).size.height * 0.4,
                    child: buildMedicalReportImage(context, base64String),
                  ),
                );
              }).toList(),
            ),
          ),
          actions: <Widget>[
            IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.cancel_presentation_outlined),
            )
          ],
        );
      },
    );
  }

  Widget buildMedicalReportImage(BuildContext context, String base64String) {
    try {
      final Uint8List bytes = base64Decode(base64String);
      final image = Image.memory(
        bytes,
        fit: BoxFit.contain,
      );

      double scale = 1.0;

      return GestureDetector(
        onScaleUpdate: (ScaleUpdateDetails details) {
          setState(() {
            scale *= details.scale;
          });
        },
        child: Column(
          children: [
            Stack(
              alignment: AlignmentDirectional.bottomEnd,
              children: [
                Transform.scale(
                  scale: scale,
                  child: image,
                ),
                IconButton(
                  icon: const Icon(
                    Icons.download,
                    size: 20,
                  ),
                  onPressed: () {
                    _downloadImage(bytes);
                  },
                ),
              ],
            ),
          ],
        ),
      );
    } catch (e) {
      print('Error decoding medical report image: $e');
      return const Text('Error decoding medical report image');
    }
  }

  void _downloadImage(Uint8List imageBytes) async {
    try {
      // Save imageBytes to the device's gallery
      final result = await ImageGallerySaver.saveImage(imageBytes);

      if (result != null && result.isNotEmpty) {
        // If the result is not null or empty, the image was successfully saved
        // Show a snackbar to inform the user about the download status
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Image downloaded successfully'),
            ),
          );
        }
      } else {
        // If the result is null or empty, the image failed to save
        // Show a snackbar to inform the user about the failure
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to download image'),
            ),
          );
        }
      }
    } catch (e) {
      // Handle any exceptions that occur during the download process
      // Show a snackbar to inform the user about the error
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error downloading image: $e'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("My Donations"), automaticallyImplyLeading: false),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
        child: SizedBox(
          height: 550,
          width: 440,
          child: Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0)),
            shadowColor: const Color.fromARGB(255, 9, 100, 148),
            elevation: 20,
            color: const Color.fromARGB(255, 1, 46, 69),
            child: Padding(
              padding: const EdgeInsets.all(9),
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : storedName.isEmpty // Check if no data is present
                      ? const Center(
                          child: Text(
                            'No Request donation Made Yet\nIf made wait for approval',
                            style: TextStyle(color: Colors.white),
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Name", style: txt),
                                Text(storedName, style: txt)
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Mobile Number", style: txt),
                                Text(storedPhone, style: txt)
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Blood Group", style: txt),
                                Text(storedBloodGroup, style: txt)
                              ],
                            ),
                            if (isDonatingBlood)
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Blood Type", style: txt),
                                  Text(storedBloodType, style: txt)
                                ],
                              ),
                            if (isDonatingBlood == true)
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Organ Type", style: txt),
                                  Text(storedOrganType, style: txt)
                                ],
                              ),
                            if (hasDonatedBefore)
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Date of Last Donation", style: txt),
                                  Text(lasttimedonated.split(' ')[0],
                                      style: txt)
                                ],
                              ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Date of Last Donation", style: txt),
                                Text('First Timer', style: txt)
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Gender", style: txt),
                                Text(gender, style: txt)
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Age", style: txt),
                                Text(age, style: txt)
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Weight", style: txt),
                                Text(weight, style: txt)
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Location", style: txt),
                                Text("$storedCountry $storedState\n$storedCity",
                                    style: txt)
                              ],
                            ),
                            ElevatedButton(
                              onPressed: () {
                                _showMedicalReportDialog(
                                    medicalReportImages); // Call method to show the medical report dialog
                              },
                              child: const Text('View Medical Report'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                _showConsentLetterDialog(); // Call method to show the consent letter dialog
                              },
                              child: const Text('View Consent Letter'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                removeDonation();
                              },
                              child: const Text('Remove Donation'),
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
