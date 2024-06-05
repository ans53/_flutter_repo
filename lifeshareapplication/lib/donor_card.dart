import 'package:flutter/material.dart';

TextStyle textDesign = const TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.w700,
    fontSize: 15,
    letterSpacing: 2);

class DonorCard extends StatelessWidget {
  final Map<String, dynamic> donorDetails;

  const DonorCard({required this.donorDetails, super.key});

  @override
  Widget build(BuildContext context) {
    TextStyle textDesign = const TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.w700,
      fontSize: 13,
      letterSpacing: 2,
    );

    return SizedBox(
      height: 250,
      width: 400,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Donor Name", style: textDesign),
                  Text(donorDetails['Name'] ?? 'N/A', style: textDesign),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Mobile Number", style: textDesign),
                  Text(donorDetails['Phone'].toString(), style: textDesign),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Blood Group", style: textDesign),
                  Text(donorDetails['Blood Group'] ?? 'N/A', style: textDesign),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Country", style: textDesign),
                  Text(donorDetails['Country'] ?? 'N/A', style: textDesign),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("State", style: textDesign),
                  Text(donorDetails['State'] ?? 'N/A', style: textDesign),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("City", style: textDesign),
                  Text(donorDetails['City'] ?? 'N/A', style: textDesign),
                ],
              ),
              if (donorDetails['hasDonatedBefore'])
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Date of Last Donation", style: textDesign),
                    Text(
                      donorDetails['Date of Last Donation'].split(' ')[0] ??
                          'N/A',
                      style: textDesign,
                    ),
                  ],
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Last Date of Donation", style: textDesign),
                  Text(
                    'First Timer',
                    style: textDesign,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
