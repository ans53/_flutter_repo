import 'package:flutter/material.dart';

class RecipientCard extends StatelessWidget {
  final Map<String, dynamic> recipientDetails;
  final TextStyle text = const TextStyle(
    color: Color.fromRGBO(255, 255, 255, 1),
    fontWeight: FontWeight.w700,
    fontSize: 13,
    letterSpacing: 2,
  );
  const RecipientCard({super.key, required this.recipientDetails});

  @override
  Widget build(BuildContext context) {
    Widget makeOrgantype() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Organ Type", style: text),
          Text(recipientDetails['Organ Type'] ?? 'N/A', style: text),
        ],
      );
    }

    Widget makeBloodType() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Blood Type", style: text),
          Text(recipientDetails['Blood Type'] ?? 'N/A', style: text),
        ],
      );
    }

    Widget makeBloodQuantity() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Blood Quantity", style: text),
          Text(recipientDetails['Blood Quantity'].toString(), style: text),
        ],
      );
    }

    return SizedBox(
      height: 330,
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
                  Text("Recipient Name", style: text),
                  Text(recipientDetails['Name'] ?? 'N/A', style: text),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Mobile Number", style: text),
                  Text(recipientDetails['Phone'].toString(), style: text),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Blood Group", style: text),
                  Text(recipientDetails['Blood group'] ?? 'N/A', style: text),
                ],
              ),
              if (recipientDetails['isOrganRequired'])
                makeOrgantype()
              else
                makeBloodType(),
              if (!recipientDetails['isOrganRequired']) makeBloodQuantity(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Required By Date", style: text),
                  Text(
                      recipientDetails['Required by Date'].split(' ')[0] ??
                          'N/A',
                      style: text),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Country", style: text),
                  Text(recipientDetails['Country'] ?? 'N/A', style: text),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("State", style: text),
                  Text(recipientDetails['State'] ?? 'N/A', style: text),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("City", style: text),
                  Text(recipientDetails['City'] ?? 'N/A', style: text),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Critical Request", style: text),
                  Switch(
                    activeColor: Colors.tealAccent,
                    value: recipientDetails['Critical Request'] ?? false,
                    onChanged: (value) {},
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
