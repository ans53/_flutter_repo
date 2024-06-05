import 'package:flutter/material.dart';

class RequestCard extends StatelessWidget {
  final String name;
  final String phone;
  final bool isOrganRequired;
  final String bloodGroup;
  final String bloodType;
  final String quantity;
  final String organType;
  final String requiredByDate;
  final String id;
  final String city;
  final String state;
  final String country;
  final Function(String) onDelete;

  const RequestCard({
    super.key,
    required this.name,
    required this.phone,
    required this.bloodGroup,
    required this.bloodType,
    required this.isOrganRequired,
    required this.requiredByDate,
    required this.quantity,
    required this.organType,
    required this.id,
    required this.city,
    required this.state,
    required this.country,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
   
    TextStyle txt = const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13, letterSpacing: 2);
    return SizedBox(
      height: 400,
      width: 480,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        shadowColor: const Color.fromARGB(255, 9, 100, 148),
        elevation: 20,
        color: const Color.fromARGB(255, 1, 46, 69),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Recipient Name", style: txt),
                  Text(name, style: txt), // Use the provided name
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Mobile Number", style: txt),
                  Text(phone, style: txt), // Use the provided phone number
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Blood Group", style: txt),
                  Text(bloodGroup, style: txt), // Use the provided blood group
                ],
              ),
               if(!isOrganRequired)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Blood Type", style: txt),
                  Text(bloodType, style: txt), // Use the provided blood group
                ],
              ),
               if(!isOrganRequired)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Blood Quantity", style: txt),
                  Text(quantity, style: txt), // Use the provided blood group
                ],
              ),
              if(isOrganRequired)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Organ Type", style: txt),
                  Text(organType, style: txt), // Use the provided blood group
                ],
              ),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Location", style: txt),
                    Text('$country $state \n $city ',
                        style: txt, textAlign: TextAlign.right,)
                  ],
                ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [Text("Required by Date",style: txt,),Text(requiredByDate.split(' ')[0],style:txt),],
              ),
              ElevatedButton(
                onPressed: () => onDelete(id), // Pass the id to onDelete function
                child: const Text('Delete'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
