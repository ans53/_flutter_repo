import 'package:flutter/material.dart';
import 'package:lifeshareapplication/donor_registration.dart';
import 'package:lifeshareapplication/drawer.dart';
import 'package:lifeshareapplication/model/data_flow.dart';
import 'package:lifeshareapplication/recipient_registration.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: Colors.teal,
      ),
      drawer: const MyDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(17.0),
        child: Consumer<UuidProvider>(
          builder: (context, id, _) {
            String userId = id.uid?.toString() ?? '';
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: 200.0,
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 2, 105, 112),
                    image: DecorationImage(
                      image: AssetImage('assets/mainpage.jpeg'),
                      alignment: Alignment.topRight,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(50.0),
                      bottomRight: Radius.circular(50.0),
                    ),
                  ),
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.all(10),
                  child: ListTile(
                    title: const Text(
                      'Id',
                      style: TextStyle(
                        color: Color.fromARGB(255, 1, 46, 69),
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    subtitle: Text(
                      userId,
                      style: const TextStyle(
                        color: Color.fromARGB(255, 1, 46, 69),
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30.0),

                // Options for Donating or Requesting Donation
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 10,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.all(20),
                      ),
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) =>
                                const DonorRegistration()));
                      },
                      child: const Column(
                        children: [
                          Icon(
                            Icons.handshake,
                            size: 40,
                          ),
                          Text(
                            'Donate',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                 
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 10,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.all(20),
                      ),
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) =>
                                const RecipientRegistration()));
                      },
                      child: const Column(
                        children: [
                          Icon(
                            Icons.bloodtype,
                            size: 40,
                          ),
                          Text(
                            'Request Donation',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}




