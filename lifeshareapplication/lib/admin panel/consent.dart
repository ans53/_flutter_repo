import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:lifeshareapplication/admin%20panel/add_admin.dart';
import 'package:lifeshareapplication/http_client.dart';
import 'package:lifeshareapplication/tabbar.dart';

class ConsentCard extends StatefulWidget {
  final String id;
  final String phone;
  final String name;
  final bool hasConsentLetter;
  final String? consentLetterBase64;

  const ConsentCard({
    super.key,
    required this.id,
    required this.phone,
    required this.name,
    required this.hasConsentLetter,
    required this.consentLetterBase64,
  });

  @override
  State<ConsentCard> createState() => _ConsentCardState();
}

class _ConsentCardState extends State<ConsentCard> {
  bool consentUploaded = false;
  File? selectedImage;

  @override
  void initState() {
    super.initState();
    consentUploaded = widget.hasConsentLetter;
  }

  void _selectImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null) {
      setState(() {
        selectedImage = File(result.files.single.path!);
      });
    }
  }

  void _uploadConsent() async {
    if (selectedImage != null) {
      await _uploadConsentLetter(widget.id, selectedImage!);
      setState(() {
        consentUploaded = true;
      });
    }
  }

  void _cancelUpload() {
    setState(() {
      selectedImage = null;
    });
  }

  Future<void> _uploadConsentLetter(String childId, File selectedImage) async {
    try {
      final url = Uri.https(
        'lifeshare-873ea-default-rtdb.firebaseio.com',
        'approvedDonorDetails.json',
      );

      final response = await client.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic>? responseData = jsonDecode(response.body);

        if (responseData != null && responseData.isNotEmpty) {
          // Loop through each record to find the one with matching sub-field 'Id'
          for (final record in responseData.entries) {
            final dynamic idValue = record.value['Id'];
            if (idValue == childId) {
              final String headerId = record.key;

              // Encode selected image to base64
              final consentLetterBase64 =
                  base64Encode(await selectedImage.readAsBytes());

              final url = Uri.https(
                'lifeshare-873ea-default-rtdb.firebaseio.com',
                'approvedDonorDetails/$headerId.json',
              );

              final response = await client.patch(
                url,
                headers: {'Content-Type': 'application/json'},
                body: json.encode({
                  'ConsentLetter': consentLetterBase64,
                  'ConsentUploaded': true,
                }),
              );

              if (response.statusCode == 200) {
                setState(() {
                  consentUploaded = true;
                });
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Consent letter uploaded')),
                  );
                }
              } else {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Failed to upload consent letter')),
                  );
                }
              }
              break; // Stop the loop once a matching record is found
            }
          }
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to fetch donor details')),
          );
        }
      }
    } catch (error) {
      print('Error uploading consent letter: $error');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An error occurred')),
        );
      }
    }
  }

  void _showConsentLetterDialog(
      BuildContext context, String? consentLetterBase64) {
    final Uint8List bytes = base64Decode(consentLetterBase64!);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Consent Letter'),
          content: consentLetterBase64.isNotEmpty
              ? SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.4,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.memory(
                        bytes,
                        fit: BoxFit.contain,
                      ),
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: IconButton(
                          onPressed: () {
                            _downloadImage(bytes);
                          },
                          icon: const Icon(
                            Icons.download,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : const Text('No consent letter available'),
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
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              ListTile(
                title: Text(widget.name,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    )),
                subtitle: Text('ID: ${widget.id} Phone: ${widget.phone}'),
              ),
            ],
          ),
          if (widget.hasConsentLetter)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: SizedBox(
                  width: 150,
                  child: ElevatedButton(
                    onPressed: () {
                      // Call method to show the consent letter dialog
                      _showConsentLetterDialog(
                          context, widget.consentLetterBase64);
                    },
                    child: const Text(
                      'View Consent',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
            ),
          if (!widget.hasConsentLetter)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: SizedBox(
                  width: 150,
                  child: ElevatedButton(
                    onPressed: _selectImage,
                    child: const Text(
                      'Upload Consent',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
            ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Display uploaded image if available
              if (selectedImage != null)
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Image.file(
                    selectedImage!,
                    fit: BoxFit.cover,
                  ),
                ),
              // Buttons at the bottom
              if (selectedImage != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: _cancelUpload,
                      icon: const Icon(
                        Icons.cancel,
                        color: Colors.red,
                        size: 20,
                      ),
                    ),
                    IconButton(
                      onPressed: _uploadConsent,
                      icon: const Icon(
                        Icons.check,
                        color: Color.fromARGB(255, 43, 254, 50),
                        size: 20,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class ConsentUpload extends StatefulWidget {
  const ConsentUpload({super.key});

  @override
  State<ConsentUpload> createState() => _ConsentUploadState();
}

class _ConsentUploadState extends State<ConsentUpload> {
  List<Widget> approvedDetailsCard = [];
  List<String> searchItems = [];
  String searchPhone = '';

  Future<void> getData(BuildContext context) async {
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
        final Map<String, dynamic>? responseData = jsonDecode(response.body);

        if (responseData != null && responseData.isNotEmpty) {
          print(responseData.entries);
          print(response.body);

          approvedDetailsCard.clear();
          searchItems.clear();

          for (final MapEntry<String, dynamic> entry in responseData.entries) {
            final Map<String, dynamic> user = entry.value;
            final String storedName = user['Name'] ?? "Unknown";
            final String storedPhone = user['Phone'].toString();
            searchItems.add(storedPhone);
            final String storedId = user['Id'].toString();
            final bool hasConsentLetter = user['ConsentUploaded'] ?? false;
            String? consentLetterBase64;

            if (hasConsentLetter == true) {
              consentLetterBase64 = user['ConsentLetter']
                  .toString(); // Retrieve the consent letter content
            }

            if (searchPhone.isEmpty ||
                storedPhone.contains(searchPhone.trim())) {
              approvedDetailsCard.add(
                ConsentCard(
                  id: storedId,
                  name: storedName,
                  phone: storedPhone,
                  hasConsentLetter: hasConsentLetter,
                  consentLetterBase64:
                      consentLetterBase64, // Pass the consent letter content to ConsentCard
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
        title: const Text('Upload Consent'),
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
                  detailsCards: approvedDetailsCard,
                  searchPhone: searchPhone,
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
        future: getData(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return const Center(child: Text('Error loading data'));
            } else {
              if (approvedDetailsCard.isEmpty) {
                return const Center(child: Text('No matching data found'));
              } else {
                return ListView.builder(
                  itemCount: approvedDetailsCard.length,
                  itemBuilder: (context, index) {
                    if (index < approvedDetailsCard.length) {
                      return approvedDetailsCard[index];
                    } else {
                      return const SizedBox();
                    }
                  },
                  padding: const EdgeInsets.all(10),
                );
              }
            }
          } else {
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
}

class CustomSearchDelegate extends SearchDelegate {
  final Function(String) onSearch;
  final List<String> searchItems;
  final List<Widget> detailsCards;
  final String searchPhone;

  CustomSearchDelegate({
    required this.onSearch,
    required this.searchItems,
    required this.detailsCards,
    required this.searchPhone,
  });

  @override
  void close(BuildContext context, [result]) {
    super.close(context, result);
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
    final filteredCards = detailsCards
        .where((card) =>
            card is ConsentCard &&
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
            query = filteredSuggestions[index];
            onSearch(filteredSuggestions[index]);
            close(context, query);
          },
        );
      },
    );
  }

  @override
  void showResults(BuildContext context) {
    if (query.isNotEmpty) {
      onSearch(query);
    }
  }
}
