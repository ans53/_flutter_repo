import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  String? userName;
  String? userPhone;

  void setUserDetails(String name, String phone) {
    userName = name;
    userPhone = phone;
    notifyListeners();
  }
}

class UuidProvider with ChangeNotifier {
  String? uid;

  void setUserId(String id) {
    uid = id;
    notifyListeners();
  }
}

class LocationProvider with ChangeNotifier {
  String? city;
  String? state;
  String? country;

  void setUserLocation(String mycity, String mystate, String mycountry) {
    city = mycity;
    state = mystate;
    country = mycountry;
    notifyListeners();
  }
}

class MedicalRequirement with ChangeNotifier {
  String? blood;
  String? organ;

  void setMedicalRequirement(String myblood, String myorgan) {
    blood = myblood;
    organ = myorgan;
    notifyListeners();
  }
}
