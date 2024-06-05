import 'package:flutter/material.dart';
import 'package:lifeshareapplication/admin%20panel/admin_login.dart';
import 'package:lifeshareapplication/donor_list.dart';
import 'package:lifeshareapplication/myprofile.dart';
import 'package:lifeshareapplication/recipient_list.dart';

TextStyle textDesign = const TextStyle(
    color: Color.fromARGB(255, 1, 46, 69),
    fontSize: 20,
    fontWeight: FontWeight.w700);
Color darkPrimaryColor = const Color.fromARGB(255, 1, 46, 69);

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.7,
      backgroundColor: const Color.fromARGB(255, 189, 244, 255),
      // ignore: prefer_const_literals_to_create_immutables
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(5, 60, 5, 20),
            child: Container(
              height: 160.0, // Adjust the height as needed
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 2, 105, 112),
                image: DecorationImage(
                    image: AssetImage(
                        'assets/mainpage.jpeg')), // Customize the image space color
                borderRadius: BorderRadius.only(
                  bottomLeft:
                      Radius.circular(50.0), // Adjust the radius as needed
                  bottomRight: Radius.circular(50.0),
                ),
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ListTile(
                title: Text(
                  'Search for Donor',
                  style: textDesign,
                ),
                leading: Icon(Icons.health_and_safety,
                    size: 40, color: darkPrimaryColor),
                splashColor: const Color.fromARGB(255, 189, 244, 255),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const DonorList()));
                },
              ),
              const SizedBox(
                height: 10,
              ),
              ListTile(
                title: Text(
                  'Search for Recipient',
                  style: textDesign,
                ),
                leading: Icon(Icons.healing_outlined,
                    size: 40, color: darkPrimaryColor),
                splashColor: const Color.fromARGB(255, 189, 244, 255),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const RecipientList()));
                },
              ),
              const SizedBox(
                height: 10,
              ),
              ListTile(
                title: Text(
                  'My Profile',
                  style: textDesign,
                ),
                leading:
                    Icon(Icons.person_2, size: 40, color: darkPrimaryColor),
                splashColor: const Color.fromARGB(255, 189, 244, 255),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const MyProfile()));
                },
              ),
              const SizedBox(
                height: 10,
              ),
              ListTile(
                title: Text(
                  'Admin Panel',
                  style: textDesign,
                ),
                leading: Icon(Icons.admin_panel_settings,
                    size: 40, color: darkPrimaryColor),
                splashColor: const Color.fromARGB(255, 189, 244, 255),
                onTap: () {
                  // Handle navigation to admin panel page
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) =>
                          const AdminLoginScreen())); // Close the drawer
                  // Implement navigation logic to admin panel page
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
