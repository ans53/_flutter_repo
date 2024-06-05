// ignore_for_file: avoid_print

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lifeshareapplication/login_page.dart';
import 'package:lifeshareapplication/model/data_flow.dart';
import 'package:lifeshareapplication/model/pref.dart';
import 'package:lifeshareapplication/tabbar.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Future<void> checkAlreadyLoggedIn() async {
    bool alreadyLoggedIn = await PreferencesHelper.isLoggedIn();
    if (alreadyLoggedIn) {
      String? name = await UserDetailSharedPreferences.getName();
      String? phone = await UserDetailSharedPreferences.getPhone();
      String? city = await UserDetailSharedPreferences.getCity();
      String? state = await UserDetailSharedPreferences.getState();
      String? country = await UserDetailSharedPreferences.getCountry();
      String? id = await UserDetailSharedPreferences.getId();
      if (name != null &&
          phone != null &&
          city != null &&
          state != null &&
          country != null &&
          id != null) {
        // All necessary user details are available, so navigate to the tab bar screen
    
          Provider.of<UserProvider>(context, listen: false)
              .setUserDetails(name, phone);
          Provider.of<LocationProvider>(context, listen: false)
              .setUserLocation(city, state, country);
          Provider.of<UuidProvider>(context, listen: false).setUserId(id);
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const MyTabbar()));
        
      } else {
        // Some user details are missing, navigate to the login screen
        if (context.mounted) {
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const LoginScreen()));
        }
      }
    } else {
      // User is not logged in, navigate to the login screen
      if (context.mounted) {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginScreen()));
      }
    }
  }

  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 8), () => checkAlreadyLoggedIn());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0xffFDD7CD),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Image.asset(
                  "assets/mainmain.gif",
                  height: 500.0,
                  width: 400.0,
                ),
                const Text(
                  "LifeShare",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 40.0,
                  ),
                ),
                const SizedBox(
                  height: 25,
                ),
                const Text(
                  "Your phone, their Lifeline",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 25.0,
                  ),
                ),
              ],
            ),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          ],
        ),
      ),
    );
  }
}
