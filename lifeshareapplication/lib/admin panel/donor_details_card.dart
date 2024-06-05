// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:lifeshareapplication/http_client.dart';
import 'package:lifeshareapplication/model/detail.dart';

class DonorDetailsCard extends StatefulWidget {
  final String name;
  final String phone;
  final String gender;
  final String bloodtype;
  final String age;
  final String lastdayofdonation;
  final String weight;
  final String city;
  final String state;
  final String country;
  final String organType;
  final bool isDonatingOrgan;
  final String id;
  final List<String> medicalReportImages;
  final bool hasDonatedBefore;
  final Function(String, BuildContext, {bool approved}) onDelete;

  const DonorDetailsCard({
    super.key,
    required this.name,
    required this.phone,
    required this.id,
    required this.gender,
    required this.bloodtype,
    required this.weight,
    required this.age,
    required this.lastdayofdonation,
    required this.city,
    required this.state,
    required this.country,
    required this.organType,
    required this.isDonatingOrgan,
    required this.hasDonatedBefore,
    required this.onDelete,
    required this.medicalReportImages,
  });

  @override
  State<DonorDetailsCard> createState() => _DetailsCardState();
}

class _DetailsCardState extends State<DonorDetailsCard> {
  bool isVisible = true;

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
                  padding: const EdgeInsets.only(bottom: 1.0),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: MediaQuery.of(context).size.height * 0.4,
                    child: _buildMedicalReportImage(context, base64String),
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

  Widget _buildMedicalReportImage(BuildContext context, String base64String) {
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
                    _saveImage(bytes);
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

  Future<void> _saveImage(Uint8List bytes) async {
    final result = await ImageGallerySaver.saveImage(bytes);
    if (result != null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image saved to gallery')),
        );
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save image to gallery')),
        );
      }
    }
  }

  Widget organEntry() {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Organ for donation", style: txt),
          Text(widget.organType, style: txt)
        ],
      ),
    );
  }

  TextStyle txt = const TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.w700,
      fontSize: 12,
      letterSpacing: 2);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      height: isVisible ? 410.0 : 0.0,
      child: Card(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        shadowColor: const Color.fromARGB(255, 9, 100, 148),
        elevation: 20,
        color: const Color.fromARGB(255, 1, 46, 69),
        child: Padding(
          padding: const EdgeInsets.all(9),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Donor Name", style: txt),
                    Text(widget.name, style: txt)
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Mobile Number", style: txt),
                    Text(widget.phone, style: txt)
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Age", style: txt),
                    Text(widget.age, style: txt)
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Weight", style: txt),
                    Text(widget.weight, style: txt)
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Gender", style: txt),
                    Text(widget.gender, style: txt)
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Blood Group", style: txt),
                    Text(widget.bloodtype, style: txt)
                  ],
                ),
              ),
              if (widget.isDonatingOrgan) organEntry(),
              if (widget.hasDonatedBefore)
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Date of Last Donation", style: txt),
                      Text(widget.lastdayofdonation.split(' ')[0], style: txt)
                    ],
                  ),
                ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Date of Last Donation", style: txt),
                    Text('First Timer', style: txt)
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Location", style: txt),
                    Text(
                      '${widget.country} ${widget.state} \n ${widget.city} ',
                      style: txt,
                      textAlign: TextAlign.right,
                    )
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Remove User: ${widget.id}", style: txt),
                    Visibility(
                      visible: isVisible,
                      child: IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.amber,
                          size: 25,
                        ),
                        onPressed: () {
                          _showConfirmationDialog('Delete');
                          setState(() {
                            isVisible = !isVisible;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Expanded(
                child: ElevatedButton(
                  style:
                      ElevatedButton.styleFrom(fixedSize: const Size(160, 100)),
                  onPressed: () {
                    _showConfirmationDialog('Approve');
                  },
                  child: const Text('Approve Donor',
                      style: TextStyle(fontSize: 14)),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          fixedSize: const Size(200, 100)),
                      onPressed: () {
                        _showMedicalReportDialog(widget.medicalReportImages);
                      },
                      child: const Text('View Medical Report',
                          style: TextStyle(fontSize: 14)),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showConfirmationDialog(String action) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Are you sure?'),
          content: Text('Do you want to $action this donor?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (action == 'Approve') {
                  addDonors();
                } else if (action == 'Delete') {
                  widget.onDelete(widget.id, context);
                }
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  void addDonors() async {
    final List<Map<String, dynamic>> encodedMedicalReportImages =
        widget.medicalReportImages.map((base64Image) {
      return {
        'imageData': base64Image,
      };
    }).toList();
    DonorData donorData = DonorData(
      uuid: widget.id,
      name: widget.name,
      age: int.tryParse(widget.age) ?? 0,
      phoneNumber: BigInt.tryParse(widget.phone) ?? BigInt.zero,
      selectedGender: widget.gender,
      weight: int.tryParse(widget.weight) ?? 0,
      dateOfLastDonation:
          DateTime.tryParse(widget.lastdayofdonation) ?? DateTime.now(),
      isDonatingOrgans: widget.isDonatingOrgan,
      selectedBloodGroup: widget.bloodtype,
      selectedOrganType: widget.organType,
      hasDonatedBefore: widget.hasDonatedBefore,
    );

    try {
      final url = Uri.https(
        'lifeshare-873ea-default-rtdb.firebaseio.com',
        'approvedDonorDetails.json',
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
          'City': widget.city,
          'State': widget.state,
          'Country': widget.country,
          'Medical Report': encodedMedicalReportImages,
          'ConsentUploaded': donorData.hasConsent,
          'hasDonatedBefore': donorData.hasDonatedBefore
        }),
      );

      if (response.statusCode == 200) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Data Has been Approved')),
          );
        }
        if (context.mounted) {
          widget.onDelete(widget.id, context, approved: true);
        }
        setState(() {
          isVisible = false;
        });
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
        const SnackBar(content: Text('An error occurred while saving data')),
      );
    }
  }
}
